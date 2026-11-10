-- =====================================================================
-- ATHLETIX · Actualización 1: productos de la tienda y ajustes
-- Ejecutar en Supabase > SQL Editor DESPUÉS de esquema.sql y seguridad.sql
-- =====================================================================

-- Público: Hombre, Mujer o Unisex (el equipo de entrenamiento es para todos)
alter table productos drop constraint if exists productos_publico_check;
alter table productos add constraint productos_publico_check
  check (publico in ('Hombre', 'Mujer', 'Unisex'));

-- Nombre público del autor de la reseña ("Ana P."), sin exponer otros datos del cliente
alter table resenas add column if not exists autor varchar(40);

create or replace function poner_autor_resena() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  select split_part(trim(nombres), ' ', 1) || ' ' || left(trim(apellidos), 1) || '.'
    into new.autor from clientes where id = new.cliente_id;
  new.creado_en := coalesce(new.creado_en, now());
  return new;
end $$;

drop trigger if exists trg_resena_autor on resenas;
create trigger trg_resena_autor before insert or update on resenas
  for each row execute function poner_autor_resena();

-- Saber si el usuario actual es administrador (para mostrar el panel)
grant execute on function es_admin() to authenticated;

-- Pedidos con los datos que necesita el panel del administrador
create or replace function pedidos_admin()
returns table (id int, numero varchar, estado varchar, total numeric, creado_en timestamptz,
               cliente text, correo varchar, telefono char(10), cedula char(10),
               tienda varchar, horario varchar, productos text)
language plpgsql stable security definer set search_path = public as $$
begin
  if not es_admin() then raise exception 'Solo un administrador puede ver todos los pedidos'; end if;
  return query
  select p.id, p.numero, p.estado, p.total, p.creado_en,
         c.nombres || ' ' || c.apellidos, c.correo, c.telefono, c.cedula,
         t.nombre, t.horario,
         (select string_agg(d.cantidad || ' × ' || pr.nombre || coalesce(' (talla ' || d.talla || ')', ''), ', ')
            from detalle_pedido d join productos pr on pr.id = d.producto_id where d.pedido_id = p.id)
    from pedidos p join clientes c on c.id = p.cliente_id join tiendas t on t.id = p.tienda_id
   order by p.creado_en desc;
end $$;
revoke execute on function pedidos_admin() from public, anon;
grant  execute on function pedidos_admin() to authenticated;

