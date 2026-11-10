/*==============================================================*/
/* ATHLETIX - MIGRACIÓN al modelo con la convención de la clase  */
/* Ejecutar UNA sola vez en Supabase > SQL Editor.               */
/* Todo va en una transacción: si algo falla, no cambia nada.    */
/*==============================================================*/
begin;

/*==============================================================*/
/* ATHLETIX - Modelo físico (PostgreSQL / Supabase)             */
/* Convención: tablas en singular y columnas con prefijo de 3   */
/* letras de su tabla (CLI_, PRD_, PED_, PAG_, PPC_...). Las     */
/* claves foráneas conservan el nombre de la columna padre.      */
/*==============================================================*/

/*==============================================================*/
/* Validación de cédula ecuatoriana (algoritmo módulo 10)        */
/*==============================================================*/
create or replace function cedula_valida(c text) returns boolean
language plpgsql immutable as $$
declare
  suma int := 0; d int; i int; prov int;
begin
  if c is null or c !~ '^[0-9]{10}$' then return false; end if;
  prov := substr(c, 1, 2)::int;
  if prov < 1 or (prov > 24 and prov <> 30) then return false; end if;
  if substr(c, 3, 1)::int > 5 then return false; end if;
  for i in 1..9 loop
    d := substr(c, i, 1)::int;
    if i % 2 = 1 then d := d * 2; if d > 9 then d := d - 9; end if; end if;
    suma := suma + d;
  end loop;
  return (10 - (suma % 10)) % 10 = substr(c, 10, 1)::int;
end $$;

/*==============================================================*/
/* Table: CATEGORIA                                              */
/*==============================================================*/
create table categoria (
   cat_codigo           int2           not null,
   cat_nombre           varchar(40)    not null,
   cat_slug             varchar(20)    not null,
   constraint pk_categoria primary key (cat_codigo),
   constraint ak_categoria_nombre unique (cat_nombre),
   constraint ak_categoria_slug unique (cat_slug)
);

/*==============================================================*/
/* Table: PRODUCTO                                               */
/*==============================================================*/
create table producto (
   prd_codigo           varchar(10)    not null,
   cat_codigo           int2           not null,
   prd_nombre           varchar(80)    not null,
   prd_descripcion      text           not null,
   prd_publico          varchar(6)     not null,
   prd_precio           numeric(12,2)  not null,
   prd_imagen           varchar(120)   not null,
   prd_usa_talla        bool           not null default false,
   prd_activo           bool           not null default true,
   prd_fecha_creacion   timestamptz    not null default now(),
   constraint pk_producto primary key (prd_codigo),
   constraint ckc_prd_publico check (prd_publico in ('Hombre', 'Mujer', 'Unisex')),
   constraint ckc_prd_precio check (prd_precio > 0)
);

/*==============================================================*/
/* Table: PRODUCTO_TALLA  (existencia por talla; U = única)      */
/*==============================================================*/
create table producto_talla (
   prd_codigo           varchar(10)    not null,
   pta_talla            varchar(5)     not null,
   pta_existencia       int4           not null default 0,
   constraint pk_producto_talla primary key (prd_codigo, pta_talla),
   constraint ckc_pta_existencia check (pta_existencia >= 0)
);

/*==============================================================*/
/* Table: CLIENTE                                                */
/*==============================================================*/
create table cliente (
   cli_cedula           char(10)       not null,
   cli_usuario          uuid           not null,
   cli_nombres          varchar(60)    not null,
   cli_apellidos        varchar(60)    not null,
   cli_telefono         char(10)       not null,
   cli_correo           varchar(120)   not null,
   cli_fecha_registro   timestamptz    not null default now(),
   constraint pk_cliente primary key (cli_cedula),
   constraint ak_cliente_usuario unique (cli_usuario),
   constraint ak_cliente_correo unique (cli_correo),
   constraint ckc_cli_cedula check (cedula_valida(cli_cedula)),
   constraint ckc_cli_nombres check (cli_nombres ~ '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ'' -]{2,60}$'),
   constraint ckc_cli_apellidos check (cli_apellidos ~ '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ'' -]{2,60}$'),
   constraint ckc_cli_telefono check (cli_telefono ~ '^09[0-9]{8}$')
);

