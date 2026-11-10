"""Prepara las fotos del catálogo: vista 1 = imagen completa; vistas 2 y 3 = recortes de cada parte.
Cada foto sale en 4:3 (1600 x 1200) con fondo blanco, en JPG y en WebP de 600, 1000 y 1600 px."""
import sys
from PIL import Image, ImageFilter
import numpy as np

ANCHO, ALTO = 1600, 1200

def blanquear(im):
    """Lleva el fondo claro (blanco o gris muy claro de estudio) a blanco puro, con transición suave."""
    a = np.asarray(im.convert('RGB')).astype(np.float32)
    m, M = a.min(axis=2), a.max(axis=2)
    borde = np.concatenate([m[:8].ravel(), m[-8:].ravel(), m[:, :8].ravel(), m[:, -8:].ravel()])
    fondo = float(np.percentile(borde, 60))           # tono del fondo según los bordes
    alto = min(250.0, max(fondo - 3, 236.0))
    bajo = alto - 12
    t = np.clip((m - bajo) / (alto - bajo), 0, 1)
    t *= np.clip(1 - (M - m - 6) / 14, 0, 1)          # solo tonos grises (sin color)
    t = t[..., None]
    return Image.fromarray((a * (1 - t) + 255 * t).round().astype(np.uint8))

def recortar_contenido(im, margen=0.04):
    a = np.asarray(im)
    mask = a.min(axis=2) < 248
    ys, xs = np.where(mask)
    if not len(xs):
        return im
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    return im.crop((x0, y0, x1 + 1, y1 + 1))

def encuadrar(im, relleno=0.06):
    im = recortar_contenido(im)
    disp_w, disp_h = ANCHO * (1 - 2 * relleno), ALTO * (1 - 2 * relleno)
    k = min(disp_w / im.width, disp_h / im.height)
    nuevo = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS)
    lienzo = Image.new('RGB', (ANCHO, ALTO), 'white')
    lienzo.paste(nuevo, ((ANCHO - nuevo.width) // 2, (ALTO - nuevo.height) // 2))
    return lienzo.filter(ImageFilter.UnsharpMask(radius=1.0, percent=45, threshold=2))

def vistas(origen, cortes):
    im = blanquear(Image.open(origen))
    salida = []
    for c in cortes:
        if c is None:  # vista completa
            salida.append(encuadrar(im))
            continue
        tipo, (x0, y0, x1, y1) = c
        x0, x1, y0, y1 = x0 * im.width, x1 * im.width, y0 * im.height, y1 * im.height
        if tipo == 'z':  # acercamiento: se amplía la caja a 4:3 para que llene el cuadro
            cx, cy, w, h = (x0 + x1) / 2, (y0 + y1) / 2, x1 - x0, y1 - y0
            if w / h < ANCHO / ALTO: w = h * ANCHO / ALTO
            else: h = w * ALTO / ANCHO
            w, h = min(w, im.width), min(h, im.height)
            cx, cy = min(max(cx, w / 2), im.width - w / 2), min(max(cy, h / 2), im.height - h / 2)
            parte = im.crop((round(cx - w / 2), round(cy - h / 2), round(cx + w / 2), round(cy + h / 2)))
            salida.append(parte.resize((ANCHO, ALTO), Image.LANCZOS).filter(ImageFilter.UnsharpMask(radius=1.0, percent=45, threshold=2)))
        else:  # parte separada: se recorta y se centra con margen
            salida.append(encuadrar(im.crop((round(x0), round(y0), round(x1), round(y1)))))
    return salida

def guardar(fotos, destino, codigo):
    for i, f in enumerate(fotos, 1):
        f.save(f'{destino}/{codigo}-{i}.jpg', quality=90, optimize=True, progressive=True)
        for w in (600, 1000, 1600):
            g = f if w == ANCHO else f.resize((w, round(w * ALTO / ANCHO)), Image.LANCZOS)
            g.save(f'{destino}/w/{codigo}-{i}-{w}.webp', quality=86, method=6)
