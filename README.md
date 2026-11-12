# ATHLETIX · Tienda deportiva en línea

👉 **Abrir la tienda:** https://g2geovis.github.io/athletix-tienda-v2/

Sitio web de la tienda ATHLETIX, hecho en HTML, CSS y JavaScript, con una página HTML por pantalla. Se adapta a celular, tablet y laptop.

Proyecto de la asignatura **Interacción Humano Computador** (Ingeniería en Sistemas de Información, PUCE).

## Funciones

- Catálogo de 90 productos (calzado, tecnología e implementos y entrenamiento) con filtros por categoría, género del calzado y precio que se quedan visibles al bajar, orden y buscador con sinónimos y tolerancia a errores de escritura. Todo viene de la base de datos.
- El género es un atributo del producto: solo el calzado es de Hombre o de Mujer (21 y 20 modelos); tecnología e implementos y entrenamiento son para todos (Unisex). Una regla en la base lo asegura.
- La sesión dura mientras la tienda está abierta (se comparte entre sus pestañas): al cerrar el navegador y volver a abrir el enlace, nadie aparece con la sesión iniciada. Al iniciar sesión se vuelve a la página donde estaba el cliente (o al carrito si tiene productos).
- Cuentas reales con Supabase: registro con cédula ecuatoriana validada (módulo 10), confirmación por correo, recuperar contraseña y botón para mostrar la contraseña. Las contraseñas se guardan cifradas con bcrypt (Supabase Auth); la tienda nunca las ve.
- Clientes de Ecuador (cédula y celular 09…) y de otros países: al elegir «Otro país» aparecen el país, el pasaporte y el celular con el código del país. La factura muestra C.I. o Pasaporte.
- No se permite registrar dos veces la misma cédula, el mismo celular ni el mismo correo (la base lo asegura con reglas únicas).
- Ingreso con cuenta de Google (OAuth de Supabase). El botón aparece solo cuando el proveedor Google está activado en Supabase; al primer ingreso el cliente completa su cédula y celular.
- Carrito: agregar, cambiar cantidad y quitar productos. Se puede comprar todo el stock de una talla (botón «Llevar todo»).
- Solo retiro en tienda: el cliente elige la tienda y su pedido está listo de 1 a 3 horas según cuánto y qué pidió (60 min + 10 por unidad desde la 4.ª + 15 por producto distinto desde el 3.º + 20 si hay calzado + 20 si hay tecnología). Código de retiro de 6 caracteres. No hay envíos a domicilio.
- Dos formas de pago: en efectivo en la tienda al retirar ( el pago queda Pendiente y pasa a Aprobado al marcar el pedido como Retirado) o con tarjeta en línea. Pago con tarjeta simulado (sin dinero real): acepta todas las tarjetas (Visa, Mastercard, American Express, Diners Club, Discover, JCB, UnionPay y Maestro); reconoce la marca por los primeros dígitos, revisa la cantidad de dígitos de cada marca y el número con Luhn, la fecha y el CVV (3 dígitos). Solo se guardan la marca y los últimos 4 dígitos. Cada pago queda en la tabla PAGO.
- Orden de pedido imprimible con lo que el cliente debe retirar y el código para identificar su pedido.
- Correo de compra con el detalle de lo pedido y la factura en PDF adjunta, y correo al cliente cada vez que cambia el estado de su pedido, con botón para ver su pedido. Salen desde el Gmail de la tienda (función de Supabase `correo-compra`); si falla, EmailJS envía una copia sin el PDF. Llegan a cualquier correo (Gmail, Outlook, Hotmail, etc.).
- Factura en PDF (jsPDF) con los datos del cliente (nombre, cédula, dirección, celular y correo), productos, IVA y total; también se descarga desde la orden de pedido. Lleva la nota «Documento sin validez tributaria: no está autorizado por el SRI».
- Mis pedidos con su estado, orden, seguimiento y reseña de cada producto comprado.
- Administrador: pedidos (cambiar estado; al cancelar se devuelve el stock y se anula el pago), productos (crear, editar, ocultar y borrar, con subida de fotos) y pagos recibidos.
- Stock en vivo para el administrador (página Stock): existencias por talla, última reducción (stock anterior → nuevo, pedido y hora) y todos los movimientos; se actualiza sola cada 15 segundos. Un trigger de la base registra cada cambio en MOVIMIENTO_STOCK (venta, cancelación, ajuste).
- Cada factura tiene su propio número secuencial (001-001-000000001, …) que nunca se repite.
- Fotos de productos en alta resolución (1600 × 1200, formato 4:3, tres vistas por producto) con imágenes responsivas: cada pantalla descarga el WebP justo (600, 1000 o 1600 px) según su tamaño y densidad.
- Compras seguras ante concurrencia: el stock se descuenta con bloqueo por fila en una sola transacción y cada intento de pago tiene una clave única para no duplicar pedidos.
- Carrito y favoritos guardados en la base (tablas CARRITO y FAVORITO): con la cuenta se ven iguales en la computadora y en el celular. Sin sesión se guardan en el navegador (localStorage) y se suman a la cuenta al ingresar.
- Mis pedidos y el panel del administrador muestran la foto de cada producto pedido. Favoritos tiene un botón para agregar todos al carrito (pide la talla si hace falta).
- Contraseñas de al menos 8 caracteres con letras, números y un carácter especial.
- El administrador recibe el aviso de pedido nuevo con el mismo diseño que el cliente: detalle con fotos, datos del cliente, pago y retiro.
- El correo de contacto abre el correo web del cliente (Gmail, Outlook/Hotmail o Yahoo, según su cuenta); sin sesión le deja elegir.
- Reseñas de compra verificada: la base verifica que el cliente compró el producto (pedido no cancelado); una reseña por cliente y producto, de 1 a 5 estrellas. La calificación del producto es el promedio de sus reseñas. Cada reseña muestra el nombre del cliente (nombre e inicial del apellido), la fecha y la marca «Compra verificada».