/*==============================================================*/
/* Table: ADMINISTRADOR                                          */
/*==============================================================*/
create table administrador (
   adm_usuario          uuid           not null,
   constraint pk_administrador primary key (adm_usuario)
);

/*==============================================================*/
/* Table: TIENDA                                                 */
/*==============================================================*/
create table tienda (
   tie_codigo           int2           not null,
   tie_nombre           varchar(60)    not null,
   tie_direccion        varchar(120)   not null,
   tie_ciudad           varchar(40)    not null,
   tie_horario          varchar(60)    not null,
   constraint pk_tienda primary key (tie_codigo),
   constraint ak_tienda_nombre unique (tie_nombre)
);

/*==============================================================*/
/* Table: TARJETA  (solo últimos 4 dígitos, nunca el número)     */
/*==============================================================*/
create table tarjeta (
   tar_codigo           int4           generated by default as identity,
   cli_cedula           char(10)       not null,
   tar_marca            varchar(12)    not null,
   tar_ultimos4         char(4)        not null,
   tar_titular          varchar(60)    not null,
   tar_mes_vence        int2           not null,
   tar_anio_vence       int2           not null,
   constraint pk_tarjeta primary key (tar_codigo),
   constraint ak_tarjeta_cliente unique (cli_cedula, tar_marca, tar_ultimos4, tar_mes_vence, tar_anio_vence),
   constraint ckc_tar_marca check (tar_marca in ('Visa', 'Mastercard')),
   constraint ckc_tar_ultimos4 check (tar_ultimos4 ~ '^[0-9]{4}$'),
   constraint ckc_tar_mes check (tar_mes_vence between 1 and 12),
   constraint ckc_tar_anio check (tar_anio_vence >= 2026)
);

/*==============================================================*/
/* Table: PEDIDOCLIENTE                                          */
/*==============================================================*/
create sequence if not exists seq_ped_numero start 1001;

create table pedidocliente (
   ped_numero           numeric(12)    not null default nextval('seq_ped_numero'),
   cli_cedula           char(10)       not null,
   tie_codigo           int2           not null,
   ped_fecha            timestamptz    not null default now(),
   ped_estado           varchar(20)    not null default 'Recibido',
   ped_subtotal         numeric(12,2)  not null,
   ped_iva              numeric(12,2)  not null,
   ped_total            numeric(12,2)  not null,
   ped_clave            uuid           null,
   ped_fecha_actualizacion timestamptz not null default now(),
   constraint pk_pedidocliente primary key (ped_numero),
   constraint ak_pedidocliente_clave unique (ped_clave),
   constraint ckc_ped_estado check (ped_estado in ('Recibido', 'Preparando', 'Listo', 'Retirado', 'Cancelado')),
   constraint ckc_ped_valores check (ped_subtotal >= 0 and ped_iva >= 0 and ped_total = ped_subtotal + ped_iva)
);

/*==============================================================*/
/* Table: PAGOS                                                  */
/*==============================================================*/
create table pagos (
   pag_codigo           varchar(15)    not null,
   ped_numero           numeric(12)    not null,
   tar_codigo           int4           not null,
   pag_monto            numeric(12,2)  not null,
   pag_fecha            timestamptz    not null default now(),
   constraint pk_pagos primary key (pag_codigo),
   constraint ckc_pag_monto check (pag_monto > 0)
);

/*==============================================================*/
/* Table: PRODUCTO_PEDCLI  (detalle del pedido)                  */
/*==============================================================*/
create table producto_pedcli (
   ped_numero           numeric(12)    not null,
   prd_codigo           varchar(10)    not null,
   ppc_talla            varchar(5)     not null default 'U',
   ppc_cantidad         int2           not null,
   ppc_precio           numeric(12,2)  not null,
   constraint pk_producto_pedcli primary key (ped_numero, prd_codigo, ppc_talla),
   constraint ckc_ppc_cantidad check (ppc_cantidad between 1 and 10),
   constraint ckc_ppc_precio check (ppc_precio > 0)
);

