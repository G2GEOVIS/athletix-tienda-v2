/* ATHLETIX · Panel del administrador, ayuda y página no encontrada */
'use strict';

/* ======================= Panel de pedidos (administrador) ======================= */
// Estados a los que puede pasar cada pedido (la base de datos aplica las mismas reglas)
const SIGUIENTES = {
  Recibido: ['Preparando', 'Listo', 'Cancelado'],
  Preparando: ['Listo', 'Cancelado'],
  Listo: ['Retirado', 'Cancelado'],
  Retirado: [],
  Cancelado: []
};
async function vistaAdmin(partes, params) {
  if (!protegerCuenta()) return null;
  if (!estado.esAdmin) return vistaNoEncontrada();
  const r = await Api.pedidos.todos();
  if (r.error) return { titulo: 'Panel de pedidos', seccion: 'admin', html: errorCargaHtml(r.error) };
  const filtro = ['Recibido', 'Preparando', 'Listo', 'Retirado', 'Cancelado'].includes(params.get('estado')) ? params.get('estado') : '';
  const todos = r.datos || [];
  const lista = filtro ? todos.filter((p) => p.estado === filtro) : todos;
  const rd = await Api.pedidos.detalles(lista.slice(0, 200).map((p) => p.id));
  const detalles = rd.error ? {} : rd.datos;
  // Fotos de lo que pidió el cliente; si no se pudo leer el detalle, se muestra el texto de siempre
  const productosHtml = (p) => {
    const ds = detalles[p.id];
    if (!ds || !ds.length) return `<dt>Productos</dt><dd>${esc(p.productos)}</dd>`;
    return `<dt>Productos</dt><dd><ul class="admin-productos">${ds.map((d) => { const pr = productoPorDbId(d.producto_id); return `<li>${pr ? `${foto(img(pr), { ancho: 64, alto: 64, sizes: 64 })}` : '<span class="admin-productos__sin"></span>'}<span><strong>${esc(pr ? pr.nombre : d.producto_id)}</strong><span class="texto-suave">${d.cantidad} × ${dinero(d.precio_unitario)}${d.talla ? ` · Talla ${esc(d.talla)}` : ''} · Cód. ${esc(d.producto_id)}</span></span></li>`; }).join('')}</ul></dd>`;
  };
  const cuenta = (e) => todos.filter((p) => p.estado === e).length;
  const resaltar = leerTemporal('pedido-resaltado');
  return {
    titulo: 'Panel de pedidos',
    seccion: 'admin',
    html: `
    <div class="contenedor pagina">
      ${menuAdmin('pedidos')}
      <h1 class="titulo-pagina">Panel de pedidos</h1>
      <p class="subtitulo cabecera-pagina">Cambia el estado de cada pedido. Con cada cambio (preparando, listo para retirar, retirado o cancelado) el cliente recibe un correo automáticamente.</p>
      ${avisoStockBajo()}
      ${Api.correo.configurado() ? '' : `<p class="alerta" style="margin-bottom:1rem">${icono('alerta')}<span>El envío de correos no está configurado (falta la plantilla de EmailJS).</span></p>`}
      <nav class="filtro-estados" aria-label="Filtrar pedidos por estado">
        <a href="admin.html" ${!filtro ? 'aria-current="page"' : ''}>Todos (${todos.length})</a>
        ${ESTADOS.concat('Cancelado').map((e) => `<a href="admin.html?estado=${e}" ${filtro === e ? 'aria-current="page"' : ''}>${NOMBRE_ESTADO[e]} (${cuenta(e)})</a>`).join('')}
      </nav>
      ${!lista.length ? `<div class="panel panel--gris vacio">${icono('paquete')}<p>No hay pedidos${filtro ? ' en este estado' : ''}.</p></div>` : `
      <ul class="pedidos">${lista.map((p) => `
        <li class="pedido${resaltar === p.id ? ' pedido--resaltado' : ''}" data-pedido="${p.id}" tabindex="-1">
          <div class="pedido__cabecera">
            <h2 class="pedido__numero">${esc(p.numero)}</h2>
            <span class="estado estado--${p.estado.toLowerCase()}">${nombreEstado(p.estado)}</span>
          </div>
          <p class="texto-suave">${fechaHora(p.creado_en)} · ${icono('tienda')} Retiro en ${esc(p.tienda)}</p>
          <dl class="datos-lista datos-lista--compacta" style="margin-top:.75rem">
            <dt>Cliente</dt><dd>${esc(p.cliente)} · ${nombreDocumento(p.cedula)} ${esc(p.cedula)}</dd>
            <dt>Contacto</dt><dd>${esc(p.correo)} · ${esc(p.telefono)}</dd>
            ${productosHtml(p)}
            <dt>Código</dt><dd><strong>${esc(p.codigoRetiro || '')}</strong> · listo aprox. ${p.horaEstimada ? fechaHora(p.horaEstimada) : ''}</dd>
            <dt>Pago</dt><dd>${esc(p.pagoTexto)}</dd>
            <dt>Total</dt><dd>${dinero(p.total)}</dd>
          </dl>
          <a class="enlace-pequeno" href="orden.html?pedido=${p.id}">${icono('documento')}Ver orden de pedido</a>
          ${SIGUIENTES[p.estado].length ? `
          <div class="cambio-estado" role="group" aria-labelledby="cambiar-${p.id}">
            <p id="cambiar-${p.id}" class="cambio-estado__titulo">Pasar a:</p>
            ${SIGUIENTES[p.estado].map((e) => `<button class="boton ${e === 'Cancelado' ? 'boton--peligro' : 'boton--principal'}" type="button" data-pedido-id="${p.id}" data-nuevo-estado="${e}">${e === 'Cancelado' ? 'Cancelar pedido' : nombreEstado(e)}</button>`).join('')}
          </div>` : `<p class="texto-suave" style="margin-top:1rem">${p.estado === 'Retirado' ? 'Pedido entregado: ya no cambia de estado.' : 'Pedido cancelado: el pago se anuló y el stock volvió.'}</p>`}
          <p class="texto-suave resultado-estado" aria-live="polite"></p>
        </li>`).join('')}
      </ul>`}
    </div>`,
    montar(main) {
      // Si se acaba de cambiar un pedido, se muestra resaltado en su nueva pestaña
      const resaltado = resaltar && $(`[data-pedido="${resaltar}"]`, main);
      if (resaltado) { resaltado.scrollIntoView({ block: 'center' }); resaltado.focus({ preventScroll: true }); }
      guardarTemporal('pedido-resaltado', null);

      main.addEventListener('click', async (e) => {
        const boton = e.target.closest('[data-nuevo-estado]');
        if (!boton) return;
        const p = todos.find((x) => x.id === Number(boton.dataset.pedidoId));
        const nuevo = boton.dataset.nuevoEstado;
        if (nuevo === 'Cancelado' && !(await confirmar('¿Cancelar este pedido?', `El pedido ${p.numero} se cancelará: sus productos vuelven al stock y el pago queda anulado. No se puede deshacer.`, 'Sí, cancelar'))) return;
        $$('[data-nuevo-estado]', boton.parentElement).forEach((b) => { if (b !== boton) b.disabled = true; });
        const r2 = await conEspera(boton, 'Guardando…', async () => {
          const rc = await Api.pedidos.cambiarEstado(p.id, nuevo);
          if (rc.error) return rc;
          p.estado = nuevo;
          // El cliente recibe un correo con cada cambio de estado de su pedido
          return { correo: await Api.correo.pedidoActualizado(p, nuevo) };
        });
        if (!r2 || r2.error) {
          $$('[data-nuevo-estado]', boton.parentElement).forEach((b) => { b.disabled = false; });
          if (r2) aviso(r2.error, 'error');
          return;
        }
        let texto = `El pedido ${p.numero} pasó a "${nombreEstado(nuevo)}".`;
        if (r2.correo) texto += r2.correo.error ? ` ${r2.correo.error}` : ` Se envió un correo a ${p.correo}.`;
        aviso(texto, r2.correo && r2.correo.error ? 'error' : 'ok');
        anunciar(texto);
        revisarPedidosNuevos();
        // El pedido aparece de inmediato en la pestaña de su nuevo estado
        guardarTemporal('pedido-resaltado', p.id);
        const destino = filtro ? `admin.html?estado=${nuevo}` : 'admin.html';
        ir(destino);
      });
    }
  };
}