## Enlace permanente

La tienda está en GitHub Pages, que no caduca. Una tarea diaria (`.github/workflows/mantener-activa.yml`) consulta la tienda y la base para que el plan gratuito de Supabase no se pause por inactividad.

## Estructura

Cada pantalla es un archivo HTML. Todos comparten el mismo encabezado, pie de página, estilos y scripts;
la etiqueta `<body data-pagina="...">` indica qué pantalla dibuja cada archivo.

```
index.html               Inicio
productos.html           Catálogo con filtros, orden y buscador (?cat=calzado, ?q=reloj)
producto.html            Detalle de un producto (?id=vx): fotos, tallas, ficha y reseñas
carrito.html             Carrito
login.html               Iniciar sesión
registro.html            Crear cuenta
confirmar-correo.html    Aviso para confirmar el correo
completar-perfil.html    Datos que faltan después de confirmar
recuperar.html           Recuperar contraseña
nueva-clave.html         Crear nueva contraseña
retiro.html              Paso 2: tienda de retiro
pago.html                Paso 3: pago simulado con tarjeta
confirmacion.html        Paso 4: compra realizada
orden.html               Orden de pedido imprimible (?pedido=N)
pedidos.html             Mis pedidos
perfil.html              Mi perfil: mis datos
metodos-pago.html        Mi perfil: tarjetas guardadas
cambiar-clave.html       Mi perfil: cambiar contraseña
admin.html               Panel de pedidos (administrador)
admin-productos.html     Lista de productos (administrador)
admin-producto.html      Crear o editar un producto (?id=código)
admin-pagos.html         Pagos recibidos (administrador)
favoritos.html           Mis favoritos (guardados en el navegador)
ayuda.html               Centro de ayuda
quienes-somos.html       Quiénes somos: historia, misión, visión, valores y tiendas
404.html                 Página no encontrada

plantilla.html           Base común de todas las páginas
herramientas/generar_paginas.py  Crea los HTML desde la plantilla, con los grupos de JS de cada página y su versión (usar npm run construir)

css/estilos.css          Estilos (primero celular)
img/                     Logo y fotos de productos: img/productos/<código>-<vista>.jpg (1600 px) e img/productos/w/<código>-<vista>-600|1000|1600.webp
js/config.js             Claves públicas de Supabase y EmailJS
js/validaciones.js       Cédula, nombres, celular, correo, contraseña, dirección y tarjeta (marca, dígitos y Luhn)
js/factura.js            Factura en PDF (carga jsPDF solo cuando hace falta)
js/vendor/jspdf.umd.min.js  Librería jsPDF 2.5.2
supabase/functions/correo-compra/index.ts  Envía el correo de compra con la factura adjunta (secretos GMAIL_USUARIO y GMAIL_CLAVE_APP)
correos/plantilla-cliente-emailjs.html  Copia de la plantilla de EmailJS para los correos de estado
js/api.js                Acceso a Supabase y EmailJS con errores en español
js/core.js               Estado, utilidades y componentes de formularios
js/vistas-tienda.js      Inicio, catálogo, producto, reseñas y carrito
js/vistas-cuenta.js      Ingreso, registro, perfil, tarjetas y pedidos
js/vistas-compra.js      Entrega, pago, confirmación, orden y seguimiento
js/vistas-admin.js       Pedidos, productos, pagos y ayuda
js/app.js                Arranque, sesión y elección de la pantalla según el archivo

bd/01_tablas.sql          Mis tablas con la forma de modelar de la clase (CATEGORIA, PRODUCTO, PRODUCTO_TALLA, CLIENTE,
                          ADMINISTRADOR, TIENDA, METODO_PAGO, PEDIDO, DETALLE_PEDIDO, RESENA; PAGO y
                          PRODUCTO_IMAGEN se agregan en el 05)
bd/02_seguridad_y_funciones.sql  Seguridad por filas, compra en una transacción, reglas de estados y reseñas
bd/03_datos.sql           Categorías, tiendas, productos y existencias
bd/04_productos_nuevos.sql       Catálogo ampliado (52 productos más)
bd/05_pagos_entrega_admin.sql    Tabla PAGO, PRODUCTO_IMAGEN y permisos del administrador
bd/06_datos_productos.sql        Características, ficha técnica y fotos de cada producto
bd/07_fotos_storage.sql          Carpeta pública de fotos (solo el administrador sube)
bd/08_quitar_edad.sql            Quita la edad: el producto se clasifica solo por género
bd/10_renombrar_atributos.sql    Nombres de atributos más claros (prd_genero, prd_visible, mtp_ ...) para una base que ya existía
bd/11_solo_retiro.sql            Solo retiro en tienda: quita las columnas de domicilio
bd/12_solo_tarjeta.sql           Solo pago con tarjeta: quita las columnas de transferencia
bd/13_sin_unisex.sql             Calzado y tecnología solo Hombre o Mujer
bd/14_direccion_y_marcas.sql     Dirección del cliente (para la factura) y todas las marcas de tarjeta (base nueva: 01-08, 11 a 14)
bd/15_limpiar_datos.sql          Borra pedidos y clientes (menos el administrador) y devuelve el stock
bd/16_favoritos_y_carrito.sql    Tablas FAVORITO y CARRITO de cada cuenta (ejecutar antes del 15)
bd/17_celular_unico.sql          Un celular por cuenta (regla única y función celular_registrado)
bd/18_pago_en_tienda.sql         Pago en la tienda (PAGO.pag_forma, estado Pendiente) y tiempo de retiro de 1 a 3 horas
bd/19_movimientos_y_factura.sql  MOVIMIENTO_STOCK (trigger que registra cada cambio de stock) y número de factura propio (seq_factura)
bd/20_clientes_extranjeros.sql   Clientes de otros países: cli_pais, cli_tipo_documento (Cédula o Pasaporte) y celular internacional
bd/21_tallas_mujer.sql           Todo el calzado de mujer con tallas 36, 36.5, 37, 37.5, 38, 38.5, 39 y 40
bd/22_calzado_athletix.sql       Nombres sin marcas para 20 zapatillas (reemplazado por el script 23)
bd/23_catalogo_nuevo.sql         Catálogo final: nombre, descripción, ficha, precio y 3 vistas por producto según su foto;
                                 tecnología y entrenamiento para todos (el género solo existe en el calzado)
bd/24_blindaje.sql               Valida cada línea del carrito en crear_pedido; sin registros dobles (nombre de producto y
                                 correo únicos sin importar mayúsculas); tope de largo en reseñas y de stock
bd/migracion_mis_tablas.sql      Paso de la base anterior a la actual (ya aplicado)
bd/25_catalogo_final.sql         Catálogo final de 90 productos (21 calzado de hombre, 20 de mujer, 29 de tecnología e
                                 implementos y 20 de entrenamiento); la categoría 2 se llama «Tecnología e implementos»
bd/26_reglas_producto.sql        Reglas del producto también en la base (código, nombre, descripción, precio y fotos)
bd/historial/             Scripts anteriores de la base (se conservan como respaldo)
bd/modelo_powerdesigner.sql      Modelo actual (15 tablas) para File > Reverse Engineer > Database en PowerDesigner (DBMS PostgreSQL)
```

