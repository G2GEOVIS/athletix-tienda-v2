-- =====================================================================
-- ATHLETIX · Base de datos de la tienda (PostgreSQL / Supabase)
-- Modelo relacional: se puede importar en PowerDesigner
-- (File > Reverse Engineer > Database, DBMS: PostgreSQL).
-- =====================================================================

-- ---------- Validación de cédula ecuatoriana (algoritmo módulo 10) ----------
create or replace function cedula_valida(c text) returns boolean
language plpgsql immutable as $$
declare
  suma int := 0; d int; i int; prov int; verif int;
begin
  if c is null or c !~ '^[0-9]{10}$' then return false; end if;
  prov := substr(c, 1, 2)::int;
  if prov < 1 or (prov > 24 and prov <> 30) then return false; end if;
  if substr(c, 3, 1)::int > 5 then return false; end if;   -- persona natural
  for i in 1..9 loop
    d := substr(c, i, 1)::int;
    if i % 2 = 1 then d := d * 2; if d > 9 then d := d - 9; end if; end if;
    suma := suma + d;
  end loop;
  verif := (10 - (suma % 10)) % 10;
  return verif = substr(c, 10, 1)::int;
end $$;

-- ---------- Catálogo ----------
create table categorias (
  id        smallint generated always as identity primary key,
  nombre    varchar(40) not null unique,
  slug      varchar(40) not null unique
);

create table productos (
  id           int generated always as identity primary key,
  categoria_id smallint not null references categorias(id),
  publico      varchar(6) not null check (publico in ('Hombre', 'Mujer')),
  codigo       varchar(12) not null unique,
  nombre       varchar(80) not null,
  descripcion  text not null,
  precio       numeric(10,2) not null check (precio > 0),
  imagen_url   text not null,
  usa_talla    boolean not null default false,
  activo       boolean not null default true,
  creado_en    timestamptz not null default now()
);

create table producto_tallas (
  producto_id int not null references productos(id) on delete cascade,
  talla       varchar(5) not null,
  stock       int not null default 0 check (stock >= 0),
  primary key (producto_id, talla)
);

-- ---------- Clientes (1 a 1 con la cuenta de Supabase Auth) ----------
create table clientes (
  id         uuid primary key references auth.users(id) on delete cascade,
  cedula     char(10) not null unique check (cedula_valida(cedula)),
  nombres    varchar(60) not null check (nombres ~ '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ'' ]{2,60}$'),
  apellidos  varchar(60) not null check (apellidos ~ '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ'' ]{2,60}$'),
  telefono   char(10) not null check (telefono ~ '^09[0-9]{8}$'),
  correo     varchar(120) not null unique,
  creado_en  timestamptz not null default now()
);

-- Solo se guardan los últimos 4 dígitos, nunca el número completo ni el CVV
create table metodos_pago (
  id          int generated always as identity primary key,
  cliente_id  uuid not null references clientes(id) on delete cascade,
  marca       varchar(12) not null check (marca in ('Visa', 'Mastercard')),
  ultimos4    char(4) not null check (ultimos4 ~ '^[0-9]{4}$'),
  titular     varchar(60) not null,
  mes_vence   smallint not null check (mes_vence between 1 and 12),
  anio_vence  smallint not null check (anio_vence >= 2026),
  unique (cliente_id, marca, ultimos4, mes_vence, anio_vence)
);

create table tiendas (
  id        smallint generated always as identity primary key,
  nombre    varchar(60) not null unique,
  direccion varchar(120) not null,
  ciudad    varchar(40) not null,
  horario   varchar(60) not null
);

-- ---------- Pedidos ----------
create table pedidos (
  id              int generated always as identity primary key,
  numero          varchar(16) not null unique,        -- AX-2026-1001
  cliente_id      uuid not null references clientes(id),
  tienda_id       smallint not null references tiendas(id),
  metodo_pago_id  int not null references metodos_pago(id),
  estado          varchar(12) not null default 'Recibido'
                  check (estado in ('Recibido', 'Preparando', 'Listo', 'Retirado', 'Cancelado')),
  subtotal        numeric(10,2) not null check (subtotal >= 0),
  iva             numeric(10,2) not null check (iva >= 0),          -- 15 %
  total           numeric(10,2) not null check (total = subtotal + iva),
  creado_en       timestamptz not null default now(),
  actualizado_en  timestamptz not null default now()
);

create table detalle_pedido (
  id              int generated always as identity primary key,
  pedido_id       int not null references pedidos(id) on delete cascade,
  producto_id     int not null references productos(id),
  talla           varchar(5),
  cantidad        smallint not null check (cantidad between 1 and 10),
  precio_unitario numeric(10,2) not null check (precio_unitario > 0),
  unique (pedido_id, producto_id, talla)
);

-- ---------- Reseñas de compra verificada ----------
create table resenas (
  id          int generated always as identity primary key,
  cliente_id  uuid not null references clientes(id) on delete cascade,
  producto_id int not null references productos(id) on delete cascade,
  estrellas   smallint not null check (estrellas between 1 and 5),
  comentario  varchar(500) not null check (length(trim(comentario)) >= 10),
  creado_en   timestamptz not null default now(),
  unique (cliente_id, producto_id)            -- una reseña por cliente y producto
);

-- Solo puede opinar quien compró y retiró el producto
create or replace function verificar_compra_resena() returns trigger
language plpgsql as $$
begin
  if not exists (
    select 1 from pedidos p
    join detalle_pedido d on d.pedido_id = p.id
    where p.cliente_id = new.cliente_id
      and d.producto_id = new.producto_id
      and p.estado = 'Retirado'
  ) then
    raise exception 'Solo los clientes que compraron y retiraron este producto pueden dejar una reseña';
  end if;
  return new;
end $$;

create trigger trg_resena_compra_verificada
  before insert or update on resenas
  for each row execute function verificar_compra_resena();

-- Promedio y número de opiniones por producto
create view vista_calificaciones as
select p.id as producto_id,
       coalesce(round(avg(r.estrellas), 1), 0) as promedio,
       count(r.id) as opiniones
from productos p left join resenas r on r.producto_id = p.id
group by p.id;

-- ---------- Índices ----------
create index idx_productos_categoria on productos (categoria_id, publico);
create index idx_pedidos_cliente     on pedidos (cliente_id, creado_en desc);
create index idx_resenas_producto    on resenas (producto_id);