-- ---------- Los 16 productos de la tienda ----------
insert into productos (categoria_id, publico, codigo, nombre, descripcion, precio, imagen_url, usa_talla) values
  (1, 'Hombre', 'vx', 'Veloz Aero Llama', 'Zapatilla para correr de alto rendimiento para ritmos rápidos y competencias. Su espuma RebotePlus y la placa de propulsión de nylon convierten cada zancada en impulso, con una malla ultraligera que se ajusta al pie.', 165.00, 'img/productos/vx-1.jpg', true),
  (1, 'Hombre', 'sf', 'Flujo Tormenta Turquesa', 'Zapatilla para correr amortiguada para rodajes largos y entrenamiento diario. La espuma NúcleoNube de doble densidad absorbe el impacto en cada pisada y su suela ancha da estabilidad kilómetro tras kilómetro.', 135.00, 'img/productos/sf-1.jpg', true),
  (1, 'Mujer', 'oc', 'Ritmo Océano Coral', 'Zapatilla para correr ligera para mujer, ideal para entrenar a diario. Su malla transpirable mantiene el pie fresco y la mediasuela FlexiLigera acompaña el movimiento natural de la pisada.', 119.00, 'img/productos/oc-1.jpg', true),
  (1, 'Mujer', 'lr', 'Luz Carrera Lima', 'Zapatilla para correr con suela reactiva para mujer. La espuma ResorteLigero devuelve energía en cada zancada, perfecta para series, ritmo sostenido y cambios de ritmo.', 129.00, 'img/productos/lr-1.jpg', true),
  (1, 'Unisex', 'tn', 'Terrax Sendero Neón', 'Zapatilla de montaña para corredores que salen de la ciudad. Sus tacos de 5 mm muerden el barro y la tierra suelta, y la puntera reforzada protege el pie de piedras y raíces.', 149.00, 'img/productos/tn-1.jpg', true),
  (2, 'Hombre', 'pt', 'Pulso Ruta GPS Pro', 'Reloj deportivo con GPS pensado para corredores. Muestra en tiempo real tu ritmo, distancia y frecuencia cardiaca en una pantalla AMOLED grande y fácil de leer mientras corres.', 229.00, 'img/productos/pt-1.jpg', false),
  (2, 'Unisex', 'sa', 'Aire Sónico Óseo', 'Audífonos de conducción ósea para correr escuchando música sin tapar tus oídos. Te mantienen atento al tráfico y a tu entorno, con un arco flexible que no se mueve aunque aceleres.', 89.00, 'img/productos/sa-1.jpg', false),
  (2, 'Unisex', 'cb', 'Cardio Banda Élite', 'Banda cardiaca de pecho para entrenar por zonas con precisión. Envía tu frecuencia cardiaca en tiempo real al reloj, al teléfono o a la máquina del gimnasio.', 79.00, 'img/productos/cb-1.jpg', false),
  (2, 'Unisex', 'sp', 'Sensor de Zancada Pro', 'Sensor de zancada que se engancha en la zapatilla y analiza tu técnica de carrera. Registra cadencia, longitud de zancada y tiempo de contacto para que corras de forma más eficiente.', 59.00, 'img/productos/sp-1.jpg', false),
  (2, 'Unisex', 'hb', 'Cinturón Hidratación Pro', 'Cinturón de hidratación para corredores con dos botellas de 300 ml y un bolsillo para el celular. Se ajusta a la cintura sin rebotar, ideal para rodajes largos y montaña.', 39.00, 'img/productos/hb-1.jpg', false),
  (2, 'Mujer', 'au', 'Reloj Aura Rosa Pro', 'Reloj inteligente para mujer con caja color oro rosa y correa de silicona suave. Registra tus entrenamientos, pasos, frecuencia cardiaca y sueño en una pantalla AMOLED redonda de colores vivos.', 189.00, 'img/productos/au-1.jpg', false),
  (3, 'Unisex', 'at', 'Kit Pista de Agilidad Pro', 'Kit completo de agilidad para preparación atlética. Combina escalera, vallas y conos para trabajar velocidad de pies, coordinación y cambios de dirección en cancha o en el parque.', 49.00, 'img/productos/at-1.jpg', false),
  (3, 'Unisex', 'pv', 'Chaleco Fuerza Élite', 'Chaleco lastrado para sumar carga a tus entrenamientos de fuerza, carrera y saltos. Sus placas extraíbles permiten ajustar el peso según tu nivel y progresar poco a poco.', 89.00, 'img/productos/pv-1.jpg', false),
  (3, 'Unisex', 'sc', 'Paracaídas de Velocidad Pro', 'Paracaídas de resistencia para mejorar tu aceleración y velocidad. Al correr se abre detrás de ti y aumenta la resistencia de forma progresiva según tu velocidad.', 35.00, 'img/productos/sc-1.jpg', false),
  (3, 'Unisex', 'fl', 'Set Lazo de Fuerza', 'Set de 5 bandas de resistencia para fuerza, movilidad y calentamiento. Cada color tiene un nivel distinto y todas se guardan en su bolsa para llevarlas a donde entrenes.', 25.00, 'img/productos/fl-1.jpg', false),
  (3, 'Unisex', 'cm', 'Balón Medicinal Núcleo Pro', 'Balón medicinal para fuerza funcional y trabajo abdominal. Su superficie texturizada da un agarre firme en lanzamientos, giros y abdominales, incluso con las manos sudadas.', 45.00, 'img/productos/cm-1.jpg', false)