/*==============================================================*/
/* Table: RESENA  (solo de clientes que compraron y retiraron)   */
/*==============================================================*/
create table resena (
   res_codigo           int4           generated by default as identity,
   cli_cedula           char(10)       not null,
   prd_codigo           varchar(10)    not null,
   res_estrellas        int2           not null,
   res_comentario       varchar(500)   not null,
   res_autor            varchar(40)    null,
   res_fecha            timestamptz    not null default now(),
   constraint pk_resena primary key (res_codigo),
   constraint ak_resena_cliente_producto unique (cli_cedula, prd_codigo),
   constraint ckc_res_estrellas check (res_estrellas between 1 and 5),
   constraint ckc_res_comentario check (length(trim(res_comentario)) >= 10)
);

/*==============================================================*/
/* Relaciones                                                    */
/*==============================================================*/
alter table producto add constraint fk_categoria_producto foreign key (cat_codigo) references categoria (cat_codigo) on delete restrict;
alter table producto_talla add constraint fk_producto_productotalla foreign key (prd_codigo) references producto (prd_codigo) on delete cascade;
alter table cliente add constraint fk_usuario_cliente foreign key (cli_usuario) references auth.users (id) on delete cascade;
alter table administrador add constraint fk_usuario_administrador foreign key (adm_usuario) references auth.users (id) on delete cascade;
alter table tarjeta add constraint fk_cliente_tarjeta foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade;
alter table pedidocliente add constraint fk_cliente_pedidocliente foreign key (cli_cedula) references cliente (cli_cedula) on delete restrict;
alter table pedidocliente add constraint fk_tienda_pedidocliente foreign key (tie_codigo) references tienda (tie_codigo) on delete restrict;
alter table pagos add constraint fk_pedidocliente_pago foreign key (ped_numero) references pedidocliente (ped_numero) on delete cascade;
alter table pagos add constraint fk_tarjeta_pago foreign key (tar_codigo) references tarjeta (tar_codigo) on delete restrict;
alter table producto_pedcli add constraint fk_pedcli_prodpedcli foreign key (ped_numero) references pedidocliente (ped_numero) on delete cascade;
alter table producto_pedcli add constraint fk_producto_prdpedcli foreign key (prd_codigo) references producto (prd_codigo) on delete restrict;
alter table resena add constraint fk_cliente_resena foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade;
alter table resena add constraint fk_producto_resena foreign key (prd_codigo) references producto (prd_codigo) on delete cascade;

create index idx_producto_categoria on producto (cat_codigo, prd_publico);
create index idx_pedidocliente_cliente on pedidocliente (cli_cedula, ped_fecha desc);
create index idx_resena_producto on resena (prd_codigo);

/*==============================================================*/
/* Copia de los datos del modelo anterior al nuevo              */
/*==============================================================*/
insert into categoria (cat_codigo, cat_nombre, cat_slug) select id, nombre, slug from categorias;
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_publico, prd_precio, prd_imagen, prd_usa_talla, prd_activo, prd_fecha_creacion)
  select codigo, categoria_id, nombre, descripcion, publico, precio, imagen_url, usa_talla, activo, creado_en from productos;
insert into producto_talla (prd_codigo, pta_talla, pta_existencia)
  select p.codigo, t.talla, t.stock from producto_tallas t join productos p on p.id = t.producto_id;
insert into tienda (tie_codigo, tie_nombre, tie_direccion, tie_ciudad, tie_horario) select id, nombre, direccion, ciudad, horario from tiendas;
insert into cliente (cli_cedula, cli_usuario, cli_nombres, cli_apellidos, cli_telefono, cli_correo, cli_fecha_registro)
  select cedula, id, nombres, apellidos, telefono, correo, creado_en from clientes;
insert into administrador (adm_usuario) select id from administradores;
insert into tarjeta (tar_codigo, cli_cedula, tar_marca, tar_ultimos4, tar_titular, tar_mes_vence, tar_anio_vence)
  select m.id, c.cedula, m.marca, m.ultimos4, m.titular, m.mes_vence, m.anio_vence from metodos_pago m join clientes c on c.id = m.cliente_id;
