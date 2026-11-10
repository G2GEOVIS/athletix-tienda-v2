/*==============================================================*/
/* ATHLETIX - Clientes extranjeros                               */
/*  - CLIENTE.cli_pais: país donde vive (Ecuador por defecto)    */
/*  - CLIENTE.cli_tipo_documento: 'Cédula' (Ecuador, se valida   */
/*    con el módulo 10) o 'Pasaporte' (5 a 20 letras y números)  */
/*  - cli_cedula pasa a varchar(20) para guardar el pasaporte    */
/*    (se conserva el nombre: es el documento del cliente)       */
/*  - cli_celular: 09XXXXXXXX en Ecuador o +código y número       */
/*    (formato internacional) en otros países                    */
/* Para cambiar el tipo de la clave se quitan y se vuelven a     */
/* crear las reglas de seguridad, la vista y las claves foráneas.*/
/*==============================================================*/
begin;

-- 1. Se quitan temporalmente lo que depende de la columna cli_cedula
drop view if exists vista_resenas;
drop view if exists vista_calificaciones;
drop policy if exists "mis metodos de pago" on metodo_pago;
drop policy if exists "mis pedidos" on pedido;
drop policy if exists "mi detalle" on detalle_pedido;
drop policy if exists "mi resena ver" on resena;
drop policy if exists "mi resena crear" on resena;
drop policy if exists "mi resena editar" on resena;
drop policy if exists "mi resena borrar" on resena;
drop policy if exists "mis pagos" on pago;
drop policy if exists "mis favoritos" on favorito;
drop policy if exists "mi carrito" on carrito;
alter table metodo_pago drop constraint if exists fk_cliente_metodopago;
alter table pedido      drop constraint if exists fk_cliente_pedido;
alter table resena      drop constraint if exists fk_cliente_resena;
alter table favorito    drop constraint if exists fk_cliente_favorito;
alter table carrito     drop constraint if exists fk_cliente_carrito;
drop function if exists mi_cedula();

-- 2. Nuevos datos del cliente y tipos más amplios
alter table cliente add column if not exists cli_pais varchar(40) not null default 'Ecuador';
alter table cliente add column if not exists cli_tipo_documento varchar(9) not null default 'Cédula';
alter table cliente drop constraint if exists ckc_cli_tipo_documento;
alter table cliente add constraint ckc_cli_tipo_documento check (cli_tipo_documento in ('Cédula', 'Pasaporte'));
alter table cliente drop constraint if exists ckc_cli_pais;
alter table cliente add constraint ckc_cli_pais check (length(trim(cli_pais)) between 3 and 40);
alter table cliente drop constraint if exists ckc_cli_cedula;
alter table cliente drop constraint if exists ckc_cli_celular;
alter table cliente alter column cli_cedula  type varchar(20) using trim(cli_cedula);
alter table cliente alter column cli_celular type varchar(16) using trim(cli_celular);
alter table metodo_pago alter column cli_cedula type varchar(20) using trim(cli_cedula);
alter table pedido      alter column cli_cedula type varchar(20) using trim(cli_cedula);
alter table resena      alter column cli_cedula type varchar(20) using trim(cli_cedula);
alter table favorito    alter column cli_cedula type varchar(20) using trim(cli_cedula);
alter table carrito     alter column cli_cedula type varchar(20) using trim(cli_cedula);
alter table cliente add constraint ckc_cli_cedula check (
  (cli_tipo_documento = 'Cédula' and cedula_valida(cli_cedula)) or
  (cli_tipo_documento = 'Pasaporte' and cli_cedula ~ '^[A-Z0-9]{5,20}$'));
alter table cliente add constraint ckc_cli_celular check (
  (cli_pais = 'Ecuador' and cli_celular ~ '^09[0-9]{8}$') or
  (cli_pais <> 'Ecuador' and cli_celular ~ '^\+[1-9][0-9]{6,14}$'));

-- 3. Claves foráneas otra vez
alter table metodo_pago add constraint fk_cliente_metodopago foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade;
alter table pedido      add constraint fk_cliente_pedido     foreign key (cli_cedula) references cliente (cli_cedula) on delete restrict;
alter table resena      add constraint fk_cliente_resena     foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade;
alter table favorito    add constraint fk_cliente_favorito   foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade;
alter table carrito     add constraint fk_cliente_carrito    foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade;

