/* ATHLETIX · Vistas de compra: retiro en tienda, pago, confirmación y orden de pedido */
'use strict';

const CLAVE_PAGO_PENDIENTE = 'athletix-pago-pendiente';

function protegerCompra() {
  if (!estado.carrito.length) { ir('carrito.html'); return false; }
  if (!protegerCuenta('retiro')) return false;
  return true;
}

/* Las tiendas se leen de la base una vez por página */

/* Tienda de retiro elegida (se guarda mientras dura la compra) */
function leerEntrega() {
  const e = leerTemporal('entrega');
  if (!e || e.tipo !== 'Retiro' || !e.tienda) return null;
  return e;
}

/* ======================= Retiro en tienda ======================= */
async function vistaRetiro() {
  if (!protegerCompra()) return null;
  const rt = await cargarTiendas();
  if (rt.error) return { titulo: 'Retiro en tienda', seccion: 'carrito', html: errorCargaHtml(rt.error) };
  // Si no eligió en esta compra, se usa la última tienda que usó esta cuenta (guardada en el navegador)
  const ultima = leerLocal(claveCuenta(CLAVE_ENTREGA));
  const ultimaValida = ultima && estado.tiendas.some((t) => t.id === ultima.tienda);
  const recordada = !leerEntrega() && ultimaValida;
  const e = leerEntrega() || (ultimaValida ? ultima : null) || { tipo: 'Retiro', tienda: estado.tiendas[0] && estado.tiendas[0].id };
  const c = estado.cliente;
  return {
    titulo: 'Retiro en tienda',
    seccion: 'carrito',
    html: `
    <div class="contenedor pagina">
      ${pasos(2)}
      <h1 class="titulo-pagina cabecera-pagina">Retiro en tienda</h1>
      <p class="subtitulo" style="margin-bottom:1rem">Retiras tu pedido gratis en la tienda que elijas. Con los productos de tu carrito estará listo en aprox. <strong>${textoDuracion(minutosRetiro(estado.carrito))}</strong> y te avisamos por correo.</p>
      ${recordada ? `<p class="alerta alerta--info" style="margin-bottom:1rem">${icono('info')}<span>Usamos la última tienda que elegiste. Puedes cambiarla si quieres.</span></p>` : ''}
      <div class="compra-grilla">
        <form id="form-retiro" class="formulario" style="display:grid;gap:1.5rem" novalidate>
          <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
          <fieldset class="panel">
            <legend class="leyenda-panel">¿En qué tienda lo retiras?</legend>
            <div class="opciones-tienda">
              ${estado.tiendas.map((t) => `
                <label class="opcion-tienda">
                  <input type="radio" name="tienda" value="${t.id}" ${t.id === e.tienda ? 'checked' : ''}>
                  <span class="opcion-tienda__cuerpo">
                    <span class="tienda__icono">${icono('ubicacion')}</span>
                    <span><strong>${esc(t.nombre)}</strong><span class="d-bloque">${esc(t.direccion)}, ${esc(t.ciudad)}</span><span class="d-bloque texto-suave">${esc(t.horario)}</span></span>
                  </span>
                </label>`).join('')}
            </div>
          </fieldset>

          <section class="panel" aria-labelledby="titulo-quien">
            <h2 id="titulo-quien">Quién retira y datos de tu factura</h2>
            <dl class="datos-lista">
              <dt>Nombre</dt><dd>${esc(c.nombres)} ${esc(c.apellidos)}</dd>
              <dt>${nombreDocumento(c.cedula, false)}</dt><dd>${esc(c.cedula)}</dd>
              <dt>Celular</dt><dd>${esc(c.telefono)}</dd>
              <dt>Correo</dt><dd>${esc(correoSesion())}</dd>
            </dl>
            <div style="margin-top:1rem">${campo({ id: 'direccion', etiqueta: 'Dirección de domicilio', ayuda: 'Calle principal, número y calle secundaria, ciudad. Aparece en tu factura.', valor: c.direccion || '', max: 150, extra: 'autocomplete="street-address"' })}</div>
            <p class="alerta alerta--info" style="margin-top:1.25rem">${icono('correo')}<span>Al pagar recibes la <strong>orden de pedido</strong> con tu número de pedido y un código de retiro de 6 caracteres. En la tienda presenta tu <strong>${nombreDocumento(c.cedula, false).toLowerCase()}</strong> y tu <strong>número de pedido</strong> (o el código) para verificar tu compra.</span></p>
          </section>
        </form>
        <div id="zona-resumen">${resumenPedido(botonesEntrega())}</div>
      </div>
    </div>`,
    montar(main) {
      const form = $('#form-retiro', main);
      activarEnlacesError(form);
      validarAlSalir(form, 'direccion', (v) => Validar.direccion(v));
      form.addEventListener('submit', async (ev) => {
        ev.preventDefault();
        const tienda = Number(new FormData(form).get('tienda'));
        if (!tienda) { aviso('Elige la tienda donde retirarás tu pedido.', 'error'); return; }
        // La dirección se guarda en la base (CLIENTE) para la factura
        const direccion = $('#direccion', form).value.trim().replace(/\s+/g, ' ');
        if (!validarFormulario(form, [['direccion', Validar.direccion(direccion)]], 'Revisa tus datos:')) return;
        if (direccion !== (c.direccion || '')) {
          const r = await conEspera($('button[form="form-retiro"]', main), 'Guardando…', () => Api.cliente.actualizar(c.id, { ...c, direccion }));
          if (!r || r.error) { if (r) aviso(r.error, 'error'); return; }
          estado.cliente = r.datos;
        }
        guardarTemporal('entrega', { tipo: 'Retiro', tienda });
        guardarLocal(claveCuenta(CLAVE_ENTREGA), leerEntrega());
        ir('pago.html');
      });
    }
  };
}
function botonesEntrega() {
  return `<button class="boton boton--principal boton--bloque" type="submit" form="form-retiro">Continuar al pago</button><a class="boton boton--texto boton--bloque" href="carrito.html">${icono('izquierda')}Volver al carrito</a>`;
}
function textoEntrega(e, tienda) {
  return `<strong style="font-size:1rem">Retiro en ${esc(tienda ? tienda.nombre : '')} · listo en aprox. ${textoDuracion(minutosRetiro(estado.carrito))}</strong><p class="texto-suave">${esc(tienda ? tienda.direccion : '')}</p>`;
}

