-- =====================================================================
-- ATHLETIX · Seguridad, funciones del servidor y datos iniciales
-- Ejecutar en Supabase > SQL Editor DESPUÉS de esquema.sql
-- =====================================================================

-- ---------- Administradores (pueden cambiar el estado de los pedidos) ----------
create table if not exists administradores (
  id uuid primary key references auth.users(id) on delete cascade
);

create or replace function es_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from administradores where id = auth.uid());
$$;

-- ---------- Activar seguridad por filas (RLS) en todas las tablas ----------
alter table categorias      enable row level security;
alter table productos       enable row level security;
alter table producto_tallas enable row level security;
alter table tiendas         enable row level security;
alter table clientes        enable row level security;
alter table metodos_pago    enable row level security;
alter table pedidos         enable row level security;
alter table detalle_pedido  enable row level security;
alter table resenas         enable row level security;
alter table administradores enable row level security;

-- Catálogo: cualquiera puede verlo, nadie lo modifica desde la página
create policy "catalogo visible" on categorias      for select using (true);
create policy "catalogo visible" on productos       for select using (activo or es_admin());
create policy "catalogo visible" on producto_tallas for select using (true);
create policy "catalogo visible" on tiendas         for select using (true);

-- Cliente: cada uno ve y edita solo sus propios datos
create policy "mi perfil ver"     on clientes for select using (id = auth.uid() or es_admin());
create policy "mi perfil crear"   on clientes for insert with check (id = auth.uid());
create policy "mi perfil editar"  on clientes for update using (id = auth.uid()) with check (id = auth.uid());

create policy "mis tarjetas" on metodos_pago for all
  using (cliente_id = auth.uid()) with check (cliente_id = auth.uid());

-- Pedidos: se leen los propios (o todos si es administrador); se crean solo con crear_pedido()
create policy "mis pedidos"  on pedidos        for select using (cliente_id = auth.uid() or es_admin());
create policy "mis detalles" on detalle_pedido for select using (
  exists (select 1 from pedidos p where p.id = pedido_id and (p.cliente_id = auth.uid() or es_admin())));

-- Reseñas: todos las leen; cada cliente crea, edita o borra solo la suya
create policy "resenas visibles" on resenas for select using (true);
create policy "mi resena crear"  on resenas for insert with check (cliente_id = auth.uid());
create policy "mi resena editar" on resenas for update using (cliente_id = auth.uid()) with check (cliente_id = auth.uid());
create policy "mi resena borrar" on resenas for delete using (cliente_id = auth.uid());

create policy "solo admin" on administradores for select using (id = auth.uid());

-- La vista de calificaciones se consulta con los permisos de quien la usa
alter view vista_calificaciones set (security_invoker = true);

-- Los visitantes sin cuenta solo leen el catálogo y las reseñas
revoke all on clientes, metodos_pago, pedidos, detalle_pedido from anon;

-- El correo del cliente siempre es el de su cuenta (no se puede falsificar)
create or replace function copiar_correo_cuenta() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  select email into new.correo from auth.users where id = new.id;
  return new;
end $$;

create trigger trg_cliente_correo before insert or update on clientes
  for each row execute function copiar_correo_cuenta();

-- ---------- Comprobar si una cédula o un correo ya están registrados ----------
-- Devuelve solo verdadero/falso, sin exponer datos de otros clientes
create or replace function cedula_registrada(p_cedula text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from clientes where cedula = p_cedula);
$$;

create or replace function correo_registrado(p_correo text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from auth.users where lower(email) = lower(trim(p_correo)));
$$;

create sequence if not exists seq_numero_pedido start 1001;

-- ---------- Crear un pedido de forma segura ----------
-- Los precios y el total se calculan aquí con los datos de la base,
-- así nadie puede cambiar el precio desde el navegador.
-- p_items: [{"producto_id": 1, "talla": "42", "cantidad": 2}, ...]
create or replace function crear_pedido(p_tienda smallint, p_metodo_pago int, p_items jsonb)
returns table (pedido_id int, numero varchar, total numeric)
language plpgsql security definer set search_path = public as $$
declare
  v_cliente uuid := auth.uid();
  v_pedido int;
  v_numero varchar;
  v_subtotal numeric(10,2) := 0;
  v_iva numeric(10,2);
  it jsonb;
  v_prod productos%rowtype;
  v_cant int;
  v_talla varchar;