/* ======================= Menú del administrador ======================= */
function menuAdmin(actual) {
  const items = [['pedidos', 'admin.html', 'paquete', 'Pedidos'], ['productos', 'admin-productos.html', 'tienda', 'Productos'], ['stock', 'admin-stock.html', 'grafico', 'Stock'], ['pagos', 'admin-pagos.html', 'tarjeta', 'Pagos']];
  return `<nav class="menu-admin" aria-label="Administración">${items.map(([k, href, ic, t]) => `<a href="${href}" ${k === actual ? 'aria-current="page"' : ''}>${icono(ic)}${t}</a>`).join('')}</nav>`;
}
function soloAdmin() {
  if (!protegerCuenta()) return false;
  if (!estado.esAdmin) return 'no';
  return true;
}

/* ======================= Productos (administrador): leer, crear, editar, desactivar, borrar ======================= */
async function vistaAdminProductos(partes, params) {
  const ok = soloAdmin(); if (!ok) return null; if (ok === 'no') return vistaNoEncontrada();
  if (!estado.catalogoConectado) await cargarCatalogo();
  const q = normalizar(params.get('q') || '');
  const cat = CATEGORIAS[params.get('cat')] ? params.get('cat') : '';
  let lista = PRODUCTOS.slice();
  if (cat) lista = lista.filter((p) => p.categoria === cat);
  if (q) lista = lista.filter((p) => normalizar(`${p.id} ${p.nombre}`).includes(q));
  const stockTotal = (p) => Object.values(p.stock || {}).reduce((a, b) => a + b, 0);
  return {
    titulo: 'Productos (administrador)',
    seccion: 'admin',
    html: `
    <div class="contenedor pagina">
      ${menuAdmin('productos')}
      <div class="cabecera-seccion"><h1 class="titulo-pagina">Productos</h1>
        <a class="boton boton--principal" href="admin-producto.html">${icono('mas')}Nuevo producto</a></div>
      <p class="subtitulo cabecera-pagina">${plural(PRODUCTOS.length, 'producto', 'productos')} en la base de datos. Edita precio, stock, fotos y datos, o desactiva los que no quieras mostrar.</p>
      <form class="filtro-admin" id="filtro-admin" role="search" aria-label="Filtrar productos">
        <div class="campo"><label for="buscar-admin">Buscar por código o nombre</label><input id="buscar-admin" name="q" type="search" value="${esc(params.get('q') || '')}"></div>
        <div class="campo"><label for="cat-admin">Categoría</label><select id="cat-admin" name="cat"><option value="">Todas</option>${Object.entries(CATEGORIAS).map(([k, v]) => `<option value="${k}" ${k === cat ? 'selected' : ''}>${v}</option>`).join('')}</select></div>
        <button class="boton boton--secundario" type="submit">${icono('lupa')}Filtrar</button>
      </form>
      <p class="texto-suave" aria-live="polite" style="margin:.75rem 0">${plural(lista.length, 'resultado', 'resultados')}</p>
      <div class="tabla-desplazable" tabindex="0" role="region" aria-label="Lista de productos">
        <table class="tabla-admin">
          <thead><tr><th scope="col">Foto</th><th scope="col">Código</th><th scope="col">Producto</th><th scope="col">Categoría</th><th scope="col" class="num">Precio</th><th scope="col" class="num">Stock</th><th scope="col">Estado</th><th scope="col">Acciones</th></tr></thead>
          <tbody>${lista.map((p) => `
            <tr>
              <td>${foto(img(p), { ancho: 56, alto: 56, sizes: 56 })}</td>
              <td>${esc(p.id)}</td>
              <th scope="row">${esc(p.nombre)}</th>
              <td>${esc(etiquetaCategoria(p))}</td>
              <td class="num">${dinero(p.precio)}</td>
              <td class="num">${stockTotal(p)}</td>
              <td><span class="estado ${p.activo === false ? 'estado--cancelado' : 'estado--listo'}">${p.activo === false ? 'Oculto' : 'Visible'}</span></td>
              <td class="acciones">
                <a class="boton boton--secundario boton--chico" href="admin-producto.html?id=${encodeURIComponent(p.id)}">${icono('editar')}Editar<span class="solo-lector"> ${esc(p.nombre)}</span></a>
                <button class="boton boton--secundario boton--chico" type="button" data-activar="${esc(p.id)}" data-activo="${p.activo === false ? '0' : '1'}">${p.activo === false ? 'Mostrar' : 'Ocultar'}<span class="solo-lector"> ${esc(p.nombre)}</span></button>
                <button class="boton boton--peligro boton--chico" type="button" data-borrar="${esc(p.id)}">${icono('basura')}Borrar<span class="solo-lector"> ${esc(p.nombre)}</span></button>
              </td>
            </tr>`).join('')}</tbody>
        </table>
      </div>
    </div>`,
    montar(main) {
      $('#filtro-admin', main).addEventListener('submit', (e) => {
        e.preventDefault();
        const d = new FormData(e.target); const p = new URLSearchParams();
        if (d.get('q')) p.set('q', d.get('q')); if (d.get('cat')) p.set('cat', d.get('cat'));
        ir('admin-productos.html' + (p.toString() ? '?' + p : ''));
      });
      main.addEventListener('click', async (e) => {
        const act = e.target.closest('[data-activar]');
        const bor = e.target.closest('[data-borrar]');
        if (act) {
          const visible = act.dataset.activo === '1';
          const r = await conEspera(act, 'Guardando…', () => Api.admin.activar(act.dataset.activar, !visible));
          if (!r) return;
          if (r.error) { aviso(r.error, 'error'); return; }
          aviso(visible ? 'El producto ya no se muestra en la tienda.' : 'El producto vuelve a mostrarse en la tienda.');
          await cargarCatalogo(); render();
        }
        if (bor) {
          const p = producto(bor.dataset.borrar);
          if (!(await confirmar('¿Borrar este producto?', `Se borrará "${p ? p.nombre : bor.dataset.borrar}" con sus tallas y fotos. Si ya tiene ventas, no se puede borrar: ocúltalo.`, 'Sí, borrar'))) return;
          const r = await conEspera(bor, 'Borrando…', () => Api.admin.borrarProducto(bor.dataset.borrar));
          if (!r) return;
          if (r.error) { aviso(r.error, 'error'); return; }
          aviso('Producto borrado.');
          await cargarCatalogo(); render();
        }
      });
    }
  };
}

