/*==============================================================*/
/* ATHLETIX - Solo retiro en tienda                              */
/* La tienda no hace envíos a domicilio: el cliente retira su    */
/* pedido en la tienda que elige (listo en 1 hora).              */
/* Se quitan las columnas de domicilio y el código vuelve a      */
/* llamarse ped_codigo_retiro. Todo o nada.                      */
/*==============================================================*/
begin;

drop function if exists crear_pedido(jsonb, uuid, text, int2, text, text, text, jsonb);
drop function if exists pedidos_admin();

alter table pedido drop constraint if exists ckc_ped_tipo_entrega;
alter table pedido drop constraint if exists ckc_ped_valores;
alter table pedido drop column if exists ped_tipo_entrega, drop column if exists ped_direccion,
  drop column if exists ped_ciudad, drop column if exists ped_referencia, drop column if exists ped_costo_envio;
alter table pedido rename column ped_codigo_entrega to ped_codigo_retiro;
alter table pedido add constraint ckc_ped_valores check (ped_subtotal >= 0 and ped_iva >= 0 and ped_total = ped_subtotal + ped_iva);

/*---------------- Crear pedido (una sola transacción) ----------------*/
create or replace function crear_pedido(p_items jsonb, p_clave uuid, p_tienda int2, p_pago jsonb)
returns table (ped_numero int4, ped_codigo text, ped_total numeric, ped_codigo_retiro char(6), ped_hora_estimada timestamptz)
language plpgsql security definer set search_path = public as $$
declare
  v_cedula   char(10) := mi_cedula();
  v_numero   int4;
  v_tienda   int2;
  v_subtotal numeric(12,2) := 0;
  v_iva      numeric(12,2);
  v_total    numeric(12,2);
  v_hora     timestamptz;
  v_metodo   text := p_pago->>'metodo';
  v_tar_cod  int4;
  v_tar_marca varchar(12);
  v_tar_ult4 char(4);
  r          record;
begin
  if auth.uid() is null then raise exception 'Debes iniciar sesión para comprar'; end if;
  if v_cedula is null then raise exception 'Completa tu perfil antes de comprar'; end if;

  -- Idempotencia: si el mismo intento de pago llega dos veces, se devuelve el pedido ya creado
  if p_clave is not null then
    return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_retiro, p.ped_hora_estimada
      from pedido p where p.ped_clave_pago = p_clave and p.cli_cedula = v_cedula;
    if found then return; end if;
  end if;

  -- Retiro en la tienda elegida: el pedido está listo en 1 hora
  select tie_codigo into v_tienda from tienda where tie_codigo = p_tienda;
  if v_tienda is null then raise exception 'Elige la tienda donde retirarás tu pedido'; end if;
  v_hora := now() + interval '1 hour';

  -- Pago simulado: tarjeta guardada del cliente o transferencia con banco y número de comprobante
  if v_metodo = 'Tarjeta' then
    select mtp_codigo, mtp_marca, mtp_ultimos4 into v_tar_cod, v_tar_marca, v_tar_ult4 from metodo_pago
     where mtp_codigo = nullif(p_pago->>'tarjeta', '')::int4 and cli_cedula = v_cedula;
    if v_tar_cod is null then raise exception 'El método de pago no es válido'; end if;
  elsif v_metodo = 'Transferencia' then
    if coalesce(p_pago->>'banco', '') not in ('Banco Pichincha', 'Banco Guayaquil', 'Produbanco', 'Banco del Pacífico', 'Banco Internacional') then
      raise exception 'Elige el banco desde el que transferiste';
    end if;
    if coalesce(p_pago->>'referencia', '') !~ '^[0-9]{6,12}$' then
      raise exception 'El número de comprobante debe tener de 6 a 12 números';
    end if;
  else
    raise exception 'Elige cómo pagar';
  end if;

  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then raise exception 'El carrito está vacío'; end if;
  if jsonb_array_length(p_items) > 60 then raise exception 'Demasiados productos en un solo pedido'; end if;
  if (select count(*) from pedido where cli_cedula = v_cedula and ped_fecha > now() - interval '1 minute') >= 5 then
    raise exception 'Hiciste demasiados pedidos seguidos. Espera un minuto.';
  end if;

  begin
    -- Bloqueo por fila en orden fijo: dos compras al mismo tiempo nunca venden más de lo que hay
    for r in
      select p.prd_codigo, p.prd_nombre, p.prd_precio, p.prd_tiene_talla, p.prd_visible,
             coalesce(nullif(x->>'talla', ''), 'U') as talla,
             sum((x->>'cantidad')::int) as cantidad
        from jsonb_array_elements(p_items) x
        left join producto p on p.prd_codigo = x->>'producto'
       group by p.prd_codigo, p.prd_nombre, p.prd_precio, p.prd_tiene_talla, p.prd_visible, coalesce(nullif(x->>'talla', ''), 'U')
       order by p.prd_codigo, 6
    loop
      if r.prd_codigo is null or not r.prd_visible then raise exception 'Un producto del carrito ya no está disponible'; end if;
      if r.cantidad is null or r.cantidad < 1 then raise exception 'La cantidad de "%" no es válida', r.prd_nombre; end if;
      if r.prd_tiene_talla and r.talla = 'U' then raise exception 'Elige una talla para "%"', r.prd_nombre; end if;

      update producto_talla set pta_cantidad = pta_cantidad - r.cantidad
       where prd_codigo = r.prd_codigo and pta_talla = r.talla and pta_cantidad >= r.cantidad;
      if not found then
        raise exception 'No hay stock suficiente de "%"%', r.prd_nombre, case when r.talla = 'U' then '' else ' talla ' || r.talla end;
      end if;
      v_subtotal := v_subtotal + r.prd_precio * r.cantidad;
    end loop;

    v_iva := round(v_subtotal * 0.15, 2);
    v_total := v_subtotal + v_iva;
    insert into pedido (cli_cedula, tie_codigo, ped_subtotal, ped_iva, ped_total, ped_clave_pago, ped_codigo_retiro, ped_hora_estimada)
    values (v_cedula, v_tienda, v_subtotal, v_iva, v_total, p_clave,
            upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6)), v_hora)
    returning pedido.ped_numero into v_numero;

    insert into detalle_pedido (ped_numero, prd_codigo, dpe_talla, dpe_cantidad, dpe_precio)
    select v_numero, p.prd_codigo, coalesce(nullif(x->>'talla', ''), 'U'), sum((x->>'cantidad')::int), p.prd_precio
      from jsonb_array_elements(p_items) x join producto p on p.prd_codigo = x->>'producto'
     group by p.prd_codigo, coalesce(nullif(x->>'talla', ''), 'U'), p.prd_precio;

    insert into pago (ped_numero, pag_metodo, mtp_codigo, pag_marca, pag_ultimos4, pag_banco, pag_comprobante, pag_monto)
    values (v_numero, v_metodo,
            v_tar_cod, v_tar_marca, v_tar_ult4,
            case when v_metodo = 'Transferencia' then p_pago->>'banco' end,
            case when v_metodo = 'Transferencia' then p_pago->>'referencia' end,
            v_total);
  exception when unique_violation then
    if p_clave is not null then
      return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_retiro, p.ped_hora_estimada
        from pedido p where p.ped_clave_pago = p_clave and p.cli_cedula = v_cedula;
      if found then return; end if;
    end if;
    raise;
  end;

  return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_retiro, p.ped_hora_estimada
    from pedido p where p.ped_numero = v_numero;
