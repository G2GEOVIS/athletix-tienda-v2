/*==============================================================*/
/* ATHLETIX - Datos iniciales: categorías, tiendas y productos  */
/*==============================================================*/

insert into categoria (cat_codigo, cat_nombre) values
  (1, 'Calzado deportivo'),
  (2, 'Tecnología deportiva'),
  (3, 'Equipo de entrenamiento')
on conflict do nothing;

insert into tienda (tie_codigo, tie_nombre, tie_direccion, tie_ciudad, tie_horario) values
  (1, 'ATHLETIX Quicentro', 'Av. Naciones Unidas y Av. 6 de Diciembre, C.C. Quicentro Shopping', 'Quito', 'Lunes a domingo, 10:00 a 21:00'),
  (2, 'ATHLETIX El Recreo', 'Av. Pedro Vicente Maldonado S11-122, C.C. El Recreo', 'Quito', 'Lunes a domingo, 10:00 a 20:00'),
  (3, 'ATHLETIX Mall del Sol', 'Av. Juan Tanca Marengo y Av. Joaquín Orrantia, C.C. Mall del Sol', 'Guayaquil', 'Lunes a domingo, 10:00 a 21:00')
on conflict do nothing;

insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla) values
  ('vx', 1, 'Veloz Aero Llama', 'Zapatilla para correr de alto rendimiento para ritmos rápidos y competencias. Su espuma RebotePlus y la placa de propulsión de nylon convierten cada zancada en impulso, con una malla ultraligera que se ajusta al pie.', 'Hombre', 165.00, true),
  ('sf', 1, 'Flujo Tormenta Turquesa', 'Zapatilla para correr amortiguada para rodajes largos y entrenamiento diario. La espuma NúcleoNube de doble densidad absorbe el impacto en cada pisada y su suela ancha da estabilidad kilómetro tras kilómetro.', 'Hombre', 135.00, true),
  ('oc', 1, 'Ritmo Océano Coral', 'Zapatilla para correr ligera para mujer, ideal para entrenar a diario. Su malla transpirable mantiene el pie fresco y la mediasuela FlexiLigera acompaña el movimiento natural de la pisada.', 'Mujer', 119.00, true),
  ('lr', 1, 'Luz Carrera Lima', 'Zapatilla para correr con suela reactiva para mujer. La espuma ResorteLigero devuelve energía en cada zancada, perfecta para series, ritmo sostenido y cambios de ritmo.', 'Mujer', 129.00, true),
  ('tn', 1, 'Terrax Sendero Neón', 'Zapatilla de montaña para corredores que salen de la ciudad. Sus tacos de 5 mm muerden el barro y la tierra suelta, y la puntera reforzada protege el pie de piedras y raíces.', 'Unisex', 149.00, true),
  ('pt', 2, 'Pulso Ruta GPS Pro', 'Reloj deportivo con GPS pensado para corredores. Muestra en tiempo real tu ritmo, distancia y frecuencia cardiaca en una pantalla AMOLED grande y fácil de leer mientras corres.', 'Hombre', 229.00, false),
  ('sa', 2, 'Aire Sónico Óseo', 'Audífonos de conducción ósea para correr escuchando música sin tapar tus oídos. Te mantienen atento al tráfico y a tu entorno, con un arco flexible que no se mueve aunque aceleres.', 'Unisex', 89.00, false),
  ('cb', 2, 'Cardio Banda Élite', 'Banda cardiaca de pecho para entrenar por zonas con precisión. Envía tu frecuencia cardiaca en tiempo real al reloj, al teléfono o a la máquina del gimnasio.', 'Unisex', 79.00, false),
  ('sp', 2, 'Sensor de Zancada Pro', 'Sensor de zancada que se engancha en la zapatilla y analiza tu técnica de carrera. Registra cadencia, longitud de zancada y tiempo de contacto para que corras de forma más eficiente.', 'Unisex', 59.00, false),
  ('hb', 2, 'Cinturón Hidratación Pro', 'Cinturón de hidratación para corredores con dos botellas de 300 ml y un bolsillo para el celular. Se ajusta a la cintura sin rebotar, ideal para rodajes largos y montaña.', 'Unisex', 39.00, false),
  ('au', 2, 'Reloj Aura Rosa Pro', 'Reloj inteligente para mujer con caja color oro rosa y correa de silicona suave. Registra tus entrenamientos, pasos, frecuencia cardiaca y sueño en una pantalla AMOLED redonda de colores vivos.', 'Mujer', 189.00, false),
  ('at', 3, 'Kit Pista de Agilidad Pro', 'Kit completo de agilidad para preparación atlética. Combina escalera, vallas y conos para trabajar velocidad de pies, coordinación y cambios de dirección en cancha o en el parque.', 'Unisex', 49.00, false),
  ('pv', 3, 'Chaleco Fuerza Élite', 'Chaleco lastrado para sumar carga a tus entrenamientos de fuerza, carrera y saltos. Sus placas extraíbles permiten ajustar el peso según tu nivel y progresar poco a poco.', 'Unisex', 89.00, false),
  ('sc', 3, 'Paracaídas de Velocidad Pro', 'Paracaídas de resistencia para mejorar tu aceleración y velocidad. Al correr se abre detrás de ti y aumenta la resistencia de forma progresiva según tu velocidad.', 'Unisex', 35.00, false),
  ('fl', 3, 'Set Lazo de Fuerza', 'Set de 5 bandas de resistencia para fuerza, movilidad y calentamiento. Cada color tiene un nivel distinto y todas se guardan en su bolsa para llevarlas a donde entrenes.', 'Unisex', 25.00, false),
  ('cm', 3, 'Balón Medicinal Núcleo Pro', 'Balón medicinal para fuerza funcional y trabajo abdominal. Su superficie texturizada da un agarre firme en lanzamientos, giros y abdominales, incluso con las manos sudadas.', 'Unisex', 45.00, false)