insert into pedidocliente (ped_numero, cli_cedula, tie_codigo, ped_fecha, ped_estado, ped_subtotal, ped_iva, ped_total, ped_clave, ped_fecha_actualizacion)
  select substring(p.numero from '(\d+)$')::numeric, c.cedula, p.tienda_id, p.creado_en, p.estado, p.subtotal, p.iva, p.total, p.clave, p.actualizado_en
    from pedidos p join clientes c on c.id = p.cliente_id;
insert into pagos (pag_codigo, ped_numero, tar_codigo, pag_monto, pag_fecha)
  select 'PAG-' || lpad(substring(p.numero from '(\d+)$'), 8, '0'), substring(p.numero from '(\d+)$')::numeric, p.metodo_pago_id, p.total, p.creado_en from pedidos p;
insert into producto_pedcli (ped_numero, prd_codigo, ppc_talla, ppc_cantidad, ppc_precio)
  select substring(p.numero from '(\d+)$')::numeric, pr.codigo, coalesce(d.talla, 'U'), d.cantidad, d.precio_unitario
    from detalle_pedido d join pedidos p on p.id = d.pedido_id join productos pr on pr.id = d.producto_id;
insert into resena (res_codigo, cli_cedula, prd_codigo, res_estrellas, res_comentario, res_autor, res_fecha)
  select r.id, c.cedula, pr.codigo, r.estrellas, r.comentario, r.autor, r.creado_en
    from resenas r join clientes c on c.id = r.cliente_id join productos pr on pr.id = r.producto_id;

select setval('seq_ped_numero', greatest(1001, coalesce((select max(ped_numero)::bigint + 1 from pedidocliente), 1001)), false);
select setval(pg_get_serial_sequence('tarjeta', 'tar_codigo'), coalesce((select max(tar_codigo) from tarjeta), 0) + 1, false);
select setval(pg_get_serial_sequence('resena', 'res_codigo'), coalesce((select max(res_codigo) from resena), 0) + 1, false);

/*==============================================================*/
/* Se elimina el modelo anterior                                 */
/*==============================================================*/
drop view if exists vista_calificaciones;
drop function if exists crear_pedido(smallint, int, jsonb, uuid);
drop function if exists crear_pedido(smallint, int, jsonb);
drop function if exists cambiar_estado_pedido(int, varchar);
drop function if exists pedidos_nuevos();
drop function if exists pedidos_admin();
drop table if exists resenas, detalle_pedido, pedidos, metodos_pago, direcciones, administradores, clientes, producto_tallas, productos, tiendas, categorias cascade;
drop function if exists verificar_compra_resena() cascade;
drop function if exists poner_autor_resena() cascade;
drop function if exists copiar_correo_cuenta() cascade;
drop sequence if exists seq_numero_pedido;

/*==============================================================*/
/* ATHLETIX - Seguridad por filas (RLS), funciones y triggers   */
/* Ejecutar después de 01_tablas.sql                            */
/*==============================================================*/

/*---------------- Funciones de apoyo ----------------*/
create or replace function es_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from administrador where adm_usuario = auth.uid());
$$;

-- Cédula del cliente que tiene la sesión abierta
create or replace function mi_cedula() returns char(10)
language sql stable security definer set search_path = public as $$
  select cli_cedula from cliente where cli_usuario = auth.uid();
$$;

create or replace function cedula_registrada(p_cedula text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from cliente where cli_cedula = p_cedula);
$$;

create or replace function correo_registrado(p_correo text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from auth.users where lower(email) = lower(trim(p_correo)));
$$;

/*---------------- Triggers ----------------*/
-- El correo del cliente siempre es el de su cuenta (no se puede falsificar)
create or replace function tib_cliente() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  select email into new.cli_correo from auth.users where id = new.cli_usuario;
  if tg_op = 'UPDATE' then
    new.cli_cedula := old.cli_cedula;           -- la cédula no se cambia
    new.cli_usuario := old.cli_usuario;
    new.cli_fecha_registro := old.cli_fecha_registro;
  end if;
  return new;
