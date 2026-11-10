/*==============================================================*/
/* ATHLETIX - Solo pago con tarjeta                              */
/* La tienda acepta solo tarjetas (de prueba, pago simulado).    */
/* PAGO guarda la tarjeta usada, su marca y últimos 4 dígitos.   */
/* Se quitan las columnas de transferencia. Todo o nada.         */
/*==============================================================*/
begin;

drop function if exists crear_pedido(jsonb, uuid, int2, jsonb);
drop function if exists pedidos_admin();

alter table pago drop constraint if exists ckc_pag_metodo;
alter table pago drop constraint if exists ckc_pag_datos;
alter table pago drop column if exists pag_metodo, drop column if exists pag_banco, drop column if exists pag_comprobante;
alter table pago alter column pag_marca set not null, alter column pag_ultimos4 set not null;
alter table pago drop constraint if exists ckc_pag_ultimos4;
alter table pago add constraint ckc_pag_ultimos4 check (pag_ultimos4 ~ '^[0-9]{4}$');

/*---------------- Crear pedido (una sola transacción) ----------------*/
create or replace function crear_pedido(p_items jsonb, p_clave uuid, p_tienda int2, p_tarjeta int4)
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

  -- Pago simulado con una tarjeta guardada del cliente
  select mtp_codigo, mtp_marca, mtp_ultimos4 into v_tar_cod, v_tar_marca, v_tar_ult4 from metodo_pago
   where mtp_codigo = p_tarjeta and cli_cedula = v_cedula;
  if v_tar_cod is null then raise exception 'Elige una tarjeta válida para pagar'; end if;

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

    insert into pago (ped_numero, mtp_codigo, pag_marca, pag_ultimos4, pag_monto)
    values (v_numero, v_tar_cod, v_tar_marca, v_tar_ult4, v_total);
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
         (select g.pag_marca || ' •••• ' || g.pag_ultimos4 || case when g.pag_estado = 'Anulado' then ' (anulado)' else '' end
            from pago g where g.ped_numero = p.ped_numero)
    from pedido p join cliente c on c.cli_cedula = p.cli_cedula join tienda t on t.tie_codigo = p.tie_codigo
   order by p.ped_fecha desc;
end $$;

revoke execute on function crear_pedido(jsonb, uuid, int2, int4) from public, anon;
grant  execute on function crear_pedido(jsonb, uuid, int2, int4) to authenticated;
revoke execute on function pedidos_admin() from public, anon;
grant  execute on function pedidos_admin() to authenticated;

commit;
