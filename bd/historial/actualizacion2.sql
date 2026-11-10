-- =====================================================================
-- ATHLETIX · Actualización 2: transacciones, concurrencia y avisos al administrador
-- Ejecutar en Supabase > SQL Editor DESPUÉS de actualizacion.sql
--
-- Qué garantiza:
--  1. Atomicidad: un pedido se crea completo (stock, pedido y detalle) o no se crea nada.
--  2. Concurrencia: si dos clientes compran la última unidad al mismo tiempo, solo uno la obtiene;
--     el stock nunca queda negativo (bloqueo por fila + condición stock >= cantidad).
--  3. Sin bloqueos mutuos (deadlocks): las filas de stock se bloquean siempre en el mismo orden.
--  4. Idempotencia: si el navegador reintenta el pago (doble clic, recarga, mala conexión),
--     se devuelve el mismo pedido y no se cobra dos veces.
--  5. Estados válidos: un pedido solo avanza en orden y, si se cancela, el stock se devuelve.
-- =====================================================================

-- Clave única que el navegador genera para cada intento de pago
alter table pedidos add column if not exists clave uuid unique;

-- Se reemplaza la función anterior (cambia su lista de parámetros)
drop function if exists crear_pedido(smallint, int, jsonb);

create or replace function crear_pedido(p_tienda smallint, p_metodo_pago int, p_items jsonb, p_clave uuid default null)
returns table (pedido_id int, numero varchar, total numeric)
language plpgsql security definer set search_path = public as $$
declare
  v_cliente  uuid := auth.uid();
  v_pedido   int;
  v_numero   varchar;
  v_subtotal numeric(10,2) := 0;
  v_iva      numeric(10,2);
  r          record;
begin
  if v_cliente is null then raise exception 'Debes iniciar sesión para comprar'; end if;

  -- Idempotencia: el mismo intento de pago devuelve el mismo pedido
  if p_clave is not null then
    return query select p.id, p.numero, p.total from pedidos p where p.clave = p_clave and p.cliente_id = v_cliente;
    if found then return; end if;
  end if;

  if not exists (select 1 from clientes where id = v_cliente) then raise exception 'Completa tu perfil antes de comprar'; end if;
  if not exists (select 1 from metodos_pago where id = p_metodo_pago and cliente_id = v_cliente) then raise exception 'El método de pago no es válido'; end if;
  if not exists (select 1 from tiendas where id = p_tienda) then raise exception 'La tienda de retiro no es válida'; end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then raise exception 'El carrito está vacío'; end if;
  if jsonb_array_length(p_items) > 30 then raise exception 'Demasiados productos en un solo pedido'; end if;
  -- Freno contra abuso: máximo 5 pedidos por minuto por cliente
  if (select count(*) from pedidos where cliente_id = v_cliente and creado_en > now() - interval '1 minute') >= 5 then
    raise exception 'Hiciste demasiados pedidos seguidos. Espera un minuto.';
  end if;

  begin
    -- Se agrupan las líneas repetidas y se recorren SIEMPRE en el mismo orden (evita deadlocks)
    for r in
      select p.id, p.nombre, p.precio, p.usa_talla, p.activo,
             nullif(x->>'talla', '') as talla,
             sum((x->>'cantidad')::int) as cantidad
        from jsonb_array_elements(p_items) x
        left join productos p on p.id = (x->>'producto_id')::int
       group by p.id, p.nombre, p.precio, p.usa_talla, p.activo, nullif(x->>'talla', '')
       order by p.id, nullif(x->>'talla', '')
    loop
      if r.id is null or not r.activo then raise exception 'Un producto del carrito ya no está disponible'; end if;
      if r.cantidad is null or r.cantidad < 1 or r.cantidad > 10 then
        raise exception 'La cantidad de "%" debe estar entre 1 y 10', r.nombre; end if;
      if r.usa_talla and r.talla is null then raise exception 'Elige una talla para "%"', r.nombre; end if;

      -- Bloquea la fila del stock y descuenta solo si alcanza (operación atómica)
      update producto_tallas set stock = stock - r.cantidad
       where producto_id = r.id and talla = coalesce(r.talla, 'U') and stock >= r.cantidad;
      if not found then
        raise exception 'No hay stock suficiente de "%"%', r.nombre, coalesce(' talla ' || r.talla, '');
      end if;
      v_subtotal := v_subtotal + r.precio * r.cantidad;
    end loop;

    v_iva := round(v_subtotal * 0.15, 2);
    v_numero := 'AX-' || to_char(now(), 'YYYY') || '-' || lpad(nextval('seq_numero_pedido')::text, 5, '0');

    insert into pedidos (numero, cliente_id, tienda_id, metodo_pago_id, subtotal, iva, total, clave)
    values (v_numero, v_cliente, p_tienda, p_metodo_pago, v_subtotal, v_iva, v_subtotal + v_iva, p_clave)
    returning id into v_pedido;

    insert into detalle_pedido (pedido_id, producto_id, talla, cantidad, precio_unitario)
    select v_pedido, p.id, nullif(x->>'talla', ''), sum((x->>'cantidad')::int), p.precio
      from jsonb_array_elements(p_items) x join productos p on p.id = (x->>'producto_id')::int
     group by p.id, nullif(x->>'talla', ''), p.precio;
  exception when unique_violation then
    -- Dos reintentos simultáneos con la misma clave: se deshace este y se devuelve el que ganó
    if p_clave is not null then
      return query select p.id, p.numero, p.total from pedidos p where p.clave = p_clave and p.cliente_id = v_cliente;
      if found then return; end if;
    end if;
    raise;
  end;

  return query select v_pedido, v_numero, v_subtotal + v_iva;
