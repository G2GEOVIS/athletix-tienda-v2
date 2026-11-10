/* ATHLETIX · Vistas de la tienda: inicio, catálogo, detalle con reseñas y carrito */
'use strict';

/* ======================= Inicio ======================= */
function vistaInicio() {
  const destacado = producto('vx');
  const cats = [
    ['calzado', 'Calzado', 'Para entrenar y competir', 'sf', 'Ver calzado', 'Par de zapatillas de running azules'],
    ['tecnologia', 'Tecnología e implementos', 'Relojes, sensores, audio e hidratación', 'pt', 'Ver tecnología e implementos', 'Reloj GPS deportivo negro'],
    ['entrenamiento', 'Entrenamiento', 'Fuerza, velocidad y agilidad', 'fl', 'Ver entrenamiento', 'Kit de tubos de resistencia con manijas']
  ];
  return {
    titulo: 'Tienda deportiva en línea',
    seccion: 'inicio',
    html: `
    <section class="hero" aria-labelledby="hero-titulo">
      <div class="contenedor hero__grilla">
        <div>
          <span class="hero__etiqueta">NUEVO · CARRERA 2026</span>
          <h1 class="hero__titulo" id="hero-titulo">Vuela en cada kilómetro</h1>
          <p class="hero__texto">${esc(destacado.nombre)}: espuma FF Turbo+ y placa de carbono para tus ritmos más rápidos.</p>
          <a class="boton boton--naranja" href="producto.html?id=vx">Comprar ${esc(destacado.nombre)} ${icono('derecha')}</a>
        </div>
        <div class="hero__imagen"><img src="${img(destacado)}" alt="Par de zapatillas ${esc(destacado.nombre)} en rojo y naranja" width="800" height="600"></div>
      </div>
    </section>

    <section class="contenedor beneficios" aria-label="Beneficios de comprar en ATHLETIX">
      <ul class="beneficios__lista">
        <li class="beneficio"><span class="beneficio__icono">${icono('tienda')}</span><p><strong>Retiro gratis en tienda</strong><span>Quito y Guayaquil</span></p></li>
        <li class="beneficio"><span class="beneficio__icono">${icono('correo')}</span><p><strong>Te avisamos por correo</strong><span>Cuando tu pedido esté listo</span></p></li>
        <li class="beneficio"><span class="beneficio__icono">${icono('escudo')}</span><p><strong>Paga como prefieras</strong><span>Todas las tarjetas o efectivo al retirar</span></p></li>
        <li class="beneficio"><span class="beneficio__icono">${icono('estrella')}</span><p><strong>Opiniones reales</strong><span>Solo de clientes que compraron</span></p></li>
      </ul>
    </section>

    <section class="contenedor categorias" aria-labelledby="titulo-categorias">
      <h2 class="titulo-seccion" id="titulo-categorias">Compra por categoría</h2>
      <p class="subtitulo">Elige qué necesitas para entrenar hoy.</p>
      <div class="categorias__grilla">
        ${cats.map(([c, t, d, foto, ver, altFoto]) => `
          <a class="tarjeta-categoria" href="productos.html?cat=${c}">
            <img src="img/productos/${foto}-1.jpg" alt="${altFoto}" width="800" height="600" loading="lazy">
            <div class="tarjeta-categoria__texto"><h3>${t}</h3><p>${d}</p><span class="enlace-flecha">${ver} ${icono('derecha')}</span></div>
          </a>`).join('')}
      </div>
    </section>`
  };
}

/* ======================= Catálogo y búsqueda ======================= */
const PALABRAS_VACIAS = new Set(['de', 'del', 'la', 'el', 'los', 'las', 'para', 'y', 'con', 'en', 'un', 'una', 'unos', 'unas', 'por', 'a', 'al', 'o', 'que', 'mi', 'me', 'quiero', 'busco', 'necesito', 'algo', 'tipo', 'marca', 'color', 'talla', 'precio', 'deporte', 'deportivo', 'deportiva', 'deportivos', 'deportivas']);

/* Buscador: entiende sinónimos y palabras de uso común en Ecuador, ignora tildes y mayúsculas
   y tolera errores de escritura (una o dos letras de diferencia). */
const SINONIMOS = [
  ['zapatilla', 'zapatillas', 'zapato', 'zapatos', 'tenis', 'teni', 'calzado', 'sneaker', 'sneakers', 'championes'],
  ['trail', 'montana', 'montaña', 'sendero', 'senderismo', 'monte', 'cerro', 'trekking'],
  ['reloj', 'relojes', 'smartwatch', 'watch', 'pulsera'],
  ['audifonos', 'audifono', 'auriculares', 'auricular', 'cascos', 'headphones', 'earbuds', 'musica', 'audio'],
  ['botella', 'termo', 'tomatodo', 'cantimplora', 'hidratacion', 'hidratar'],
  ['cinturon', 'correa', 'canguro', 'rinonera', 'riñonera'],
  ['chaleco', 'vest', 'mochila'],
  ['gafas', 'lentes', 'anteojos', 'gafa', 'lente'],
  ['plantillas', 'plantilla', 'insoles', 'suela'],
  ['camara', 'video', 'gopro', 'grabar'],
  ['anillo', 'ring', 'sortija'],
  ['masaje', 'masajeador', 'pistola', 'recuperacion', 'relajar'],
  ['linterna', 'frontal', 'lampara', 'luz', 'led', 'noche'],
  ['rodillera', 'rodilla'],
  ['secador', 'secadora', 'secar'],
  ['banda', 'pecho', 'pulso', 'cardiaco', 'cardio', 'frecuencia', 'corazon'],
  ['sensor', 'potencia', 'medidor'],
  ['alarma', 'seguridad', 'silbato'],
  ['top', 'sujetador', 'brasier', 'sosten', 'bra'],
  ['pesas', 'pesa', 'mancuerna', 'mancuernas', 'peso', 'lastre', 'kettlebell'],
  ['ligas', 'liga', 'elastico', 'elasticos', 'elasticas', 'tubos'],
  ['cuerda', 'soga', 'comba', 'saltar', 'saltador'],
  ['balon', 'pelota', 'bola', 'medicinal'],
  ['rodillo', 'foam', 'roller', 'miofascial'],
  ['cajon', 'caja', 'box', 'pliometrico', 'saltos'],
  ['vallas', 'valla', 'obstaculos', 'obstaculo'],
  ['conos', 'cono', 'escalera', 'agilidad', 'picas'],
  ['tacos', 'arrancadores', 'bloques', 'salida'],
  ['cronometro', 'cronometraje', 'fotoceldas'],
  ['caminadora', 'trotadora', 'treadmill'],
  ['trineo', 'sled', 'arrastre', 'empuje'],
  ['paracaidas', 'arnes'],
  ['abdominal', 'abdomen', 'abdominales', 'core', 'rueda'],
  ['tabla', 'equilibrio', 'balance', 'bosu'],
  ['mujer', 'mujeres', 'dama', 'damas', 'femenino', 'chica', 'chicas', 'ella'],
  ['hombre', 'hombres', 'caballero', 'caballeros', 'masculino', 'chico', 'chicos', 'el'],
  ['tecnologia', 'implementos', 'implemento', 'gadget', 'electronico'],
  ['entrenamiento', 'gimnasio', 'gym', 'ejercicio', 'fitness', 'equipo'],
  ['barato', 'baratos', 'economico', 'economicos', 'oferta'],
  ['rosa', 'rosado', 'fucsia', 'pink'], ['negro', 'negra', 'black'], ['blanco', 'blanca', 'white'], ['azul', 'celeste', 'marino', 'blue'],
  ['rojo', 'roja', 'red', 'coral'], ['verde', 'lima', 'menta', 'oliva', 'neon'], ['amarillo', 'amarilla', 'limon'], ['gris', 'grafito', 'plateado'],
  ['morado', 'morada', 'lila', 'lavanda', 'violeta', 'purpura'], ['naranja', 'anaranjado', 'salmon', 'durazno']
].map((g) => g.map(normalizar));
const GRUPO_DE = new Map();
SINONIMOS.forEach((g, i) => g.forEach((w) => { if (!GRUPO_DE.has(w)) GRUPO_DE.set(w, i); }));
function grupoDe(w) {
  const s = singular(w);
  if (GRUPO_DE.has(w)) return GRUPO_DE.get(w);
  if (GRUPO_DE.has(s)) return GRUPO_DE.get(s);
  if (w.length < 5) return undefined;
  const tope = w.length >= 8 ? 2 : 1;
  for (const [x, g] of GRUPO_DE) if (x.length >= 4 && distancia(w, x, tope) <= tope) return g;
  return undefined;
}
const singular = (w) => (w.length > 4 && w.endsWith('es') ? w.slice(0, -2) : w.length > 3 && w.endsWith('s') ? w.slice(0, -1) : w);

