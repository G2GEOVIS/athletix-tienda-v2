-- ATHLETIX · 22 · Calzado con diseño propio ATHLETIX
-- Las 20 zapatillas dejan de usar nombres y tecnologías de otras marcas: nuevo nombre, descripción, ficha
-- y nombres de las 3 fotos (lateral, interior y frontal). Precio, tallas y stock no cambian.
begin;
update producto set prd_nombre = 'ATHLETIX Pulso Gel', prd_descripcion = 'Zapatilla de running de estabilidad para rodajes largos. Su espuma de doble densidad absorbe el impacto y la parte superior de punto negro, con finas líneas blancas, mantiene el pie fresco y sujeto.',
  prd_caracteristicas = 'Espuma de doble densidad para mayor confort
Parte superior de punto transpirable
Gran estabilidad en cada zancada',
  prd_ficha = 'Amortiguación: Espuma de doble densidad
Color: Negro
Peso: ≈300 g
Desnivel (drop): 10 mm
Uso ideal: Rodajes largos y estabilidad
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh01';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh01' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh01' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh01' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Vuelo Neón', prd_descripcion = 'Zapatilla versátil para el entrenamiento diario. Su espuma reactiva da una pisada suave, y la malla blanca con detalles verde lima deja respirar el pie y se ve en cualquier ruta.',
  prd_caracteristicas = 'Amortiguación suave y reactiva
Malla transpirable con detalles de alta visibilidad
Ideal para entrenamientos y competencias',
  prd_ficha = 'Amortiguación: Espuma reactiva
Color: Blanco y lima
Peso: ≈285 g
Desnivel (drop): 10 mm
Uso ideal: Entrenamiento diario
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh02';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh02' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh02' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh02' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Onda Azul', prd_descripcion = 'Zapatilla de running cómoda y estable para uso diario. La entresuela reparte el impacto y da una transición fluida, y su malla azul rey es ligera y fresca.',
  prd_caracteristicas = 'Entresuela estable de transición fluida
Malla ligera y transpirable
Suela con buen agarre en asfalto',
  prd_ficha = 'Amortiguación: Espuma estable
Color: Azul rey
Peso: ≈290 g
Desnivel (drop): 12 mm
Uso ideal: Uso diario y distancias medias
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh03';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh03' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh03' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh03' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Sendero Volcán', prd_descripcion = 'Zapatilla de trail running para senderos y terrenos mixtos. Su suela con tacos profundos agarra en tierra, piedra y asfalto, y la puntera reforzada protege el pie en las bajadas.',
  prd_caracteristicas = 'Suela con tacos de máximo agarre
Puntera y talón reforzados
Tejido ripstop resistente',
  prd_ficha = 'Amortiguación: Espuma protectora de trail
Color: Negro y rojo
Peso: ≈300 g
Desnivel (drop): 8 mm
Uso ideal: Trail y terrenos mixtos
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh04';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh04' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh04' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh04' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Rayo Lima', prd_descripcion = 'Zapatilla ligera y rápida para series y ritmos de competencia. Su espuma de alto retorno devuelve energía en cada zancada y su color amarillo neón no pasa desapercibido.',
  prd_caracteristicas = 'Ligereza y alta respuesta
Parte superior de punto ultraligera
Diseñada para ritmos rápidos',
  prd_ficha = 'Amortiguación: Espuma de alto retorno
Color: Amarillo neón
Peso: ≈260 g
Desnivel (drop): 6 mm
Uso ideal: Series y competencia
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh05';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh05' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh05' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh05' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Grafito Ride', prd_descripcion = 'Zapatilla equilibrada que sirve para casi todo: rodajes suaves, cambios de ritmo y uso diario. Su malla gris grafito con talón plateado combina con cualquier ropa deportiva.',
  prd_caracteristicas = 'Amortiguación cómoda y duradera
Malla transpirable
Transición suave en cada zancada',
  prd_ficha = 'Amortiguación: Espuma de larga duración
Color: Gris grafito
Peso: ≈275 g
Desnivel (drop): 8 mm
Uso ideal: Versatilidad
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh06';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh06' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh06' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh06' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Nube Alta', prd_descripcion = 'Zapatilla de amortiguación máxima y muy liviana para sumar kilómetros con comodidad. Su entresuela alta con forma de balancín hace que cada paso sea suave y natural.',
  prd_caracteristicas = 'Amortiguación máxima y ligera