async function vistaAdminProducto(partes, params) {
  const ok = soloAdmin(); if (!ok) return null; if (ok === 'no') return vistaNoEncontrada();
  if (!estado.catalogoConectado) await cargarCatalogo();
  const id = params.get('id');
  const p = id ? producto(id) : null;
  if (id && !p) return vistaNoEncontrada();
  const nuevo = !p;
  const v = p || { id: '', nombre: '', categoria: 'calzado', publico: 'Hombre', precio: '', descripcion: '', caracteristicas: [], ficha: [], etiqueta: '', activo: true, tallas: [], stock: {}, imagenes: [], vistas: [] };
  const usaTalla = v.tallas && v.tallas.length > 0;
  const filasTalla = usaTalla ? v.tallas.map((t) => [t, v.stock[t] || 0]) : [];
  const stockUnico = usaTalla ? 0 : (v.stock && v.stock.U) || 0;
  const fotos = (v.imagenes && v.imagenes.length ? v.imagenes : (p ? [1, 2, 3].map((n) => img(p, n)) : [])).map((u, i) => [u, (v.vistas || [])[i] || 'vista ' + (i + 1)]);
  let fila = 0;
  const filaTalla = (t = '', s = 0) => { const k = ++fila; return `<li class="fila-talla"><div class="campo"><label for="talla-${k}">Talla</label><input id="talla-${k}" name="talla" value="${esc(t)}" maxlength="5" required></div><div class="campo"><label for="stock-${k}">Stock</label><input id="stock-${k}" name="stock-talla" type="number" min="0" max="99999" value="${s}" required></div><button class="boton-icono" type="button" data-quitar-talla>${icono('basura')}Quitar<span class="solo-lector"> talla ${esc(t)}</span></button></li>`; };
  const filaFoto = (u = '', d = '') => { const k = ++fila; return `<li class="fila-foto"><img src="${esc(u || FOTO_RESPALDO)}" alt="" width="72" height="72"><div class="campo"><label for="foto-url-${k}">Dirección de la foto</label><input id="foto-url-${k}" name="foto-url" value="${esc(u)}" maxlength="300"></div><div class="campo"><label for="foto-desc-${k}">Descripción</label><input id="foto-desc-${k}" name="foto-desc" value="${esc(d)}" maxlength="80"></div><button class="boton-icono" type="button" data-quitar-foto>${icono('basura')}Quitar<span class="solo-lector"> foto ${k}</span></button></li>`; };
  return {
    titulo: nuevo ? 'Nuevo producto' : `Editar ${v.nombre}`,
    seccion: 'admin',
    html: `
    <div class="contenedor pagina">
      ${menuAdmin('productos')}
      <a class="boton boton--texto" href="admin-productos.html">${icono('izquierda')}Volver a productos</a>
      <h1 class="titulo-pagina">${nuevo ? 'Nuevo producto' : `Editar: ${esc(v.nombre)}`}</h1>
      <p class="subtitulo cabecera-pagina">Los campos con <span class="requerido">*</span> son obligatorios. Los cambios se guardan en la base de datos y se ven al instante en la tienda.</p>
      <form class="formulario panel" id="form-producto" novalidate style="max-width:56rem">
        <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
        <div class="formulario__fila formulario__fila--doble">
          ${campo({ id: 'codigo', etiqueta: 'Código', ayuda: nuevo ? 'De 2 a 10 letras minúsculas o números, sin espacios. No se puede cambiar después.' : 'El código no se puede cambiar.', valor: v.id, max: 10, extra: nuevo ? 'autocomplete="off" autocapitalize="off"' : 'readonly' })}
          ${campo({ id: 'nombre', etiqueta: 'Nombre', valor: v.nombre, max: 80 })}
        </div>
        <div class="formulario__fila formulario__fila--doble">
          <div class="campo"><label for="categoria">Categoría <span class="requerido" aria-hidden="true">*</span></label><select id="categoria">${Object.entries(CATEGORIAS).map(([k, t]) => `<option value="${k}" ${k === v.categoria ? 'selected' : ''}>${t}</option>`).join('')}</select></div>
          ${campo({ id: 'precio', etiqueta: 'Precio (USD, sin IVA)', ayuda: 'Ejemplo: 129.50', valor: v.precio, max: 9, extra: 'inputmode="decimal"' })}
        </div>
        <div class="formulario__fila formulario__fila--doble">
          <div class="campo"><label for="publico">Género <span class="requerido" aria-hidden="true">*</span></label><select id="publico">${['Hombre', 'Mujer', 'Unisex'].map((x) => `<option ${x === (v.publico || 'Unisex') ? 'selected' : ''}>${x}</option>`).join('')}</select></div>
        </div>
        <div class="campo"><label for="descripcion">Descripción <span class="requerido" aria-hidden="true">*</span></label><p class="campo__ayuda" id="descripcion-ayuda">De 20 a 600 caracteres.</p>
          <textarea id="descripcion" rows="4" maxlength="600" aria-describedby="descripcion-ayuda descripcion-error">${esc(v.descripcion)}</textarea><p class="campo__error" id="descripcion-error" hidden>${icono('alerta')}<span></span></p></div>
        <div class="campo"><label for="caracteristicas">Características</label><p class="campo__ayuda" id="caracteristicas-ayuda">Una por línea.</p>
          <textarea id="caracteristicas" rows="3" aria-describedby="caracteristicas-ayuda">${esc((v.caracteristicas || []).join('\n'))}</textarea></div>
        <div class="campo"><label for="ficha">Ficha técnica</label><p class="campo__ayuda" id="ficha-ayuda">Una por línea con el formato «Dato: valor». Ejemplo: Peso: 250 g</p>
          <textarea id="ficha" rows="4" aria-describedby="ficha-ayuda ficha-error">${esc((v.ficha || []).map(([a, b]) => `${a}: ${b}`).join('\n'))}</textarea><p class="campo__error" id="ficha-error" hidden>${icono('alerta')}<span></span></p></div>
        <div class="formulario__fila formulario__fila--doble">
          ${campo({ id: 'etiqueta', etiqueta: 'Etiqueta', ayuda: 'Opcional, por ejemplo: Nuevo', valor: v.etiqueta || '', max: 20, opcional: true })}
          <div><p style="font-weight:700;margin-bottom:.5rem">Visibilidad</p><label class="opcion"><input type="checkbox" id="activo" ${v.activo !== false ? 'checked' : ''}> Mostrar en la tienda</label></div>
        </div>

        <fieldset class="panel panel--gris">
          <legend class="leyenda-panel">Stock</legend>
          <label class="opcion"><input type="checkbox" id="usa-talla" ${usaTalla ? 'checked' : ''}> El producto tiene tallas</label>
          <div id="stock-unico" ${usaTalla ? 'hidden' : ''}>${campo({ id: 'stock-u', etiqueta: 'Unidades disponibles', tipo: 'number', valor: stockUnico, max: 5, extra: 'min="0" max="99999" inputmode="numeric"' })}</div>
          <div id="stock-tallas" ${usaTalla ? '' : 'hidden'}>
            <ul class="lista-filas" id="lista-tallas">${filasTalla.map(([t, s]) => filaTalla(t, s)).join('')}</ul>
            <button class="boton boton--secundario boton--chico" type="button" id="agregar-talla">${icono('mas')}Agregar talla</button>
          </div>
        </fieldset>

        <fieldset class="panel panel--gris">
          <legend class="leyenda-panel">Fotos (hasta 6)</legend>
          <p class="texto-suave">Sube una foto horizontal (proporción 4:3) con fondo blanco (JPG, PNG o WEBP, máximo 3 MB) o escribe la dirección de una foto.</p>
          <ul class="lista-filas" id="lista-fotos">${fotos.map(([u, d]) => filaFoto(u, d)).join('')}</ul>
          <div class="campo"><label for="subir-foto">Subir foto nueva</label><input id="subir-foto" type="file" accept="image/jpeg,image/png,image/webp"></div>
          <p class="texto-suave" id="estado-foto" aria-live="polite"></p>
        </fieldset>

        <div class="botones-fila">
          <button class="boton boton--principal" type="submit">${icono('check')}${nuevo ? 'Crear producto' : 'Guardar cambios'}</button>
          <a class="boton boton--texto" href="admin-productos.html">Cancelar</a>
          ${nuevo ? '' : `<a class="boton boton--texto" href="producto.html?id=${encodeURIComponent(v.id)}">Ver en la tienda</a>`}
        </div>
      </form>
    </div>`,
    montar(main) {
      const form = $('#form-producto', main);
      activarEnlacesError(form);
      const listaT = $('#lista-tallas', form), listaF = $('#lista-fotos', form);
      // Género según la categoría: el calzado es de Hombre o Mujer; tecnología y entrenamiento son Unisex (para todos)
      const ajustarGenero = () => {
        const cat = $('#categoria', form).value, sel = $('#publico', form);
        [...sel.options].forEach((o) => { o.disabled = (cat !== 'calzado') !== (o.value === 'Unisex'); o.hidden = o.disabled; });
        if (sel.selectedOptions[0].disabled) sel.value = [...sel.options].find((o) => !o.disabled).value;
      };
      $('#categoria', form).addEventListener('change', ajustarGenero);
      ajustarGenero();
      $('#usa-talla', form).addEventListener('change', (e) => {
        $('#stock-tallas', form).hidden = !e.target.checked; $('#stock-unico', form).hidden = e.target.checked;
        if (e.target.checked && !listaT.children.length) listaT.insertAdjacentHTML('beforeend', filaTalla());
      });
      $('#agregar-talla', form).addEventListener('click', () => { listaT.insertAdjacentHTML('beforeend', filaTalla()); $$('input[name="talla"]', listaT).pop().focus(); });
      form.addEventListener('click', (e) => {
        const qt = e.target.closest('[data-quitar-talla]'); if (qt) { qt.closest('li').remove(); anunciar('Talla quitada'); }
        const qf = e.target.closest('[data-quitar-foto]'); if (qf) { qf.closest('li').remove(); anunciar('Foto quitada'); }
      });
      $('#subir-foto', form).addEventListener('change', async (e) => {
        const archivo = e.target.files[0];
        const salida = $('#estado-foto', form);
        if (!archivo) return;
        if (listaF.children.length >= 6) { salida.textContent = 'Ya tienes 6 fotos: quita una para subir otra.'; return; }
        if (!['image/jpeg', 'image/png', 'image/webp'].includes(archivo.type) || archivo.size > 3 * 1024 * 1024) { salida.textContent = 'La foto debe ser JPG, PNG o WEBP y pesar máximo 3 MB.'; return; }
        const codigo = ($('#codigo', form).value.trim() || 'nuevo').toLowerCase();
        salida.textContent = 'Subiendo foto…';
        const r = await Api.admin.subirFoto(archivo, codigo);
        if (r.error) { salida.textContent = r.error; return; }
        listaF.insertAdjacentHTML('beforeend', filaFoto(r.datos, listaF.children.length ? 'otra vista' : 'vista principal'));
        salida.textContent = 'Foto subida. Recuerda guardar el producto.';
        e.target.value = '';
      });
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const val = (id) => $('#' + id, form).value.trim();
        const codigo = val('codigo').toLowerCase();
        const precio = Number(val('precio').replace(',', '.'));
        const usa = $('#usa-talla', form).checked;
        const tallas = usa ? $$('.fila-talla', listaT).map((li) => ({ talla: $('input[name="talla"]', li).value.trim(), stock: Number($('input[name="stock-talla"]', li).value) })) : [{ talla: 'U', stock: Number(val('stock-u')) }];
        const fotosF = $$('.fila-foto', listaF).map((li, i) => ({ orden: i + 1, url: $('input[name="foto-url"]', li).value.trim(), descripcion: $('input[name="foto-desc"]', li).value.trim() || `vista ${i + 1}` })).filter((f) => f.url);
        const repetidas = new Set(tallas.map((t) => t.talla)).size !== tallas.length;
        const reglas = [
          ['codigo', /^[a-z0-9]{2,10}$/.test(codigo) ? (nuevo && producto(codigo) ? 'Ya existe un producto con ese código.' : '') : 'Usa de 2 a 10 letras minúsculas o números, sin espacios.'],
          ['nombre', val('nombre').length >= 3 ? '' : 'Escribe el nombre del producto (mínimo 3 caracteres).'],
          ['precio', precio > 0 && precio < 100000 && /^\d+([.,]\d{1,2})?$/.test(val('precio')) ? '' : 'Escribe un precio válido mayor que 0, con máximo 2 decimales.'],
          ['descripcion', val('descripcion').length >= 20 ? '' : 'La descripción debe tener al menos 20 caracteres.']
        ];
        // Stock: números enteros de 0 a 100 000 (lo mismo que exige la base)
        const stockValido = (n) => Number.isInteger(n) && n >= 0 && n <= 100000;
        if (!usa) reglas.push(['stock-u', val('stock-u') !== '' && stockValido(Number(val('stock-u'))) ? '' : 'Escribe un número entero de unidades, de 0 a 100 000.']);
        if (usa && (!tallas.length || tallas.some((t) => !t.talla || !/^[A-Za-z0-9.,/ -]{1,5}$/.test(t.talla) || !stockValido(t.stock)) || repetidas)) reglas.push(['agregar-talla', 'Revisa las tallas: cada una necesita un nombre de hasta 5 caracteres, un stock entero de 0 a 100 000 y no se pueden repetir.']);
        // Fotos: dirección https o una foto de la propia tienda (img/...)
        const fotoMala = $$('input[name="foto-url"]', listaF).find((i) => i.value.trim() && !/^(https:\/\/|img\/)\S+$/.test(i.value.trim()));
        if (fotoMala) reglas.push([fotoMala.id, 'La dirección de la foto debe empezar con https:// (o img/ para las fotos de la tienda) y no llevar espacios.']);
        // Ficha técnica: cada línea con el formato «Dato: valor»
        const lineaMala = val('ficha').split('\n').map((l) => l.trim()).filter(Boolean).find((l) => !/^[^:]{1,40}:\s*\S/.test(l));
        if (lineaMala) reglas.push(['ficha', `Esta línea de la ficha no tiene el formato «Dato: valor»: ${lineaMala.slice(0, 40)}`]);
        if (!validarFormulario(form, reglas, 'Revisa el producto:')) return;
        const datos = {
          codigo, nombre: val('nombre'), categoria: $('#categoria', form).value, publico: $('#publico', form).value,
          precio: Math.round(precio * 100) / 100, descripcion: val('descripcion'), caracteristicas: val('caracteristicas'), ficha: val('ficha'),
          etiqueta: val('etiqueta'), activo: $('#activo', form).checked, usaTalla: usa, tallas, fotos: fotosF
        };
        const r = await conEspera($('button[type="submit"]', form), 'Guardando…', () => Api.admin.guardarProducto(datos, nuevo));
        if (!r) return;
        if (r.error) { errorGeneral(form, r.error); return; }
        aviso(nuevo ? 'Producto creado.' : 'Cambios guardados.');
        ir('admin-productos.html');
      });
    }
  };
}