/* ======================= Pago (simulado) con tarjeta ======================= */
async function vistaPago() {
  if (!protegerCompra()) return null;
  const rTiendas = await cargarTiendas();
  if (rTiendas.error) return { titulo: 'Pago', seccion: 'carrito', html: errorCargaHtml(rTiendas.error) };
  const entrega = leerEntrega();
  const tienda = entrega ? estado.tiendas.find((t) => t.id === entrega.tienda) : null;
  if (!tienda) { ir('retiro.html'); return null; }
  const avisos = revisarCarrito();
  if (!estado.carrito.length) { ir('carrito.html'); return null; }

  // Si se recargó la página mientras se pagaba, se revisa si el pedido ya se creó para no cobrar dos veces
  const pendiente = leerPendiente();
  if (pendiente) {
    const rp = await Api.pedidos.mios();
    const reciente = !rp.error && (rp.datos || []).find((p) => new Date(p.creado_en).getTime() >= pendiente.desde - 5000);
    if (reciente) { terminarCompra(reciente); return null; }
    borrarPendiente();
  }

  const rt = await Api.cliente.tarjetas();
  const hoy = new Date();
  const tarjetas = (rt.datos || []).filter((t) => t.anio_vence > hoy.getFullYear() || (t.anio_vence === hoy.getFullYear() && t.mes_vence >= hoy.getMonth() + 1));
  const total = totalCarrito();
  return {
    titulo: 'Pago',
    seccion: 'carrito',
    html: `
    <div class="contenedor pagina">
      ${pasos(3)}
      <h1 class="titulo-pagina cabecera-pagina">Pago</h1>
      ${avisos.length ? `<div class="alerta alerta--info" role="status" style="margin-bottom:1.25rem">${icono('info')}<ul style="margin:0">${avisos.map((a) => `<li>${esc(a)}</li>`).join('')}</ul></div>` : ''}
      <div class="compra-grilla">
        <section class="panel" aria-labelledby="titulo-pago" id="zona-pago">
          <h2 id="titulo-pago">¿Cómo quieres pagar?</h2>
          <form class="formulario" id="form-pago" novalidate>
            <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
            <fieldset class="formas-pago">
              <legend class="solo-lector">Forma de pago</legend>
              <label class="opcion opcion--caja"><input type="radio" name="forma" value="tarjeta" checked> ${icono('tarjeta')}<span><strong>Tarjeta de crédito o débito</strong><span class="texto-suave d-bloque">Aceptamos todas las tarjetas</span></span></label>
              <label class="opcion opcion--caja"><input type="radio" name="forma" value="tienda"> ${icono('tienda')}<span><strong>Efectivo en la tienda al retirar</strong><span class="texto-suave d-bloque">Pagas en efectivo en la caja de ${esc(tienda.nombre)} cuando retiras tu pedido</span></span></label>
            </fieldset>
            <div id="pago-en-tienda" hidden>
              <p class="alerta alerta--info">${icono('info')}<span>Reservamos tus productos y los preparamos igual. Pagas <strong>${dinero(total)} en efectivo</strong> en la caja cuando retires tu pedido, presentando tu cédula y tu número de pedido.</span></p>
            </div>
            <div id="pago-tarjeta" class="formulario">
              ${avisoTarjetasPrueba()}
              ${tarjetas.length ? `
              <fieldset class="grupo-tarjetas">
                <legend style="font-weight:700;margin-bottom:.5rem">Elige la tarjeta</legend>
                ${tarjetas.map((t, i) => `<label class="opcion opcion--caja"><input type="radio" name="metodo" value="${t.id}" ${i === 0 ? 'checked' : ''}> ${icono('tarjeta')}<span>${t.marca} •••• ${t.ultimos4} <span class="texto-suave">· vence ${String(t.mes_vence).padStart(2, '0')}/${String(t.anio_vence).slice(2)}</span></span></label>`).join('')}
                <label class="opcion opcion--caja"><input type="radio" name="metodo" value="nueva"> ${icono('mas')}<span>Usar otra tarjeta</span></label>
              </fieldset>
              <div id="cvv-guardada">${campo({ id: 'cvv-g', etiqueta: 'CVV de la tarjeta elegida', tipo: 'password', ayuda: '3 dígitos al reverso', max: 3, extra: 'autocomplete="cc-csc" inputmode="numeric"' })}</div>` : ''}
              <div id="tarjeta-nueva" ${tarjetas.length ? 'hidden' : ''}>
                <div class="formulario">${camposTarjeta()}</div>
              </div>
            </div>

            <p class="alerta alerta--info" id="nota-tarjeta">${icono('candado')}<span>Pago simulado: no se cobra dinero real. <strong>Una vez pagado, el pedido no se puede modificar.</strong></span></p>
            <button class="boton boton--principal boton--bloque" type="submit" id="boton-pagar">${icono('candado')}Pagar ${dinero(total)}</button>
            <a class="boton boton--texto" href="retiro.html">${icono('izquierda')}Volver a elegir tienda</a>
          </form>
        </section>
        ${resumenPedido(`<div class="tienda" style="margin-top:1rem;background:var(--blanco)"><span class="tienda__icono">${icono('ubicacion')}</span><div>${textoEntrega(entrega, tienda)}</div></div>`)}
      </div>
    </div>`,
    montar(main) {
      const form = $('#form-pago', main);
      // Una clave por intento de pago: si el envío se repite, la base devuelve el mismo pedido
      const clavePago = (window.crypto && crypto.randomUUID) ? crypto.randomUUID() : null;
      activarCamposTarjeta(form);
      const cvvG = $('#cvv-g', form);
      // El CVV de la tarjeta guardada tiene 4 números si es American Express
      const marcaGuardada = () => { const t = tarjetas.find((x) => String(x.id) === (($('input[name="metodo"]:checked', form) || {}).value)); return t ? t.marca : ''; };
      const ajustarCvvG = () => {
        if (!cvvG) return;
        const n = Validar.largoCvv(marcaGuardada());
        cvvG.maxLength = n;
        $('#cvv-g-ayuda', form).textContent = n === 4 ? '4 dígitos al frente de la tarjeta' : '3 dígitos al reverso';
        if (cvvG.value.length > n) cvvG.value = cvvG.value.slice(0, n);
      };
      if (cvvG) { filtrarEntrada(cvvG, NO_DIGITOS, () => Validar.largoCvv(marcaGuardada())); ajustarCvvG(); }
      const nueva = $('#tarjeta-nueva', form);
      const usarNueva = () => !tarjetas.length || (($('input[name="metodo"]:checked', form) || {}).value === 'nueva');
      const enTienda = () => (($('input[name="forma"]:checked', form) || {}).value === 'tienda');
      const pintarForma = () => {
        $('#pago-tarjeta', form).hidden = enTienda();
        $('#nota-tarjeta', form).hidden = enTienda();
        $('#pago-en-tienda', form).hidden = !enTienda();
        $('#boton-pagar', form).innerHTML = enTienda() ? `${icono('check')}Confirmar pedido · pagas ${dinero(total)} en efectivo` : `${icono('candado')}Pagar ${dinero(total)}`;
      };
      form.addEventListener('change', (e) => {
        if (e.target.name === 'forma') { pintarForma(); ocultarResumen(form); }
        if (e.target.name === 'metodo') {
          ajustarCvvG();
          nueva.hidden = !usarNueva();
          $('#cvv-guardada', form).hidden = usarNueva();
          ocultarResumen(form);
        }
      });

      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        let pago;
        let datosTarjeta = null;
        if (enTienda()) {
          pago = { tarjeta: null };
        } else if (usarNueva()) {
          datosTarjeta = leerTarjeta(form);
          if (!datosTarjeta) return;
        } else {
          if (!validarFormulario(form, [['cvv-g', Validar.cvv(cvvG.value, marcaGuardada())]], 'Revisa el pago:')) return;
          pago = { tarjeta: Number($('input[name="metodo"]:checked', form).value) };
        }
        const boton = $('button[type="submit"]', form);
        let r;
        try {
        r = await conEspera(boton, enTienda() ? 'Confirmando pedido…' : 'Procesando pago…', async () => {
          mostrarProcesando(main, true);
          if (datosTarjeta) {
            const rg = await Api.cliente.guardarTarjeta(datosTarjeta.registro);
            if (rg.error) return rg;
            pago = { tarjeta: rg.datos.id };
          }
          const items = estado.carrito.map((l) => ({ producto: (producto(l.id) || {}).dbId, talla: l.talla || '', cantidad: l.cantidad }));
          if (items.some((i) => !i.producto)) return { error: 'Algunos productos no están disponibles en este momento. Recarga la página.' };
          guardarPendiente();
          const rp = await Api.pedidos.crear({ items, clave: clavePago, tienda: tienda.id, tarjeta: pago.tarjeta });
          if (rp.error) borrarPendiente();
          return rp;
        });
        } catch (e) {
          // Nunca se queda la pantalla de "procesando": se avisa y se puede volver a intentar
          r = { error: 'No pudimos completar la compra. Revisa tu conexión e inténtalo otra vez.' };
        }
        if (!r) return;
        mostrarProcesando(main, false);
        if (r.error) {
          if (/stock|disponible/i.test(r.error)) {
            // Otro cliente compró antes: se actualiza el stock y el carrito, y se explica qué cambió
            await cargarCatalogo();
            const cambios = revisarCarrito();
            if (cambios.length) { aviso(`${r.error.replace(/\.?$/, '.')} ${cambios.join(' ')} Revisa tu pedido antes de pagar.`, 'error'); render(); return; }
          }
          errorGeneral(form, r.error);
          return;
        }
        const fila = r.datos;
        const detalleEntrega = { tienda: `${tienda.nombre} (${tienda.direccion})`, horario: `Listo aprox. a las ${horaCorta(fila.horaEstimada)} · ${tienda.horario}` };
        const productosTexto = estado.carrito.map((l) => `${l.cantidad} × ${(producto(l.id) || { nombre: l.id }).nombre}${l.talla ? ' (talla ' + l.talla + ')' : ''}`).join(', ');
        // Correos de confirmación al cliente y de aviso al administrador (no detienen la compra si fallan).
        // Se esperan como máximo 6 segundos antes de cambiar de página para que alcancen a salir.
        mostrarProcesando(main, true);
        // Factura en PDF (se adjunta al correo) con el detalle de lo que compró
        const items = estado.carrito.filter((l) => producto(l.id)).map((l) => { const pr = producto(l.id); return { codigo: pr.dbId, nombre: pr.nombre, talla: l.talla, cantidad: l.cantidad, precio: pr.precio }; });
        const datosFactura = {
          id: fila.factura || fila.id, pedido: fila.numero, fecha: new Date(), codigoRetiro: fila.codigoRetiro, items, pago: textoPago(pago, datosTarjeta),
          cliente: { ...estado.cliente, correo: correoSesion() }, tienda: { nombre: tienda.nombre, direccion: tienda.direccion },
          subtotal: subtotalCarrito(), iva: ivaCarrito(), total: Number(fila.total)
        };
        let pdf = null;
        try { pdf = await Promise.race([Factura.generar(datosFactura), new Promise((ok) => setTimeout(() => ok(null), 4000))]); } catch (err) { pdf = null; }
        const correos = Promise.allSettled([
          Api.correo.compraConfirmada({ correo: correoSesion(), nombre: estado.cliente.nombres, numero: fila.numero, total: fila.total, codigo: fila.codigoRetiro, pagoTexto: textoPago(pago, datosTarjeta), enTienda: pago.tarjeta === null, id: fila.id, ...detalleEntrega,
            items, subtotal: datosFactura.subtotal, iva: datosFactura.iva, numeroFactura: Factura.numero(fila.factura || fila.id), factura: pdf ? pdf.dataUri : '' }),
          Api.correo.nuevoPedido({
            numero: fila.numero, total: fila.total, tienda: detalleEntrega.tienda,
            cliente: `${estado.cliente.nombres} ${estado.cliente.apellidos}`, cedula: estado.cliente.cedula,
            correo: correoSesion(), telefono: estado.cliente.telefono, productos: productosTexto,
            id: fila.id, codigo: fila.codigoRetiro, direccion: estado.cliente.direccion, items, subtotal: datosFactura.subtotal, iva: datosFactura.iva,
            enTienda: pago.tarjeta === null, pagoTexto: textoPago(pago, datosTarjeta)
          })]);
        await Promise.race([correos, new Promise((ok) => setTimeout(ok, 6000))]);
        terminarCompra(fila);
      });
    }
  };
}
function textoPago(pago, datosTarjeta) {
  if (!pago) return '';
  if (pago.tarjeta === null) return 'Efectivo en la tienda al retirar (pendiente)';
  if (datosTarjeta) return `Tarjeta ${datosTarjeta.registro.marca} terminada en ${datosTarjeta.registro.ultimos4}`;
  return 'Tarjeta guardada';
}

