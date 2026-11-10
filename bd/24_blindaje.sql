/*==============================================================*/
/* ATHLETIX - 24 - Blindaje de datos                             */
/* - Pedido: valida cada línea del carrito (producto, cantidad   */
/*   entera de 1 a 9999 y talla) antes de tocar el stock.        */
/* - Sin registros dobles: nombre de producto y correo de        */
/*   cliente únicos sin importar mayúsculas.                     */
/* - Reseña con largo máximo.                                    */
/* - Se puede ejecutar más de una vez.                           */
/*==============================================================*/
begin;

CREATE OR REPLACE FUNCTION public.crear_pedido(p_items jsonb, p_clave uuid, p_tienda smallint, p_tarjeta integer)
 RETURNS TABLE(ped_numero integer, ped_codigo text, ped_total numeric, ped_codigo_retiro character, ped_hora_estimada timestamp with time zone, ped_factura integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_cedula   varchar(20) := mi_cedula();
  v_numero   int4;
  v_tienda   int2;
  v_subtotal numeric(12,2) := 0;
  v_iva      numeric(12,2);
  v_total    numeric(12,2);
  v_hora     timestamptz;
  v_tar_cod  int4;
  v_tar_marca varchar(20);
  v_tar_ult4 char(4);
  v_unidades int4 := 0;
  v_productos int4 := 0;
  v_calzado  boolean := false;
  v_tecnologia boolean := false;
  v_minutos  int4;
  r          record;
begin
  if auth.uid() is null then raise exception 'Debes iniciar sesión para comprar'; end if;
  if v_cedula is null then raise exception 'Completa tu perfil antes de comprar'; end if;

  -- Idempotencia: si el mismo intento de pago llega dos veces, se devuelve el pedido ya creado
  if p_clave is not null then
    return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_retiro, p.ped_hora_estimada, p.ped_factura
      from pedido p where p.ped_clave_pago = p_clave and p.cli_cedula = v_cedula;
    if found then return; end if;
  end if;

  -- Retiro en la tienda elegida
  select tie_codigo into v_tienda from tienda where tie_codigo = p_tienda;
  if v_tienda is null then raise exception 'Elige la tienda donde retirarás tu pedido'; end if;

  -- Forma de pago: con una tarjeta guardada del cliente (pago simulado) o, si p_tarjeta es null, en la tienda al retirar
  if p_tarjeta is not null then
    select mtp_codigo, mtp_marca, mtp_ultimos4 into v_tar_cod, v_tar_marca, v_tar_ult4 from metodo_pago
     where mtp_codigo = p_tarjeta and cli_cedula = v_cedula;
    if v_tar_cod is null then raise exception 'Elige una tarjeta válida para pagar'; end if;
  end if;

  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then raise exception 'El carrito está vacío'; end if;
  if jsonb_array_length(p_items) > 60 then raise exception 'Demasiados productos en un solo pedido'; end if;
  -- Cada línea del carrito debe traer un producto y una cantidad entera razonable (evita datos manipulados)
  if exists (select 1 from jsonb_array_elements(p_items) x
              where jsonb_typeof(x) <> 'object'
                 or coalesce(x->>'producto', '') = ''
                 or coalesce(x->>'cantidad', '') !~ '^[0-9]{1,4}$'
                 or length(coalesce(x->>'talla', '')) > 5) then
    raise exception 'Hay un producto con una cantidad o talla no válida en el carrito. Revisa tu carrito.';
  end if;
  if (select count(*) from pedido where cli_cedula = v_cedula and ped_fecha > now() - interval '1 minute') >= 5 then
    raise exception 'Hiciste demasiados pedidos seguidos. Espera un minuto.';
  end if;

  -- Los movimientos de stock de esta compra quedan registrados como "Venta"
  perform set_config('athletix.motivo', 'Venta', true);
  begin
    -- Bloqueo por fila en orden fijo: dos compras al mismo tiempo nunca venden más de lo que hay
    for r in
      select p.prd_codigo, p.prd_nombre, p.prd_precio, p.prd_tiene_talla, p.prd_visible, p.cat_codigo,
             coalesce(nullif(x->>'talla', ''), 'U') as talla,
             sum((x->>'cantidad')::int) as cantidad
        from jsonb_array_elements(p_items) x
        left join producto p on p.prd_codigo = x->>'producto'
       group by p.prd_codigo, p.prd_nombre, p.prd_precio, p.prd_tiene_talla, p.prd_visible, p.cat_codigo, coalesce(nullif(x->>'talla', ''), 'U')
       order by p.prd_codigo, 7
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
      v_unidades := v_unidades + r.cantidad;
      v_productos := v_productos + 1;
      v_calzado := v_calzado or r.cat_codigo = 1;
      v_tecnologia := v_tecnologia or r.cat_codigo = 2;
    end loop;

    -- Tiempo de preparación: de 1 a 3 horas según cuánto y qué se pidió
    --   60 min base + 10 por cada unidad desde la 4.ª + 15 por cada producto distinto desde el 3.º
    --   + 20 si lleva calzado (buscar tallas en bodega) + 20 si lleva tecnología (revisar y cargar el equipo)
    v_minutos := 60 + 10 * greatest(v_unidades - 3, 0) + 15 * greatest(v_productos - 2, 0)
                 + case when v_calzado then 20 else 0 end + case when v_tecnologia then 20 else 0 end;
    v_minutos := least(180, greatest(60, ceil(v_minutos / 5.0) * 5));
    v_hora := now() + make_interval(mins => v_minutos);

    v_iva := round(v_subtotal * 0.15, 2);
    v_total := v_subtotal + v_iva;
    insert into pedido (cli_cedula, tie_codigo, ped_subtotal, ped_iva, ped_total, ped_clave_pago, ped_codigo_retiro, ped_hora_estimada, ped_factura)
    values (v_cedula, v_tienda, v_subtotal, v_iva, v_total, p_clave,
            upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6)), v_hora, nextval('seq_factura'))
    returning pedido.ped_numero into v_numero;
    -- Se une cada movimiento de stock de esta compra con su pedido
    update movimiento_stock m set ped_numero = v_numero where m.mst_transaccion = txid_current() and m.ped_numero is null;

    insert into detalle_pedido (ped_numero, prd_codigo, dpe_talla, dpe_cantidad, dpe_precio)
    select v_numero, p.prd_codigo, coalesce(nullif(x->>'talla', ''), 'U'), sum((x->>'cantidad')::int), p.prd_precio
      from jsonb_array_elements(p_items) x join producto p on p.prd_codigo = x->>'producto'
     group by p.prd_codigo, coalesce(nullif(x->>'talla', ''), 'U'), p.prd_precio;

    if v_tar_cod is not null then
      insert into pago (ped_numero, pag_forma, mtp_codigo, pag_marca, pag_ultimos4, pag_monto, pag_estado)
      values (v_numero, 'Tarjeta', v_tar_cod, v_tar_marca, v_tar_ult4, v_total, 'Aprobado');
    else
      insert into pago (ped_numero, pag_forma, pag_monto, pag_estado)
      values (v_numero, 'En tienda', v_total, 'Pendiente');
    end if;
  exception when unique_violation then
    if p_clave is not null then
      return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_retiro, p.ped_hora_estimada, p.ped_factura
        from pedido p where p.ped_clave_pago = p_clave and p.cli_cedula = v_cedula;
      if found then return; end if;
    end if;
    raise;
  end;

  return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total, p.ped_codigo_retiro, p.ped_hora_estimada, p.ped_factura
    from pedido p where p.ped_numero = v_numero;
end $function$;

-- Nombre de producto único (sin importar mayúsculas ni espacios al inicio o al final)
create unique index if not exists ak_producto_nombre on producto (lower(trim(prd_nombre)));

-- Correo de cliente único sin importar mayúsculas
create unique index if not exists ak_cliente_correo_minusculas on cliente (lower(cli_correo));

-- Reseña: de 10 a 1000 caracteres
alter table resena drop constraint if exists ckc_res_comentario_max;
alter table resena add constraint ckc_res_comentario_max check (length(res_comentario) <= 1000);

-- Stock con tope razonable para evitar errores de digitación del administrador
alter table producto_talla drop constraint if exists ckc_pta_cantidad_max;
alter table producto_talla add constraint ckc_pta_cantidad_max check (pta_cantidad <= 100000);

commit;