end $$;

revoke execute on function crear_pedido(smallint, int, jsonb, uuid) from public, anon;
grant  execute on function crear_pedido(smallint, int, jsonb, uuid) to authenticated;

-- ---------- Cambiar estado con reglas y devolución de stock ----------
create or replace function cambiar_estado_pedido(p_pedido int, p_estado varchar)
returns void language plpgsql security definer set search_path = public as $$
declare
  v_actual varchar;
  permitidos text[];
begin
  if not es_admin() then raise exception 'Solo un administrador puede cambiar el estado'; end if;
  -- Bloquea el pedido para que dos administradores no lo cambien a la vez
  select estado into v_actual from pedidos where id = p_pedido for update;
  if not found then raise exception 'El pedido no existe'; end if;

  permitidos := case v_actual
    when 'Recibido'   then array['Preparando', 'Listo', 'Cancelado']
    when 'Preparando' then array['Listo', 'Cancelado']
    when 'Listo'      then array['Retirado', 'Cancelado']
    else array[]::text[] end;
  if not (p_estado = any (permitidos)) then
    raise exception 'No se puede pasar un pedido de "%" a "%"', v_actual, p_estado;
  end if;

  -- Si se cancela, el stock vuelve a estar disponible
  if p_estado = 'Cancelado' then
    update producto_tallas t set stock = t.stock + d.cantidad
      from detalle_pedido d
     where d.pedido_id = p_pedido and t.producto_id = d.producto_id and t.talla = coalesce(d.talla, 'U');
  end if;

  update pedidos set estado = p_estado, actualizado_en = now() where id = p_pedido;
end $$;

-- ---------- Aviso de pedidos nuevos para el administrador ----------
create or replace function pedidos_nuevos() returns int
language plpgsql stable security definer set search_path = public as $$
begin
  if not es_admin() then return 0; end if;
  return (select count(*) from pedidos where estado = 'Recibido');
end $$;
revoke execute on function pedidos_nuevos() from public, anon;
grant  execute on function pedidos_nuevos() to authenticated;