on conflict do nothing;

insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values
  ('vx', '39', 15),
  ('vx', '40', 15),
  ('vx', '41', 15),
  ('vx', '42', 15),
  ('vx', '43', 15),
  ('vx', '44', 15),
  ('vx', '45', 15),
  ('sf', '39', 15),
  ('sf', '40', 15),
  ('sf', '41', 15),
  ('sf', '42', 15),
  ('sf', '43', 15),
  ('sf', '44', 15),
  ('sf', '45', 15),
  ('oc', '36', 15),
  ('oc', '36.5', 15),
  ('oc', '37', 15),
  ('oc', '37.5', 15),
  ('oc', '38', 15),
  ('oc', '38.5', 15),
  ('oc', '39', 15),
  ('oc', '40', 15),
  ('lr', '36', 15),
  ('lr', '36.5', 15),
  ('lr', '37', 15),
  ('lr', '37.5', 15),
  ('lr', '38', 15),
  ('lr', '38.5', 15),
  ('lr', '39', 15),
  ('lr', '40', 15),
  ('tn', '37', 15),
  ('tn', '38', 15),
  ('tn', '39', 15),
  ('tn', '40', 15),
  ('tn', '41', 15),
  ('tn', '42', 15),
  ('tn', '43', 15),
  ('tn', '44', 15),
  ('tn', '45', 15),
  ('pt', 'U', 30),
  ('sa', 'U', 30),
  ('cb', 'U', 30),
  ('sp', 'U', 30),
  ('hb', 'U', 30),
  ('au', 'U', 30),
  ('at', 'U', 30),
  ('pv', 'U', 30),
  ('sc', 'U', 30),
  ('fl', 'U', 30),
  ('cm', 'U', 30)
on conflict do nothing;

-- Hacerte administrador (cambia el correo, quita los guiones y ejecuta solo esta línea):
-- insert into administrador (adm_usuario) select id from auth.users where email = 'TU_CORREO@gmail.com';
