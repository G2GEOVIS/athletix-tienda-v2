/*==============================================================*/
/* ATHLETIX - Favoritos y carrito guardados en la cuenta         */
/*  - FAVORITO: productos que el cliente marcó con el corazón     */
/*  - CARRITO:  productos que el cliente tiene en su carrito      */
/* Así se ven iguales en la computadora y en el celular.          */
/* Cada cliente solo ve y cambia sus propias filas (RLS).         */
/*==============================================================*/
begin;

create table if not exists favorito (
   cli_cedula           char(10)       not null,
   prd_codigo           varchar(10)    not null,
   fav_fecha            timestamptz    not null default now(),
   constraint pk_favorito primary key (cli_cedula, prd_codigo),
   constraint fk_cliente_favorito foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade,
   constraint fk_producto_favorito foreign key (prd_codigo) references producto (prd_codigo) on delete cascade
);

-- car_talla = 'U' cuando el producto no usa talla (igual que en DETALLE_PEDIDO)
create table if not exists carrito (
   cli_cedula           char(10)       not null,
   prd_codigo           varchar(10)    not null,
   car_talla            varchar(5)     not null default 'U',
   car_cantidad         int4           not null,
   car_fecha            timestamptz    not null default now(),
   constraint pk_carrito primary key (cli_cedula, prd_codigo, car_talla),
   constraint fk_cliente_carrito foreign key (cli_cedula) references cliente (cli_cedula) on delete cascade,
   constraint fk_producto_carrito foreign key (prd_codigo) references producto (prd_codigo) on delete cascade,
   constraint ckc_car_cantidad check (car_cantidad between 1 and 9999)
);

alter table favorito enable row level security;
alter table carrito  enable row level security;

drop policy if exists "mis favoritos" on favorito;
create policy "mis favoritos" on favorito for all
  using (cli_cedula = mi_cedula()) with check (cli_cedula = mi_cedula());
drop policy if exists "mi carrito" on carrito;
create policy "mi carrito" on carrito for all
  using (cli_cedula = mi_cedula()) with check (cli_cedula = mi_cedula());

revoke all on favorito, carrito from anon;
grant select, insert, update, delete on favorito, carrito to authenticated;

commit;