/* Distancia de edición con tope (para tolerar errores de escritura sin hacer lenta la búsqueda) */
function distancia(a, b, tope) {
  if (Math.abs(a.length - b.length) > tope) return tope + 1;
  let previa = Array.from({ length: b.length + 1 }, (_, j) => j);
  for (let i = 1; i <= a.length; i++) {
    const fila = [i]; let menor = i;
    for (let j = 1; j <= b.length; j++) {
      fila[j] = Math.min(previa[j] + 1, fila[j - 1] + 1, previa[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
      menor = Math.min(menor, fila[j]);
    }
    if (menor > tope) return tope + 1;
    previa = fila;
  }
  return previa[b.length];
}

/* Qué tan bien coincide una palabra buscada con las palabras de un producto (0 = nada) */
function coincidencia(w, { voces, desc }, conErrores) {
  const s = singular(w);
  let mejor = 0;
  // Una palabra que solo aparece en la descripción cuenta menos
  if (desc.has(w) || desc.has(s)) mejor = 1;
  for (const voz of voces) {
    if (voz === w || voz === s) return 3;
    if (s.length >= 3 && voz.startsWith(s)) mejor = Math.max(mejor, 2.5);
    else if (voz.length >= 4 && w.startsWith(voz)) mejor = Math.max(mejor, 2);
    else if (conErrores && w.length >= 5 && voz.length >= 4) {
      const tope = w.length >= 8 ? 2 : 1;
      if (Math.min(distancia(w, voz, tope), distancia(s, voz, tope)) <= tope) mejor = Math.max(mejor, 1.5);
    }
  }
  // Sinónimo: "tenis" encuentra zapatillas, "cascos" encuentra audífonos, etc. (también con un error de escritura)
  const grupo = conErrores ? grupoDe(w) : (GRUPO_DE.has(w) ? GRUPO_DE.get(w) : GRUPO_DE.get(s));
  if (mejor < 2 && grupo !== undefined && SINONIMOS[grupo].some((x) => voces.includes(x) || voces.includes(singular(x)))) mejor = Math.max(mejor, 2);
  return mejor;
}

const vocesDe = new WeakMap();
function vocesProducto(p) {
  if (!vocesDe.has(p)) {
    const partir = (t) => normalizar(t).split(/[^a-z0-9ñ]+/).filter(Boolean);
    const voces = [...new Set(partir([p.nombre, CATEGORIAS[p.categoria], p.publico || 'unisex', p.claves.join(' '), (p.ficha || []).map((f) => f[1]).join(' '), (p.caracteristicas || []).join(' ')].join(' ')))];
    vocesDe.set(p, { voces, desc: new Set(partir(p.descripcion || '').filter((w) => w.length > 3)) });
  }
  return vocesDe.get(p);
}

function buscar(lista, consulta) {
  // "10kg" se lee como "10 kg"
  const palabras = normalizar(consulta).replace(/(\d)([a-zñ])/g, '$1 $2').replace(/([a-zñ])(\d)/g, '$1 $2')
    .split(/[^a-z0-9ñ]+/).filter((w) => w && !PALABRAS_VACIAS.has(w)).slice(0, 8);
  if (!palabras.length) return lista;
  // Se toleran errores de escritura solo en las palabras que no aparecen tal cual en ningún producto
  // (así "addidas" encuentra Adidas, pero "salomon" no se confunde con el color salmón)
  const conErrores = palabras.map((w) => !lista.some((p) => coincidencia(w, vocesProducto(p), false) > 0));
  const puntuados = lista.map((p) => {
    const voces = vocesProducto(p);
    const notas = palabras.map((w, i) => coincidencia(w, voces, conErrores[i]));
    return { p, todas: notas.every((n) => n > 0), total: notas.reduce((a, b) => a + b, 0) };
  });
  // Primero los productos que tienen todas las palabras; si ninguno, los que tienen alguna
  let elegidos = puntuados.filter((x) => x.todas);
  if (!elegidos.length) elegidos = puntuados.filter((x) => x.total > 0);
  return elegidos.sort((a, b) => b.total - a.total).map((x) => x.p);
}

const RANGOS = {
  todos: ['Todos los precios', () => true],
  bajo: ['Menos de $50', (p) => p.precio < 50],
  medio: ['De $50 a $150', (p) => p.precio >= 50 && p.precio <= 150],
  alto: ['Más de $150', (p) => p.precio > 150]
};
const ORDENES = {
  relevancia: ['Recomendados', null],
  menor: ['Precio: menor a mayor', (a, b) => a.precio - b.precio],
  mayor: ['Precio: mayor a menor', (a, b) => b.precio - a.precio],
  valorados: ['Mejor valorados', (a, b) => (b.rating || 0) - (a.rating || 0) || b.opiniones - a.opiniones]
};

function filtrar(params) {
  const cat = CATEGORIAS[params.get('cat')] ? params.get('cat') : 'todas';
  const pub = ['Hombre', 'Mujer'].includes(params.get('pub')) ? params.get('pub') : 'todos';
  const precio = RANGOS[params.get('precio')] ? params.get('precio') : 'todos';
  const orden = ORDENES[params.get('orden')] ? params.get('orden') : 'relevancia';
  const q = (params.get('q') || '').slice(0, 80);
  let lista = buscar(PRODUCTOS.filter((p) => p.activo !== false), q);
  if (cat !== 'todas') lista = lista.filter((p) => p.categoria === cat);
  // El género solo existe en el calzado (Hombre o Mujer). Tecnología y entrenamiento son para todos,
  // así que con un género elegido se siguen mostrando y solo se filtra el calzado.
  const usaGenero = usaFiltroGenero(cat);
  if (usaGenero && pub !== 'todos') lista = lista.filter((p) => p.categoria !== 'calzado' || p.publico === pub);
  lista = lista.filter(RANGOS[precio][1]);
  if (ORDENES[orden][1]) lista = [...lista].sort(ORDENES[orden][1]);
  return { lista, cat, pub: usaGenero ? pub : 'todos', precio, orden, q };
}

function tarjetaProducto(p) {
  const agotado = p.stock && Object.values(p.stock).every((s) => s <= 0);
  const total = stockTotal(p);
  const pocas = !agotado && total !== null && total <= POCAS_UNIDADES;
  return `
    <li>
      <article class="tarjeta-producto">
        <div class="tarjeta-producto__imagen"><img src="${img(p)}" alt="Foto de ${esc(p.nombre)}" width="800" height="600" loading="lazy"></div>
        ${botonFavorito(p, 'tarjeta-producto__favorito')}
        ${agotado ? '<span class="etiqueta etiqueta--azul tarjeta-producto__etiqueta">Agotado</span>' : pocas ? `<span class="etiqueta etiqueta--naranja tarjeta-producto__etiqueta">${total === 1 ? '¡Última unidad!' : `¡Últimas ${total}!`}</span>` : (p.etiqueta ? `<span class="etiqueta tarjeta-producto__etiqueta">${p.etiqueta}</span>` : '')}
        <div class="tarjeta-producto__cuerpo">
          <h2 class="tarjeta-producto__nombre"><a href="producto.html?id=${p.id}">${esc(p.nombre)}</a></h2>
          <p class="texto-suave">${etiquetaCategoria(p)}</p>
          ${calificacionHtml(p)}
          <div class="tarjeta-producto__pie">
            <p class="precio">${dinero(p.precio)}</p>
            <span class="tarjeta-producto__ver" aria-hidden="true">Ver producto →</span>
          </div>
        </div>
      </article>
    </li>`;
}

function htmlResultados(f) {
  if (!f.lista.length) {
    return `
      <div class="sin-resultados">
        <h2 class="titulo-seccion">Sin resultados</h2>
        <p class="subtitulo">No encontramos productos${f.q ? ` para "${esc(f.q)}"` : ' con estos filtros'}. Prueba con otra palabra o con una de estas búsquedas:</p>
        <ul class="chips">${BUSQUEDAS_POPULARES.map((b) => `<li><a class="chip" href="productos.html?q=${encodeURIComponent(b)}">${b}</a></li>`).join('')}</ul>
        <p style="margin-top:1.25rem"><a class="boton boton--secundario" href="productos.html">Ver todos los productos</a></p>
      </div>`;
  }
  return `<ul class="grilla-productos">${f.lista.map(tarjetaProducto).join('')}</ul>`;
}

/* El filtro de género se muestra en «Todas» y en «Calzado»; en tecnología y entrenamiento solo queda el precio */
function usaFiltroGenero(cat) { return cat === 'todas' || cat === 'calzado'; }
const textoBotonFiltros = (cat) => (usaFiltroGenero(cat) ? 'Género y precio' : 'Precio');

function tituloCatalogo(f) {
  if (f.q) return `Resultados para "${esc(f.q)}"`;
  if (f.cat !== 'todas') return CATEGORIAS[f.cat];
  return 'Todos los productos';
}

/* Lo elegido en género y precio, para verlo en el celular sin abrir el panel */
function resumenFiltros(f) {
  const partes = [];
  if (f.pub && f.pub !== 'todos' && usaFiltroGenero(f.cat)) partes.push(f.pub);
  if (f.precio && f.precio !== 'todos') partes.push(RANGOS[f.precio][0]);
  return partes.length ? partes.join(' · ') : 'Todos';
}
function vistaProductos(partes, params) {
  const f = filtrar(params);
  const radio = (grupo, valor, texto, actual) =>
    `<label class="opcion"><input type="radio" name="${grupo}" value="${valor}" ${valor === actual ? 'checked' : ''}> ${texto}</label>`;
  return {
    titulo: f.q ? `Resultados para ${f.q}` : (f.cat !== 'todas' ? CATEGORIAS[f.cat] : 'Productos'),
    seccion: 'productos',
    html: `
    <div class="contenedor pagina">
      <nav class="migas" aria-label="Ruta de navegación"><ol><li><a href="index.html">Inicio</a></li><li><span aria-current="page">Productos</span></li></ol></nav>
      <div class="cabecera-pagina resultados__info">
        <h1 class="titulo-pagina" id="titulo-catalogo">${tituloCatalogo(f)}</h1>
        <div class="resultados__orden">
          <p class="texto-suave" id="conteo" aria-live="polite">${plural(f.lista.length, 'producto', 'productos')}</p>
          <label class="orden"><span>Ordenar por</span>
            <select id="orden">${Object.entries(ORDENES).map(([k, [t]]) => `<option value="${k}" ${k === f.orden ? 'selected' : ''}>${t}</option>`).join('')}</select>
          </label>
        </div>
      </div>
      <div class="catalogo">
        <aside class="filtros" aria-label="Filtros">
          <form class="filtros__cuerpo" id="filtros-cuerpo">
            <fieldset class="grupo-filtro grupo-filtro--categoria">
              <legend>Categoría</legend>
              <div class="grupo-filtro__opciones">${radio('cat', 'todas', 'Todas', f.cat)}${radio('cat', 'calzado', 'Calzado', f.cat)}${radio('cat', 'tecnologia', 'Tecnología e implementos', f.cat)}${radio('cat', 'entrenamiento', 'Entrenamiento', f.cat)}</div>
            </fieldset>
            <button class="filtros__abrir" type="button" aria-expanded="false" aria-controls="filtros-mas"><span>${icono('filtro')}<span id="texto-filtros">${textoBotonFiltros(f.cat)}</span><span class="filtros__resumen" id="filtros-resumen">${resumenFiltros(f)}</span></span>${icono('chevronAbajo')}</button>
            <div class="filtros__mas" id="filtros-mas">
              <fieldset class="grupo-filtro" id="grupo-publico" ${usaFiltroGenero(f.cat) ? '' : 'hidden'}>
                <legend>Género del calzado</legend>
                <div class="grupo-filtro__opciones">${radio('pub', 'todos', 'Todos', f.pub)}${radio('pub', 'Hombre', 'Hombre', f.pub)}${radio('pub', 'Mujer', 'Mujer', f.pub)}</div>
              </fieldset>
              <fieldset class="grupo-filtro">
                <legend>Precio</legend>
                <div class="grupo-filtro__opciones">${Object.entries(RANGOS).map(([k, [t]]) => radio('precio', k, t, f.precio)).join('')}</div>
              </fieldset>
              <button class="boton boton--secundario boton--bloque" type="button" id="limpiar-filtros">Limpiar filtros</button>
            </div>
          </form>
        </aside>
        <section aria-labelledby="titulo-catalogo" id="resultados">${htmlResultados(f)}</section>
      </div>
    </div>`,
    montar(main) {
      const form = $('#filtros-cuerpo', main);
      const abrir = $('.filtros__abrir', main);
      const mas = $('#filtros-mas', main);
      abrir.addEventListener('click', () => {
        const ab = abrir.getAttribute('aria-expanded') !== 'true';
        abrir.setAttribute('aria-expanded', ab);
        mas.classList.toggle('abierto', ab);
      });
      // Al tocar un filtro se deja la búsqueda escrita y se muestra la categoría elegida; al cambiar el orden la búsqueda se mantiene
      const aplicar = (conBusqueda) => {
        const p = new URLSearchParams();
        const q = leerRuta().params.get('q');
        if (q && conBusqueda === true) p.set('q', q);
        else { const campo = $('#buscar-texto'); if (campo) campo.value = ''; }
        const d = new FormData(form);
        const cat = d.get('cat');
        if (cat !== 'todas') p.set('cat', cat);
        if (usaFiltroGenero(cat) && d.get('pub') !== 'todos') p.set('pub', d.get('pub'));
        if (d.get('precio') !== 'todos') p.set('precio', d.get('precio'));
        const orden = $('#orden', main).value;
        if (orden !== 'relevancia') p.set('orden', orden);
        history.replaceState(null, '', 'productos.html' + (p.toString() ? '?' + p : ''));
        recordarCatalogo();
        const f2 = filtrar(p);
        // En tecnología y entrenamiento se oculta el género y se vuelve a "Todos"
        const grupoGenero = $('#grupo-publico', main);
        grupoGenero.hidden = !usaFiltroGenero(f2.cat);
        $('#texto-filtros', main).textContent = textoBotonFiltros(f2.cat);
        if (grupoGenero.hidden) $('input[name=pub][value=todos]', grupoGenero).checked = true;
        $('#resultados', main).innerHTML = htmlResultados(f2);
        $('#titulo-catalogo', main).innerHTML = tituloCatalogo(f2);
        $('#conteo', main).textContent = plural(f2.lista.length, 'producto', 'productos');
        document.title = `${f2.cat !== 'todas' ? CATEGORIAS[f2.cat] : 'Productos'} | ATHLETIX`;
        // En celular el panel de filtros se cierra para dejar ver los productos (el botón «Filtros» sigue arriba)
        if (abrir.offsetParent && abrir.getAttribute('aria-expanded') === 'true') { abrir.setAttribute('aria-expanded', 'false'); mas.classList.remove('abierto'); }
        $('#filtros-resumen', main).textContent = resumenFiltros(f2);
        // Lleva la vista al inicio de los productos para ver el resultado del filtro
        const reducir = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
        $('#resultados', main).scrollIntoView({ behavior: reducir ? 'auto' : 'smooth', block: 'start' });
      };
      form.addEventListener('change', () => aplicar(false));
      $('#orden', main).addEventListener('change', () => aplicar(true));
      $('#limpiar-filtros', main).addEventListener('click', () => {
        history.replaceState(null, '', 'productos.html');
        render();
        anunciar('Filtros limpiados. Se muestran todos los productos.');
      });
    }
  };
}

/* ======================= Detalle de producto ======================= */
function vistaProducto(partes) {
  const p = producto(partes[1]);
  if (!p || p.activo === false) return vistaNoEncontrada();
  const tieneTallas = p.tallas.length > 0;
  const sinStock = !tieneTallas && stockDe(p, null) <= 0;
  return {
    titulo: p.nombre,
    seccion: 'productos',
    html: `
    <div class="contenedor pagina">
      <div class="migas">
        <button class="boton-volver" type="button" id="volver">${icono('izquierda')}Volver</button>
        <nav aria-label="Ruta de navegación"><ol>
          <li><a href="index.html">Inicio</a></li>
          <li><a href="productos.html?cat=${p.categoria}">${CATEGORIAS[p.categoria]}</a></li>
          <li><span aria-current="page">${esc(p.nombre)}</span></li>
        </ol></nav>
      </div>

      <div class="detalle">
        <section class="galeria" aria-label="Fotos del producto">
          <div class="galeria__principal">
            <img id="foto-principal" src="${img(p, 1)}" alt="${esc(p.nombre)}, ${p.vistas[0]}" width="800" height="600">
            <button class="galeria__flecha galeria__flecha--anterior" type="button" data-paso="-1" aria-label="Foto anterior">${icono('chevronIzq')}</button>
            <button class="galeria__flecha galeria__flecha--siguiente" type="button" data-paso="1" aria-label="Foto siguiente">${icono('chevronDer')}</button>
          </div>
          <ul class="galeria__miniaturas">
            ${p.vistas.map((_, i) => i + 1).map((v) => `<li><button class="galeria__miniatura" type="button" data-vista="${v}" aria-label="Ver ${p.vistas[v - 1]}" ${v === 1 ? 'aria-current="true"' : ''}><img src="${img(p, v)}" alt="" width="800" height="600" loading="lazy"></button></li>`).join('')}
          </ul>
        </section>

        <section class="compra" aria-labelledby="nombre-producto">
          <div class="compra__encabezado">
            <span class="etiqueta-categoria">${etiquetaCategoria(p)}</span>
            ${p.etiqueta ? `<span class="etiqueta">${p.etiqueta}</span>` : ''}
          </div>
          <h1 id="nombre-producto">${esc(p.nombre)}</h1>
          <div id="calificacion-producto">${calificacionHtml(p)}</div>
          <div class="compra__precio"><p class="precio">${dinero(p.precio)}</p><p class="texto-suave">Precio sin IVA; el 15 % se suma al pagar · Retiro gratis</p></div>
          <hr class="separador">

          <form id="form-compra" novalidate>
            ${tieneTallas ? `
            <fieldset class="tallas" id="grupo-tallas" aria-describedby="error-talla talla-elegida">
              <div class="tallas__encabezado">
                <legend>Selecciona tu talla (EU)</legend>
                <button class="boton-icono" type="button" id="guia-tallas">${icono('regla')}Guía de tallas</button>
              </div>
              <div class="tallas__lista">
                ${p.tallas.map((t) => { const s = stockDe(p, t); return `<label class="talla ${s <= 0 ? 'talla--agotada' : ''}"><input type="radio" name="talla" value="${t}" ${s <= 0 ? 'disabled' : ''}><span>${t}${s <= 0 ? '<span class="solo-lector"> (agotada)</span>' : ''}</span></label>`; }).join('')}
              </div>
              <p class="texto-suave" id="talla-elegida" style="margin-top:.5rem" aria-live="polite">Elegida: ninguna</p>
              <p class="campo__error" id="error-talla" hidden>${icono('alerta')}<span>Selecciona una talla para agregar el calzado al carrito.</span></p>
            </fieldset>` : ''}

            <div style="margin-top:1.25rem">
              <p style="font-weight:700;margin-bottom:.5rem" id="etiqueta-cantidad">Cantidad</p>
              <div class="fila-cantidad">
                <div class="cantidad" role="group" aria-labelledby="etiqueta-cantidad">
                  <button type="button" data-cambio="-1" aria-label="Quitar una unidad" disabled>${icono('menos')}</button>
                  <output id="cantidad" aria-live="polite">1</output>
                  <button type="button" data-cambio="1" aria-label="Agregar una unidad">${icono('mas')}</button>
                </div>
                <button class="boton-enlace" type="button" id="llevar-todo" hidden>Llevar todo</button>
                <span class="texto-suave" id="limite-cantidad" aria-live="polite">Elige tu talla para ver cuántas unidades hay</span>
              </div>
            </div>

            ${sinStock ? `<p class="alerta" style="margin-top:1.25rem">${icono('info')}<span>Este producto está agotado por ahora.</span></p>` : ''}
            <button class="boton boton--principal boton--bloque" type="submit" style="margin-top:1.25rem" ${sinStock ? 'disabled' : ''}>${icono('carrito')}Agregar al carrito</button>
            ${botonFavorito(p, 'boton boton--secundario boton--bloque boton-favorito--texto', true)}
          </form>

          <ul class="lista-iconos">
            <li>${icono('tienda')}Retiro gratis en tienda, listo de 1 a 3 horas</li>
            <li>${icono('correo')}Te avisamos por correo cuando esté listo</li>
            <li>${icono('escudo')}Paga con cualquier tarjeta o en efectivo al retirar</li>
          </ul>
        </section>
      </div>

      <section class="pestanas" aria-label="Información del producto">
        <div class="pestanas__lista" role="tablist" aria-label="Información del producto">
          <button class="pestanas__boton" role="tab" id="pestana-desc" aria-controls="panel-desc" aria-selected="true">Descripción</button>
          <button class="pestanas__boton" role="tab" id="pestana-ficha" aria-controls="panel-ficha" aria-selected="false" tabindex="-1">Ficha técnica</button>
          <button class="pestanas__boton" role="tab" id="pestana-opin" aria-controls="panel-opin" aria-selected="false" tabindex="-1">Opiniones de clientes</button>
        </div>
        <div class="pestanas__panel" role="tabpanel" id="panel-desc" aria-labelledby="pestana-desc" tabindex="0">
          <p>${esc(p.descripcion)}</p>
          <h2>Características principales</h2>
          <ul class="lista-check">${p.caracteristicas.map((c) => `<li>${icono('check')}${esc(c)}</li>`).join('')}</ul>
        </div>
        <div class="pestanas__panel" role="tabpanel" id="panel-ficha" aria-labelledby="pestana-ficha" tabindex="0" hidden>
          <dl class="ficha">${p.ficha.map(([k, v]) => `<div><dt>${esc(k)}</dt><dd>${esc(v)}</dd></div>`).join('')}</dl>
        </div>
        <div class="pestanas__panel" role="tabpanel" id="panel-opin" aria-labelledby="pestana-opin" tabindex="0" hidden>
          <div id="zona-resenas"><p class="texto-suave">Cargando opiniones…</p></div>
        </div>
      </section>
    </div>`,
    montar(main) {
      let vista = 1;
      let cantidad = 1;
      const foto = $('#foto-principal', main);
      const mostrar = (v) => {
        const n = p.vistas.length;
        vista = ((v - 1 + n) % n) + 1;
        foto.src = img(p, vista);
        foto.alt = `${p.nombre}, ${p.vistas[vista - 1]}`;
        $$('.galeria__miniatura', main).forEach((b) => {
          if (Number(b.dataset.vista) === vista) b.setAttribute('aria-current', 'true'); else b.removeAttribute('aria-current');
        });
      };
      $$('[data-paso]', main).forEach((b) => b.addEventListener('click', () => { mostrar(vista + Number(b.dataset.paso)); anunciar(`Foto ${vista} de ${p.vistas.length}: ${p.vistas[vista - 1]}`); }));
      $$('.galeria__miniatura', main).forEach((b) => {
        b.addEventListener('click', () => mostrar(Number(b.dataset.vista)));
        b.addEventListener('mouseenter', () => mostrar(Number(b.dataset.vista)));
      });
      $('#volver', main).addEventListener('click', () => { if (history.length > 1) history.back(); else ir('productos.html'); });

      // Pestañas accesibles
      const tabs = $$('[role="tab"]', main);
      const activar = (tab, enfocar = true) => {
        tabs.forEach((t) => {
          const activa = t === tab;
          t.setAttribute('aria-selected', activa);
          t.tabIndex = activa ? 0 : -1;
          $('#' + t.getAttribute('aria-controls'), main).hidden = !activa;
        });
        if (enfocar) tab.focus();
      };
      tabs.forEach((t, i) => {
        t.addEventListener('click', () => activar(t));
        t.addEventListener('keydown', (e) => {
          const mov = { ArrowRight: 1, ArrowLeft: -1 }[e.key];
          if (mov) { e.preventDefault(); activar(tabs[(i + mov + tabs.length) % tabs.length]); }
          if (e.key === 'Home') { e.preventDefault(); activar(tabs[0]); }
          if (e.key === 'End') { e.preventDefault(); activar(tabs[tabs.length - 1]); }
        });
      });
      main.addEventListener('click', (e) => {
        if (!e.target.closest('[data-ir-opiniones]')) return;
        const t = $('#pestana-opin', main);
        activar(t, false);
        t.scrollIntoView({ behavior: 'smooth', block: 'start' });
        t.focus({ preventScroll: true });
      });

      // Cantidad: se puede llevar todo el stock disponible
      const salida = $('#cantidad', main);
      const [menos, mas] = $$('[data-cambio]', main);
      const grupoTallas = $('#grupo-tallas', main);
      const tallaElegida = () => { const t = $('input[name="talla"]:checked', main); return t ? t.value : null; };
      const maximo = () => Math.max(1, stockDe(p, tieneTallas ? tallaElegida() : null) || 1);
      const pintarCantidad = () => {
        cantidad = Math.min(cantidad, maximo());
        salida.textContent = cantidad;
        menos.disabled = cantidad <= 1;
        mas.disabled = cantidad >= maximo();
        const stock = stockDe(p, tieneTallas ? tallaElegida() : null);
        $('#limite-cantidad', main).textContent = tieneTallas && !tallaElegida()
          ? 'Elige tu talla para ver cuántas unidades hay'
          : stock > 0 && stock <= POCAS_UNIDADES
            ? (stock === 1 ? `¡Queda solo 1 unidad${tieneTallas ? ' en esta talla' : ''}!` : `¡Quedan solo ${stock} unidades${tieneTallas ? ' en esta talla' : ''}! Puedes llevarlas todas.`)
            : `Disponibles: ${plural(stock, 'unidad', 'unidades')}${tieneTallas ? ' en esta talla' : ''}. Puedes llevarlas todas.`;
        $('#limite-cantidad', main).classList.toggle('limite--pocas', stock > 0 && stock <= POCAS_UNIDADES && !(tieneTallas && !tallaElegida()));
        const todo = $('#llevar-todo', main);
        if (todo) { todo.hidden = (tieneTallas && !tallaElegida()) || stock < 2; todo.textContent = `Llevar todo (${stock})`; }
      };
      const todo = $('#llevar-todo', main);
      if (todo) todo.addEventListener('click', () => { cantidad = maximo(); pintarCantidad(); anunciar(`Cantidad: ${cantidad}`); });
      [menos, mas].forEach((b) => b.addEventListener('click', () => {
        cantidad = Math.min(maximo(), Math.max(1, cantidad + Number(b.dataset.cambio)));
        pintarCantidad();
        if (b.disabled) (b === menos ? mas : menos).focus();
      }));
      pintarCantidad();

      if (grupoTallas) {
        grupoTallas.addEventListener('change', (e) => {
          $('#talla-elegida', main).textContent = `Elegida: ${e.target.value}`;
          $('#error-talla', main).hidden = true;
          grupoTallas.classList.remove('campo-error');
          pintarCantidad();
        });
        $('#guia-tallas', main).addEventListener('click', () => abrirGuiaTallas(p));
      }

      $('#form-compra', main).addEventListener('submit', (e) => {
        e.preventDefault();
        let talla = null;
        if (grupoTallas) {
          talla = tallaElegida();
          if (!talla) {
            $('#error-talla', main).hidden = false;
            grupoTallas.classList.add('campo-error');
            const primera = $('input[name="talla"]:not(:disabled)', main);
            if (primera) primera.focus();
            anunciar('Selecciona una talla para agregar el calzado al carrito.');
            return;
          }
        }
        const agregadas = agregarAlCarrito(p.id, talla, cantidad);
        cantidad = 1;
        pintarCantidad();
        mostrarProductoAgregado(p, talla, agregadas);
      });

      cargarResenas(p, main);
    }
  };
}

/* Guía de tallas: centímetros del pie para cada talla del producto (o de todo el calzado si no se indica) */
function htmlGuiaTallas(p) {
  const filas = p && p.tallas && p.tallas.length ? GUIA_TALLAS.filter(([t]) => p.tallas.includes(t)) : GUIA_TALLAS;
  const nota = p && p.publico === 'Mujer' ? 'Calzado de mujer: tallas 36 a 40 con medias tallas.' : p && p.publico === 'Hombre' ? 'Calzado de hombre: tallas 39 a 45.' : 'Mujer: 36 a 40 con medias tallas · Hombre: 39 a 45.';
  return `<p class="texto-suave" style="margin-bottom:1rem">Mide tu pie del talón al dedo más largo y elige la talla según los centímetros.</p>
    <dl class="guia-tallas">${filas.map(([t, cm]) => `<div><dt>Talla ${t}</dt><dd>${cm}</dd></div>`).join('')}</dl>
    <p class="texto-suave" style="margin-top:1rem">${nota} Si estás entre dos tallas, elige la mayor.</p>`;
}
function abrirGuiaTallas(p) {
  abrirDialogo(`
    <h2 class="dialogo__titulo" id="dialogo-titulo">Guía de tallas${p && p.nombre ? ` · ${esc(p.nombre)}` : ''}</h2>
    ${htmlGuiaTallas(p)}
    <button class="boton boton--principal boton--bloque" type="button" data-cerrar-dialogo style="margin-top:1.25rem">Entendido</button>`, { ancho: true });
}

/* ======================= Reseñas de compra verificada ======================= */
const PALABRA_ESTRELLAS = { 5: 'Excelente', 4: 'Muy bueno', 3: 'Bueno', 2: 'Regular', 1: 'Malo' };
async function cargarResenas(p, main) {
  const zona = $('#zona-resenas', main);
  if (!p.dbId) { zona.innerHTML = '<p class="texto-suave">Las opiniones no están disponibles en este momento.</p>'; return; }
  const r = await Api.resenas.deProducto(p.dbId);
  if (!zona.isConnected) return;
  if (r.error) {
    zona.innerHTML = `<p class="alerta" role="alert">${icono('alerta')}<span>${esc(r.error)}</span></p>`;
    return;
  }
  const lista = r.datos || [];
  const total = lista.length;
  const promedio = total ? lista.reduce((s, x) => s + x.estrellas, 0) / total : 0;
  p.rating = promedio; p.opiniones = total;
  $('#calificacion-producto', main).innerHTML = total
    ? `<p class="calificacion">${estrellas(promedio)}<span>${promedio.toFixed(1)}<span class="solo-lector"> de 5</span> · <button class="enlace-boton" type="button" data-ir-opiniones>Ver ${plural(total, 'opinión', 'opiniones')}</button></span></p>`
    : '<p class="calificacion texto-suave">Sin opiniones todavía</p>';
  const mia = estado.cliente ? lista.find((x) => x.mia) : null;

  zona.innerHTML = `
    <div class="opiniones">
      <div>
        ${total ? `
          <p class="resumen-opiniones__nota">${promedio.toFixed(1)}</p>
          ${estrellas(promedio)}
          <p class="texto-suave">Basado en ${plural(total, 'opinión', 'opiniones')} de clientes que compraron</p>
          <ul class="barras" aria-label="Distribución de calificaciones">
            ${[5, 4, 3, 2, 1].map((n) => { const c = lista.filter((x) => x.estrellas === n).length; const pct = Math.round((c / total) * 100); return `<li class="barra"><span>${plural(n, 'estrella', 'estrellas')}</span><span class="barra__pista" aria-hidden="true"><span class="barra__relleno" style="width:${pct}%"></span></span><span>${c}</span></li>`; }).join('')}
          </ul>` : `<p class="resumen-opiniones__nota" style="font-size:1.5rem">Aún no hay opiniones</p><p class="texto-suave">Las opiniones solo las pueden dejar clientes que compraron este producto.</p>`}
        <div id="zona-escribir" style="margin-top:1.25rem"></div>
      </div>
      <ul class="resenas">
        ${lista.map((x) => { const autor = x.autor || 'Cliente'; const iniciales = autor.split(' ').map((w) => w[0] || '').join('').slice(0, 2).toUpperCase(); return `<li class="resena${x.mia ? ' resena--mia' : ''}">
          <div class="resena__cabecera">
            <span class="resena__avatar" aria-hidden="true">${esc(iniciales)}</span>
            <div><p class="resena__autor">${esc(autor)}${x.mia ? ' <span class="resena__tuya">Tu reseña</span>' : ''}</p>
            <p class="resena__fecha">${fecha(x.creado_en)}</p></div>
          </div>
          <p class="resena__nota">${estrellas(x.estrellas)}<span class="solo-lector">${x.estrellas} de 5 estrellas</span><strong>${PALABRA_ESTRELLAS[x.estrellas] || ''}</strong></p>
          <p class="resena__texto">${esc(x.comentario)}</p>
          <p class="resena__pie"><span class="verificada">${icono('check')}Compra verificada</span><span>Compró este producto en ATHLETIX</span></p></li>`; }).join('')}
      </ul>
    </div>`;
  pintarZonaEscribir(p, main, mia);
}

async function pintarZonaEscribir(p, main, mia) {
  const zona = $('#zona-escribir', main);
  if (!zona) return;
  // Desde el correo de "pedido retirado" se llega con ?resenar=1: se abre directo el formulario de reseña
  const desdeCorreo = leerRuta().params.get('resenar') === '1';
  if (!estado.sesion) {
    if (desdeCorreo) { aviso('Inicia sesión para escribir tu reseña.'); ir(conVolver('login.html', paginaActual())); return; }
    zona.innerHTML = `<p class="texto-suave">¿Compraste este producto? <a href="${conVolver('login.html', paginaActual())}">Inicia sesión</a> para dejar tu opinión.</p>`;
    return;
  }
  if (!estado.cliente) { zona.innerHTML = ''; return; }
  zona.innerHTML = `<button class="boton boton--secundario boton--bloque" type="button" id="escribir-resena">${icono(mia ? 'editar' : 'estrella')}${mia ? 'Editar mi reseña' : 'Escribir reseña'}</button>
    <div id="resultado-compra" aria-live="polite"></div>`;
  $('#escribir-resena', zona).addEventListener('click', async (e) => {
    const salida = $('#resultado-compra', zona);
    salida.innerHTML = '';
    if (mia) { abrirFormularioResena(p, main, mia); return; }
    // Antes de abrir el formulario se busca en la base una compra de este producto hecha con esta cuenta
    const r = await conEspera(e.currentTarget, 'Verificando tu compra…', () => Api.pedidos.compro(p.dbId));
    if (!r) return;
    if (r.error) { salida.innerHTML = `<p class="alerta" style="margin-top:.75rem">${icono('alerta')}<span>${esc(r.error)}</span></p>`; return; }
    if (!r.datos) {
      salida.innerHTML = `<p class="alerta alerta--error" style="margin-top:.75rem" role="alert">${icono('alerta')}<span><strong>No encontramos una compra de este producto en tu cuenta.</strong> Solo los clientes que compraron este producto pueden dejar una reseña.</span></p>`;
      return;
    }
    abrirFormularioResena(p, main, null, r.datos);
  });
  if (desdeCorreo) {
    history.replaceState(null, '', `producto.html?id=${encodeURIComponent(p.id)}`);
    const pestana = $('#pestana-opin', main);
    if (pestana) { pestana.click(); pestana.scrollIntoView({ block: 'start' }); }
    $('#escribir-resena', zona).click();
  }
}

/* alTerminar: qué hacer después de guardar o borrar (en el producto se recargan sus reseñas; en Mis pedidos se recarga la lista) */
function abrirFormularioResena(p, main, mia, pedidoVerificado, alTerminar) {
  const terminar = alTerminar || (() => cargarResenas(p, main));
  abrirDialogo(`
    <h2 class="dialogo__titulo" id="dialogo-titulo">${mia ? 'Editar mi reseña' : 'Escribir reseña'}</h2>
    <p class="texto-suave" style="margin-bottom:${pedidoVerificado ? '.5rem' : '1rem'}">${esc(p.nombre)}</p>
    ${pedidoVerificado ? `<p class="verificada" style="margin-bottom:1rem">${icono('check')}Compra verificada · pedido ${esc(pedidoVerificado)}</p>` : ''}
    <form class="formulario" id="form-resena" novalidate>
      <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
      <fieldset class="selector-estrellas" aria-describedby="estrellas-error">
        <legend>Tu calificación <span class="requerido" aria-hidden="true">*</span></legend>
        <div class="selector-estrellas__lista">
          ${[1, 2, 3, 4, 5].map((n) => `<label><input type="radio" name="estrellas" value="${n}" ${mia && mia.estrellas === n ? 'checked' : ''}><span aria-hidden="true">${icono('estrella')}</span><span class="solo-lector">${plural(n, 'estrella', 'estrellas')}</span></label>`).join('')}
        </div>
        <p class="campo__error" id="estrellas-error" hidden>${icono('alerta')}<span></span></p>
      </fieldset>
      <div class="campo">
        <label for="comentario">Tu opinión <span class="requerido" aria-hidden="true">*</span></label>
        <p class="campo__ayuda" id="comentario-ayuda">Entre 10 y 500 caracteres. Cuéntanos cómo te fue con el producto.</p>
        <textarea id="comentario" name="comentario" rows="4" maxlength="500" aria-describedby="comentario-ayuda comentario-error contador-comentario">${mia ? esc(mia.comentario) : ''}</textarea>
        <p class="texto-suave" id="contador-comentario" aria-live="polite">${mia ? mia.comentario.length : 0} / 500</p>
        <p class="campo__error" id="comentario-error" hidden>${icono('alerta')}<span></span></p>
      </div>
      <div class="dialogo__botones">
        ${mia ? '<button class="boton boton--secundario" type="button" id="borrar-resena">Borrar</button>' : '<button class="boton boton--secundario" type="button" data-cerrar-dialogo>Cancelar</button>'}
        <button class="boton boton--principal" type="submit">Publicar reseña</button>
      </div>
    </form>`, {
    alAbrir: (d) => {
      const form = $('#form-resena', d);
      const texto = $('#comentario', form);
      const radios = $$('input[name="estrellas"]', form);
      const pintarEstrellas = () => {
        const v = Number((radios.find((r) => r.checked) || {}).value || 0);
        radios.forEach((r) => r.parentElement.classList.toggle('activa', Number(r.value) <= v));
      };
      radios.forEach((r) => r.addEventListener('change', pintarEstrellas));
      pintarEstrellas();
      (radios.find((r) => r.checked) || radios[0]).focus();
      texto.addEventListener('input', () => { $('#contador-comentario', form).textContent = `${texto.value.length} / 500`; });
      if (mia) {
        $('#borrar-resena', form).addEventListener('click', async (e) => {
          const r = await conEspera(e.currentTarget, 'Borrando…', () => Api.resenas.borrar(estado.cliente.cedula, p.dbId));
          if (!r) return;
          if (r.error) { errorGeneral(form, r.error); return; }
          cerrarDialogo();
          aviso('Borraste tu reseña.');
          terminar();
        });
      }
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const valor = Number((radios.find((r) => r.checked) || {}).value || 0);
        const comentario = texto.value.trim().replace(/\s+/g, ' ');
        const errEstrellas = valor ? '' : 'Elige de 1 a 5 estrellas.';
        const errEst = $('#estrellas-error', form);
        errEst.hidden = !errEstrellas; $('span', errEst).textContent = errEstrellas;
        const reglas = [['comentario', comentario.length < 10 ? 'Escribe al menos 10 caracteres.' : '']];
        if (errEstrellas) reglas.unshift([radios[0].id = 'estrella-1', errEstrellas]);
        if (!validarFormulario(form, reglas, 'Revisa tu reseña:')) return;
        const r = await conEspera($('button[type="submit"]', form), 'Publicando…', () =>
          Api.resenas.guardar(!!mia, { cedula: estado.cliente.cedula, producto: p.dbId, estrellas: valor, comentario }));
        if (!r) return;
        if (r.error) { errorGeneral(form, r.error); return; }
        cerrarDialogo();
        aviso('¡Gracias! Tu reseña ya está publicada.');
        terminar();
      });
    }
  });
}

