# -*- coding: utf-8 -*-
"""Aplica herramientas/catalogo.py a js/datos.js (respaldo sin conexión) y genera bd/25_catalogo_final.sql."""
import re
import unicodedata
from catalogo import CATALOGO, PRECIOS_ACTUALES, OCULTOS

RUTA_DATOS = 'js/datos.js'
RUTA_SQL = 'bd/25_catalogo_final.sql'
CAT_CODIGO = {'calzado': 1, 'tecnologia': 2, 'entrenamiento': 3}
STOCK_NUEVO = 12  # unidades por talla de las zapatillas nuevas
# Productos agregados en esta versión (llevan la etiqueta «Nuevo»)
NUEVOS = {'zh13', 'zh14', 'zh15', 'zh16', 'zh17', 'zh18', 'zm14', 'zm15', 'zm16', 'zm17', 'zm18', 'tm15', 'en16', 'en17', 'en18', 'en19', 'en20', 'en21'}


def js(s):
    return "'" + str(s).replace('\\', '\\\\').replace("'", "\\'") + "'"


def lista(xs):
    return '[' + ', '.join(js(x) for x in xs) + ']'


def sql(s):
    return "'" + str(s).replace("'", "''") + "'"


def normal(t):
    t = unicodedata.normalize('NFD', t.lower())
    return ''.join(c for c in t if unicodedata.category(c) != 'Mn')


def claves(p):
    base = {'calzado': ['zapatilla', 'zapatillas', 'tenis', 'calzado', 'correr', 'running'],
            'tecnologia': ['tecnologia', 'implementos', 'accesorio', 'gadget'],
            'entrenamiento': ['entrenamiento', 'gimnasio']}[p['cat']]
    if p['pub']:
        base.append(p['pub'].lower())
    palabras = [w for w in re.split(r'[^a-z0-9ñ]+', normal(p['nombre'])) if len(w) > 2]
    return list(dict.fromkeys(base + palabras + [normal(x) for x in p['claves']]))


def precio(n):
    return ('%.2f' % n).rstrip('0').rstrip('.')


def bloque_js(p, etiqueta):
    return ('  {\n'
            f"    id: '{p['id']}', nombre: {js(p['nombre'])}, categoria: '{p['cat']}', publico: {js(p['pub']) if p['pub'] else 'null'}, precio: {precio(p['precio'])},\n"
            f"    etiqueta: {js(etiqueta)},\n"
            f"    tallas: {lista(p['tallas'])},\n"
            f"    vistas: {lista([v for v, _ in p['vistas']])},\n"
            f"    descripcion: {js(p['desc'])},\n"
            f"    caracteristicas: {lista(p['car'])},\n"
            f"    ficha: [{', '.join('[' + js(k) + ', ' + js(v) + ']' for k, v in p['ficha'])}],\n"
            f"    claves: {lista(claves(p))}\n"
            '  }')