end $$;
create trigger tib_cliente before insert or update on cliente
  for each row execute function tib_cliente();

-- Solo opina quien compró y retiró el producto; el autor se arma con su nombre
create or replace function tib_resena() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if not exists (
    select 1 from pedidocliente p join producto_pedcli d on d.ped_numero = p.ped_numero
     where p.cli_cedula = new.cli_cedula and d.prd_codigo = new.prd_codigo and p.ped_estado = 'Retirado'
  ) then
    raise exception 'Solo los clientes que compraron y retiraron este producto pueden dejar una reseña';
  end if;
  select split_part(trim(cli_nombres), ' ', 1) || ' ' || left(trim(cli_apellidos), 1) || '.'
    into new.res_autor from cliente where cli_cedula = new.cli_cedula;
  return new;
end $$;
create trigger tib_resena before insert or update on resena
  for each row execute function tib_resena();

/*---------------- Vista de calificaciones ----------------*/
create or replace view vista_calificaciones with (security_invoker = true) as
select p.prd_codigo,
       coalesce(round(avg(r.res_estrellas), 1), 0) as promedio,
       count(r.res_codigo) as opiniones
  from producto p left join resena r on r.prd_codigo = p.prd_codigo
 group by p.prd_codigo;

/*---------------- Seguridad por filas ----------------*/
alter table categoria       enable row level security;
alter table producto        enable row level security;
alter table producto_talla  enable row level security;
alter table tienda          enable row level security;
alter table cliente         enable row level security;
alter table administrador   enable row level security;
alter table tarjeta         enable row level security;
alter table pedidocliente   enable row level security;
alter table pagos           enable row level security;
alter table producto_pedcli enable row level security;
alter table resena          enable row level security;

create policy "catalogo visible" on categoria      for select using (true);
create policy "catalogo visible" on producto       for select using (prd_activo or es_admin());
create policy "catalogo visible" on producto_talla for select using (true);
create policy "catalogo visible" on tienda         for select using (true);

create policy "mi perfil ver"    on cliente for select using (cli_usuario = auth.uid() or es_admin());
create policy "mi perfil crear"  on cliente for insert with check (cli_usuario = auth.uid());
create policy "mi perfil editar" on cliente for update using (cli_usuario = auth.uid()) with check (cli_usuario = auth.uid());

create policy "solo admin" on administrador for select using (adm_usuario = auth.uid());

create policy "mis tarjetas" on tarjeta for all using (cli_cedula = mi_cedula()) with check (cli_cedula = mi_cedula());

create policy "mis pedidos" on pedidocliente for select using (cli_cedula = mi_cedula() or es_admin());
create policy "mis pagos" on pagos for select using (
  exists (select 1 from pedidocliente p where p.ped_numero = pagos.ped_numero and (p.cli_cedula = mi_cedula() or es_admin())));
create policy "mi detalle" on producto_pedcli for select using (
  exists (select 1 from pedidocliente p where p.ped_numero = producto_pedcli.ped_numero and (p.cli_cedula = mi_cedula() or es_admin())));

create policy "resenas visibles" on resena for select using (true);
create policy "mi resena crear"  on resena for insert with check (cli_cedula = mi_cedula());
create policy "mi resena editar" on resena for update using (cli_cedula = mi_cedula()) with check (cli_cedula = mi_cedula());
create policy "mi resena borrar" on resena for delete using (cli_cedula = mi_cedula());

revoke all on cliente, tarjeta, pedidocliente, pagos, producto_pedcli, administrador from anon;

/*---------------- Crear pedido (una sola transacción) ----------------*/
-- Atomicidad: todo o nada. Concurrencia: bloqueo por fila del stock en orden fijo (sin deadlocks).
-- Idempotencia: p_clave evita pedidos duplicados por reintentos.
create or replace function crear_pedido(p_tienda int2, p_tarjeta int4, p_items jsonb, p_clave uuid default null)
returns table (ped_numero numeric, ped_codigo text, ped_total numeric)
language plpgsql security definer set search_path = public as $$
declare
  v_cedula   char(10) := mi_cedula();
  v_numero   numeric(12);
  v_subtotal numeric(12,2) := 0;
  v_iva      numeric(12,2);
  r          record;