/* ======================= Carrito ======================= */
function agregarAlCarrito(id, talla, cantidad) {
  const p = producto(id);
  const limite = stockDe(p, talla);
  const linea = estado.carrito.find((i) => i.id === id && i.talla === talla);
  let agregadas = Math.min(cantidad, limite - (linea ? linea.cantidad : 0));
  if (agregadas <= 0) return 0;
  if (linea) linea.cantidad += agregadas;
  else estado.carrito.push({ id, talla, cantidad: agregadas });
  guardarCarrito();
  actualizarContador();
  return agregadas;
}

function mostrarProductoAgregado(p, talla, agregadas) {
  const limite = agregadas <= 0;
  abrirDialogo(`
    <h2 class="dialogo__titulo" id="dialogo-titulo"><span class="icono-ok">${icono(limite ? 'info' : 'check')}</span>${limite ? 'Ya tienes el máximo' : '¡Producto agregado al carrito!'}</h2>
    <p>${limite ? `Ya tienes en tu carrito todas las unidades disponibles de ${esc(p.nombre)}${talla ? ` en talla ${talla}` : ''}. No hay más stock.` : `${plural(agregadas, 'unidad', 'unidades')} de ${esc(p.nombre)}${talla ? `, talla ${talla}` : ''}.`}</p>
    <dl class="datos-lista" style="margin-top:1rem">
      <dt>Productos en tu carrito</dt><dd>${unidadesCarrito()}</dd>
      <dt>Subtotal</dt><dd>${dinero(subtotalCarrito())}</dd>
    </dl>
    <div class="dialogo__botones">
      <a class="boton boton--secundario seguir-comprando" href="${urlCatalogo()}" id="seguir-comprando">Seguir comprando</a>
      <a class="boton boton--principal" href="carrito.html">${icono('carrito')}Ver carrito</a>
    </div>`, { alAbrir: (d) => $('#seguir-comprando', d).focus() });
}

