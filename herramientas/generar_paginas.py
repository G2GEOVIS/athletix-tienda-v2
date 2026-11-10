"""ATHLETIX - Genera un archivo HTML por pantalla a partir de plantilla.html.

Todas las páginas comparten el mismo encabezado, pie de página y scripts; cada una
indica qué pantalla es con <body data-pagina="...">. Si cambias el encabezado o el
pie, edita plantilla.html y vuelve a ejecutar:  python3 herramientas/generar_paginas.py
"""
import hashlib
import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
PAGINAS = [
    # archivo, pantalla, título, descripción
    ('index.html', '', 'ATHLETIX | Tienda deportiva en línea', 'Tienda deportiva en línea de calzado, tecnología e implementos deportivos y equipo de entrenamiento. Compra en línea y retira en tienda.'),
    ('productos.html', 'productos', 'Productos | ATHLETIX', 'Catálogo de ATHLETIX: calzado, tecnología e implementos deportivos y equipo de entrenamiento.'),
    ('producto.html', 'producto', 'Producto | ATHLETIX', 'Detalle del producto: fotos, tallas, ficha técnica y opiniones de compradores.'),
    ('carrito.html', 'carrito', 'Carrito | ATHLETIX', 'Revisa los productos de tu carrito antes de comprar.'),
    ('login.html', 'ingresar', 'Iniciar sesión | ATHLETIX', 'Ingresa a tu cuenta de ATHLETIX.'),
    ('registro.html', 'registro', 'Crear cuenta | ATHLETIX', 'Crea tu cuenta de ATHLETIX con tu cédula y tu correo.'),
    ('confirmar-correo.html', 'verifica-correo', 'Confirma tu correo | ATHLETIX', 'Confirma tu correo para activar tu cuenta.'),
    ('completar-perfil.html', 'completar-perfil', 'Completa tu perfil | ATHLETIX', 'Completa tus datos para poder comprar.'),
    ('recuperar.html', 'recuperar', 'Recuperar contraseña | ATHLETIX', 'Recibe un enlace para crear una nueva contraseña.'),
    ('nueva-clave.html', 'nueva-clave', 'Nueva contraseña | ATHLETIX', 'Crea una nueva contraseña para tu cuenta.'),
    ('retiro.html', 'retiro', 'Retiro en tienda | ATHLETIX', 'Elige la tienda donde retiras tu pedido: listo de 1 a 3 horas.'),
    ('pago.html', 'pago', 'Pago | ATHLETIX', 'Paga tu pedido con cualquier tarjeta o en efectivo al retirar.'),
    ('confirmacion.html', 'confirmacion', 'Compra realizada | ATHLETIX', 'Tu compra se realizó con éxito.'),
    ('pedidos.html', 'pedidos', 'Mis pedidos | ATHLETIX', 'Revisa el estado de tus pedidos.'),
    ('perfil.html', 'perfil', 'Mi perfil | ATHLETIX', 'Revisa y edita los datos de tu cuenta.'),
    ('metodos-pago.html', 'perfil/pagos', 'Métodos de pago | ATHLETIX', 'Administra tus tarjetas guardadas.'),
    ('cambiar-clave.html', 'perfil/seguridad', 'Cambiar contraseña | ATHLETIX', 'Cambia la contraseña de tu cuenta.'),
    ('admin.html', 'admin', 'Panel de pedidos | ATHLETIX', 'Panel del administrador para gestionar los pedidos.'),
    ('admin-productos.html', 'admin-productos', 'Productos (administrador) | ATHLETIX', 'Crear, editar, desactivar y borrar productos.'),
    ('admin-producto.html', 'admin-producto', 'Editar producto | ATHLETIX', 'Formulario del producto: datos, fotos y stock por talla.'),
    ('admin-stock.html', 'admin-stock', 'Stock (administrador) | ATHLETIX', 'Existencias de cada producto, última reducción y movimientos de stock.'),
    ('admin-pagos.html', 'admin-pagos', 'Pagos (administrador) | ATHLETIX', 'Registro de todos los pagos guardados en la base de datos.'),
    ('orden.html', 'orden', 'Orden de pedido | ATHLETIX', 'Orden de pedido con el código de retiro y los productos.'),
    ('favoritos.html', 'favoritos', 'Mis favoritos | ATHLETIX', 'Productos que guardaste como favoritos.'),
    ('ayuda.html', 'ayuda', 'Centro de ayuda | ATHLETIX', 'Preguntas frecuentes sobre compras, pagos, retiro y reseñas.'),
    ('quienes-somos.html', 'quienes-somos', 'Quiénes somos | ATHLETIX', 'Conoce ATHLETIX: nuestra historia, misión, visión, valores y las tiendas donde retiras tus pedidos.'),
    ('404.html', '404', 'Página no encontrada | ATHLETIX', 'La página que buscas no existe.'),
]

plantilla = (RAIZ / 'plantilla.html').read_text(encoding='utf-8')

# Versión de cada archivo propio (huella de su contenido): al publicar cambios, el navegador
# descarga los archivos nuevos en vez de mezclar una versión vieja guardada con una nueva.
def con_version(m):
    ruta = m.group(2)
    huella = hashlib.sha1((RAIZ / ruta).read_bytes()).hexdigest()[:8]
    return f'{m.group(1)}{ruta}?v={huella}"'
# Versión del sitio: huella de todos los archivos propios (cambia con cualquier cambio publicado).
# js/version.js la compara con la de la página: si el navegador juntó una página guardada con archivos
# nuevos, recarga una sola vez la versión al día, así nunca se mezclan versiones.
archivos = sorted(set(re.findall(r'(?:src|href)="((?:js|css)/[^"?]+)"', plantilla)) - {'js/version.js'})
VERSION = hashlib.sha1(b''.join((RAIZ / a).read_bytes() for a in archivos)).hexdigest()[:10]
(RAIZ / 'js' / 'version.js').write_text(
    "/* ATHLETIX · Versión publicada (la escribe herramientas/generar_paginas.py; no editar a mano) */\n"
    f"window.VERSION_SITIO = '{VERSION}';\n"
    "(function () {\n"
    "  var meta = document.querySelector('meta[name=\"version-sitio\"]');\n"
    "  var pagina = meta && meta.content;\n"
    "  if (!pagina || pagina === window.VERSION_SITIO) return;\n"
    "  var marca = 'recarga-' + window.VERSION_SITIO;\n"
    "  try { if (sessionStorage.getItem(marca)) return; sessionStorage.setItem(marca, '1'); } catch (e) { return; }\n"
    "  var u = new URL(location.href); u.searchParams.set('v', window.VERSION_SITIO); location.replace(u.toString());\n"
    "})();\n", encoding='utf-8')
plantilla = plantilla.replace('{{VERSION}}', VERSION)
plantilla = re.sub(r'((?:src|href)=")((?:js|css)/[^"?]+)"', con_version, plantilla)
for archivo, pantalla, titulo, descripcion in PAGINAS:
    html = (plantilla.replace('{{TITULO}}', titulo)
                     .replace('{{DESCRIPCION}}', descripcion)
                     .replace('{{PAGINA}}', pantalla))
    (RAIZ / archivo).write_text(html, encoding='utf-8')
    print('generada', archivo)
print('versión del sitio:', VERSION)