end $$;

/*---------------- Panel del administrador ----------------*/
drop function if exists pedidos_admin();
create or replace function pedidos_admin()
returns table (ped_numero int4, ped_codigo text, ped_estado varchar, ped_total numeric, ped_fecha timestamptz,
               cliente text, cli_correo varchar, cli_celular char(10), cli_cedula char(10),
               tie_nombre varchar, tie_horario varchar, productos text,
               ped_codigo_retiro char(6), ped_hora_estimada timestamptz, pago text)
language plpgsql stable security definer set search_path = public as $$
begin
  if not es_admin() then raise exception 'Solo un administrador puede ver todos los pedidos'; end if;
  return query
  select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'),
         p.ped_estado, p.ped_total, p.ped_fecha,
         c.cli_nombres || ' ' || c.cli_apellidos, c.cli_correo, c.cli_celular, c.cli_cedula,
         t.tie_nombre, t.tie_horario,
         (select string_agg(d.dpe_cantidad || ' × ' || pr.prd_nombre || case when d.dpe_talla = 'U' then '' else ' (talla ' || d.dpe_talla || ')' end, ', ')
            from detalle_pedido d join producto pr on pr.prd_codigo = d.prd_codigo where d.ped_numero = p.ped_numero),
         p.ped_codigo_retiro, p.ped_hora_estimada,
         (select case when g.pag_metodo = 'Tarjeta' then g.pag_marca || ' •••• ' || g.pag_ultimos4
                      else 'Transferencia ' || g.pag_banco || ' · comprobante ' || g.pag_comprobante end
                 || case when g.pag_estado = 'Anulado' then ' (anulado)' else '' end
            from pago g where g.ped_numero = p.ped_numero)
    from pedido p join cliente c on c.cli_cedula = p.cli_cedula join tienda t on t.tie_codigo = p.tie_codigo
   order by p.ped_fecha desc;
end $$;

revoke execute on function crear_pedido(jsonb, uuid, int2, jsonb) from public, anon;
grant  execute on function crear_pedido(jsonb, uuid, int2, jsonb) to authenticated;
revoke execute on function pedidos_admin() from public, anon;
grant  execute on function pedidos_admin() to authenticated;

commit;