function pasos(actual) {
  const nombres = ['Carrito', 'Entrega', 'Pago', 'Confirmación'];
  return `<ol class="pasos" aria-label="Pasos de la compra">${nombres.map((n, i) => {
    const estadoPaso = i + 1 < actual ? 'hecho' : (i + 1 === actual ? 'actual' : '');
    return `<li class="paso ${estadoPaso ? 'paso--' + estadoPaso : ''}" ${i + 1 === actual ? 'aria-current="step"' : ''}>
      <span class="paso__numero">${i + 1 < actual ? icono('check') : i + 1}</span><span class="paso__texto">${n}</span>
      ${i + 1 < actual ? '<span class="solo-lector"> (completado)</span>' : ''}</li>`;
  }).join('')}</ol>`;
}

function resumenPedido(extra = '') {
  return `
    <aside class="panel panel--gris resumen" aria-labelledby="titulo-resumen">
      <h2 id="titulo-resumen">Resumen del pedido</h2>
      <dl>
        <dt>Productos</dt><dd>${unidadesCarrito()}</dd>
        <dt>Subtotal</dt><dd>${dinero(subtotalCarrito())}</dd>
        <dt>IVA (15 %)</dt><dd>${dinero(ivaCarrito())}</dd>
        <dt>Retiro en tienda</dt><dd>Gratis</dd>
        <dt class="resumen__total">Total</dt><dd class="resumen__total">${dinero(totalCarrito())}</dd>
      </dl>
      ${extra}
    </aside>`;
}