Entresuela tipo balancín
Comodidad en largas distancias',
  prd_ficha = 'Amortiguación: Espuma de alto volumen
Color: Blanco y naranja
Peso: ≈250 g
Desnivel (drop): 5 mm
Uso ideal: Largas distancias
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh07';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh07' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh07' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh07' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Trueno Negro', prd_descripcion = 'Zapatilla de entrenamiento diario con transiciones suaves y un ajuste seguro. Su malla negra con cuello amarillo amortigua sin perder estabilidad.',
  prd_caracteristicas = 'Amortiguación equilibrada
Ajuste cómodo y seguro
Ideal para entrenamientos diarios y carreras',
  prd_ficha = 'Amortiguación: Espuma equilibrada
Color: Negro y amarillo
Peso: ≈285 g
Desnivel (drop): 12 mm
Uso ideal: Entrenamiento diario
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh08';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh08' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh08' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh08' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Estable Marino', prd_descripcion = 'Zapatilla de soporte para corredores con pisada pronadora. Su talón firme guía el pie y la espuma da una pisada cómoda kilómetro tras kilómetro.',
  prd_caracteristicas = 'Talón firme para mayor estabilidad
Malla superior transpirable
Perfecta para corredores de todos los niveles',
  prd_ficha = 'Amortiguación: Espuma con soporte
Color: Azul marino y naranja
Peso: ≈285 g
Desnivel (drop): 8 mm
Uso ideal: Pisada pronadora
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh09';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh09' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh09' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh09' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Élite Carmín', prd_descripcion = 'Zapatilla cómoda con retorno de energía para rodajes largos. Su parte superior de punto color vino con talón metálico rosado acompaña la pisada y mantiene el pie fresco.',
  prd_caracteristicas = 'Espuma con retorno de energía
Parte superior de punto ligera
Máximo confort en largas distancias',
  prd_ficha = 'Amortiguación: Espuma de retorno de energía
Color: Vino
Peso: ≈280 g
Desnivel (drop): 8 mm
Uso ideal: Rodajes largos
Tallas: 39 – 45 (EU)'
  where prd_codigo = 'zh10';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zh10' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zh10' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zh10' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Pulso Lavanda', prd_descripcion = 'Zapatilla de estabilidad para mujer con amortiguación de larga duración. Su malla lavanda y el talón con degradado pastel dan soporte y estilo en entrenamientos y carreras largas.',
  prd_caracteristicas = 'Amortiguación de larga duración
Soporte y estabilidad para mayor control
Ideal para entrenamientos y carreras largas',
  prd_ficha = 'Amortiguación: Espuma de doble densidad
Color: Lavanda
Peso: ≈260 g
Desnivel (drop): 10 mm
Uso ideal: Rodajes largos y estabilidad
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm01';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm01' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm01' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm01' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Vuelo Rosa', prd_descripcion = 'Zapatilla de running para mujer, cómoda y ligera. Su espuma da buen retorno de energía y la malla rosa con detalles coral deja respirar el pie.',
  prd_caracteristicas = 'Amortiguación con retorno de energía
Malla transpirable ultraligera
Perfecta para entrenamientos diarios y carreras',
  prd_ficha = 'Amortiguación: Espuma reactiva
Color: Rosa y coral
Peso: ≈240 g
Desnivel (drop): 10 mm
Uso ideal: Entrenamiento diario
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm02';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm02' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm02' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm02' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Onda Turquesa', prd_descripcion = 'Zapatilla cómoda para mujer con una pisada estable. Su amortiguación suave y reactiva acompaña distancias medias y largas, en un fresco color turquesa con menta.',
  prd_caracteristicas = 'Pisada estable
Amortiguación suave y reactiva
Ideal para distancias medias y largas',
  prd_ficha = 'Amortiguación: Espuma estable
Color: Turquesa y menta
Peso: ≈245 g
Desnivel (drop): 12 mm
Uso ideal: Distancias medias y largas
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm03';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm03' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm03' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm03' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Nube Durazno', prd_descripcion = 'Zapatilla de máxima comodidad para mujer. Su espuma es muy suave y la malla blanca con detalles durazno se adapta al pie en carreras largas y uso diario.',
  prd_caracteristicas = 'Espuma ultra suave