function mostrarProcesando(main, activo) {
  let capa = $('#capa-pago', main);
  if (activo && !capa) {
    capa = document.createElement('div');
    capa.id = 'capa-pago';
    capa.className = 'capa-pago';
    capa.setAttribute('role', 'status');
    capa.innerHTML = '<div class="cargando" aria-hidden="true"></div><p><strong>Procesando tu pago…</strong></p><p class="texto-suave">No cierres ni recargues esta página.</p>';
    $('#zona-pago', main).appendChild(capa);
  } else if (!activo && capa) capa.remove();
}

function guardarPendiente() { try { localStorage.setItem(CLAVE_PAGO_PENDIENTE, JSON.stringify({ desde: Date.now() })); } catch (e) { /* sin almacenamiento */ } }
function borrarPendiente() { try { localStorage.removeItem(CLAVE_PAGO_PENDIENTE); } catch (e) { /* sin almacenamiento */ } }
function leerPendiente() {
  try {
    const p = JSON.parse(localStorage.getItem(CLAVE_PAGO_PENDIENTE));
    if (p && Date.now() - p.desde < 5 * 60 * 1000) return p;
  } catch (e) { /* sin almacenamiento */ }
  borrarPendiente();
  return null;
}

/* El carrito también está guardado en la cuenta (base de datos). Antes se mandaba a vaciar con una espera de 0,4 s y la
   página cambiaba enseguida a la confirmación: muchas veces el borrado no alcanzaba a salir y los productos ya comprados
   volvían a aparecer en el carrito. Ahora se espera (máximo 4 s) a que la base lo borre antes de cambiar de página;
   si aun así no se pudo, queda una marca para borrarlo en la siguiente página. */
