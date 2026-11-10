/*==============================================================*/
/* ATHLETIX - Nombres de atributos más claros                    */
/* Se renombran columnas (los datos se conservan) y se vuelven   */
/* a crear las funciones que las usan. Todo o nada.              */
/*  prd_publico -> prd_genero      prd_usa_talla -> prd_tiene_talla */
/*  prd_activo -> prd_visible      pta_stock -> pta_cantidad        */
/*  ped_entrega -> ped_tipo_entrega                                 */
/*  ped_codigo_retiro -> ped_codigo_entrega                         */
/*  ped_clave -> ped_clave_pago    dpe_precio_unitario -> dpe_precio */
/*  cli_telefono -> cli_celular    pag_referencia -> pag_comprobante */
/*  METODO_PAGO: prefijo mpa_ -> mtp_                               */
/*==============================================================*/
begin;

alter table producto rename column prd_publico to prd_genero;
alter table producto rename column prd_usa_talla to prd_tiene_talla;
alter table producto rename column prd_activo to prd_visible;
alter table producto_talla rename column pta_stock to pta_cantidad;
alter table pedido rename column ped_entrega to ped_tipo_entrega;
alter table pedido rename column ped_codigo_retiro to ped_codigo_entrega;
alter table pedido rename column ped_clave to ped_clave_pago;
alter table detalle_pedido rename column dpe_precio_unitario to dpe_precio;
alter table cliente rename column cli_telefono to cli_celular;
alter table pago rename column pag_referencia to pag_comprobante;
alter table pago rename column mpa_codigo to mtp_codigo;
alter table metodo_pago rename column mpa_codigo to mtp_codigo;
alter table metodo_pago rename column mpa_marca to mtp_marca;
alter table metodo_pago rename column mpa_ultimos4 to mtp_ultimos4;
alter table metodo_pago rename column mpa_titular to mtp_titular;
alter table metodo_pago rename column mpa_mes_vence to mtp_mes_vence;
alter table metodo_pago rename column mpa_anio_vence to mtp_anio_vence;
alter sequence metodo_pago_mpa_codigo_seq rename to metodo_pago_mtp_codigo_seq;

alter table producto rename constraint ckc_prd_publico to ckc_prd_genero;
alter table producto_talla rename constraint ckc_pta_stock to ckc_pta_cantidad;
alter table pedido rename constraint ckc_ped_entrega to ckc_ped_tipo_entrega;
alter table cliente rename constraint ckc_cli_telefono to ckc_cli_celular;
alter table metodo_pago rename constraint ckc_mpa_marca to ckc_mtp_marca;
alter table metodo_pago rename constraint ckc_mpa_ultimos4 to ckc_mtp_ultimos4;
alter table metodo_pago rename constraint ckc_mpa_mes to ckc_mtp_mes;
alter table metodo_pago rename constraint ckc_mpa_anio to ckc_mtp_anio;

/*---------------- Crear pedido (una sola transacción) ----------------*/
drop function if exists crear_pedido(jsonb, uuid, text, int2, text, text, text, jsonb);
create or replace function crear_pedido(
  p_items jsonb, p_clave uuid, p_entrega text, p_tienda int2, p_ciudad text, p_direccion text, p_referencia text, p_pago jsonb)