Malla transpirable que se adapta al pie
Ideal para carreras largas y uso diario',
  prd_ficha = 'Amortiguación: Espuma ultra suave
Color: Blanco y durazno
Peso: ≈250 g
Desnivel (drop): 6 mm
Uso ideal: Máxima comodidad
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm04';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm04' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm04' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm04' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Rayo Coral', prd_descripcion = 'Zapatilla ligera para mujer pensada para ganar velocidad. Su espuma color coral da una gran respuesta y la parte superior de punto negro es muy liviana.',
  prd_caracteristicas = 'Ligereza y gran respuesta
Parte superior de punto ultraligera
Ideal para mejorar tu ritmo y velocidad',
  prd_ficha = 'Amortiguación: Espuma de alto retorno
Color: Negro y coral
Peso: ≈225 g
Desnivel (drop): 8 mm
Uso ideal: Velocidad
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm05';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm05' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm05' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm05' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Lila Ride', prd_descripcion = 'Zapatilla versátil para mujer que sirve para todo tipo de entrenamiento. Su espuma es cómoda y la parte superior de punto lila es ligera y transpirable.',
  prd_caracteristicas = 'Amortiguación cómoda
Parte superior de punto ligera
Ideal para todo tipo de entrenamientos',
  prd_ficha = 'Amortiguación: Espuma de larga duración
Color: Lila
Peso: ≈240 g
Desnivel (drop): 8 mm
Uso ideal: Versatilidad
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm06';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm06' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm06' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm06' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Nube Salmón', prd_descripcion = 'Zapatilla muy suave y liviana para mujer, ideal para largas distancias y recuperación. Su entresuela flexible amortigua cada paso y su color salmón alegra cualquier entrenamiento.',
  prd_caracteristicas = 'Amortiguación máxima
Gran ligereza y flexibilidad
Ideal para largas distancias y recuperación',
  prd_ficha = 'Amortiguación: Espuma de alto volumen
Color: Salmón
Peso: ≈205 g
Desnivel (drop): 5 mm
Uso ideal: Largas distancias
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm07';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm07' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm07' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm07' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Trueno Violeta', prd_descripcion = 'Zapatilla equilibrada para mujer con transiciones suaves y estables. Su malla color ciruela con detalles violeta es excelente para entrenamientos diarios y carreras.',
  prd_caracteristicas = 'Amortiguación equilibrada
Transiciones suaves y estables
Excelente para entrenamientos diarios y carreras',
  prd_ficha = 'Amortiguación: Espuma equilibrada
Color: Ciruela y violeta
Peso: ≈255 g
Desnivel (drop): 12 mm
Uso ideal: Entrenamiento diario
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm08';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm08' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm08' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm08' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Estable Celeste', prd_descripcion = 'Zapatilla de soporte para corredoras con pronación. Su talón firme guía la pisada y la amortiguación protege las articulaciones, en un suave celeste con detalles naranja.',
  prd_caracteristicas = 'Talón firme para mayor estabilidad
Amortiguación protectora
Ideal para corredoras con pronación',
  prd_ficha = 'Amortiguación: Espuma con soporte
Color: Celeste y naranja
Peso: ≈250 g
Desnivel (drop): 8 mm
Uso ideal: Pisada pronadora
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm09';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm09' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm09' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm09' and pim_orden = 3;
update producto set prd_nombre = 'ATHLETIX Élite Magenta', prd_descripcion = 'Zapatilla cómoda para mujer con espuma que devuelve energía. Ligera y transpirable, en negro con detalles magenta, sirve para entrenamientos y competencias.',
  prd_caracteristicas = 'Espuma con retorno de energía
Malla ligera y transpirable
Ideal para entrenamientos y competencias',
  prd_ficha = 'Amortiguación: Espuma de retorno de energía
Color: Negro y magenta
Peso: ≈240 g
Desnivel (drop): 8 mm
Uso ideal: Entrenamiento y competencia
Tallas: 36 – 40 (EU)'
  where prd_codigo = 'zm10';
update producto_imagen set pim_descripcion = 'vista lateral' where prd_codigo = 'zm10' and pim_orden = 1;
update producto_imagen set pim_descripcion = 'vista interior' where prd_codigo = 'zm10' and pim_orden = 2;
update producto_imagen set pim_descripcion = 'vista frontal' where prd_codigo = 'zm10' and pim_orden = 3;
commit;