begin
  if auth.uid() is null then raise exception 'Debes iniciar sesión para comprar'; end if;
  if v_cedula is null then raise exception 'Completa tu perfil antes de comprar'; end if;

  if p_clave is not null then
    return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total
      from pedidocliente p where p.ped_clave = p_clave and p.cli_cedula = v_cedula;
    if found then return; end if;
  end if;

  if not exists (select 1 from tarjeta where tar_codigo = p_tarjeta and cli_cedula = v_cedula) then raise exception 'El método de pago no es válido'; end if;
  if not exists (select 1 from tienda where tie_codigo = p_tienda) then raise exception 'La tienda de retiro no es válida'; end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then raise exception 'El carrito está vacío'; end if;
  if jsonb_array_length(p_items) > 30 then raise exception 'Demasiados productos en un solo pedido'; end if;
  if (select count(*) from pedidocliente where cli_cedula = v_cedula and ped_fecha > now() - interval '1 minute') >= 5 then
    raise exception 'Hiciste demasiados pedidos seguidos. Espera un minuto.';
  end if;

  begin
    for r in
      select p.prd_codigo, p.prd_nombre, p.prd_precio, p.prd_usa_talla, p.prd_activo,
             coalesce(nullif(x->>'talla', ''), 'U') as talla,
             sum((x->>'cantidad')::int) as cantidad
        from jsonb_array_elements(p_items) x
        left join producto p on p.prd_codigo = x->>'producto'
       group by p.prd_codigo, p.prd_nombre, p.prd_precio, p.prd_usa_talla, p.prd_activo, coalesce(nullif(x->>'talla', ''), 'U')
       order by p.prd_codigo, 6
    loop
      if r.prd_codigo is null or not r.prd_activo then raise exception 'Un producto del carrito ya no está disponible'; end if;
      if r.cantidad is null or r.cantidad < 1 or r.cantidad > 10 then raise exception 'La cantidad de "%" debe estar entre 1 y 10', r.prd_nombre; end if;
      if r.prd_usa_talla and r.talla = 'U' then raise exception 'Elige una talla para "%"', r.prd_nombre; end if;

      update producto_talla set pta_existencia = pta_existencia - r.cantidad
       where prd_codigo = r.prd_codigo and pta_talla = r.talla and pta_existencia >= r.cantidad;
      if not found then
        raise exception 'No hay stock suficiente de "%"%', r.prd_nombre, case when r.talla = 'U' then '' else ' talla ' || r.talla end;
      end if;
      v_subtotal := v_subtotal + r.prd_precio * r.cantidad;
    end loop;

    v_iva := round(v_subtotal * 0.15, 2);
    insert into pedidocliente (cli_cedula, tie_codigo, ped_subtotal, ped_iva, ped_total, ped_clave)
    values (v_cedula, p_tienda, v_subtotal, v_iva, v_subtotal + v_iva, p_clave)
    returning pedidocliente.ped_numero into v_numero;

    insert into producto_pedcli (ped_numero, prd_codigo, ppc_talla, ppc_cantidad, ppc_precio)
    select v_numero, p.prd_codigo, coalesce(nullif(x->>'talla', ''), 'U'), sum((x->>'cantidad')::int), p.prd_precio
      from jsonb_array_elements(p_items) x join producto p on p.prd_codigo = x->>'producto'
     group by p.prd_codigo, coalesce(nullif(x->>'talla', ''), 'U'), p.prd_precio;

    insert into pagos (pag_codigo, ped_numero, tar_codigo, pag_monto)
    values ('PAG-' || lpad(v_numero::text, 8, '0'), v_numero, p_tarjeta, v_subtotal + v_iva);
  exception when unique_violation then
    if p_clave is not null then
      return query select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'), p.ped_total
        from pedidocliente p where p.ped_clave = p_clave and p.cli_cedula = v_cedula;
      if found then return; end if;
    end if;
    raise;
  end;

  return query select v_numero, 'AX-' || to_char(now(), 'YYYY') || '-' || lpad(v_numero::text, 5, '0'), v_subtotal + v_iva;