returns table (ped_numero int4, ped_codigo text, ped_total numeric, ped_codigo_entrega char(6), ped_hora_estimada timestamptz)
language plpgsql security definer set search_path = public as $$
declare
  v_cedula   char(10) := mi_cedula();
  v_numero   int4;
  v_tienda   int2;
  v_subtotal numeric(12,2) := 0;
  v_iva      numeric(12,2);
  v_envio    numeric(10,2) := 0;
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
    return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_entrega, p.ped_hora_estimada
      from pedido p where p.ped_clave_pago = p_clave and p.cli_cedula = v_cedula;
    if found then return; end if;
  end if;

  -- Entrega: retiro en tienda (listo en 1 hora) o envío a domicilio express (2 a 3 horas)
  if p_entrega = 'Retiro' then
    select tie_codigo into v_tienda from tienda where tie_codigo = p_tienda;
    if v_tienda is null then raise exception 'La tienda de retiro no es válida'; end if;
    v_hora := now() + interval '1 hour';
  elsif p_entrega = 'Domicilio' then
    select tie_codigo into v_tienda from tienda where tie_ciudad = p_ciudad order by tie_codigo limit 1;
    if v_tienda is null then raise exception 'Por ahora solo enviamos a Quito y Guayaquil'; end if;
    if p_direccion is null or length(trim(p_direccion)) < 8 then raise exception 'Escribe la dirección completa de entrega'; end if;
    v_envio := 3.50;
    v_hora := now() + interval '3 hours';
  else
    raise exception 'Elige cómo recibir tu pedido';
  end if;

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
    v_total := v_subtotal + v_iva + v_envio;
    insert into pedido (cli_cedula, tie_codigo, ped_subtotal, ped_iva, ped_costo_envio, ped_total, ped_clave_pago,
                        ped_tipo_entrega, ped_ciudad, ped_direccion, ped_referencia, ped_codigo_entrega, ped_hora_estimada)
    values (v_cedula, v_tienda, v_subtotal, v_iva, v_envio, v_total, p_clave,
            p_entrega, case when p_entrega = 'Domicilio' then p_ciudad end,
            case when p_entrega = 'Domicilio' then trim(p_direccion) end,
            case when p_entrega = 'Domicilio' then nullif(trim(coalesce(p_referencia, '')), '') end,
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
      return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_entrega, p.ped_hora_estimada
        from pedido p where p.ped_clave_pago = p_clave and p.cli_cedula = v_cedula;
      if found then return; end if;
    end if;
    raise;
  end;

  return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_entrega, p.ped_hora_estimada
    from pedido p where p.ped_numero = v_numero;
end $$;

/*---------------- Cambiar estado: al cancelar se devuelve el stock y se anula el pago ----------------*/
create or replace function cambiar_estado_pedido(p_numero int4, p_estado varchar)
returns void language plpgsql security definer set search_path = public as $$
declare
  v_actual varchar;
  permitidos text[];
begin
  if not es_admin() then raise exception 'Solo un administrador puede cambiar el estado'; end if;
  select ped_estado into v_actual from pedido where ped_numero = p_numero for update;
  if not found then raise exception 'El pedido no existe'; end if;
  permitidos := case v_actual
    when 'Recibido'   then array['Preparando', 'Listo', 'Cancelado']
    when 'Preparando' then array['Listo', 'Cancelado']
    when 'Listo'      then array['Retirado', 'Cancelado']
    else array[]::text[] end;
  if not (p_estado = any (permitidos)) then raise exception 'No se puede pasar un pedido de "%" a "%"', v_actual, p_estado; end if;
  if p_estado = 'Cancelado' then
    update producto_talla t set pta_cantidad = t.pta_cantidad + d.dpe_cantidad
      from detalle_pedido d
     where d.ped_numero = p_numero and t.prd_codigo = d.prd_codigo and t.pta_talla = d.dpe_talla;
    update pago set pag_estado = 'Anulado' where ped_numero = p_numero;
  end if;
  update pedido set ped_estado = p_estado where ped_numero = p_numero;
end $$;

/*---------------- Panel del administrador ----------------*/
drop function if exists pedidos_admin();
create or replace function pedidos_admin()
returns table (ped_numero int4, ped_codigo text, ped_estado varchar, ped_total numeric, ped_fecha timestamptz,
               cliente text, cli_correo varchar, cli_celular char(10), cli_cedula char(10),
               tie_nombre varchar, tie_horario varchar, productos text,
               ped_tipo_entrega varchar, ped_ciudad varchar, ped_direccion varchar, ped_referencia varchar,
               ped_codigo_entrega char(6), ped_hora_estimada timestamptz, pago text)
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
         p.ped_tipo_entrega, p.ped_ciudad, p.ped_direccion, p.ped_referencia, p.ped_codigo_entrega, p.ped_hora_estimada,
         (select case when g.pag_metodo = 'Tarjeta' then g.pag_marca || ' •••• ' || g.pag_ultimos4
                      else 'Transferencia ' || g.pag_banco || ' · comprobante ' || g.pag_comprobante end
                 || case when g.pag_estado = 'Anulado' then ' (anulado)' else '' end
            from pago g where g.ped_numero = p.ped_numero)
    from pedido p join cliente c on c.cli_cedula = p.cli_cedula join tienda t on t.tie_codigo = p.tie_codigo
   order by p.ped_fecha desc;
end $$;

revoke execute on function crear_pedido(jsonb, uuid, text, int2, text, text, text, jsonb) from public, anon;
grant  execute on function crear_pedido(jsonb, uuid, text, int2, text, text, text, jsonb) to authenticated;
revoke execute on function pedidos_admin() from public, anon;
grant  execute on function pedidos_admin() to authenticated;

commit;