/* Quita del carrito productos que ya no existen y ajusta cantidades al stock disponible */
function revisarCarrito() {
  const avisos = [];
  estado.carrito = estado.carrito.filter((l) => {
    const p = producto(l.id);
    if (!p || p.activo === false || (p.tallas.length && !p.tallas.includes(l.talla)) || (!p.tallas.length && l.talla)) { avisos.push('Quitamos un producto que ya no está disponible.'); return false; }
    const stock = stockDe(p, l.talla);
    if (stock <= 0) { avisos.push(`${p.nombre}${l.talla ? ' talla ' + l.talla : ''} se agotó y lo quitamos del carrito.`); return false; }
    if (l.cantidad > stock) { l.cantidad = stock; avisos.push(`Ajustamos la cantidad de ${p.nombre} a ${l.cantidad} (stock disponible).`); }
    return true;
  });
  if (avisos.length) { guardarCarrito(); actualizarContador(); }
  return avisos;
}

function vistaCarrito() {
  const avisos = revisarCarrito();
  const vacio = estado.carrito.length === 0;
  return {
    titulo: 'Tu carrito',
    seccion: 'carrito',
    html: `
    <div class="contenedor pagina">
      ${pasos(1)}
      <h1 class="titulo-pagina cabecera-pagina">Tu carrito</h1>
      ${avisos.length ? `<div class="alerta alerta--info" role="status" style="margin-bottom:1.25rem">${icono('info')}<ul style="margin:0">${avisos.map((a) => `<li>${esc(a)}</li>`).join('')}</ul></div>` : ''}
      ${vacio ? `
        <div class="panel panel--gris vacio">
          ${icono('carrito')}
          <h2 class="titulo-seccion">Tu carrito está vacío</h2>
          <p class="texto-suave">Agrega productos para empezar tu compra.</p>
          <a class="boton boton--principal" href="productos.html">Ver productos</a>
        </div>` : `
        <div class="compra-grilla">
          <section aria-label="Productos en tu carrito">
            <ul class="lista-carrito">${estado.carrito.map(itemCarrito).join('')}</ul>
          </section>
          ${resumenPedido(`
            <button class="boton boton--principal boton--bloque" type="button" id="continuar-compra">Continuar con la compra</button>
            <a class="boton boton--secundario boton--bloque seguir-comprando" href="${urlCatalogo()}">${icono('izquierda')}Seguir comprando</a>
            <div style="text-align:center;margin-top:.5rem"><button class="boton-icono" type="button" id="vaciar">${icono('basura')}Vaciar carrito</button></div>
            <p class="texto-suave" style="margin-top:1rem;display:flex;gap:.5rem">${icono('candado')}Aceptamos todas las tarjetas, o paga en efectivo al retirar.</p>`)}
        </div>`}
    </div>`,
    montar(main) {
      if (vacio) return;
      $('#continuar-compra', main).addEventListener('click', () => {
        if (!estado.catalogoConectado) { aviso('No hay conexión con la tienda. Revisa tu internet y vuelve a intentarlo.', 'error'); return; }
        ir(estado.sesion ? 'retiro.html' : 'login.html?volver=retiro');
      });
      $('#vaciar', main).addEventListener('click', async () => {
        if (!(await confirmar('¿Vaciar el carrito?', 'Se quitarán todos los productos del carrito.', 'Sí, vaciar'))) { $('#vaciar').focus(); return; }
        estado.carrito = [];
        guardarCarrito(); actualizarContador();
        render();
        anunciar('Vaciaste el carrito.');
      });
      main.addEventListener('click', (e) => {
        const b = e.target.closest('[data-item]');
        if (!b) return;
        const i = Number(b.dataset.item);
        const linea = estado.carrito[i];
        if (!linea) return;
        const p = producto(linea.id);
        const accion = b.dataset.accion;
        if (accion === 'menos' || accion === 'mas') {
          const max = stockDe(p, linea.talla);
          linea.cantidad = Math.min(max, Math.max(1, linea.cantidad + (accion === 'mas' ? 1 : -1)));
          guardarCarrito(); actualizarContador();
          rerenderCarrito(`[data-item="${i}"][data-accion="${accion}"]`, `[data-item="${i}"][data-accion="${accion === 'mas' ? 'menos' : 'mas'}"]`);
          anunciar(`${p.nombre}: ${plural(linea.cantidad, 'unidad', 'unidades')}. Total ${dinero(totalCarrito())}.`);
        }
        if (accion === 'eliminar') {
          const quitada = estado.carrito.splice(i, 1)[0];
          guardarCarrito(); actualizarContador();
          rerenderCarrito('[data-accion="eliminar"]', '#continuar-compra');
          // Control y libertad del usuario: se puede deshacer
          aviso(`Quitaste ${p.nombre} del carrito.`, 'ok', { texto: 'Deshacer', fn: () => {
            estado.carrito.splice(Math.min(i, estado.carrito.length), 0, quitada);
            guardarCarrito(); actualizarContador(); render();
            anunciar(`${p.nombre} volvió a tu carrito.`);
          } });
        }
        if (accion === 'talla') abrirCambioTalla(i);
      });
    }
  };
}