-- 4. Documento del cliente con sesión, reglas de seguridad y vista de reseñas
create or replace function mi_cedula() returns varchar
language sql stable security definer set search_path = public as $$
  select cli_cedula from cliente where cli_usuario = auth.uid();
$$;
grant execute on function mi_cedula() to authenticated;

create policy "mis metodos de pago" on metodo_pago for all using (cli_cedula = mi_cedula()) with check (cli_cedula = mi_cedula());
create policy "mis pedidos" on pedido for select using (cli_cedula = mi_cedula() or es_admin());
create policy "mi detalle" on detalle_pedido for select using (
  exists (select 1 from pedido p where p.ped_numero = detalle_pedido.ped_numero and (p.cli_cedula = mi_cedula() or es_admin())));
create policy "mi resena ver"    on resena for select using (cli_cedula = mi_cedula() or es_admin());
create policy "mi resena crear"  on resena for insert with check (cli_cedula = mi_cedula());
create policy "mi resena editar" on resena for update using (cli_cedula = mi_cedula()) with check (cli_cedula = mi_cedula());
create policy "mi resena borrar" on resena for delete using (cli_cedula = mi_cedula());
create policy "mis pagos" on pago for select using (
  exists (select 1 from pedido p where p.ped_numero = pago.ped_numero and (p.cli_cedula = mi_cedula() or es_admin())));
create policy "mis favoritos" on favorito for all using (cli_cedula = mi_cedula()) with check (cli_cedula = mi_cedula());
create policy "mi carrito" on carrito for all using (cli_cedula = mi_cedula()) with check (cli_cedula = mi_cedula());

create view vista_resenas as
select r.prd_codigo, r.res_estrellas, r.res_comentario, r.res_fecha,
       split_part(trim(c.cli_nombres), ' ', 1) || ' ' || left(trim(c.cli_apellidos), 1) || '.' as autor,
       (r.cli_cedula = mi_cedula()) as es_mia
  from resena r join cliente c on c.cli_cedula = r.cli_cedula;
create view vista_calificaciones as
select p.prd_codigo,
       coalesce(round(avg(r.res_estrellas), 1), 0) as promedio,
       count(r.cli_cedula) as opiniones
  from producto p left join resena r on r.prd_codigo = p.prd_codigo
 group by p.prd_codigo;
grant select on vista_resenas, vista_calificaciones to anon, authenticated;

-- 5. Funciones que usan el documento con el tipo nuevo
create or replace function crear_pedido(p_items jsonb, p_clave uuid, p_tienda int2, p_tarjeta int4)
returns table (ped_numero int4, ped_codigo text, ped_total numeric, ped_codigo_retiro char(6), ped_hora_estimada timestamptz, ped_factura int4)
language plpgsql security definer set search_path = public as $$
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
end $$;

drop function if exists pedidos_admin();
create or replace function pedidos_admin()
returns table (ped_numero int4, ped_codigo text, ped_estado varchar, ped_total numeric, ped_fecha timestamptz,
               cliente text, cli_correo varchar, cli_celular varchar, cli_cedula varchar,
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
         (select case when g.pag_forma = 'En tienda' then 'Efectivo en la tienda al retirar' else g.pag_marca || ' •••• ' || g.pag_ultimos4 end
                 || case g.pag_estado when 'Anulado' then ' (anulado)' when 'Pendiente' then ' (pendiente)' else '' end
            from pago g where g.ped_numero = p.ped_numero)
    from pedido p join cliente c on c.cli_cedula = p.cli_cedula join tienda t on t.tie_codigo = p.tie_codigo
   order by p.ped_fecha desc;
end $$;

revoke execute on function crear_pedido(jsonb, uuid, int2, int4) from public, anon;
grant  execute on function crear_pedido(jsonb, uuid, int2, int4) to authenticated;
revoke execute on function pedidos_admin() from public, anon;
grant  execute on function pedidos_admin() to authenticated;

commit;