begin
  if v_cliente is null then raise exception 'Debes iniciar sesión para comprar'; end if;
  if not exists (select 1 from clientes where id = v_cliente) then
    raise exception 'Completa tu perfil antes de comprar'; end if;
  if not exists (select 1 from metodos_pago where id = p_metodo_pago and cliente_id = v_cliente) then
    raise exception 'El método de pago no es válido'; end if;
  if not exists (select 1 from tiendas where id = p_tienda) then
    raise exception 'La tienda de retiro no es válida'; end if;
  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'El carrito está vacío'; end if;
  if jsonb_array_length(p_items) > 30 then raise exception 'Demasiados productos en un solo pedido'; end if;

  -- Primero se valida todo y se descuenta el stock
  for it in select * from jsonb_array_elements(p_items) loop
    v_cant  := (it->>'cantidad')::int;
    v_talla := nullif(it->>'talla', '');
    select * into v_prod from productos where id = (it->>'producto_id')::int and activo;
    if not found then raise exception 'Un producto del carrito ya no está disponible'; end if;
    if v_cant is null or v_cant < 1 or v_cant > 10 then
      raise exception 'La cantidad de "%" debe estar entre 1 y 10', v_prod.nombre; end if;
    if v_prod.usa_talla and v_talla is null then
      raise exception 'Elige una talla para "%"', v_prod.nombre; end if;

    update producto_tallas set stock = stock - v_cant
     where producto_id = v_prod.id and talla = coalesce(v_talla, 'U') and stock >= v_cant;
    if not found then
      raise exception 'No hay stock suficiente de "%" (talla %)', v_prod.nombre, coalesce(v_talla, 'única'); end if;

    v_subtotal := v_subtotal + v_prod.precio * v_cant;
  end loop;

  v_iva := round(v_subtotal * 0.15, 2);
  v_numero := 'AX-' || to_char(now(), 'YYYY') || '-' || lpad(nextval('seq_numero_pedido')::text, 5, '0');

  insert into pedidos (numero, cliente_id, tienda_id, metodo_pago_id, subtotal, iva, total)
  values (v_numero, v_cliente, p_tienda, p_metodo_pago, v_subtotal, v_iva, v_subtotal + v_iva)
  returning id into v_pedido;

  insert into detalle_pedido (pedido_id, producto_id, talla, cantidad, precio_unitario)
  select v_pedido, p.id, nullif(x->>'talla', ''), sum((x->>'cantidad')::int), p.precio
    from jsonb_array_elements(p_items) x
    join productos p on p.id = (x->>'producto_id')::int
   group by p.id, nullif(x->>'talla', ''), p.precio;

  return query select v_pedido, v_numero, v_subtotal + v_iva;
end $$;

-- ---------- Cambiar el estado de un pedido (solo administradores) ----------
create or replace function cambiar_estado_pedido(p_pedido int, p_estado varchar)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not es_admin() then raise exception 'Solo un administrador puede cambiar el estado'; end if;
  if p_estado not in ('Recibido', 'Preparando', 'Listo', 'Retirado', 'Cancelado') then
    raise exception 'Estado no válido'; end if;
  update pedidos set estado = p_estado, actualizado_en = now() where id = p_pedido;
  if not found then raise exception 'El pedido no existe'; end if;
end $$;

-- Las funciones solo las pueden usar usuarios con sesión (y las de registro, todos)
revoke execute on function crear_pedido(smallint, int, jsonb) from public, anon;
grant  execute on function crear_pedido(smallint, int, jsonb) to authenticated;
revoke execute on function cambiar_estado_pedido(int, varchar) from public, anon;
grant  execute on function cambiar_estado_pedido(int, varchar) to authenticated;
grant  execute on function cedula_registrada(text), correo_registrado(text) to anon, authenticated;

-- ---------- Datos iniciales ----------
insert into categorias (nombre, slug) values
  ('Calzado deportivo', 'calzado'),
  ('Tecnología deportiva', 'tecnologia'),
  ('Equipo de entrenamiento', 'entrenamiento')
on conflict do nothing;

insert into tiendas (nombre, direccion, ciudad, horario) values
  ('ATHLETIX Quicentro', 'Av. Naciones Unidas y Av. 6 de Diciembre, C.C. Quicentro Shopping', 'Quito', 'Lunes a domingo, 10:00 a 21:00'),
  ('ATHLETIX El Recreo', 'Av. Pedro Vicente Maldonado S11-122, C.C. El Recreo', 'Quito', 'Lunes a domingo, 10:00 a 20:00'),
  ('ATHLETIX Mall del Sol', 'Av. Juan Tanca Marengo y Av. Joaquín Orrantia, C.C. Mall del Sol', 'Guayaquil', 'Lunes a domingo, 10:00 a 21:00')
on conflict do nothing;