function rerenderCarrito(...selectores) {
  render();
  const main = $('#contenido');
  for (const s of selectores) {
    const el = $(s, main);
    if (el && !el.disabled) { el.focus(); return; }
  }
  const t = $('h1', main); if (t) t.focus();
}

function itemCarrito(linea, i) {
  const p = producto(linea.id);
  const nombreCompleto = `${p.nombre}${linea.talla ? ', talla ' + linea.talla : ''}`;
  const max = stockDe(p, linea.talla);
  return `
    <li class="item-carrito">
      <a class="item-carrito__imagen" href="producto.html?id=${p.id}" tabindex="-1" aria-hidden="true"><img src="${img(p)}" alt="" width="800" height="600"></a>
      <div>
        <p class="texto-suave" style="font-size:.85rem">${CATEGORIAS[p.categoria]}</p>
        <h2 class="item-carrito__nombre"><a href="producto.html?id=${p.id}">${esc(p.nombre)}</a></h2>
        ${linea.talla ? `<p class="item-carrito__talla"><span>Talla: <strong>${linea.talla}</strong></span>
          <button class="boton-icono" type="button" data-item="${i}" data-accion="talla" style="min-height:2.25rem;color:var(--verde)">${icono('editar')}Cambiar talla<span class="solo-lector"> de ${esc(p.nombre)}</span></button></p>` : ''}
        <p class="texto-suave">${dinero(p.precio)} c/u</p>
      </div>
      <div class="item-carrito__acciones">
        <div class="cantidad" role="group" aria-label="Cantidad de ${esc(nombreCompleto)}">
          <button type="button" data-item="${i}" data-accion="menos" aria-label="Quitar una unidad" ${linea.cantidad <= 1 ? 'disabled' : ''}>${icono('menos')}</button>
          <output>${linea.cantidad}</output>
          <button type="button" data-item="${i}" data-accion="mas" aria-label="Agregar una unidad" ${linea.cantidad >= max ? 'disabled' : ''}>${icono('mas')}</button>
        </div>
        <p class="item-carrito__subtotal"><span class="solo-lector">Subtotal: </span>${dinero(p.precio * linea.cantidad)}</p>
        <button class="boton-icono" type="button" data-item="${i}" data-accion="eliminar">${icono('basura')}Eliminar<span class="solo-lector"> ${esc(nombreCompleto)}</span></button>
      </div>
    </li>`;
}