async function terminarCompra(fila) {
  guardarTemporal('ultimo-pedido', { numero: fila.numero, id: fila.id });
  guardarTemporal('entrega', null);
  estado.carrito = [];
  clearTimeout(esperasCuenta.carrito);
  guardarLocal(claveCuenta(CLAVE_CARRITO), []);
  actualizarContador(); borrarPendiente();
  if (estado.cliente) {
    const marca = claveCuenta(CLAVE_CARRITO_COMPRADO);
    guardarLocal(marca, true);
    try {
      const r = await Promise.race([Api.cuenta.vaciarCarrito(estado.cliente.cedula), new Promise((ok) => setTimeout(() => ok({ error: 'tiempo' }), 4000))]);
      if (r && !r.error) guardarLocal(marca, null);
    } catch (e) { /* queda la marca: se borra en la siguiente página */ }
  }
  location.replace('confirmacion.html');
}

/* ======================= Datos de un pedido (para confirmación y orden de pedido) ======================= */
async function cargarPedido(params) {
  const id = Number(params.get('pedido') || (leerTemporal('ultimo-pedido') || {}).id);
  if (!id) return { error: 'No encontramos ese pedido.' };
  const r = await Api.pedidos.uno(id);
  if (r.error) return r;
  if (!r.datos) return { error: 'No encontramos ese pedido o no es de tu cuenta.' };
  return r;
}
const horaCorta = (f) => new Date(f).toLocaleTimeString('es-EC', { hour: '2-digit', minute: '2-digit' });