## Optimización de recursos (versión 2)

Lo que se cambió para que la tienda cargue más rápido en celular y en PC, sin cambiar lo que hace:

- **Fotos**: AVIF (calidad 55) y WebP (calidad 75) en 6 anchos (400 a 1600 px) con `<picture>`, `srcset` y `sizes`
  medidos para cada tipo de foto. Una sola función arma todas las fotos (`foto()` en `js/core.js`), así no se baja
  el JPG y luego el WebP. La foto principal se precarga desde el `<head>` con prioridad alta; las que están fuera
  de pantalla usan carga diferida (`loading="lazy"`). Los correos usan una miniatura JPG de 112 px.
- **JavaScript y CSS**: minificados con esbuild y separados por grupo de páginas (`js/min/`): cada página baja la
  base y solo las vistas que usa (por ejemplo, el inicio ya no baja el panel de administrador). Todos con `defer`.
  EmailJS (respaldo del correo) se descarga solo si hace falta.
- **Fuentes**: alojadas en `fuentes/` en WOFF2, solo los 5 pesos que se usan, con `font-display: swap` y precarga
  de las cuatro que se ven al abrir (antes 7 pesos desde Google Fonts, que bloqueaban la primera pintura). Recortadas
  a los caracteres del español (unos 19 KB cada una en vez de 23 KB):
  `pyftsubset <fuente> --unicodes="U+0020-007E,U+00A0-00FF,U+0152-0153,U+2000-206F,U+20AC,U+2122,U+2191-2193,U+2212" --layout-features="kern,liga" --flavor=woff2`