function abrirCambioTalla(i) {
  const linea = estado.carrito[i];
  const p = producto(linea.id);
  abrirDialogo(`
    <h2 class="dialogo__titulo" id="dialogo-titulo">Cambiar talla</h2>
    <p><strong>${esc(p.nombre)}</strong></p>
    <p class="texto-suave" style="margin-bottom:1rem">Talla actual: <strong>${linea.talla}</strong></p>
    <form id="form-talla">
      <fieldset class="tallas">
        <legend style="margin-bottom:.6rem">Elige la nueva talla (EU)</legend>
        <div class="tallas__lista">
          ${p.tallas.map((t) => { const s = stockDe(p, t); return `<label class="talla ${s <= 0 ? 'talla--agotada' : ''}"><input type="radio" name="nueva" value="${t}" ${t === linea.talla ? 'checked' : ''} ${s <= 0 && t !== linea.talla ? 'disabled' : ''}><span>${t}${s <= 0 ? '<span class="solo-lector"> (agotada)</span>' : ''}</span></label>`; }).join('')}
        </div>
      </fieldset>
      <div class="dialogo__botones">
        <button class="boton boton--secundario" type="button" data-cerrar-dialogo>Cancelar</button>
        <button class="boton boton--principal" type="submit">Cambiar talla</button>
      </div>
    </form>`, {
    alAbrir: (d) => {
      $('input:checked', d).focus();
      $('#form-talla', d).addEventListener('submit', (e) => {
        e.preventDefault();
        const nueva = new FormData(e.target).get('nueva');
        cerrarDialogo();
        if (!nueva || nueva === linea.talla) return;
        const max = stockDe(p, nueva);
        const otra = estado.carrito.find((x, j) => j !== i && x.id === linea.id && x.talla === nueva);
        if (otra) {
          otra.cantidad = Math.min(max, otra.cantidad + linea.cantidad);
          estado.carrito.splice(i, 1);
        } else {
          linea.talla = nueva;
          linea.cantidad = Math.min(max, linea.cantidad);
        }
        guardarCarrito(); actualizarContador();
        rerenderCarrito('[data-accion="talla"]');
        anunciar(`Cambiaste ${p.nombre} a la talla ${nueva}.`);
      });
    }
  });
}