/* ======================= Confirmación ======================= */
async function vistaConfirmacion(partes, params) {
  if (!protegerCuenta()) return null;
  if (!params.get('pedido') && !leerTemporal('ultimo-pedido')) { ir('pedidos.html'); return null; }
  const r = await cargarPedido(params);
  if (r.error) return { titulo: 'Compra realizada', seccion: 'carrito', html: errorCargaHtml(r.error) };
  const p = r.datos;
  return {
    titulo: 'Compra realizada',
    seccion: 'carrito',
    html: `
    <div class="contenedor pagina">
      ${pasos(4)}
      <div class="panel centro">
        <div class="icono-exito"><span>${icono('check')}</span></div>
        <h1 class="titulo-pagina">¡Compra realizada con éxito!</h1>
        <p class="subtitulo">Gracias por tu compra, ${esc(nombreCliente())}. Te enviamos la orden de pedido a <strong>${esc(correoSesion())}</strong>.</p>
        <p class="numero-pedido">Pedido N.º ${esc(p.numero)}</p>
        <div class="codigo-retiro" role="group" aria-label="Código de retiro">
          <span>Tu código de retiro</span>
          <strong>${esc(p.codigoRetiro)}</strong>
          <span class="texto-suave">En la tienda presenta tu cédula y tu número de pedido (o este código)</span>
        </div>
        <dl class="datos-lista panel panel--gris detalle-pedido">
          <dt>Productos</dt><dd>${plural(p.detalle_pedido.reduce((s, d) => s + d.cantidad, 0), 'producto', 'productos')}</dd>
          <dt>Total pagado</dt><dd>${dinero(p.total)}</dd>
          <dt>Pago</dt><dd>${esc(p.pagoTexto)} · ${esc(p.pago ? p.pago.estado : 'Aprobado')}</dd>
          <dt>Retiro en</dt><dd>${esc(p.tiendas.nombre)} · ${esc(p.tiendas.direccion)}</dd>
          <dt>Listo aprox.</dt><dd>${horaCorta(p.horaEstimada)} (en ${textoDuracion(Math.max(60, Math.round((new Date(p.horaEstimada) - new Date(p.creado_en)) / 60000)))})</dd>
        </dl>
        <div class="botones-fila" style="margin-top:1.5rem">
          <a class="boton boton--principal" href="orden.html?pedido=${p.id}">${icono('documento')}Ver orden de pedido</a>
          <a class="boton boton--secundario" href="pedidos.html">${icono('paquete')}Ver mis pedidos</a>
        </div>
        <a class="boton boton--texto boton--bloque seguir-comprando" style="margin-top:.75rem" href="${urlCatalogo()}">Seguir comprando</a>
      </div>
    </div>`
  };
}

