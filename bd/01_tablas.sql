/*==============================================================*/
/* ATHLETIX - Modelo físico (PostgreSQL / Supabase)             */
/* Mis tablas de la tienda con la forma de modelar de la clase:  */
/*  - nombres de tabla en singular                               */
/*  - cada columna lleva el prefijo de 3 letras de su tabla      */
/*  - las claves foráneas conservan el nombre de la columna padre */
/*  - restricciones: PK_, AK_ (únicas), CKC_ (check), FK_         */
/* Solo se guardan los atributos que la tienda usa.              */
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
   constraint pk_categoria primary key (cat_codigo),
   constraint ak_categoria_nombre unique (cat_nombre)
);

/*==============================================================*/
/* Table: PRODUCTO                                               */
/* La foto se toma de los archivos de la tienda por su código    */
/* (img/productos/<prd_codigo>-1.jpg), no se guarda en la base.  */
/*==============================================================*/
create table producto (
   prd_codigo           varchar(10)    not null,
   cat_codigo           int2           not null,
   prd_nombre           varchar(80)    not null,
   prd_descripcion      text           not null,
   prd_genero          varchar(6)     not null,
   prd_precio           numeric(10,2)  not null,
   prd_tiene_talla        bool           not null default false,
   prd_visible           bool           not null default true,
   constraint pk_producto primary key (prd_codigo),
   constraint ckc_prd_genero check (prd_genero in ('Hombre', 'Mujer', 'Unisex')),
   constraint ckc_prd_precio check (prd_precio > 0)
);

/*==============================================================*/
/* Table: PRODUCTO_TALLA  (stock por talla; U = talla única)     */
/*==============================================================*/
create table producto_talla (
   prd_codigo           varchar(10)    not null,
   pta_talla            varchar(5)     not null,
   pta_cantidad            int4           not null default 0,
   constraint pk_producto_talla primary key (prd_codigo, pta_talla),
   constraint ckc_pta_cantidad check (pta_cantidad >= 0)
);

/*==============================================================*/
/* Table: CLIENTE                                                */
/* cli_usuario enlaza con la cuenta de acceso (correo/clave)     */
/*==============================================================*/
create table cliente (
   cli_cedula           char(10)       not null,
   cli_usuario          uuid           not null,
   cli_nombres          varchar(60)    not null,
   cli_apellidos        varchar(60)    not null,
   cli_celular         char(10)       not null,
   cli_correo           varchar(120)   not null,
   cli_fecha_registro   timestamptz    not null default now(),
   constraint pk_cliente primary key (cli_cedula),
   constraint ak_cliente_usuario unique (cli_usuario),
   constraint ak_cliente_correo unique (cli_correo),
   constraint ckc_cli_cedula check (cedula_valida(cli_cedula)),
   constraint ckc_cli_nombres check (cli_nombres ~ '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ'' -]{2,60}$'),
   constraint ckc_cli_apellidos check (cli_apellidos ~ '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ'' -]{2,60}$'),
   constraint ckc_cli_celular check (cli_celular ~ '^09[0-9]{8}$')
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
/* Table: METODO_PAGO  (solo los últimos 4 dígitos, nunca el     */
/* número completo ni el CVV)                                    */
/*==============================================================*/
create table metodo_pago (
   mtp_codigo           int4           generated by default as identity,
   cli_cedula           char(10)       not null,
   mtp_marca            varchar(12)    not null,
   mtp_ultimos4         char(4)        not null,
   mtp_titular          varchar(60)    not null,
   mtp_mes_vence        int2           not null,
   mtp_anio_vence       int2           not null,
   constraint pk_metodo_pago primary key (mtp_codigo),
   constraint ak_metodo_pago_cliente unique (cli_cedula, mtp_marca, mtp_ultimos4, mtp_mes_vence, mtp_anio_vence),
   constraint ckc_mtp_marca check (mtp_marca in ('Visa', 'Mastercard')),
   constraint ckc_mtp_ultimos4 check (mtp_ultimos4 ~ '^[0-9]{4}$'),
   constraint ckc_mtp_mes check (mtp_mes_vence between 1 and 12),
   constraint ckc_mtp_anio check (mtp_anio_vence >= 2026)
);

/*==============================================================*/
/* Table: PEDIDO                                                 */
/* ped_clave_pago: identifica el intento de pago para no cobrar dos   */
/* veces si el cliente pulsa "Pagar" otra vez o la red se corta. */
/*==============================================================*/
create sequence if not exists seq_ped_numero start 1001;

create table pedido (
   ped_numero           int4           not null default nextval('seq_ped_numero'),
   cli_cedula           char(10)       not null,
   tie_codigo           int2           not null,
   mtp_codigo           int4           null,
   ped_fecha            timestamptz    not null default now(),
   ped_estado           varchar(12)    not null default 'Recibido',
   ped_subtotal         numeric(10,2)  not null,
   ped_iva              numeric(10,2)  not null,
   ped_total            numeric(10,2)  not null,
   ped_clave_pago            uuid           null,
   constraint pk_pedido primary key (ped_numero),
   constraint ak_pedido_clave unique (ped_clave_pago),
   constraint ckc_ped_estado check (ped_estado in ('Recibido', 'Preparando', 'Listo', 'Retirado', 'Cancelado')),
   constraint ckc_ped_valores check (ped_subtotal >= 0 and ped_iva >= 0 and ped_total = ped_subtotal + ped_iva)
);

/*==============================================================*/
/* Table: DETALLE_PEDIDO                                         */
/*==============================================================*/
create table detalle_pedido (
   ped_numero           int4           not null,
   prd_codigo           varchar(10)    not null,
   dpe_talla            varchar(5)     not null default 'U',
   dpe_cantidad         int2           not null,
   dpe_precio  numeric(10,2)  not null,
   constraint pk_detalle_pedido primary key (ped_numero, prd_codigo, dpe_talla),
   constraint ckc_dpe_cantidad check (dpe_cantidad between 1 and 10),
   constraint ckc_dpe_precio check (dpe_precio > 0)
);

/*==============================================================*/
/* Table: RESENA  (una por cliente y producto; solo si lo compró */
/* y lo retiró)                                                  */
/*==============================================================*/
create table resena (
   cli_cedula           char(10)       not null,
   prd_codigo           varchar(10)    not null,
   res_estrellas        int2           not null,
   res_comentario       varchar(500)   not null,
   res_fecha            timestamptz    not null default now(),
   constraint pk_resena primary key (cli_cedula, prd_codigo),
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
alter table metodo_pago add constraint fk_cliente_metodopago foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade;
alter table pedido add constraint fk_cliente_pedido foreign key (cli_cedula) references cliente (cli_cedula) on delete restrict;
alter table pedido add constraint fk_tienda_pedido foreign key (tie_codigo) references tienda (tie_codigo) on delete restrict;
alter table pedido add constraint fk_metodopago_pedido foreign key (mtp_codigo) references metodo_pago (mtp_codigo) on delete set null;
alter table detalle_pedido add constraint fk_pedido_detallepedido foreign key (ped_numero) references pedido (ped_numero) on delete cascade;
alter table detalle_pedido add constraint fk_producto_detallepedido foreign key (prd_codigo) references producto (prd_codigo) on delete restrict;
alter table resena add constraint fk_cliente_resena foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade;
alter table resena add constraint fk_producto_resena foreign key (prd_codigo) references producto (prd_codigo) on delete cascade;

create index idx_producto_categoria on producto (cat_codigo, prd_genero);
create index idx_pedido_cliente on pedido (cli_cedula, ped_fecha desc);
create index idx_resena_producto on resena (prd_codigo);