on conflict (codigo) do nothing;

insert into producto_tallas (producto_id, talla, stock) values
  ((select id from productos where codigo = 'vx'), '39', 15),
  ((select id from productos where codigo = 'vx'), '40', 15),
  ((select id from productos where codigo = 'vx'), '41', 15),
  ((select id from productos where codigo = 'vx'), '42', 15),
  ((select id from productos where codigo = 'vx'), '43', 15),
  ((select id from productos where codigo = 'vx'), '44', 15),
  ((select id from productos where codigo = 'vx'), '45', 15),
  ((select id from productos where codigo = 'sf'), '39', 15),
  ((select id from productos where codigo = 'sf'), '40', 15),
  ((select id from productos where codigo = 'sf'), '41', 15),
  ((select id from productos where codigo = 'sf'), '42', 15),
  ((select id from productos where codigo = 'sf'), '43', 15),
  ((select id from productos where codigo = 'sf'), '44', 15),
  ((select id from productos where codigo = 'sf'), '45', 15),
  ((select id from productos where codigo = 'oc'), '36', 15),
  ((select id from productos where codigo = 'oc'), '36.5', 15),
  ((select id from productos where codigo = 'oc'), '37', 15),
  ((select id from productos where codigo = 'oc'), '37.5', 15),
  ((select id from productos where codigo = 'oc'), '38', 15),
  ((select id from productos where codigo = 'oc'), '38.5', 15),
  ((select id from productos where codigo = 'oc'), '39', 15),
  ((select id from productos where codigo = 'oc'), '40', 15),
  ((select id from productos where codigo = 'lr'), '36', 15),
  ((select id from productos where codigo = 'lr'), '36.5', 15),
  ((select id from productos where codigo = 'lr'), '37', 15),
  ((select id from productos where codigo = 'lr'), '37.5', 15),
  ((select id from productos where codigo = 'lr'), '38', 15),
  ((select id from productos where codigo = 'lr'), '38.5', 15),
  ((select id from productos where codigo = 'lr'), '39', 15),
  ((select id from productos where codigo = 'lr'), '40', 15),
  ((select id from productos where codigo = 'tn'), '37', 15),
  ((select id from productos where codigo = 'tn'), '38', 15),
  ((select id from productos where codigo = 'tn'), '39', 15),
  ((select id from productos where codigo = 'tn'), '40', 15),
  ((select id from productos where codigo = 'tn'), '41', 15),
  ((select id from productos where codigo = 'tn'), '42', 15),
  ((select id from productos where codigo = 'tn'), '43', 15),
  ((select id from productos where codigo = 'tn'), '44', 15),
  ((select id from productos where codigo = 'tn'), '45', 15),
  ((select id from productos where codigo = 'pt'), 'U', 30),
  ((select id from productos where codigo = 'sa'), 'U', 30),
  ((select id from productos where codigo = 'cb'), 'U', 30),
  ((select id from productos where codigo = 'sp'), 'U', 30),
  ((select id from productos where codigo = 'hb'), 'U', 30),
  ((select id from productos where codigo = 'au'), 'U', 30),
  ((select id from productos where codigo = 'at'), 'U', 30),
  ((select id from productos where codigo = 'pv'), 'U', 30),
  ((select id from productos where codigo = 'sc'), 'U', 30),
  ((select id from productos where codigo = 'fl'), 'U', 30),
  ((select id from productos where codigo = 'cm'), 'U', 30)
on conflict do nothing;

-- ---------- Hacerte administrador ----------
-- 1) Crea tu cuenta en la tienda y confirma tu correo.
-- 2) Cambia el correo de abajo por el tuyo, quita los dos guiones del inicio y ejecuta solo esa línea:
-- insert into administradores (id) select id from auth.users where email = 'TU_CORREO@gmail.com';