def main():
    src = open(RUTA_DATOS, encoding='utf-8').read()
    patron = lambda i: re.compile(r"  \{\n    id: '%s',.*?\n  \}" % re.escape(i), re.S)
    for p in CATALOGO:
        m = patron(p['id']).search(src)
        if m:
            et = re.search(r"etiqueta: '([^']*)'", m.group(0))
            src = src[:m.start()] + bloque_js(p, et.group(1) if et else '') + src[m.end():]
        else:
            # Se ubica después del producto anterior del catálogo que ya esté en el archivo
            previos = [q['id'] for q in CATALOGO[:CATALOGO.index(p)]]
            ancla = next(m2 for m2 in (patron(i).search(src) for i in reversed(previos)) if m2)
            src = src[:ancla.end()] + ',\n' + bloque_js(p, 'Nuevo') + src[ancla.end():]
    for i, n in PRECIOS_ACTUALES.items():
        m = patron(i).search(src)
        b = re.sub(r'precio: [\d.]+', 'precio: ' + precio(n), m.group(0), count=1)
        src = src[:m.start()] + b + src[m.end():]
    for i in OCULTOS:
        m = re.compile(r",\n  \{\n    id: '%s',.*?\n  \}" % i, re.S).search(src)
        if m:
            src = src[:m.start()] + src[m.end():]
    open(RUTA_DATOS, 'w', encoding='utf-8').write(src)

    s = ['/*==============================================================*/',
         '/* ATHLETIX - 25 - Catálogo final (90 productos)                 */',
         '/* - Nombre, descripción, características, ficha, precio y 3     */',
         '/*   vistas de cada producto según su foto final.                */',
         '/* - La categoría 2 pasa a llamarse «Tecnología e implementos».  */',
         '/* - Solo el calzado es de Hombre o de Mujer.                    */',
         '/* - Productos nuevos con su stock inicial.                      */',
         '/* - Se puede ejecutar más de una vez sin duplicar registros.    */',
         '/*==============================================================*/',
         'begin;', '',
         "update categoria set cat_nombre = 'Tecnología e implementos' where cat_codigo = 2;", '',
         '-- Regla de negocio: solo el calzado es de Hombre o de Mujer; tecnología y entrenamiento son para todos',
         'alter table producto drop constraint if exists ckc_prd_genero_categoria;',
         "update producto set prd_genero = 'Unisex' where cat_codigo in (2, 3) and prd_genero <> 'Unisex';",
         "alter table producto add constraint ckc_prd_genero_categoria check ((cat_codigo = 1) = (prd_genero <> 'Unisex'));", '']
    for p in CATALOGO:
        gen = p['pub'] or 'Unisex'
        s.append(f"-- {p['id']} · {p['nombre']}")
        s.append('insert into producto (prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_tiene_talla, prd_visible, prd_etiqueta, prd_caracteristicas, prd_ficha)')
        s.append(f"values ({sql(p['id'])}, {CAT_CODIGO[p['cat']]}, {sql(p['nombre'])}, {sql(p['desc'])}, {sql(gen)}, {p['precio']:.2f}, {'true' if p['tallas'] else 'false'}, true, "
                 f"{sql('Nuevo') if p['id'] in NUEVOS else 'null'}, {sql(chr(10).join(p['car']))}, {sql(chr(10).join(k + ': ' + v for k, v in p['ficha']))})")
        s.append('on conflict (prd_codigo) do update set prd_nombre = excluded.prd_nombre, prd_descripcion = excluded.prd_descripcion, prd_genero = excluded.prd_genero,')
        s.append('  prd_precio = excluded.prd_precio, prd_visible = true, prd_caracteristicas = excluded.prd_caracteristicas, prd_ficha = excluded.prd_ficha;')
        s.append(f"delete from producto_imagen where prd_codigo = {sql(p['id'])} and pim_orden > {len(p['vistas'])};")
        for n, (v, _) in enumerate(p['vistas'], 1):
            s.append(f"insert into producto_imagen (prd_codigo, pim_orden, pim_url, pim_descripcion) values ({sql(p['id'])}, {n}, 'img/productos/{p['id']}-{n}.jpg', {sql(v)}) "
                     'on conflict (prd_codigo, pim_orden) do update set pim_url = excluded.pim_url, pim_descripcion = excluded.pim_descripcion;')
        if p['id'] in NUEVOS:
            for t in p['tallas']:
                s.append(f"insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ({sql(p['id'])}, {sql(t)}, {STOCK_NUEVO}) on conflict (prd_codigo, pta_talla) do nothing;")
        if not p['tallas']:
            s.append(f"insert into producto_talla (prd_codigo, pta_talla, pta_cantidad) values ({sql(p['id'])}, 'U', {STOCK_NUEVO}) on conflict (prd_codigo, pta_talla) do nothing;")
        s.append('')
    s.append('-- Productos que siguen con su foto actual: solo cambia el precio')
    for i, n in PRECIOS_ACTUALES.items():
        s.append(f"update producto set prd_precio = {n:.2f} where prd_codigo = '{i}';")
    s.append('')
    s.append('-- Sin foto nueva: se oculta (no se borra porque puede estar en pedidos anteriores)')
    for i in OCULTOS:
        s.append(f"update producto set prd_visible = false where prd_codigo = '{i}';")
    s += ['', 'commit;', '']
    open(RUTA_SQL, 'w', encoding='utf-8').write('\n'.join(s))


if __name__ == '__main__':
    main()