end $$;

/*---------------- Cambiar estado (solo administrador) ----------------*/
create or replace function cambiar_estado_pedido(p_numero numeric, p_estado varchar)
returns void language plpgsql security definer set search_path = public as $$
declare
  v_actual varchar;
  permitidos text[];
begin
  if not es_admin() then raise exception 'Solo un administrador puede cambiar el estado'; end if;
  select ped_estado into v_actual from pedidocliente where ped_numero = p_numero for update;
  if not found then raise exception 'El pedido no existe'; end if;
  permitidos := case v_actual
    when 'Recibido'   then array['Preparando', 'Listo', 'Cancelado']
    when 'Preparando' then array['Listo', 'Cancelado']
    when 'Listo'      then array['Retirado', 'Cancelado']
    else array[]::text[] end;
  if not (p_estado = any (permitidos)) then raise exception 'No se puede pasar un pedido de "%" a "%"', v_actual, p_estado; end if;
  if p_estado = 'Cancelado' then
    update producto_talla t set pta_existencia = t.pta_existencia + d.ppc_cantidad
      from producto_pedcli d
     where d.ped_numero = p_numero and t.prd_codigo = d.prd_codigo and t.pta_talla = d.ppc_talla;
  end if;
  update pedidocliente set ped_estado = p_estado, ped_fecha_actualizacion = now() where ped_numero = p_numero;
end $$;

/*---------------- Panel del administrador ----------------*/
create or replace function pedidos_nuevos() returns int
language plpgsql stable security definer set search_path = public as $$
begin
  if not es_admin() then return 0; end if;
  return (select count(*) from pedidocliente where ped_estado = 'Recibido');
end $$;

create or replace function pedidos_admin()
returns table (ped_numero numeric, ped_codigo text, ped_estado varchar, ped_total numeric, ped_fecha timestamptz,
               cliente text, cli_correo varchar, cli_telefono char(10), cli_cedula char(10),
               tie_nombre varchar, tie_horario varchar, productos text)
language plpgsql stable security definer set search_path = public as $$
begin
  if not es_admin() then raise exception 'Solo un administrador puede ver todos los pedidos'; end if;
  return query
  select p.ped_numero, 'AX-' || to_char(p.ped_fecha, 'YYYY') || '-' || lpad(p.ped_numero::text, 5, '0'),
         p.ped_estado, p.ped_total, p.ped_fecha,
         c.cli_nombres || ' ' || c.cli_apellidos, c.cli_correo, c.cli_telefono, c.cli_cedula,
         t.tie_nombre, t.tie_horario,
         (select string_agg(d.ppc_cantidad || ' × ' || pr.prd_nombre || case when d.ppc_talla = 'U' then '' else ' (talla ' || d.ppc_talla || ')' end, ', ')
            from producto_pedcli d join producto pr on pr.prd_codigo = d.prd_codigo where d.ped_numero = p.ped_numero)
    from pedidocliente p join cliente c on c.cli_cedula = p.cli_cedula join tienda t on t.tie_codigo = p.tie_codigo
   order by p.ped_fecha desc;
end $$;

/*---------------- Permisos de ejecución ----------------*/
revoke execute on function crear_pedido(int2, int4, jsonb, uuid) from public, anon;
grant  execute on function crear_pedido(int2, int4, jsonb, uuid) to authenticated;
revoke execute on function cambiar_estado_pedido(numeric, varchar) from public, anon;
grant  execute on function cambiar_estado_pedido(numeric, varchar) to authenticated;
revoke execute on function pedidos_nuevos() from public, anon;
grant  execute on function pedidos_nuevos() to authenticated;
revoke execute on function pedidos_admin() from public, anon;
grant  execute on function pedidos_admin() to authenticated;
grant  execute on function es_admin(), mi_cedula() to authenticated;
grant  execute on function cedula_registrada(text), correo_registrado(text) to anon, authenticated;

commit;