/* ======================= Pagos guardados (administrador) ======================= */
async function vistaAdminPagos() {
  const ok = soloAdmin(); if (!ok) return null; if (ok === 'no') return vistaNoEncontrada();
  const r = await Api.admin.pagos();
  if (r.error) return { titulo: 'Pagos', seccion: 'admin', html: errorCargaHtml(r.error) };
  const lista = r.datos || [];
  const total = lista.filter((g) => g.estado === 'Aprobado').reduce((s, g) => s + Number(g.monto), 0);
  return {
    titulo: 'Pagos (administrador)',
    seccion: 'admin',
    html: `
    <div class="contenedor pagina">
      ${menuAdmin('pagos')}
      <h1 class="titulo-pagina">Pagos</h1>
      <p class="subtitulo cabecera-pagina">Cada pago, con tarjeta o en efectivo al retirar, queda guardado en la tabla PAGO de la base de datos. Los pagos con tarjeta son simulados.</p>
      <dl class="tarjetas-resumen">
        <div><dt>Pagos registrados</dt><dd>${lista.length}</dd></div>
        <div><dt>Aprobados</dt><dd>${lista.filter((g) => g.estado === 'Aprobado').length}</dd></div>
        <div><dt>Anulados</dt><dd>${lista.filter((g) => g.estado === 'Anulado').length}</dd></div>
        <div><dt>Total aprobado</dt><dd>${dinero(total)}</dd></div>
      </dl>
      ${!lista.length ? `<div class="panel panel--gris vacio">${icono('tarjeta')}<p>Todavía no hay pagos.</p></div>` : `
      <div class="tabla-desplazable" tabindex="0" role="region" aria-label="Pagos registrados">
        <table class="tabla-admin">
          <thead><tr><th scope="col">N.º</th><th scope="col">Fecha</th><th scope="col">Pedido</th><th scope="col">Cliente</th><th scope="col">Tarjeta</th><th scope="col" class="num">Monto</th><th scope="col">Estado</th></tr></thead>
          <tbody>${lista.map((g) => `<tr><td>${g.codigo}</td><td>${fechaHora(g.fecha)}</td><td><a href="orden.html?pedido=${g.pedido}">${esc(g.numeroPedido)}</a></td><td>${esc(g.cliente)}</td><td>${esc(g.detalle)}</td><td class="num">${dinero(g.monto)}</td><td><span class="estado ${g.estado === 'Aprobado' ? 'estado--listo' : 'estado--cancelado'}">${esc(g.estado)}</span></td></tr>`).join('')}</tbody>
        </table>
      </div>`}
    </div>`
  };
}