/* ======================= Mis favoritos (guardados en el navegador) ======================= */
function vistaFavoritos() {
  const lista = estado.favoritos.map(producto).filter((p) => p && p.activo !== false);
  return {
    titulo: 'Mis favoritos',
    seccion: 'favoritos',
    html: `
    <div class="contenedor pagina">
      <nav class="migas" aria-label="Ruta de navegación"><ol><li><a href="index.html">Inicio</a></li><li><span aria-current="page">Mis favoritos</span></li></ol></nav>
      <div class="cabecera-pagina">
        <h1 class="titulo-pagina">Mis favoritos</h1>
        <p class="subtitulo">${lista.length ? `${plural(lista.length, 'producto guardado', 'productos guardados')}. Pulsa el corazón para quitar uno.` : 'Guarda productos con el corazón para verlos aquí más tarde.'}</p>
      </div>
      ${lista.length ? `<div class="botones-fila" style="margin-bottom:1.25rem"><button class="boton boton--principal" type="button" id="todo-al-carrito">${icono('carrito')}Agregar todos al carrito</button></div>
        <ul class="grilla-productos">${lista.map(tarjetaProducto).join('')}</ul>`
        : `<div class="vacio panel">${icono('corazon')}<p>Todavía no tienes favoritos.</p><a class="boton boton--principal" href="productos.html">Ver productos</a></div>`}
    </div>`,
    montar(main) {
      const boton = $('#todo-al-carrito', main);
      if (boton) boton.addEventListener('click', () => agregarFavoritosAlCarrito(lista));
    }
  };
}

/* Agrega al carrito todos los favoritos con stock (1 unidad de cada uno).
   Los que tienen tallas piden elegir la talla en una ventana antes de agregarse. */
function agregarFavoritosAlCarrito(lista) {
  const conStock = lista.filter((p) => (p.tallas.length ? p.tallas.some((t) => stockDe(p, t) > 0) : stockDe(p, null) > 0));
  const sinStock = lista.length - conStock.length;
  const conTalla = conStock.filter((p) => p.tallas.length);
  const sinTalla = conStock.filter((p) => !p.tallas.length);
  const terminar = (elegidas) => {
    let n = 0;
    sinTalla.forEach((p) => { n += agregarAlCarrito(p.id, null, 1) > 0 ? 1 : 0; });
    elegidas.forEach(([id, talla]) => { n += agregarAlCarrito(id, talla, 1) > 0 ? 1 : 0; });
    const extra = sinStock ? ` ${plural(sinStock, 'producto está agotado', 'productos están agotados')} y no se agregó.` : '';
    abrirDialogo(`
      <h2 class="dialogo__titulo" id="dialogo-titulo"><span class="icono-ok">${icono(n ? 'check' : 'info')}</span>${n ? `Agregamos ${plural(n, 'producto', 'productos')} al carrito` : 'No se agregó ningún producto'}</h2>
      <p>${n ? `Tienes ${plural(unidadesCarrito(), 'unidad', 'unidades')} en tu carrito · Subtotal ${dinero(subtotalCarrito())}.` : 'No hay stock disponible de tus favoritos o ya tienes en el carrito todo lo disponible.'}${extra}</p>
      <div class="dialogo__botones">
        <a class="boton boton--secundario seguir-comprando" href="${urlCatalogo()}">Seguir comprando</a>
        <a class="boton boton--principal" href="carrito.html">${icono('carrito')}Ver carrito</a>
      </div>`, { alAbrir: (d) => $('a.boton--principal', d).focus() });
  };
  if (!conTalla.length) { terminar([]); return; }
  // Cada calzado con sus tallas como en la página del producto, y su guía de tallas para elegir bien
  abrirDialogo(`
    <h2 class="dialogo__titulo" id="dialogo-titulo">Elige las tallas</h2>
    <p>Elige la talla de cada calzado. Si no quieres agregar alguno, déjalo en «No agregar».</p>
    <form id="form-tallas-fav" class="formulario" style="margin-top:1rem">
      ${conTalla.map((p, i) => `
      <fieldset class="tallas fav-talla" aria-describedby="fav-elegida-${i}">
        <div class="fav-talla__producto"><img src="${img(p)}" alt="" width="64" height="64"><div><legend>${esc(p.nombre)}</legend><span class="texto-suave d-bloque">${esc(p.publico || '')} · ${dinero(p.precio)}</span></div></div>
        <div class="tallas__lista">
          <label class="talla talla--no"><input type="radio" name="fav-${i}" value="" data-id="${p.id}" checked><span>No agregar</span></label>
          ${p.tallas.map((t) => { const st = stockDe(p, t); return `<label class="talla ${st <= 0 ? 'talla--agotada' : ''}"><input type="radio" name="fav-${i}" value="${t}" data-id="${p.id}" ${st <= 0 ? 'disabled' : ''}><span>${t}${st <= 0 ? '<span class="solo-lector"> (agotada)</span>' : ''}</span></label>`; }).join('')}
        </div>
        <p class="texto-suave" id="fav-elegida-${i}" aria-live="polite" style="margin-top:.4rem">Elegida: ninguna</p>
        <details class="fav-guia"><summary>${icono('regla')}Guía de tallas</summary>${htmlGuiaTallas(p)}</details>
      </fieldset>`).join('')}
      <div class="dialogo__botones">
        <button class="boton boton--secundario" type="button" data-cerrar-dialogo>Cancelar</button>
        <button class="boton boton--principal" type="submit">${icono('carrito')}Agregar al carrito</button>
      </div>
    </form>`, { ancho: true, alAbrir: (d) => { const primera = $('input:not([value=""]):not(:disabled)', d); if (primera) primera.focus(); } });
  const form = $('#form-tallas-fav');
  form.addEventListener('change', (e) => {
    const i = e.target.name.replace('fav-', '');
    const salida = $(`#fav-elegida-${i}`, form);
    if (salida) salida.textContent = e.target.value ? `Elegida: ${e.target.value}` : 'Elegida: ninguna';
  });
  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const elegidas = $$('input[type="radio"]:checked', form).filter((r) => r.value).map((r) => [r.dataset.id, r.value]);
    terminar(elegidas);
  });
}
