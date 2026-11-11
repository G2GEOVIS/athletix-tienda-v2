"""ATHLETIX v2 - Versiones web livianas de las fotos de producto.

Cada foto original (img/productos/<codigo>-<vista>.jpg, 1600 x 1200) se publica en seis anchos
(400, 600, 800, 1000, 1200 y 1600 px) y en dos formatos modernos:
  - AVIF (calidad 55): el más liviano; lo usan los navegadores que lo soportan.
  - WebP (calidad 75): respaldo para los navegadores sin AVIF.
El JPG original se mantiene solo para los correos (muchos clientes de correo no muestran WebP/AVIF).
Las fotos se guardan sin metadatos (EXIF). Uso:  python3 herramientas/fotos_web.py [codigo ...]
"""
import sys
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path
from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
CARPETA = RAIZ / 'img' / 'productos'
ANCHOS = (400, 600, 800, 1000, 1200, 1600)
CALIDAD_WEBP = 75
CALIDAD_AVIF = 55


def procesar(jpg):
    im = Image.open(jpg).convert('RGB')
    base = jpg.stem
    total = 0
    for ancho in ANCHOS:
        alto = round(ancho * im.height / im.width)
        g = im if ancho == im.width else im.resize((ancho, alto), Image.LANCZOS)
        w = CARPETA / 'w' / f'{base}-{ancho}.webp'
        a = CARPETA / 'w' / f'{base}-{ancho}.avif'
        g.save(w, 'WEBP', quality=CALIDAD_WEBP, method=6)
        g.save(a, 'AVIF', quality=CALIDAD_AVIF, speed=6)
        total += w.stat().st_size + a.stat().st_size
    return base, total


if __name__ == '__main__':
    (CARPETA / 'w').mkdir(exist_ok=True)
    codigos = sys.argv[1:]
    fotos = sorted(f for f in CARPETA.glob('*.jpg') if not codigos or f.stem.rsplit('-', 1)[0] in codigos)
    with ProcessPoolExecutor() as ex:
        for base, total in ex.map(procesar, fotos):
            print(f'{base}: {total // 1024} KB en {len(ANCHOS) * 2} archivos')
    print(f'{len(fotos)} fotos listas')
