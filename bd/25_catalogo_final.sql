/*==============================================================*/
/* ATHLETIX - 25 - Catálogo final (90 productos)                 */
/* - Nombre, descripción, características, ficha, precio y 3     */
/*   vistas de cada producto según su foto final.                */
/* - La categoría 2 pasa a llamarse «Tecnología e implementos».  */
/* - Solo el calzado es de Hombre o de Mujer.                    */
/* - Productos nuevos con su stock inicial.                      */
/* - Se puede ejecutar más de una vez sin duplicar registros.    */
/*==============================================================*/
begin;

update categoria set cat_nombre = 'Tecnología e implementos' where cat_codigo = 2;

-- Regla de negocio: solo el calzado es de Hombre o de Mujer; tecnología y entrenamiento son para todos
alter table producto drop constraint if exists ckc_prd_genero_categoria;
update producto set prd_genero = 'Unisex' where cat_codigo in (2, 3) and prd_genero <> 'Unisex';
alter table producto add constraint ckc_prd_genero_categoria check ((cat_codigo = 1) = (prd_genero <> 'Unisex'));

-- vx · ASICS Metaspeed Edge Paris
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('vx', 1, 'ASICS Metaspeed Edge Paris', 'Zapatilla de competencia para corredores de zancada corta y cadencia alta. La espuma FF Turbo+ y la placa de carbono devuelven energía en cada paso, y la parte superior roja con degradado naranja es ligera y ventilada.', 'Hombre', 239.90, true, true, null, 'Espuma FF Turbo+ de alto retorno
Placa de carbono de largo completo
Pensada para 10K, media maratón y maratón', 'Amortiguación: FF Turbo+
Placa: Carbono
Peso: ≈190 g
Desnivel (drop): 5 mm
Uso ideal: Competencia
Color: Rojo y naranja
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'vx' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('vx', 1, 'img/productos/vx-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('vx', 2, 'img/productos/vx-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('vx', 3, 'img/productos/vx-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- sf · ASICS Metaspeed Sky Paris
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('sf', 1, 'ASICS Metaspeed Sky Paris', 'Zapatilla de competencia para corredores que alargan la zancada al subir el ritmo. Combina la espuma FF Turbo+ con una placa de carbono para un despegue rápido, en un azul intenso con entresuela de colores.', 'Hombre', 249.50, true, true, null, 'Espuma FF Turbo+ con placa de carbono
Diseñada para zancadas largas
Parte superior de malla ultraligera', 'Amortiguación: FF Turbo+
Placa: Carbono
Peso: ≈185 g
Desnivel (drop): 5 mm
Uso ideal: Competencia
Color: Azul
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'sf' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sf', 1, 'img/productos/sf-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sf', 2, 'img/productos/sf-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sf', 3, 'img/productos/sf-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- tn · ASICS Novablast 4 Matcha
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tn', 1, 'ASICS Novablast 4 Matcha', 'Zapatilla de entrenamiento diario con mucho rebote. La espuma FF Blast+ es suave y reactiva, ideal para rodajes y cambios de ritmo, y su color verde matcha la hace fácil de combinar.', 'Hombre', 139.90, true, true, null, 'Espuma FF Blast+ suave y reactiva
Suela con buen agarre en asfalto
Cómoda para rodajes diarios', 'Amortiguación: FF Blast+
Placa: Sin placa
Peso: ≈255 g
Desnivel (drop): 8 mm
Uso ideal: Entrenamiento diario
Color: Verde matcha
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tn' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tn', 1, 'img/productos/tn-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tn', 2, 'img/productos/tn-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tn', 3, 'img/productos/tn-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh01 · Adidas Adizero Boston 12 Lucid Lemon
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh01', 1, 'Adidas Adizero Boston 12 Lucid Lemon', 'Zapatilla rápida para series, tempos y rodajes largos. La espuma Lightstrike Pro y las varillas EnergyRods dan una pisada firme y veloz, en un amarillo limón que se ve en cualquier ruta.', 'Hombre', 164.00, true, true, null, 'Espuma Lightstrike Pro en el antepié
Varillas EnergyRods para la transición
Versátil entre el entrenamiento y la carrera', 'Amortiguación: Lightstrike Pro y Lightstrike 2.0
Placa: Varillas EnergyRods
Peso: ≈265 g
Desnivel (drop): 6.5 mm
Uso ideal: Series y tempos
Color: Amarillo limón
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh01' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh01', 1, 'img/productos/zh01-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh01', 2, 'img/productos/zh01-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh01', 3, 'img/productos/zh01-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh02 · Adidas Adizero Adios Pro 4
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh02', 1, 'Adidas Adizero Adios Pro 4', 'Zapatilla de maratón con espuma Lightstrike Pro y varillas de carbono EnergyRods. Su suela en forma de balancín ayuda a mantener el ritmo en los últimos kilómetros. Color rojo coral.', 'Hombre', 245.00, true, true, null, 'Varillas de carbono EnergyRods
Espuma Lightstrike Pro de alto rendimiento
Geometría en balancín para ritmos sostenidos', 'Amortiguación: Lightstrike Pro
Placa: Varillas de carbono
Peso: ≈200 g
Desnivel (drop): 6 mm
Uso ideal: Maratón
Color: Rojo coral
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh02' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh02', 1, 'img/productos/zh02-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh02', 2, 'img/productos/zh02-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh02', 3, 'img/productos/zh02-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh03 · Brooks Ghost 16
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh03', 1, 'Brooks Ghost 16', 'Zapatilla neutra y cómoda para el día a día. La espuma DNA LOFT v3 amortigua sin perder estabilidad y la malla azul marino se ajusta bien al pie en distancias medias y largas.', 'Hombre', 139.50, true, true, null, 'Espuma DNA LOFT v3 suave
Transiciones fluidas del talón a la punta
Ideal para empezar a correr', 'Amortiguación: DNA LOFT v3
Placa: Sin placa
Peso: ≈269 g
Desnivel (drop): 12 mm
Uso ideal: Entrenamiento diario
Color: Azul marino
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh03' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh03', 1, 'img/productos/zh03-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh03', 2, 'img/productos/zh03-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh03', 3, 'img/productos/zh03-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh04 · HOKA Mach 6
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh04', 1, 'HOKA Mach 6', 'Zapatilla ligera y reactiva para entrenamientos de ritmo. La espuma de EVA supercrítica rebota en cada pisada y su forma de balancín facilita la transición. Colores coral y amarillo.', 'Hombre', 148.75, true, true, null, 'Espuma de EVA supercrítica
Forma de balancín para rodar mejor
Ligera para ritmos rápidos', 'Amortiguación: EVA supercrítica
Placa: Sin placa
Peso: ≈232 g
Desnivel (drop): 5 mm
Uso ideal: Ritmo y tempos
Color: Coral y amarillo
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh04' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh04', 1, 'img/productos/zh04-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh04', 2, 'img/productos/zh04-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh04', 3, 'img/productos/zh04-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh05 · Mizuno Wave Rebellion Pro 2
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh05', 1, 'Mizuno Wave Rebellion Pro 2', 'Zapatilla de competencia con espuma Mizuno Enerzy Lite+ y placa de carbono. Su talón recortado y su suela curva empujan hacia adelante. Amarillo neón con entresuela azul.', 'Hombre', 229.00, true, true, null, 'Espuma Enerzy Lite+ de alto retorno
Placa de carbono
Talón recortado que impulsa la zancada', 'Amortiguación: Enerzy Lite+
Placa: Carbono
Peso: ≈225 g
Desnivel (drop): 8 mm
Uso ideal: Competencia
Color: Amarillo neón y azul
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh05' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh05', 1, 'img/productos/zh05-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh05', 2, 'img/productos/zh05-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh05', 3, 'img/productos/zh05-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh06 · New Balance FuelCell SuperComp Elite v4
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh06', 1, 'New Balance FuelCell SuperComp Elite v4', 'Zapatilla de maratón con espuma FuelCell de alto rebote y placa de carbono Energy Arc. Blanca con detalles azul y lima, muy ligera para competir a ritmo alto.', 'Hombre', 259.90, true, true, null, 'Espuma FuelCell de alto rebote
Placa de carbono Energy Arc
Parte superior ligera y ventilada', 'Amortiguación: FuelCell
Placa: Carbono
Peso: ≈210 g
Desnivel (drop): 4 mm
Uso ideal: Maratón
Color: Blanco, azul y lima
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh06' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh06', 1, 'img/productos/zh06-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh06', 2, 'img/productos/zh06-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh06', 3, 'img/productos/zh06-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh07 · Nike Alphafly 3
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh07', 1, 'Nike Alphafly 3', 'Zapatilla de maratón con espuma ZoomX, unidades Air Zoom en el antepié y placa de carbono Flyplate. Blanca con naranja, pensada para los ritmos más exigentes.', 'Hombre', 289.00, true, true, null, 'Espuma ZoomX con unidades Air Zoom
Placa de carbono Flyplate
Malla Atomknit ligera y transpirable', 'Amortiguación: ZoomX y Air Zoom
Placa: Carbono Flyplate
Peso: ≈218 g
Desnivel (drop): 8 mm
Uso ideal: Maratón
Color: Blanco y naranja
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh07' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh07', 1, 'img/productos/zh07-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh07', 2, 'img/productos/zh07-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh07', 3, 'img/productos/zh07-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh08 · Nike Vaporfly 3
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh08', 1, 'Nike Vaporfly 3', 'Zapatilla de carrera rápida con espuma ZoomX y placa de carbono Flyplate. Muy ligera y reactiva para 5K, 10K y maratón, en verde neón.', 'Hombre', 259.00, true, true, null, 'Espuma ZoomX muy ligera
Placa de carbono Flyplate
Malla Flyknit transpirable', 'Amortiguación: ZoomX
Placa: Carbono Flyplate
Peso: ≈196 g
Desnivel (drop): 8 mm
Uso ideal: Competencia
Color: Verde neón
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh08' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh08', 1, 'img/productos/zh08-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh08', 2, 'img/productos/zh08-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh08', 3, 'img/productos/zh08-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh09 · On Cloudboom Echo 3
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh09', 1, 'On Cloudboom Echo 3', 'Zapatilla de maratón con espuma Helion HF y la placa Speedboard de carbono. Blanca con detalles negros, combina amortiguación alta y un despegue rápido.', 'Hombre', 274.90, true, true, null, 'Espuma Helion HF de alto rendimiento
Speedboard de carbono
Suela CloudTec para aterrizajes suaves', 'Amortiguación: Helion HF
Placa: Speedboard de carbono
Peso: ≈220 g
Desnivel (drop): 9 mm
Uso ideal: Maratón
Color: Blanco y negro
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh09' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh09', 1, 'img/productos/zh09-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh09', 2, 'img/productos/zh09-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh09', 3, 'img/productos/zh09-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh10 · Puma Deviate Nitro Elite 3
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh10', 1, 'Puma Deviate Nitro Elite 3', 'Zapatilla de competencia con espuma Nitro Elite y placa de carbono PWRPLATE. Su degradado de amarillo neón a azul intenso la hace inconfundible en la línea de salida.', 'Hombre', 234.50, true, true, null, 'Espuma Nitro Elite de alto retorno
Placa de carbono PWRPLATE
Suela PUMAGRIP con buen agarre', 'Amortiguación: Nitro Elite
Placa: Carbono PWRPLATE
Peso: ≈215 g
Desnivel (drop): 8 mm
Uso ideal: Competencia
Color: Amarillo neón y azul
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh10' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh10', 1, 'img/productos/zh10-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh10', 2, 'img/productos/zh10-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh10', 3, 'img/productos/zh10-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh11 · Saucony Endorphin Speed 4
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh11', 1, 'Saucony Endorphin Speed 4', 'Zapatilla versátil para entrenamientos rápidos y carreras. La espuma PWRRUN PB y la placa de nylon dan rebote sin perder control. Turquesa con detalles naranjas.', 'Hombre', 169.90, true, true, null, 'Espuma PWRRUN PB ligera
Placa de nylon flexible
Geometría SPEEDROLL que impulsa la pisada', 'Amortiguación: PWRRUN PB
Placa: Nylon
Peso: ≈231 g
Desnivel (drop): 8 mm
Uso ideal: Series y carreras
Color: Turquesa y naranja
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh11' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh11', 1, 'img/productos/zh11-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh11', 2, 'img/productos/zh11-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh11', 3, 'img/productos/zh11-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh12 · Under Armour Flow Velociti Elite
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh12', 1, 'Under Armour Flow Velociti Elite', 'Zapatilla de competencia sin suela de goma: la espuma UA Flow agarra directo en el asfalto y la placa de carbono da impulso. Blanca con degradado fucsia.', 'Hombre', 219.00, true, true, null, 'Espuma UA Flow sin suela de goma
Placa de carbono
Muy ligera para ritmos de carrera', 'Amortiguación: UA Flow
Placa: Carbono
Peso: ≈210 g
Desnivel (drop): 8 mm
Uso ideal: Competencia
Color: Blanco y fucsia
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh12' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh12', 1, 'img/productos/zh12-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh12', 2, 'img/productos/zh12-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh12', 3, 'img/productos/zh12-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zh13 · Adidas Adizero Boston 12 Amarillo Solar
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh13', 1, 'Adidas Adizero Boston 12 Amarillo Solar', 'Zapatilla rápida para series y rodajes largos a buen ritmo. La espuma Lightstrike Pro y las varillas EnergyRods 2.0 dan una pisada firme y veloz, en amarillo solar con talón negro.', 'Hombre', 158.00, true, true, 'Nuevo', 'Espuma Lightstrike Pro en el antepié
Varillas EnergyRods 2.0
Versátil entre el entrenamiento y la carrera', 'Amortiguación: Lightstrike Pro y Lightstrike 2.0
Placa: Varillas EnergyRods 2.0
Peso: ≈265 g
Desnivel (drop): 6.5 mm
Uso ideal: Series y tempos
Color: Amarillo solar y negro
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh13' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh13', 1, 'img/productos/zh13-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh13', 2, 'img/productos/zh13-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh13', 3, 'img/productos/zh13-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh13', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh13', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh13', '41', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh13', '42', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh13', '43', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh13', '44', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh13', '45', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zh14 · Salomon Trail Contagrip Verde Oliva
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh14', 1, 'Salomon Trail Contagrip Verde Oliva', 'Zapatilla de trail para senderos de tierra y piedra. La suela Contagrip con tacos marcados agarra en terreno suelto y la puntera reforzada protege en las bajadas. Color verde oliva.', 'Hombre', 132.40, true, true, 'Nuevo', 'Suela Contagrip con tacos de agarre
Puntera reforzada
Estable en terreno irregular', 'Amortiguación: Energy Foam
Placa: Sin placa
Peso: ≈300 g
Desnivel (drop): 8 mm
Uso ideal: Trail y montaña
Color: Verde oliva
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh14' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh14', 1, 'img/productos/zh14-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh14', 2, 'img/productos/zh14-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh14', 3, 'img/productos/zh14-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh14', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh14', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh14', '41', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh14', '42', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh14', '43', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh14', '44', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh14', '45', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zh15 · Mizuno Terrax Sendero Neón
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh15', 1, 'Mizuno Terrax Sendero Neón', 'Zapatilla de trail con suela de tacos verde neón para rutas de montaña. Su espuma Enerzy amortigua las bajadas y la malla gris carbón resiste el roce del camino.', 'Hombre', 127.80, true, true, 'Nuevo', 'Suela de tacos para tierra y barro
Espuma Enerzy protectora
Malla resistente al roce', 'Amortiguación: Mizuno Enerzy
Placa: Sin placa
Peso: ≈305 g
Desnivel (drop): 10 mm
Uso ideal: Trail y montaña
Color: Gris carbón y verde neón
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh15' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh15', 1, 'img/productos/zh15-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh15', 2, 'img/productos/zh15-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh15', 3, 'img/productos/zh15-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh15', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh15', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh15', '41', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh15', '42', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh15', '43', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh15', '44', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh15', '45', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zh16 · Nike Pegasus 41 Gris
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh16', 1, 'Nike Pegasus 41 Gris', 'Zapatilla versátil para entrenar todos los días. La espuma ReactX y las unidades Air Zoom dan una pisada suave y con rebote, en un gris fácil de combinar.', 'Hombre', 139.00, true, true, 'Nuevo', 'Espuma ReactX con Air Zoom
Malla transpirable
Ideal para el día a día', 'Amortiguación: ReactX y Air Zoom
Placa: Sin placa
Peso: ≈285 g
Desnivel (drop): 10 mm
Uso ideal: Entrenamiento diario
Color: Gris
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh16' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh16', 1, 'img/productos/zh16-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh16', 2, 'img/productos/zh16-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh16', 3, 'img/productos/zh16-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh16', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh16', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh16', '41', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh16', '42', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh16', '43', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh16', '44', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh16', '45', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zh17 · Mizuno Wave Rider 28
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh17', 1, 'Mizuno Wave Rider 28', 'Zapatilla de running cómoda y estable gracias a la placa Wave, que reparte el impacto y da una transición fluida. Azul rey con detalles blancos.', 'Hombre', 134.60, true, true, 'Nuevo', 'Placa Wave para mayor estabilidad
Espuma Mizuno Enerzy
Malla ligera y fresca', 'Amortiguación: Mizuno Enerzy
Placa: Placa Wave
Peso: ≈290 g
Desnivel (drop): 12 mm
Uso ideal: Entrenamiento diario
Color: Azul rey
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh17' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh17', 1, 'img/productos/zh17-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh17', 2, 'img/productos/zh17-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh17', 3, 'img/productos/zh17-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh17', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh17', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh17', '41', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh17', '42', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh17', '43', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh17', '44', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh17', '45', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zh18 · Under Armour Infinite Elite Azul
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zh18', 1, 'Under Armour Infinite Elite Azul', 'Zapatilla cómoda para rodajes largos con espuma UA Flow, ligera y con buen agarre. Azul petróleo con logo plateado.', 'Hombre', 149.25, true, true, 'Nuevo', 'Espuma UA Flow ligera
Buen agarre en asfalto
Cómoda para distancias largas', 'Amortiguación: UA Flow
Placa: Sin placa
Peso: ≈280 g
Desnivel (drop): 8 mm
Uso ideal: Rodajes largos
Color: Azul petróleo
Tallas: 39 – 45 (EU)')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zh18' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh18', 1, 'img/productos/zh18-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh18', 2, 'img/productos/zh18-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zh18', 3, 'img/productos/zh18-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh18', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh18', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh18', '41', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh18', '42', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh18', '43', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh18', '44', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zh18', '45', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- oc · Brooks Glycerin 21
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('oc', 1, 'Brooks Glycerin 21', 'Zapatilla de máxima amortiguación para rodajes largos y recuperación. La espuma DNA LOFT v3 es muy suave y la malla morada se ajusta con comodidad al pie.', 'Mujer', 164.90, true, true, null, 'Espuma DNA LOFT v3 de máxima suavidad
Ajuste cómodo y acolchado
Ideal para kilómetros largos', 'Amortiguación: DNA LOFT v3
Placa: Sin placa
Peso: ≈255 g
Desnivel (drop): 10 mm
Uso ideal: Rodajes largos
Color: Morado
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'oc' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('oc', 1, 'img/productos/oc-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('oc', 2, 'img/productos/oc-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('oc', 3, 'img/productos/oc-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- lr · Craft CTM Ultra Carbon 2
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('lr', 1, 'Craft CTM Ultra Carbon 2', 'Zapatilla con placa de carbono y espuma CTM Ultra para rodajes largos a buen ritmo. Blanca con un diseño de pinceladas azules en la entresuela.', 'Mujer', 199.00, true, true, null, 'Espuma CTM Ultra de alto volumen
Placa de carbono
Estable en distancias largas', 'Amortiguación: CTM Ultra
Placa: Carbono
Peso: ≈240 g
Desnivel (drop): 8 mm
Uso ideal: Rodajes largos rápidos
Color: Blanco y azul
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'lr' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('lr', 1, 'img/productos/lr-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('lr', 2, 'img/productos/lr-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('lr', 3, 'img/productos/lr-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm01 · Diadora Atomo V7000
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm01', 1, 'Diadora Atomo V7000', 'Zapatilla de entrenamiento con diseño italiano. Su espuma amortigua bien en rodajes diarios y la parte superior blanca con detalles azul marino y rojo da un estilo clásico.', 'Mujer', 149.00, true, true, null, 'Espuma de amortiguación equilibrada
Diseño italiano con detalles tricolor
Cómoda para entrenar a diario', 'Amortiguación: Espuma Diadora
Placa: Sin placa
Peso: ≈250 g
Desnivel (drop): 8 mm
Uso ideal: Entrenamiento diario
Color: Blanco, azul marino y rojo
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm01' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm01', 1, 'img/productos/zm01-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm01', 2, 'img/productos/zm01-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm01', 3, 'img/productos/zm01-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm02 · Karhu Fusion 4.0
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm02', 1, 'Karhu Fusion 4.0', 'Zapatilla finlandesa con tecnología Fulcrum, que guía la pisada del talón a la punta. Combina tonos crema, verde y naranja con una entresuela cómoda para el día a día.', 'Mujer', 138.50, true, true, null, 'Tecnología Fulcrum que guía la pisada
Espuma ligera y cómoda
Estilo clásico para entrenar o pasear', 'Amortiguación: Espuma Aero
Placa: Sin placa
Peso: ≈240 g
Desnivel (drop): 8 mm
Uso ideal: Entrenamiento diario
Color: Crema, verde y naranja
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm02' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm02', 1, 'img/productos/zm02-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm02', 2, 'img/productos/zm02-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm02', 3, 'img/productos/zm02-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm03 · Mizuno Wave Rebellion Flash 2
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm03', 1, 'Mizuno Wave Rebellion Flash 2', 'Zapatilla rápida para entrenamientos de ritmo con espuma Enerzy XP y placa de fibra de vidrio. Su degradado de morado a fucsia la hace muy llamativa.', 'Mujer', 154.90, true, true, null, 'Espuma Enerzy XP de alto rebote
Placa de fibra de vidrio
Talón recortado para una transición rápida', 'Amortiguación: Enerzy XP
Placa: Fibra de vidrio
Peso: ≈220 g
Desnivel (drop): 8 mm
Uso ideal: Ritmo y tempos
Color: Morado y fucsia
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm03' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm03', 1, 'img/productos/zm03-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm03', 2, 'img/productos/zm03-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm03', 3, 'img/productos/zm03-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm04 · Newton Distance 12
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm04', 1, 'Newton Distance 12', 'Zapatilla ligera con los tacos Action/Reaction en el antepié, que favorecen una pisada de media planta. Azul celeste con detalles amarillo neón.', 'Mujer', 149.50, true, true, null, 'Tacos Action/Reaction en el antepié
Drop bajo para una pisada natural
Muy ligera', 'Amortiguación: Action/Reaction
Placa: Sin placa
Peso: ≈205 g
Desnivel (drop): 3 mm
Uso ideal: Ritmo y técnica
Color: Celeste y amarillo neón
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm04' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm04', 1, 'img/productos/zm04-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm04', 2, 'img/productos/zm04-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm04', 3, 'img/productos/zm04-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm05 · On Cloudstrike Edición Especial
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm05', 1, 'On Cloudstrike Edición Especial', 'Zapatilla de edición especial con la suela CloudTec, cuyas cápsulas se comprimen al aterrizar y se vuelven firmes al despegar. Blanca con fucsia.', 'Mujer', 159.00, true, true, null, 'Suela CloudTec con cápsulas
Aterrizajes suaves y despegues firmes
Diseño de edición especial', 'Amortiguación: CloudTec
Placa: Sin placa
Peso: ≈250 g
Desnivel (drop): 9 mm
Uso ideal: Entrenamiento diario
Color: Blanco y fucsia
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm05' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm05', 1, 'img/productos/zm05-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm05', 2, 'img/productos/zm05-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm05', 3, 'img/productos/zm05-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm06 · Salomon Aero Glide 2
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm06', 1, 'Salomon Aero Glide 2', 'Zapatilla de asfalto con mucha amortiguación y forma de balancín. La espuma Energy Foam es suave y ligera, en celeste con detalles coral.', 'Mujer', 144.90, true, true, null, 'Espuma Energy Foam suave
Forma de balancín para rodar mejor
Ligera para su nivel de amortiguación', 'Amortiguación: Energy Foam
Placa: Sin placa
Peso: ≈215 g
Desnivel (drop): 10 mm
Uso ideal: Rodajes largos
Color: Celeste y coral
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm06' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm06', 1, 'img/productos/zm06-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm06', 2, 'img/productos/zm06-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm06', 3, 'img/productos/zm06-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm07 · Salomon S/LAB Phantasm 2
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm07', 1, 'Salomon S/LAB Phantasm 2', 'Zapatilla de competencia de la línea S/LAB con espuma Energy Surge y placa de carbono. Roja con talón blanco, pensada para batir marcas.', 'Mujer', 239.90, true, true, null, 'Espuma Energy Surge
Placa de carbono
Línea de competencia S/LAB', 'Amortiguación: Energy Surge
Placa: Carbono
Peso: ≈205 g
Desnivel (drop): 9 mm
Uso ideal: Competencia
Color: Rojo
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm07' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm07', 1, 'img/productos/zm07-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm07', 2, 'img/productos/zm07-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm07', 3, 'img/productos/zm07-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm08 · Skechers GOrun Speed Elite Hyper
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm08', 1, 'Skechers GOrun Speed Elite Hyper', 'Zapatilla de velocidad con espuma Hyper Burst Pro, muy ligera y reactiva. Su color coral neón la hace visible en cualquier entrenamiento.', 'Mujer', 179.50, true, true, null, 'Espuma Hyper Burst Pro
Muy ligera y reactiva
Ideal para series y carreras cortas', 'Amortiguación: Hyper Burst Pro
Placa: Placa de carbono
Peso: ≈190 g
Desnivel (drop): 8 mm
Uso ideal: Series y carreras
Color: Coral neón
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm08' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm08', 1, 'img/productos/zm08-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm08', 2, 'img/productos/zm08-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm08', 3, 'img/productos/zm08-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm09 · Topo Athletic Cyclone 2
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm09', 1, 'Topo Athletic Cyclone 2', 'Zapatilla ligera y rápida con espuma de PEBA y puntera ancha que deja mover los dedos. Verde menta con detalles coral.', 'Mujer', 139.00, true, true, null, 'Espuma de PEBA muy ligera
Puntera ancha y cómoda
Drop bajo para una pisada natural', 'Amortiguación: PEBA
Placa: Sin placa
Peso: ≈190 g
Desnivel (drop): 5 mm
Uso ideal: Ritmo y tempos
Color: Verde menta y coral
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm09' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm09', 1, 'img/productos/zm09-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm09', 2, 'img/productos/zm09-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm09', 3, 'img/productos/zm09-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm10 · Under Armour Infinite Elite Gris y Rosa
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm10', 1, 'Under Armour Infinite Elite Gris y Rosa', 'Zapatilla cómoda para rodajes largos con espuma UA HOVR+ que devuelve energía. Gris oscuro con entresuela rosa intenso.', 'Mujer', 152.75, true, true, null, 'Espuma UA HOVR+ con retorno de energía
Suela con buen agarre
Cómoda para distancias largas', 'Amortiguación: UA HOVR+
Placa: Sin placa
Peso: ≈230 g
Desnivel (drop): 8 mm
Uso ideal: Rodajes largos
Color: Gris y rosa
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm10' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm10', 1, 'img/productos/zm10-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm10', 2, 'img/productos/zm10-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm10', 3, 'img/productos/zm10-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm11 · Under Armour Velociti Wind 3
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm11', 1, 'Under Armour Velociti Wind 3', 'Zapatilla ligera y versátil para entrenar a diario y subir el ritmo. Amarillo limón con detalles grises que se ven en cualquier ruta.', 'Mujer', 129.90, true, true, null, 'Espuma ligera y reactiva
Malla transpirable
Versátil para entrenar a diario', 'Amortiguación: Espuma UA Flow
Placa: Sin placa
Peso: ≈215 g
Desnivel (drop): 8 mm
Uso ideal: Entrenamiento diario
Color: Amarillo limón
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm11' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm11', 1, 'img/productos/zm11-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm11', 2, 'img/productos/zm11-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm11', 3, 'img/productos/zm11-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm12 · Topo Athletic Atmos
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm12', 1, 'Topo Athletic Atmos', 'Zapatilla de máxima amortiguación con espuma ZipFoam y puntera ancha. Su color coral y la entresuela crema le dan un estilo cálido.', 'Mujer', 158.00, true, true, null, 'Espuma ZipFoam de máxima amortiguación
Puntera ancha y cómoda
Ideal para rodajes largos', 'Amortiguación: ZipFoam
Placa: Sin placa
Peso: ≈250 g
Desnivel (drop): 5 mm
Uso ideal: Rodajes largos
Color: Coral y crema
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm12' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm12', 1, 'img/productos/zm12-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm12', 2, 'img/productos/zm12-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm12', 3, 'img/productos/zm12-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm13 · Altra Escalante 4
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm13', 1, 'Altra Escalante 4', 'Zapatilla de drop cero y puntera ancha para una pisada natural. La espuma Altra EGO es flexible y la malla rosa es suave al tacto.', 'Mujer', 136.40, true, true, null, 'Drop cero para una pisada natural
Puntera ancha FootShape
Espuma Altra EGO flexible', 'Amortiguación: Altra EGO
Placa: Sin placa
Peso: ≈210 g
Desnivel (drop): 0 mm
Uso ideal: Entrenamiento diario
Color: Rosa
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm13' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm13', 1, 'img/productos/zm13-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm13', 2, 'img/productos/zm13-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm13', 3, 'img/productos/zm13-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;

-- zm14 · Nike Pegasus 41 Lila
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm14', 1, 'Nike Pegasus 41 Lila', 'Zapatilla versátil para entrenar todos los días. La espuma ReactX y las unidades Air Zoom dan una pisada suave y con rebote, en un lila suave.', 'Mujer', 137.50, true, true, 'Nuevo', 'Espuma ReactX con Air Zoom
Malla transpirable
Ideal para el día a día', 'Amortiguación: ReactX y Air Zoom
Placa: Sin placa
Peso: ≈240 g
Desnivel (drop): 10 mm
Uso ideal: Entrenamiento diario
Color: Lila
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm14' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm14', 1, 'img/productos/zm14-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm14', 2, 'img/productos/zm14-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm14', 3, 'img/productos/zm14-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm14', '36', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm14', '36.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm14', '37', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm14', '37.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm14', '38', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm14', '38.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm14', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm14', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zm15 · New Balance Fresh Foam X 1080 v14
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm15', 1, 'New Balance Fresh Foam X 1080 v14', 'Zapatilla de máxima comodidad. La espuma Fresh Foam X es muy suave y la malla rosa se adapta al pie en rodajes largos y en el día a día.', 'Mujer', 164.75, true, true, 'Nuevo', 'Espuma Fresh Foam X muy suave
Malla de ingeniería que se adapta al pie
Ideal para rodajes largos', 'Amortiguación: Fresh Foam X
Placa: Sin placa
Peso: ≈250 g
Desnivel (drop): 6 mm
Uso ideal: Rodajes largos
Color: Rosa
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm15' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm15', 1, 'img/productos/zm15-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm15', 2, 'img/productos/zm15-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm15', 3, 'img/productos/zm15-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm15', '36', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm15', '36.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm15', '37', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm15', '37.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm15', '38', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm15', '38.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm15', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm15', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zm16 · ASICS Gel-Kayano 31
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm16', 1, 'ASICS Gel-Kayano 31', 'Zapatilla de estabilidad para rodajes largos. La espuma FF Blast+ y el gel en el talón amortiguan cada pisada, y su soporte guía el pie. Rosa con detalles plateados.', 'Mujer', 159.90, true, true, 'Nuevo', 'Espuma FF Blast+ con gel en el talón
Soporte para pisada pronadora
Ideal para rodajes largos', 'Amortiguación: FF Blast+ y PureGEL
Placa: Sin placa
Peso: ≈260 g
Desnivel (drop): 10 mm
Uso ideal: Estabilidad
Color: Rosa y plateado
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm16' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm16', 1, 'img/productos/zm16-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm16', 2, 'img/productos/zm16-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm16', 3, 'img/productos/zm16-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm16', '36', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm16', '36.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm16', '37', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm16', '37.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm16', '38', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm16', '38.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm16', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm16', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zm17 · Saucony Ride 17
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm17', 1, 'Saucony Ride 17', 'Zapatilla equilibrada para todo tipo de entrenamiento. La espuma PWRRUN+ es cómoda y duradera, en un coral intenso.', 'Mujer', 131.80, true, true, 'Nuevo', 'Espuma PWRRUN+ cómoda
Malla transpirable
Versátil para entrenar a diario', 'Amortiguación: PWRRUN+
Placa: Sin placa
Peso: ≈240 g
Desnivel (drop): 8 mm
Uso ideal: Entrenamiento diario
Color: Coral
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm17' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm17', 1, 'img/productos/zm17-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm17', 2, 'img/productos/zm17-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm17', 3, 'img/productos/zm17-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm17', '36', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm17', '36.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm17', '37', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm17', '37.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm17', '38', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm17', '38.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm17', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm17', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- zm18 · Adidas Adizero SL 2
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('zm18', 1, 'Adidas Adizero SL 2', 'Zapatilla ligera para ganar velocidad. Su espuma Lightstrike Pro en el antepié da respuesta y la malla verde menta es fresca y liviana.', 'Mujer', 122.40, true, true, 'Nuevo', 'Espuma Lightstrike Pro en el antepié
Muy ligera
Para mejorar tu ritmo', 'Amortiguación: Lightstrike Pro y Lightstrike 2.0
Placa: Sin placa
Peso: ≈225 g
Desnivel (drop): 6.5 mm
Uso ideal: Velocidad
Color: Verde menta
Tallas: 36 – 40 (EU), con medias tallas')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'zm18' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm18', 1, 'img/productos/zm18-1.jpg', 'par completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm18', 2, 'img/productos/zm18-2.jpg', 'zapatilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('zm18', 3, 'img/productos/zm18-3.jpg', 'zapatilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm18', '36', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm18', '36.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm18', '37', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm18', '37.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm18', '38', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm18', '38.5', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm18', '39', 12) on conflict (prd_codigo, pta_talla) do nothing;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('zm18', '40', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- pt · Reloj GPS de running negro
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('pt', 2, 'Reloj GPS de running negro', 'Reloj deportivo con GPS para correr con datos en tiempo real: ritmo, frecuencia cardiaca, distancia y tiempo en una pantalla clara y fácil de leer bajo el sol.', 'Unisex', 249.00, false, true, null, 'GPS para medir ritmo y distancia
Pulso en la muñeca
Pantalla de alto contraste', 'Pantalla: AMOLED de 1.4"
Batería: Hasta 14 días (30 h con GPS)
GPS: Doble frecuencia
Mide: Ritmo, distancia y frecuencia cardiaca
Resistencia al agua: 5 ATM
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'pt' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('pt', 1, 'img/productos/pt-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('pt', 2, 'img/productos/pt-2.jpg', 'pantalla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('pt', 3, 'img/productos/pt-3.jpg', 'correa y botones') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('pt', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- sa · Audífonos de conducción ósea Shokz
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('sa', 2, 'Audífonos de conducción ósea Shokz', 'Audífonos que transmiten el sonido por los pómulos y dejan los oídos libres, para escuchar música sin perder de vista el tráfico. Color gris glaciar, resistentes al sudor.', 'Unisex', 179.90, false, true, null, 'Oídos libres para oír el entorno
Resistentes al sudor y la lluvia
Arco de titanio flexible', 'Tipo: Conducción ósea
Batería: Hasta 10 h
Conexión: Bluetooth 5.3
Resistencia: IP55
Peso: ≈29 g
Color: Gris glaciar')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'sa' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sa', 1, 'img/productos/sa-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sa', 2, 'img/productos/sa-2.jpg', 'auricular') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sa', 3, 'img/productos/sa-3.jpg', 'arco y botones') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('sa', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- cb · Banda cardiaca Polar H10
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('cb', 2, 'Banda cardiaca Polar H10', 'Banda de pecho que mide la frecuencia cardiaca con la precisión de un electrocardiograma. Se conecta al reloj, al celular y a las máquinas del gimnasio.', 'Unisex', 89.90, false, true, null, 'Medición del pulso muy precisa
Conexión Bluetooth y ANT+
Correa cómoda y lavable', 'Mide: Frecuencia cardiaca (tipo ECG)
Batería: Hasta 400 h (pila CR2025)
Conexión: Bluetooth y ANT+
Resistencia: Al agua, 30 m
Ajuste: Correa de 65 a 93 cm
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'cb' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('cb', 1, 'img/productos/cb-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('cb', 2, 'img/productos/cb-2.jpg', 'sensor') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('cb', 3, 'img/productos/cb-3.jpg', 'correa') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('cb', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- sp · Sensor de potencia Stryd
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('sp', 2, 'Sensor de potencia Stryd', 'Sensor que se engancha a los cordones y mide la potencia de carrera en vatios, además de cadencia, tiempo de contacto y oscilación. Ayuda a controlar el esfuerzo en cuestas y con viento.', 'Unisex', 219.00, false, true, null, 'Potencia de carrera en vatios
Se engancha a los cordones
Compatible con relojes deportivos', 'Mide: Potencia, cadencia y tiempo de contacto
Batería: Hasta 20 h, recargable
Conexión: Bluetooth y ANT+
Montaje: Clip en los cordones
Peso: ≈9 g
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'sp' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sp', 1, 'img/productos/sp-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sp', 2, 'img/productos/sp-2.jpg', 'sensor') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sp', 3, 'img/productos/sp-3.jpg', 'sensor en la zapatilla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('sp', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th02 · Audífonos deportivos Under Armour
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th02', 2, 'Audífonos deportivos Under Armour', 'Audífonos inalámbricos con ganchos de oreja que no se mueven al correr. Resistentes al sudor y con estuche de carga para varias sesiones.', 'Unisex', 129.50, false, true, null, 'Ganchos de oreja firmes
Resistentes al sudor
Estuche con carga extra', 'Tipo: Inalámbricos con gancho
Batería: Hasta 8 h (+24 h con el estuche)
Conexión: Bluetooth 5.3
Resistencia: IPX7
Incluye: Estuche de carga
Color: Negro y rojo')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th02' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th02', 1, 'img/productos/th02-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th02', 2, 'img/productos/th02-2.jpg', 'estuche de carga') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th02', 3, 'img/productos/th02-3.jpg', 'auricular') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th02', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th03 · Cinturón de hidratación negro y lima
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th03', 2, 'Cinturón de hidratación negro y lima', 'Cinturón para correr con dos botellas, bolsillo para el celular y detalles reflectivos en verde lima. Se ajusta a la cintura sin rebotar.', 'Unisex', 32.90, false, true, null, 'Dos botellas incluidas
Bolsillo para celular y llaves
Detalles reflectivos', 'Capacidad: 2 botellas de 300 ml
Bolsillo: Celular de hasta 6.7"
Ajuste: Cintura de 65 a 110 cm
Visibilidad: Detalles reflectivos
Material: Lycra transpirable
Color: Negro y lima')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th03' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th03', 1, 'img/productos/th03-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th03', 2, 'img/productos/th03-2.jpg', 'botella') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th03', 3, 'img/productos/th03-3.jpg', 'bolsillo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th03', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th05 · Gafas deportivas inteligentes con pantalla
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th05', 2, 'Gafas deportivas inteligentes con pantalla', 'Gafas para correr que muestran en el lente el ritmo, el pulso y la distancia, sin tener que mirar el reloj. Lente espejado que protege del sol.', 'Unisex', 279.00, false, true, null, 'Datos en el lente sin mirar el reloj
Lente espejado con protección UV
Montura ligera y firme', 'Pantalla: Proyección en el lente
Muestra: Ritmo, pulso y distancia
Batería: Hasta 10 h
Conexión: Bluetooth
Lente: Espejado con filtro UV400
Color: Negro y rojo')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th05' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th05', 1, 'img/productos/th05-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th05', 2, 'img/productos/th05-2.jpg', 'pantalla en el lente') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th05', 3, 'img/productos/th05-3.jpg', 'montura') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th05', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th07 · Anillo inteligente Oura plateado
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th07', 2, 'Anillo inteligente Oura plateado', 'Anillo que mide el sueño, la frecuencia cardiaca y la recuperación sin necesidad de llevar un reloj. De titanio plateado, ligero y resistente al agua.', 'Unisex', 349.00, false, true, null, 'Mide sueño y recuperación
Titanio ligero y resistente
Batería de varios días', 'Mide: Sueño, pulso, temperatura y actividad
Batería: Hasta 7 días
Material: Titanio
Resistencia al agua: Hasta 100 m
Conexión: Bluetooth
Color: Plateado')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th07' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th07', 1, 'img/productos/th07-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th07', 2, 'img/productos/th07-2.jpg', 'sensores') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th07', 3, 'img/productos/th07-3.jpg', 'exterior') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th07', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th08 · Plantillas inteligentes NURVV Run
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th08', 2, 'Plantillas inteligentes NURVV Run', 'Plantillas con sensores que analizan tu pisada: cadencia, zona de apoyo y equilibrio entre ambos pies. Te ayudan a mejorar la técnica y prevenir lesiones.', 'Unisex', 249.00, false, true, null, 'Sensores en toda la plantilla
Analiza la pisada y la cadencia
Consejos para mejorar la técnica', 'Mide: Pisada, cadencia y equilibrio
Sensores: 32 por plantilla
Batería: Hasta 5 h, recargable
Conexión: Bluetooth
Tallas: Recortables
Color: Negro y azul')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th08' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th08', 1, 'img/productos/th08-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th08', 2, 'img/productos/th08-2.jpg', 'plantilla con sensor') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th08', 3, 'img/productos/th08-3.jpg', 'base de la plantilla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th08', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th09 · Cámara GoPro HERO12 Black
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th09', 2, 'Cámara GoPro HERO12 Black', 'Cámara de acción resistente al agua que graba en 5.3K con estabilización. Ideal para grabar tus carreras, entrenamientos y aventuras.', 'Unisex', 389.00, false, true, null, 'Video 5.3K estabilizado
Resistente al agua
Incluye soporte de montaje', 'Video: Hasta 5.3K a 60 fps
Foto: 27 MP
Estabilización: HyperSmooth 6.0
Resistencia al agua: Hasta 10 m
Pantallas: Frontal y trasera
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th09' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th09', 1, 'img/productos/th09-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th09', 2, 'img/productos/th09-2.jpg', 'pantalla frontal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th09', 3, 'img/productos/th09-3.jpg', 'lente y soporte') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th09', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th10 · Localizador GPS Garmin inReach Mini 2
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th10', 2, 'Localizador GPS Garmin inReach Mini 2', 'Comunicador satelital de bolsillo con botón SOS, mensajes y ubicación en tiempo real. Pensado para rutas de montaña y lugares sin señal de celular.', 'Unisex', 399.50, false, true, null, 'Botón SOS por satélite
Mensajes sin señal de celular
Compacto, con mosquetón', 'Función: Ubicación, mensajes y SOS
Red: Satélites Iridium
Batería: Hasta 14 días
Resistencia: IPX7
Peso: ≈100 g
Color: Negro y naranja')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th10' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th10', 1, 'img/productos/th10-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th10', 2, 'img/productos/th10-2.jpg', 'pantalla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th10', 3, 'img/productos/th10-3.jpg', 'mosquetón') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th10', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th11 · Botella térmica inteligente negra
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th11', 2, 'Botella térmica inteligente negra', 'Botella de acero inoxidable que mantiene el agua fría y te recuerda beber con una luz LED azul en la tapa. Con asa para llevarla al gimnasio.', 'Unisex', 54.75, false, true, null, 'Recordatorio de hidratación con luz
Mantiene el agua fría por horas
Acero inoxidable', 'Capacidad: 600 ml
Material: Acero inoxidable
Temperatura: Frío hasta 24 h
Batería: Hasta 30 días, recargable
Tapa: Con luz LED y asa
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th11' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th11', 1, 'img/productos/th11-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th11', 2, 'img/productos/th11-2.jpg', 'tapa con luz') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th11', 3, 'img/productos/th11-3.jpg', 'cuerpo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th11', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th12 · Pistola de masaje negra
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th12', 2, 'Pistola de masaje negra', 'Pistola de masaje con cuatro cabezales y varias velocidades para relajar los músculos después de entrenar. Silenciosa y con batería recargable.', 'Unisex', 119.00, false, true, null, '4 cabezales intercambiables
Varias velocidades
Motor silencioso', 'Cabezales: 4 incluidos
Velocidades: 5 niveles
Batería: Hasta 6 h, recargable
Ruido: Menos de 45 dB
Peso: ≈700 g
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th12' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th12', 1, 'img/productos/th12-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th12', 2, 'img/productos/th12-2.jpg', 'cabezal y panel de control') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th12', 3, 'img/productos/th12-3.jpg', 'cabezales') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th12', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th14 · Linterna frontal LED negro y neón
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th14', 2, 'Linterna frontal LED negro y neón', 'Linterna de cabeza con tres luces LED para correr de noche o en la madrugada. Cinta ajustable con detalles reflectivos en verde neón.', 'Unisex', 34.50, false, true, null, 'Tres luces LED
Batería recargable por USB
Cinta ajustable y reflectiva', 'Luz: Hasta 400 lúmenes
Modos: Alto, medio, bajo y parpadeo
Batería: Hasta 8 h, recargable
Resistencia: IPX4
Peso: ≈80 g
Color: Negro y neón')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th14' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th14', 1, 'img/productos/th14-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th14', 2, 'img/productos/th14-2.jpg', 'luces LED') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th14', 3, 'img/productos/th14-3.jpg', 'cinta') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th14', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- th15 · Rodillera inteligente con sensor
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('th15', 2, 'Rodillera inteligente con sensor', 'Rodillera con sensor de movimiento que registra la flexión de la rodilla al correr y saltar. Da soporte con bisagras laterales y se ajusta con velcro.', 'Unisex', 164.00, false, true, null, 'Sensor de movimiento de la rodilla
Bisagras laterales de soporte
Ajuste con velcro', 'Mide: Flexión y carga de la rodilla
Soporte: Bisagras laterales
Batería: Hasta 12 h, recargable
Conexión: Bluetooth
Talla: Ajustable
Color: Negro y azul')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'th15' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th15', 1, 'img/productos/th15-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th15', 2, 'img/productos/th15-2.jpg', 'sensor') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('th15', 3, 'img/productos/th15-3.jpg', 'bisagra y ajuste') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('th15', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- hb · Cinturón de hidratación morado
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('hb', 2, 'Cinturón de hidratación morado', 'Cinturón para correr con dos botellas, bolsillo con cierre y malla transpirable. Morado con fucsia y detalles reflectivos.', 'Unisex', 31.50, false, true, null, 'Dos botellas incluidas
Bolsillo con cierre
Detalles reflectivos', 'Capacidad: 2 botellas de 300 ml
Bolsillo: Celular de hasta 6.7"
Ajuste: Cintura de 60 a 105 cm
Visibilidad: Detalles reflectivos
Material: Lycra y malla
Color: Morado y fucsia')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'hb' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('hb', 1, 'img/productos/hb-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('hb', 2, 'img/productos/hb-2.jpg', 'botella') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('hb', 3, 'img/productos/hb-3.jpg', 'bolsillo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('hb', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- au · Reloj inteligente rosa de fitness
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('au', 2, 'Reloj inteligente rosa de fitness', 'Reloj inteligente con pantalla redonda que mide pasos, pulso, calorías y sueño. Correa de silicona rosa con caja en oro rosa.', 'Unisex', 189.00, false, true, null, 'Mide pasos, pulso y sueño
Pantalla AMOLED redonda
Correa de silicona cómoda', 'Pantalla: AMOLED redonda de 1.3"
Batería: Hasta 10 días
Mide: Pulso, pasos, calorías y sueño
Resistencia al agua: 5 ATM
Correa: Silicona, de 14 a 20 cm
Color: Rosa y oro rosa')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'au' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('au', 1, 'img/productos/au-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('au', 2, 'img/productos/au-2.jpg', 'pantalla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('au', 3, 'img/productos/au-3.jpg', 'correa') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('au', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm01 · Reloj COROS Pace 3
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm01', 2, 'Reloj COROS Pace 3', 'Reloj deportivo muy ligero con GPS de doble frecuencia y batería de larga duración. Correa de silicona gris perforada, cómoda para entrenar a diario.', 'Unisex', 229.00, false, true, null, 'GPS de doble frecuencia
Batería de larga duración
Muy ligero en la muñeca', 'Pantalla: Táctil de 1.2"
Batería: Hasta 24 días (38 h con GPS)
GPS: Doble frecuencia
Mide: Ritmo, distancia, pulso y sueño
Peso: ≈30 g
Color: Blanco y gris')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm01' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm01', 1, 'img/productos/tm01-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm01', 2, 'img/productos/tm01-2.jpg', 'pantalla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm01', 3, 'img/productos/tm01-3.jpg', 'correa') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm01', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm02 · Secador de zapatillas con luz UV
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm02', 2, 'Secador de zapatillas con luz UV', 'Secador eléctrico que se coloca dentro de las zapatillas para secarlas con calor suave y eliminar olores con luz UV. Con control de tiempo.', 'Unisex', 46.80, false, true, null, 'Calor suave que no daña el calzado
Luz UV contra olores
Control con temporizador', 'Función: Secado y luz UV
Temporizador: 1, 2 o 3 horas
Temperatura: ≈50 °C
Alimentación: Enchufe de 110 V
Incluye: 2 secadores y control
Color: Blanco y gris')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm02' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm02', 1, 'img/productos/tm02-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm02', 2, 'img/productos/tm02-2.jpg', 'control') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm02', 3, 'img/productos/tm02-3.jpg', 'secadores') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm02', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm03 · Gafas deportivas rosas con lente espejado
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm03', 2, 'Gafas deportivas rosas con lente espejado', 'Gafas para correr con lente espejado rosa que protege del sol y del viento. Montura ligera que no se mueve al correr.', 'Unisex', 68.50, false, true, null, 'Lente espejado con filtro UV400
Montura ligera
No se mueven al correr', 'Lente: Espejado con filtro UV400
Montura: Ligera y flexible
Peso: ≈28 g
Ventilación: Ranuras en el lente
Incluye: Funda de tela
Color: Rosa')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm03' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm03', 1, 'img/productos/tm03-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm03', 2, 'img/productos/tm03-2.jpg', 'lente') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm03', 3, 'img/productos/tm03-3.jpg', 'patilla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm03', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm07 · Anillo inteligente oro rosa
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm07', 2, 'Anillo inteligente oro rosa', 'Anillo que mide el sueño, la frecuencia cardiaca y la recuperación después de entrenar. Acabado en oro rosa, ligero y resistente al agua.', 'Unisex', 299.00, false, true, null, 'Mide sueño y recuperación
Acabado en oro rosa
Batería de varios días', 'Mide: Sueño, pulso, temperatura y actividad
Batería: Hasta 7 días
Material: Titanio con acabado oro rosa
Resistencia al agua: Hasta 100 m
Conexión: Bluetooth
Color: Oro rosa')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm07' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm07', 1, 'img/productos/tm07-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm07', 2, 'img/productos/tm07-2.jpg', 'sensores') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm07', 3, 'img/productos/tm07-3.jpg', 'exterior') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm07', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm08 · Plantillas inteligentes rosas
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm08', 2, 'Plantillas inteligentes rosas', 'Plantillas con sensores que registran la pisada, la cadencia y el equilibrio entre ambos pies. Superficie gris acolchada con bordes rosas.', 'Unisex', 189.90, false, true, null, 'Sensores de pisada
Superficie acolchada
Se conectan al celular', 'Mide: Pisada, cadencia y equilibrio
Batería: Hasta 6 h, recargable
Conexión: Bluetooth
Material: Espuma acolchada
Tallas: Recortables
Color: Gris y rosa')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm08' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm08', 1, 'img/productos/tm08-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm08', 2, 'img/productos/tm08-2.jpg', 'plantilla izquierda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm08', 3, 'img/productos/tm08-3.jpg', 'plantilla derecha') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm08', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm09 · Alarma personal de seguridad rosa
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm09', 2, 'Alarma personal de seguridad rosa', 'Alarma de bolsillo con sirena fuerte y luz LED para correr con más tranquilidad. Se lleva en las llaves o en la mochila con su mosquetón.', 'Unisex', 24.75, false, true, null, 'Sirena muy fuerte
Luz LED para la noche
Mosquetón para llaves o mochila', 'Sirena: 130 dB
Luz: LED blanca
Batería: Recargable por USB
Activación: Botón o correa
Peso: ≈40 g
Color: Rosa')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm09' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm09', 1, 'img/productos/tm09-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm09', 2, 'img/productos/tm09-2.jpg', 'botón y luz') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm09', 3, 'img/productos/tm09-3.jpg', 'mosquetón') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm09', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm10 · Botella inteligente rosa
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm10', 2, 'Botella inteligente rosa', 'Botella de acero inoxidable con indicador luminoso que te recuerda beber agua durante el día. Tapa con asa y acabado rosa mate.', 'Unisex', 49.60, false, true, null, 'Recordatorio luminoso para beber
Mantiene el agua fría
Acabado rosa mate', 'Capacidad: 500 ml
Material: Acero inoxidable
Temperatura: Frío hasta 24 h
Batería: Hasta 30 días, recargable
Tapa: Con indicador y asa
Color: Rosa')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm10' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm10', 1, 'img/productos/tm10-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm10', 2, 'img/productos/tm10-2.jpg', 'tapa') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm10', 3, 'img/productos/tm10-3.jpg', 'indicador luminoso') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm10', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm11 · Monitor portátil de calidad del aire
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm11', 2, 'Monitor portátil de calidad del aire', 'Medidor de bolsillo que muestra la calidad del aire antes de salir a correr: partículas PM2.5 y PM10, dióxido de carbono y compuestos orgánicos.', 'Unisex', 139.00, false, true, null, 'Mide PM2.5, PM10 y CO₂
Pantalla a color fácil de leer
Con correa para llevarlo', 'Mide: PM2.5, PM10, CO₂ y VOC
Pantalla: A color de 2.4"
Batería: Hasta 12 h, recargable
Conexión: Bluetooth
Peso: ≈120 g
Color: Negro y naranja')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm11' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm11', 1, 'img/productos/tm11-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm11', 2, 'img/productos/tm11-2.jpg', 'pantalla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm11', 3, 'img/productos/tm11-3.jpg', 'correa') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm11', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm12 · Top deportivo rosa con sensor cardiaco
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm12', 2, 'Top deportivo rosa con sensor cardiaco', 'Top deportivo de soporte medio con sensor de frecuencia cardiaca integrado, sin necesidad de banda de pecho. Tela transpirable de secado rápido.', 'Unisex', 74.90, false, true, null, 'Sensor cardiaco integrado
Soporte medio
Tela de secado rápido', 'Mide: Frecuencia cardiaca
Soporte: Medio
Conexión: Bluetooth
Tela: Transpirable de secado rápido
Tallas: S, M y L
Color: Rosa')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm12' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm12', 1, 'img/productos/tm12-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm12', 2, 'img/productos/tm12-2.jpg', 'sensor') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm12', 3, 'img/productos/tm12-3.jpg', 'espalda y tirantes') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm12', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm13 · Chaleco LED de alta visibilidad
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm13', 2, 'Chaleco LED de alta visibilidad', 'Chaleco ligero con luces LED y bandas reflectivas para que te vean al correr de noche. Se ajusta con correas y se carga por USB.', 'Unisex', 39.80, false, true, null, 'Luces LED recargables
Bandas reflectivas
Ajuste con correas', 'Luz: LED con 3 modos
Batería: Hasta 8 h, recargable
Visibilidad: Hasta 500 m
Ajuste: Correas regulables
Peso: ≈150 g
Color: Negro y neón')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm13' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm13', 1, 'img/productos/tm13-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm13', 2, 'img/productos/tm13-2.jpg', 'botón de encendido') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm13', 3, 'img/productos/tm13-3.jpg', 'correas') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm13', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm14 · Secador de zapatillas con luz LED morada
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm14', 2, 'Secador de zapatillas con luz LED morada', 'Secador eléctrico con luz LED morada que seca y desinfecta las zapatillas después de entrenar. Control con botón de encendido y temporizador.', 'Unisex', 52.30, false, true, null, 'Seca y elimina olores
Luz LED desinfectante
Control con temporizador', 'Función: Secado y desinfección
Temporizador: 1, 2 o 3 horas
Temperatura: ≈50 °C
Alimentación: Enchufe de 110 V
Incluye: 2 secadores y control
Color: Negro y rosa')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm14' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm14', 1, 'img/productos/tm14-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm14', 2, 'img/productos/tm14-2.jpg', 'secadores y control') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm14', 3, 'img/productos/tm14-3.jpg', 'dentro de las zapatillas') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm14', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- tm15 · Chaleco de hidratación coral
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('tm15', 2, 'Chaleco de hidratación coral', 'Chaleco ligero para correr con dos botellas blandas al frente y bolsillos para geles, celular y cortavientos. Se ajusta al pecho y no rebota en rutas largas.', 'Unisex', 89.60, false, true, 'Nuevo', 'Dos botellas blandas incluidas
Bolsillos al frente y en la espalda
Ajuste al pecho que no rebota', 'Capacidad: 2 botellas de 500 ml y 5 L de carga
Bolsillos: 6, con cierre y elásticos
Ajuste: Correas al pecho
Material: Malla transpirable
Peso: ≈250 g
Color: Coral')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'tm15' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm15', 1, 'img/productos/tm15-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm15', 2, 'img/productos/tm15-2.jpg', 'botella') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('tm15', 3, 'img/productos/tm15-3.jpg', 'bolsillos y correas') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('tm15', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- at · Kit de agilidad ProSet
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('at', 3, 'Kit de agilidad ProSet', 'Kit completo para entrenar velocidad, coordinación y cambios de dirección: escalera de agilidad, picas de slalom, conos y bolsa para llevarlo todo.', 'Unisex', 48.90, false, true, null, 'Escalera de agilidad de 12 peldaños
8 picas y 10 conos
Bolsa de transporte', 'Escalera: 6 m · 12 peldaños
Picas: 8 de 1.6 m
Conos: 10 unidades
Incluye: Bolsa ProSet
Uso ideal: Velocidad y coordinación
Color: Amarillo, naranja y negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'at' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('at', 1, 'img/productos/at-1.jpg', 'kit completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('at', 2, 'img/productos/at-2.jpg', 'escalera') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('at', 3, 'img/productos/at-3.jpg', 'picas, conos y bolsa') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('at', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- pv · Chaleco de peso ajustable Fuerza Élite
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('pv', 3, 'Chaleco de peso ajustable Fuerza Élite', 'Chaleco con bolsillos para placas de peso que agrega carga a tus carreras, saltos y ejercicios de fuerza. Se ajusta con correas y hebillas y no rebota.', 'Unisex', 96.40, false, true, null, 'Peso ajustable con placas
Correas y hebillas de ajuste
Acolchado en los hombros', 'Peso: Ajustable hasta 20 kg
Talla: Única, ajustable
Cierre: Hebillas y velcro
Material: Nylon reforzado
Uso ideal: Fuerza, carrera y saltos
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'pv' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('pv', 1, 'img/productos/pv-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('pv', 2, 'img/productos/pv-2.jpg', 'bolsillos de peso') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('pv', 3, 'img/productos/pv-3.jpg', 'hombros y hebillas') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('pv', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- sc · Paracaídas de Velocidad Pro
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('sc', 3, 'Paracaídas de Velocidad Pro', 'Paracaídas de resistencia que se abre al correr y obliga a empujar con más fuerza. Mejora la aceleración y la potencia en carreras cortas. Incluye arnés ajustable.', 'Unisex', 29.75, false, true, null, 'Resistencia que aumenta con la velocidad
Arnés ajustable de liberación rápida
Plegable y liviano', 'Diámetro: ≈140 cm
Arnés: Ajustable con liberación rápida
Resistencia: Aumenta con tu velocidad
Material: Nylon resistente
Uso ideal: Carreras cortas y arranques
Color: Azul y negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'sc' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sc', 1, 'img/productos/sc-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sc', 2, 'img/productos/sc-2.jpg', 'paracaídas') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('sc', 3, 'img/productos/sc-3.jpg', 'arnés') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('sc', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- fl · Kit de tubos de resistencia con manijas
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('fl', 3, 'Kit de tubos de resistencia con manijas', 'Set de cinco tubos elásticos de distinta resistencia con manijas, tobilleras y anclaje de puerta. Permite entrenar todo el cuerpo en casa o en el parque.', 'Unisex', 36.80, false, true, null, '5 tubos de distinta resistencia
Manijas, tobilleras y anclaje de puerta
Bolsa para guardarlo', 'Contenido: 5 tubos, 2 manijas, 2 tobilleras y anclaje
Resistencia: De 5 a 30 kg cada tubo
Largo: ≈120 cm por tubo
Incluye: Bolsa de transporte
Uso ideal: Fuerza y tonificación
Color: Amarillo, verde, rojo, azul y negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'fl' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('fl', 1, 'img/productos/fl-1.jpg', 'kit completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('fl', 2, 'img/productos/fl-2.jpg', 'tubos y manijas') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('fl', 3, 'img/productos/fl-3.jpg', 'bolsa y accesorios') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('fl', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- cm · Balón Medicinal Núcleo Pro 10 kg
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('cm', 3, 'Balón Medicinal Núcleo Pro 10 kg', 'Balón medicinal de 10 kg con superficie texturizada que no se resbala. Ideal para lanzamientos, golpes al suelo y ejercicios de fuerza funcional.', 'Unisex', 58.30, false, true, null, '10 kg de peso
Superficie texturizada antideslizante
Resistente a golpes y caídas', 'Peso: 10 kg
Diámetro: ≈28 cm
Superficie: Texturizada antideslizante
Material: Caucho reforzado
Uso ideal: Lanzamientos y fuerza funcional
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'cm' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('cm', 1, 'img/productos/cm-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('cm', 2, 'img/productos/cm-2.jpg', 'logo y peso') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('cm', 3, 'img/productos/cm-3.jpg', 'textura') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('cm', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en07 · Cajón pliométrico de espuma 3 en 1
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en07', 3, 'Cajón pliométrico de espuma 3 en 1', 'Cajón de saltos de espuma firme con tres alturas según el lado en que lo pongas. Su cubierta acolchada protege las espinillas y no se resbala.', 'Unisex', 152.00, false, true, null, '3 alturas en un solo cajón
Espuma firme y acolchada
Cubierta antideslizante con asa', 'Alturas: 50, 60 y 76 cm (20, 24 y 30 pulgadas)
Material: Espuma de alta densidad
Carga máxima: 150 kg
Superficie: Antideslizante
Uso ideal: Saltos y potencia
Color: Gris')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en07' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en07', 1, 'img/productos/en07-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en07', 2, 'img/productos/en07-2.jpg', 'lados de 20 y 24 pulgadas') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en07', 3, 'img/productos/en07-3.jpg', 'lado de 30 pulgadas') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en07', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en08 · Tacos de salida para atletismo
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en08', 3, 'Tacos de salida para atletismo', 'Tacos de salida de aluminio con pedales ajustables en distancia e inclinación. Dan una base firme para salidas rápidas en pista.', 'Unisex', 184.50, false, true, null, 'Pedales ajustables
Riel de aluminio graduado
Clavos para pista sintética', 'Material: Aluminio
Ajuste: Distancia e inclinación
Pedales: Antideslizantes
Peso: ≈6 kg
Uso ideal: Salidas de velocidad
Color: Plateado y azul')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en08' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en08', 1, 'img/productos/en08-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en08', 2, 'img/productos/en08-2.jpg', 'pedales') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en08', 3, 'img/productos/en08-3.jpg', 'riel graduado') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en08', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en09 · Sistema de Cronometraje Pro
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en09', 3, 'Sistema de Cronometraje Pro', 'Sistema de fotoceldas inalámbricas para medir tus tiempos en 30, 60 y 100 metros con precisión de milésimas. Viene en un maletín con trípodes y pantalla.', 'Unisex', 342.80, false, true, null, 'Precisión de milésimas
Fotoceldas inalámbricas con trípodes
Maletín de transporte', 'Precisión: 1/1000 s
Incluye: Fotoceldas, trípodes, pantalla y señales
Alcance: Hasta 100 m
Batería: Hasta 10 h
Uso ideal: Medir velocidad
Color: Negro y plateado')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en09' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en09', 1, 'img/productos/en09-1.jpg', 'kit completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en09', 2, 'img/productos/en09-2.jpg', 'maletín y pantalla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en09', 3, 'img/productos/en09-3.jpg', 'fotoceldas y señales') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en09', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en10 · Cinturón de resistencia para sprints
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en10', 3, 'Cinturón de resistencia para sprints', 'Cinturón acolchado con cuerda elástica y mosquetón para entrenar arranques y sprints con resistencia, solo o con un compañero.', 'Unisex', 39.90, false, true, null, 'Cinturón acolchado ajustable
Cuerda elástica con mosquetón
Para entrenar solo o en pareja', 'Cinturón: Ajustable de 65 a 120 cm
Cuerda: Elástica de 3 m
Resistencia: Media y alta
Material: Nylon y látex
Uso ideal: Aceleraciones y sprints
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en10' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en10', 1, 'img/productos/en10-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en10', 2, 'img/productos/en10-2.jpg', 'cinturón') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en10', 3, 'img/productos/en10-3.jpg', 'mosquetón') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en10', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en11 · Cuerda de saltar Velocidad Pro
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en11', 3, 'Cuerda de saltar Velocidad Pro', 'Cuerda de saltar de cable de acero con mangos de aluminio y rodamientos que giran muy rápido. Ideal para dobles saltos y cardio intenso.', 'Unisex', 19.40, false, true, null, 'Cable de acero recubierto
Mangos de aluminio con rodamientos
Largo ajustable', 'Cable: Acero recubierto
Largo: Hasta 3 m, ajustable
Mangos: Aluminio
Peso: ≈180 g
Uso ideal: Cardio y coordinación
Color: Rojo y plateado')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en11' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en11', 1, 'img/productos/en11-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en11', 2, 'img/productos/en11-2.jpg', 'mangos') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en11', 3, 'img/productos/en11-3.jpg', 'cable') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en11', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en12 · Rodillo de liberación miofascial Núcleo Pro
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en12', 3, 'Rodillo de liberación miofascial Núcleo Pro', 'Rodillo de espuma con relieves para masajear los músculos después de entrenar. Ayuda a recuperar las piernas y mejorar la movilidad.', 'Unisex', 31.60, false, true, null, 'Relieves de distinta firmeza
Núcleo rígido que no se deforma
Liviano y fácil de llevar', 'Medida: 33 × 14 cm
Material: EVA sobre núcleo rígido
Carga máxima: 150 kg
Peso: ≈700 g
Uso ideal: Automasaje y movilidad
Color: Gris')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en12' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en12', 1, 'img/productos/en12-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en12', 2, 'img/productos/en12-2.jpg', 'relieves') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en12', 3, 'img/productos/en12-3.jpg', 'logo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en12', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en13 · Tabla de equilibrio Estabilidad Pro
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en13', 3, 'Tabla de equilibrio Estabilidad Pro', 'Tabla redonda de madera con superficie antideslizante para trabajar equilibrio, tobillos y rodillas. Útil para prevenir lesiones y para rehabilitación.', 'Unisex', 46.70, false, true, null, 'Madera resistente
Superficie antideslizante
Inclinación en todas las direcciones', 'Diámetro: 40 cm
Material: Madera con superficie de goma
Inclinación: Hasta 15°
Carga máxima: 150 kg
Uso ideal: Equilibrio y tobillos
Color: Madera y negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en13' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en13', 1, 'img/productos/en13-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en13', 2, 'img/productos/en13-2.jpg', 'superficie') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en13', 3, 'img/productos/en13-3.jpg', 'base de madera') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en13', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en14 · Kit de resistencia para tobillos
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en14', 3, 'Kit de resistencia para tobillos', 'Set de cuatro tubos elásticos con dos tobilleras acolchadas y mosquetones para trabajar piernas y glúteos. Incluye bolsa de malla.', 'Unisex', 28.90, false, true, null, '4 tubos de distinta resistencia
2 tobilleras acolchadas
Bolsa de malla y mosquetones', 'Contenido: 4 tubos, 2 tobilleras y mosquetones
Resistencia: Ligera, media, fuerte y extra fuerte
Ajuste: Velcro
Material: Neopreno y látex
Uso ideal: Piernas y glúteos
Color: Verde, azul, rojo y negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en14' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en14', 1, 'img/productos/en14-1.jpg', 'kit completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en14', 2, 'img/productos/en14-2.jpg', 'tubos') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en14', 3, 'img/productos/en14-3.jpg', 'tobilleras y bolsa') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en14', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en15 · Trineo de arrastre Fuerza Máxima
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en15', 3, 'Trineo de arrastre Fuerza Máxima', 'Trineo de acero para empujar o arrastrar con discos de peso. Incluye arnés y cuerda para trabajar fuerza y aceleración en césped o pista.', 'Unisex', 209.00, false, true, null, 'Acero resistente
Postes para empujar y para discos
Arnés y cuerda incluidos', 'Material: Acero
Peso propio: ≈15 kg
Carga: Discos de hasta 100 kg
Superficie: Césped y pista
Uso ideal: Fuerza y aceleración
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en15' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en15', 1, 'img/productos/en15-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en15', 2, 'img/productos/en15-2.jpg', 'postes y discos') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en15', 3, 'img/productos/en15-3.jpg', 'arnés y cuerda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en15', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en16 · Set de vallas de entrenamiento ajustables
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en16', 3, 'Set de vallas de entrenamiento ajustables', 'Set de cinco vallas livianas de altura ajustable para trabajar técnica de carrera, saltos y coordinación.', 'Unisex', 54.20, false, true, 'Nuevo', '5 vallas livianas
Altura ajustable
Base estable que no se voltea', 'Contenido: 5 vallas
Alturas: 15, 23 y 30 cm
Material: PVC resistente
Peso: ≈400 g cada una
Uso ideal: Técnica y saltos
Color: Amarillo neón')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en16' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en16', 1, 'img/productos/en16-1.jpg', 'set completo') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en16', 2, 'img/productos/en16-2.jpg', 'una valla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en16', 3, 'img/productos/en16-3.jpg', 'ajuste de altura') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en16', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en17 · Mancuerna ajustable con base
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en17', 3, 'Mancuerna ajustable con base', 'Mancuerna que cambia de peso con un selector giratorio: reemplaza a varias mancuernas en poco espacio. Se guarda en su base.', 'Unisex', 139.60, false, true, 'Nuevo', 'Selector de peso giratorio
Reemplaza a varias mancuernas
Base para guardarla', 'Peso: De 2.5 a 24 kg
Ajuste: Selector giratorio
Incluye: Base de apoyo
Material: Acero y plástico reforzado
Uso ideal: Fuerza en casa
Color: Negro y gris')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en17' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en17', 1, 'img/productos/en17-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en17', 2, 'img/productos/en17-2.jpg', 'selector de peso') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en17', 3, 'img/productos/en17-3.jpg', 'discos y base') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en17', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en18 · Caminadora curva sin motor
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en18', 3, 'Caminadora curva sin motor', 'Caminadora de banda curva que se mueve con tu propio paso, sin electricidad. Ideal para sprints e intervalos: tú marcas la velocidad.', 'Unisex', 1890.00, false, true, 'Nuevo', 'Banda curva sin motor
Pantalla de velocidad y distancia
Ideal para sprints e intervalos', 'Banda: Curva de lamas
Motor: No necesita
Pantalla: Velocidad, tiempo y distancia
Carga máxima: 150 kg
Uso ideal: Sprints e intervalos
Color: Negro')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en18' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en18', 1, 'img/productos/en18-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en18', 2, 'img/productos/en18-2.jpg', 'pantalla') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en18', 3, 'img/productos/en18-3.jpg', 'banda curva') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en18', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en19 · Cinturón de lastre con cadena
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en19', 3, 'Cinturón de lastre con cadena', 'Cinturón acolchado con cadena para colgar discos de peso. Ideal para fondos y dominadas con carga extra.', 'Unisex', 42.30, false, true, 'Nuevo', 'Cinturón acolchado
Cadena de acero con mosquetón
Para fondos y dominadas', 'Cinturón: Acolchado y ajustable
Cadena: Acero, 90 cm
Carga máxima: 45 kg
Material: Nylon y acero
Uso ideal: Fondos y dominadas
Color: Negro y crema')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en19' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en19', 1, 'img/productos/en19-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en19', 2, 'img/productos/en19-2.jpg', 'cinturón') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en19', 3, 'img/productos/en19-3.jpg', 'cadena y disco') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en19', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en20 · Rueda abdominal Estabilidad Core
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en20', 3, 'Rueda abdominal Estabilidad Core', 'Rueda con mangos antideslizantes para trabajar abdomen, espalda y hombros. Su llanta ancha da estabilidad en cada rodada.', 'Unisex', 18.90, false, true, 'Nuevo', 'Llanta ancha y estable
Mangos antideslizantes
Liviana y fácil de guardar', 'Diámetro: ≈18 cm
Mangos: Espuma antideslizante
Carga máxima: 120 kg
Peso: ≈700 g
Uso ideal: Abdomen y core
Color: Negro y lima')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en20' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en20', 1, 'img/productos/en20-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en20', 2, 'img/productos/en20-2.jpg', 'rueda') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en20', 3, 'img/productos/en20-3.jpg', 'mango') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en20', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- en21 · Bandas de restricción de flujo BFR
insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)
values ('en21', 3, 'Bandas de restricción de flujo BFR', 'Bandas elásticas con perilla de inflado y manómetro para entrenar con restricción de flujo sanguíneo (BFR), usadas en fuerza y recuperación con cargas bajas.', 'Unisex', 64.50, false, true, 'Nuevo', 'Perilla de inflado
Manómetro de presión
Ajuste elástico', 'Contenido: Bandas con 2 perillas y manómetro
Presión: Regulable
Ajuste: Elástico con hebilla
Material: Nylon y caucho
Uso ideal: Fuerza y recuperación con poca carga
Color: Negro y azul')
on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,
  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;
delete from producto_imagen where prd_codigo = 'en21' and pim_orden > 3;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en21', 1, 'img/productos/en21-1.jpg', 'vista principal') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en21', 2, 'img/productos/en21-2.jpg', 'manómetro') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ('en21', 3, 'img/productos/en21-3.jpg', 'perilla de inflado') on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ('en21', 'U', 12) on conflict (prd_codigo, pta_talla) do nothing;

-- Productos que siguen con su foto actual: solo cambia el precio

-- Sin foto nueva: se oculta (no se borra porque puede estar en pedidos anteriores)

commit;