/* ======================= Orden de pedido (imprimible) ======================= */
async function vistaOrden(partes, params) {
  if (!protegerCuenta()) return null;
  const r = await cargarPedido(params);
  if (r.error) return { titulo: 'Orden de pedido', seccion: 'pedidos', html: errorCargaHtml(r.error) };
  const p = r.datos;
  const cli = p.cliente || estado.cliente;
  return {
    titulo: `Orden de pedido ${p.numero}`,
    seccion: 'pedidos',
    html: `
    <div class="contenedor pagina">
      <div class="botones-fila no-imprimir" style="margin-bottom:1rem">
        <a class="boton boton--texto" href="${estado.esAdmin && !p.esMio ? 'admin.html' : 'pedidos.html'}">${icono('izquierda')}Volver</a>
        <button class="boton boton--principal" type="button" id="descargar-factura">${icono('documento')}Descargar factura (PDF)</button>
        <button class="boton boton--secundario" type="button" id="imprimir">${icono('documento')}Imprimir orden</button>
      </div>
      <article class="panel orden-pedido" aria-labelledby="titulo-orden">
        <header class="orden-pedido__cabecera">
          <div><span class="logo logo--orden" aria-hidden="true">ATHLETIX</span><p class="texto-suave">Tienda deportiva en línea</p></div>
          <div class="orden-pedido__numero"><h1 id="titulo-orden">Orden de pedido</h1><p><strong>N.º ${esc(p.numero)}</strong></p><p class="texto-suave">${fechaHora(p.creado_en)}</p></div>
        </header>
        <div class="codigo-retiro codigo-retiro--orden">
          <span>Código de retiro</span><strong>${esc(p.codigoRetiro)}</strong>
          <span class="texto-suave">En la tienda presenta tu cédula y tu número de pedido (o este código).</span>
        </div>
        <div class="orden-pedido__grilla">
          <section aria-labelledby="orden-cliente"><h2 id="orden-cliente">Cliente</h2>
            <dl class="datos-lista datos-lista--compacta">
              <dt>Nombre</dt><dd>${esc(cli.nombres)} ${esc(cli.apellidos)}</dd>
              <dt>${nombreDocumento(cli.cedula, false)}</dt><dd>${esc(cli.cedula)}</dd>
              <dt>Celular</dt><dd>${esc(cli.telefono)}</dd>
              <dt>Dirección</dt><dd>${esc(cli.direccion || '—')}</dd>
              <dt>Correo</dt><dd>${esc(cli.correo || correoSesion())}</dd>
            </dl></section>
          <section aria-labelledby="orden-entrega"><h2 id="orden-entrega">Retiro en tienda</h2>
            <dl class="datos-lista datos-lista--compacta">
              <dt>Tienda</dt><dd>${esc(p.tiendas.nombre)}</dd><dt>Dirección</dt><dd>${esc(p.tiendas.direccion)}</dd><dt>Horario</dt><dd>${esc(p.tiendas.horario)}</dd>
              <dt>Listo aprox.</dt><dd>${fechaHora(p.horaEstimada)}</dd>
              <dt>Estado</dt><dd>${esc(nombreEstado(p.estado))}</dd>
            </dl></section>
        </div>
        <h2>Productos que debes retirar</h2>
        <div class="tabla-desplazable" tabindex="0" role="region" aria-label="Productos del pedido">
          <table class="tabla-orden">
            <thead><tr><th scope="col">Código</th><th scope="col">Producto</th><th scope="col">Talla</th><th scope="col" class="num">Cant.</th><th scope="col" class="num">P. unitario</th><th scope="col" class="num">Subtotal</th></tr></thead>
            <tbody>${p.detalle_pedido.map((d) => { const pr = productoPorDbId(d.producto_id); return `<tr><td>${esc(d.producto_id)}</td><td>${esc(pr ? pr.nombre : d.producto_id)}</td><td>${esc(d.talla || 'Única')}</td><td class="num">${d.cantidad}</td><td class="num">${dinero(d.precio_unitario)}</td><td class="num">${dinero(d.precio_unitario * d.cantidad)}</td></tr>`; }).join('')}</tbody>
            <tfoot>
              <tr><th scope="row" colspan="5">Subtotal</th><td class="num">${dinero(p.subtotal)}</td></tr>
              <tr><th scope="row" colspan="5">IVA (15 %)</th><td class="num">${dinero(p.iva)}</td></tr>
              <tr><th scope="row" colspan="5">Retiro en tienda</th><td class="num">Gratis</td></tr>
              <tr class="tabla-orden__total"><th scope="row" colspan="5">Total pagado</th><td class="num">${dinero(p.total)}</td></tr>
            </tfoot>
          </table>
        </div>
        <p style="margin-top:1rem"><strong>Pago:</strong> ${esc(p.pagoTexto)} · ${esc(p.pago ? p.pago.estado : '')} · ${p.pago ? fechaHora(p.pago.fecha) : ''}</p>
        <p class="texto-suave" style="margin-top:.5rem">Orden de pedido: no reemplaza a la factura, que te llega por correo en PDF.</p>
      </article>
    </div>`,
    montar(main) {
      $('#imprimir', main).addEventListener('click', () => window.print());
      const b = $('#descargar-factura', main);
      b.addEventListener('click', async () => {
        const r = await conEspera(b, 'Generando…', async () => { try { await Factura.descargar(Factura.desdePedido(p, { ...cli, correo: cli.correo || correoSesion() })); return {}; } catch (e) { return { error: 'No se pudo generar la factura. Intenta de nuevo.' }; } });
        if (r && r.error) aviso(r.error, 'error');
      });
    }
  };
}