- **Renderizado previo**: inicio, catálogo, carrito, favoritos, ingreso, registro, recuperar, ayuda y quiénes somos
  traen su contenido ya armado en el HTML, y el detalle de cada producto en `previo/producto/<código>.html`
  (`herramientas/prerenderizar.mjs`). La página se ve apenas llegan el HTML y el CSS, y los scripts se piden justo
  después; el JavaScript vuelve a dibujar lo mismo con los botones funcionando. Ese contenido se oculta si no le
  corresponde a quien entra (sesión iniciada, filtros en la dirección, carrito o favoritos con productos).
  **Si se cambia el catálogo desde el administrador, hay que volver a ejecutar `npm run construir` y publicar**; mientras
  tanto la página muestra un instante lo anterior y se corrige sola con los datos de la base.
- **Datos**: el catálogo de la base se guarda en el navegador; la página se muestra al instante y se actualiza si la
  base responde algo distinto. Las páginas que no muestran productos no piden el catálogo.
- **Flujo de compra**: se adelanta (prefetch) la página y el código del paso siguiente.
- **Caché**: `sw.js` (Service Worker) guarda JS, CSS, fuentes y fotos para las siguientes visitas
  (GitHub Pages solo permite 10 minutos de caché).
- **Estabilidad visual**: el espacio del contenido se reserva desde el inicio para que el pie de página no salte.