/* ======================= Stock (administrador) ======================= */
/* Existencias de cada producto por talla, con la última reducción (de qué cantidad a cuál) y los movimientos.
   Se actualiza sola cada 15 segundos: cuando un cliente compra, la fila del producto se resalta. */
const STOCK_BAJO = 5;
// Aviso en el panel: productos que hay que reponer pronto
function avisoStockBajo() {
  const totales = PRODUCTOS.map((p) => stockTotal(p)).filter((t) => t !== null);
  const bajos = totales.filter((t) => t > 0 && t <= STOCK_BAJO).length;
  const agotados = totales.filter((t) => t === 0).length;
  if (!bajos && !agotados) return '';
  const partes = [bajos ? `${plural(bajos, 'producto tiene', 'productos tienen')} stock bajo (${STOCK_BAJO} o menos)` : '', agotados ? `${plural(agotados, 'producto está agotado', 'productos están agotados')}` : ''].filter(Boolean);
  return `<p class="alerta" style="margin-bottom:1rem">${icono('alerta')}<span>${partes.join(' y ')}. <a href="admin-stock.html?ver=${bajos ? 'bajo' : 'agotado'}">Revisar el stock</a></span></p>`;
}
const SEGUNDOS_STOCK = 15;
async function vistaAdminStock(partes, params) {
  const ok = soloAdmin(); if (!ok) return null; if (ok === 'no') return vistaNoEncontrada();
  const r = await Api.admin.stock();
  if (r.error) return { titulo: 'Stock', seccion: 'admin', html: errorCargaHtml(r.error) };
  return {
    titulo: 'Stock (administrador)',
    seccion: 'admin',
    html: `
    <div class="contenedor pagina">
      ${menuAdmin('stock')}
      <h1 class="titulo-pagina">Stock</h1>
      <p class="subtitulo cabecera-pagina">Cada compra descuenta el stock en la base de datos en el mismo momento, y cada cancelación lo devuelve. Aquí ves cuánto queda, la última reducción de cada producto y todos los movimientos.</p>
      <p class="estado-vivo" role="status" aria-live="polite"><span class="punto-vivo" aria-hidden="true"></span><span id="stock-actualizado">Actualizado ahora</span> · se actualiza solo cada ${SEGUNDOS_STOCK} segundos</p>
      <dl class="tarjetas-resumen" id="stock-resumen"></dl>
      <form class="filtro-admin" id="filtro-stock" role="search" aria-label="Filtrar el stock" onsubmit="return false">
        <div class="campo"><label for="buscar-stock">Buscar por código o nombre</label><input id="buscar-stock" type="search" autocomplete="off"></div>
        <div class="campo"><label for="ver-stock">Mostrar</label><select id="ver-stock"><option value="todos">Todos los productos</option><option value="bajo">Stock bajo (${STOCK_BAJO} o menos)</option><option value="agotado">Agotados</option><option value="movidos">Con movimientos</option></select></div>
        <div class="campo"><label for="cat-stock">Categoría</label><select id="cat-stock"><option value="todas">Todas</option>${Object.entries(CATEGORIAS).map(([k, t]) => `<option value="${k}">${t}</option>`).join('')}</select></div>
      </form>
      <h2 class="titulo-seccion" style="margin-top:1.5rem">Productos</h2>
      <div class="tabla-desplazable" tabindex="0" role="region" aria-label="Stock por producto">
        <table class="tabla-admin tabla-stock">
          <thead><tr><th scope="col">Producto</th><th scope="col">Stock por talla</th><th scope="col" class="num">Total</th><th scope="col">Última reducción</th></tr></thead>
          <tbody id="stock-filas"></tbody>
        </table>
      </div>
      <h2 class="titulo-seccion" style="margin-top:2rem">Últimos movimientos</h2>
      <div class="tabla-desplazable" tabindex="0" role="region" aria-label="Últimos movimientos de stock">
        <table class="tabla-admin">
          <thead><tr><th scope="col">Fecha</th><th scope="col">Producto</th><th scope="col">Talla</th><th scope="col">Motivo</th><th scope="col" class="num">Cantidad</th><th scope="col">Stock</th><th scope="col">Pedido</th></tr></thead>
          <tbody id="stock-movimientos"></tbody>
        </table>
      </div>
    </div>`,
    montar(main) {
      let datos = r.datos;
      const verInicial = params && params.get('ver');
      if (['bajo', 'agotado', 'movidos'].includes(verInicial)) $('#ver-stock', main).value = verInicial;
      let vistos = new Set((datos.movimientos || []).map((m) => m.id));
      let resaltar = new Set();
      const filtros = () => ({ q: $('#buscar-stock', main).value.trim().toLowerCase(), ver: $('#ver-stock', main).value, cat: $('#cat-stock', main).value });
      const hace = (f) => { const min = Math.round((Date.now() - new Date(f)) / 60000); return min < 1 ? 'hace un momento' : min < 60 ? `hace ${min} min` : fechaHora(f); };
      const pintar = () => {
        const f = filtros();
        const porProducto = {};
        datos.tallas.forEach((t) => { (porProducto[t.producto] = porProducto[t.producto] || []).push(t); });
        const movs = datos.movimientos || [];
        const filas = PRODUCTOS.map((p) => {
          const tallas = (porProducto[p.dbId] || []).sort((a, b) => String(a.talla).localeCompare(String(b.talla), 'es', { numeric: true }));
          const total = tallas.reduce((s, t) => s + t.cantidad, 0);
          const reduccion = movs.find((m) => m.producto === p.dbId && m.cantidad < 0);
          const movido = movs.some((m) => m.producto === p.dbId);
          return { p, tallas, total, reduccion, movido };
        }).filter(({ p, total, movido }) =>
          (!f.q || p.nombre.toLowerCase().includes(f.q) || String(p.dbId).toLowerCase().includes(f.q)) &&
          (f.cat === 'todas' || p.categoria === f.cat) &&
          (f.ver === 'todos' || (f.ver === 'bajo' && total > 0 && total <= STOCK_BAJO) || (f.ver === 'agotado' && total === 0) || (f.ver === 'movidos' && movido)));
        const todas = datos.tallas.reduce((s, t) => s + t.cantidad, 0);
        const hoy = new Date().toDateString();
        const vendidasHoy = movs.filter((m) => m.motivo === 'Venta' && new Date(m.fecha).toDateString() === hoy).reduce((s, m) => s - m.cantidad, 0);
        const totales = PRODUCTOS.filter((p) => porProducto[p.dbId]).map((p) => porProducto[p.dbId].reduce((s, t) => s + t.cantidad, 0));
        $('#stock-resumen', main).innerHTML = `
          <div><dt>Unidades en stock</dt><dd>${todas.toLocaleString('es-EC')}</dd></div>
          <div><dt>Vendidas hoy</dt><dd>${vendidasHoy}</dd></div>
          <div><dt>Stock bajo</dt><dd>${totales.filter((t) => t > 0 && t <= STOCK_BAJO).length}</dd></div>
          <div><dt>Agotados</dt><dd>${totales.filter((t) => t === 0).length}</dd></div>`;
        $('#stock-filas', main).innerHTML = filas.length ? filas.map(({ p, tallas, total, reduccion }) => `
          <tr class="${resaltar.has(p.dbId) ? 'fila-cambio' : ''}">
            <td><div class="stock-producto">${foto(img(p), { ancho: 48, alto: 48, sizes: 48 })}<span><strong>${esc(p.nombre)}</strong><span class="texto-suave">Cód. ${esc(p.dbId)} · ${CATEGORIAS[p.categoria] || ''}</span></span></div></td>
            <td><ul class="chips-stock">${tallas.map((t) => `<li class="${t.cantidad === 0 ? 'agotado' : t.cantidad <= STOCK_BAJO ? 'bajo' : ''}">${t.talla ? `<span>${esc(t.talla)}</span>` : '<span>Única</span>'}<strong>${t.cantidad}</strong></li>`).join('')}</ul></td>
            <td class="num"><strong>${total}</strong>${!tallas.length ? '' : total === 0 ? ' <span class="estado estado--cancelado">Agotado</span>' : total <= STOCK_BAJO ? ' <span class="estado estado--preparando">Bajo</span>' : ''}</td>
            <td>${reduccion ? `<span class="reduccion"><strong class="menos">${reduccion.cantidad}</strong>${reduccion.talla ? ` talla ${esc(reduccion.talla)}` : ''} · ${reduccion.antes} → <strong>${reduccion.despues}</strong></span><span class="texto-suave d-bloque">${esc(reduccion.motivo)}${reduccion.pedido ? ` · <a href="orden.html?pedido=${reduccion.pedido.id}">${esc(reduccion.pedido.numero)}</a>` : ''} · ${hace(reduccion.fecha)}</span>` : '<span class="texto-suave">Sin ventas todavía</span>'}</td>
          </tr>`).join('') : '<tr><td colspan="4" class="texto-suave">No hay productos con este filtro.</td></tr>';
        $('#stock-movimientos', main).innerHTML = movs === null || !movs.length
          ? `<tr><td colspan="7" class="texto-suave">${movs === null ? 'El registro de movimientos todavía no está activo en la base (script 19).' : 'Todavía no hay movimientos. Aparecerán apenas un cliente compre.'}</td></tr>`
          : movs.slice(0, 40).map((m) => { const p = productoPorDbId(m.producto); return `<tr class="${resaltar.has(m.producto) && !vistos.has(m.id) ? 'fila-cambio' : ''}"><td>${fechaHora(m.fecha)}</td><td>${esc(p ? p.nombre : m.producto)}</td><td>${esc(m.talla || 'Única')}</td><td>${esc(m.motivo)}</td><td class="num"><strong class="${m.cantidad < 0 ? 'menos' : 'mas'}">${m.cantidad > 0 ? '+' : ''}${m.cantidad}</strong></td><td>${m.antes} → <strong>${m.despues}</strong></td><td>${m.pedido ? `<a href="orden.html?pedido=${m.pedido.id}">${esc(m.pedido.numero)}</a>` : '—'}</td></tr>`; }).join('');
      };
      pintar();
      $('#filtro-stock', main).addEventListener('input', pintar);
      const reloj = setInterval(async () => {
        if (!main.isConnected) { clearInterval(reloj); return; }
        const r2 = await Api.admin.stock();
        if (r2.error || !main.isConnected) return;
        const nuevos = (r2.datos.movimientos || []).filter((m) => !vistos.has(m.id));
        resaltar = new Set(nuevos.map((m) => m.producto));
        datos = r2.datos;
        pintar();
        vistos = new Set((datos.movimientos || []).map((m) => m.id));
        $('#stock-actualizado', main).textContent = `Actualizado a las ${new Date().toLocaleTimeString('es-EC', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}`;
        const ventas = nuevos.filter((m) => m.motivo === 'Venta');
        if (ventas.length) aviso(`Stock actualizado: se vendieron ${ventas.reduce((s, m) => s - m.cantidad, 0)} unidades.`);
      }, SEGUNDOS_STOCK * 1000);
    }
  };
}