## Herramientas

```
npm run construir                 Minifica y separa el JS y el CSS (herramientas/construir.mjs), genera las páginas
                                  y les agrega el contenido previo (herramientas/prerenderizar.mjs, usa Playwright)
herramientas/prerenderizar.mjs    Abre cada página pública en Chromium y guarda su contenido dentro del HTML
herramientas/construir.mjs        Junta y minifica el JS por grupo (base, tienda, cuenta, compra, admin) y el CSS
herramientas/fotos_web.py         Genera las fotos AVIF y WebP (400-1600 px) y las miniaturas para correos
herramientas/generar_paginas.py   Crea cada página desde plantilla.html, agrega ?v=<huella> a cada JS/CSS y escribe
                                  js/version.js con la versión del sitio (si el navegador mezcla una página guardada
                                  con archivos nuevos, la página se recarga una sola vez con la versión al día)
herramientas/catalogo.py          Catálogo: foto de origen, vistas (recortes), nombre, precio, descripción y ficha
herramientas/entrenamiento_nuevo.py  Los 20 productos de entrenamiento (se suman al catálogo)
herramientas/fotos_catalogo.py    Prepara las fotos: vista completa y acercamientos, 1600 x 1200 en JPG y WebP 600/1000/1600
herramientas/aplicar_catalogo.py  Pasa el catálogo a js/datos.js y genera bd/23_catalogo_nuevo.sql
```

## Pruebas automáticas

En `pruebas/` hay guiones de Playwright que abren la tienda en Chromium y revisan casos límite. Ninguno escribe en la
base ni envía correos: cuando hace falta, la respuesta de la base se cambia dentro del navegador de prueba.
Uso: `node pruebas/stock.js [dirección]` (sin dirección prueba la tienda publicada).

```
humo.js           Las 29 páginas en celular y PC: sin errores, con su título y sus redirecciones
stock.js          Agotado, última unidad, llevar todo el stock, stock que baja con el producto en el carrito, carrito manipulado
compra.js         Pago con sesión simulada: sin stock al pagar, doble clic, base lenta, sesión vencida, errores del servidor
formularios.js    Registro, ingreso, búsqueda con código malicioso, direcciones raras, dos pestañas, pantallas de 280 a 2560 px
admin.js          Panel del administrador: stock negativo, precios inválidos, código repetido, acceso de un cliente normal
suave.js          La actualización que llega de la base no mueve la página ni borra lo que el cliente escribe o eligió
carrera.js        Archivos que llegan tarde (1,5 s de retraso): la página igual dibuja su pantalla
previo.js         Contenido previo: cuándo se muestra, cuándo se oculta y que el JavaScript dibuje lo mismo
teclas.js         Alt + 64, Alt Gr, acentos y ñ en los formularios
interaccion.js    Galería, carrito, búsqueda, favoritos y prefetch
```

Las librerías externas están copiadas en `js/vendor/` con su versión fija (supabase-js 2, EmailJS, jsPDF),
así el sitio no depende de que un CDN cambie de versión.

## Accesibilidad

- Estructura semántica: `header`, `nav`, `main`, `footer`, un `h1` por pantalla y enlace para saltar al contenido.
- Todo se puede usar con teclado, con foco visible en verde azulado.
- Formularios con etiquetas, mensajes de error junto a cada campo y resumen de errores.
- Diálogos nativos (`dialog`) que se cierran con Esc.
- Contraste mínimo de 4.5:1 y respeto por la opción «reducir movimiento» del sistema.
- Revisado con axe-core: 0 infracciones de WCAG 2.2 AA en las pantallas principales.

## Paleta

- Primarios: azul marino `#0B1F3A`, verde azulado `#0F766E` y naranja `#FF7A00`.
- Secundarios: gris claro `#F3F5F7` y blanco `#FFFFFF`.

Tipografía: Barlow Condensed (títulos) y Barlow (textos).
