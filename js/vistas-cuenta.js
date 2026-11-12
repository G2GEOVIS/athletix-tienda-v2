/* ATHLETIX · Vistas de cuenta: ingreso, registro, verificación de correo, perfil y pedidos */
'use strict';

/* ======================= Ingreso con Google ======================= */
const botonGoogle = () => (estado.googleActivo ? `
  <button class="boton boton--google boton--bloque" type="button" id="con-google">${GOOGLE_LOGO}Continuar con Google</button>
  <p class="separador-texto" style="margin-block:1.25rem">o con tu correo</p>` : '');

function activarGoogle(main, volver) {
  const b = $('#con-google', main);
  if (!b) return;
  b.addEventListener('click', async () => {
    if (volver) guardarVolverPendiente(volver);
    const r = await conEspera(b, 'Abriendo Google…', () => Api.auth.ingresarConGoogle());
    if (r && r.error) aviso(r.error, 'error');
  });
}

/* ======================= Ingresar ======================= */
function vistaIngresar(partes, params) {
  const volver = volverSeguro(params.get('volver')) || paginaPrevia();
  if (estado.sesion) { ir(estado.cliente ? destinoTrasIngreso(volver) : destinoSinPerfil(volver)); return null; }
  return {
    titulo: 'Inicia sesión',
    seccion: 'ingresar',
    html: `
    <div class="contenedor pagina">
      <div class="panel formulario-centro">
        <h1 class="titulo-pagina">Inicia sesión</h1>
        <p class="subtitulo cabecera-pagina">${volver === 'retiro.html' ? 'Ingresa con tu cuenta para finalizar tu compra.' : 'Ingresa para comprar y ver tus pedidos.'}</p>
        ${botonGoogle()}
        <form class="formulario" id="form-ingresar" novalidate>
          <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
          ${campo({ id: 'correo', etiqueta: 'Correo electrónico', tipo: 'email', extra: 'autocomplete="email" inputmode="email" autocapitalize="off" spellcheck="false"' })}
          ${atajosCorreo('correo')}
          ${campoClave({ id: 'clave', etiqueta: 'Contraseña' })}
          <button class="boton boton--principal boton--bloque" type="submit">Ingresar</button>
          <a class="boton boton--texto" href="recuperar.html">¿Olvidaste tu contraseña?</a>
        </form>
        <div id="zona-reenviar"></div>
        <p class="separador-texto" style="margin-block:1.25rem">¿No tienes cuenta?</p>
        <a class="boton boton--secundario boton--bloque" href="${conVolver('registro.html', volver)}">Crear cuenta</a>
      </div>
    </div>`,
    montar(main) {
      const form = $('#form-ingresar', main);
      activarAtajosCorreo(form); activarEnlacesError(form); activarVerClave(form); activarGoogle(main, volver);
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const correo = $('#correo', form).value.trim().toLowerCase();
        const clave = $('#clave', form).value;
        const ok = validarFormulario(form, [
          ['correo', Validar.correo(correo)],
          ['clave', clave ? '' : 'Escribe tu contraseña.']
        ], 'No pudimos iniciar sesión:');
        const previa = $('#invitar-registro', form); if (previa) previa.remove();
        if (!ok) return;
        const r = await conEspera($('button[type="submit"]', form), 'Ingresando…', () => Api.auth.ingresar(correo, clave));
        if (!r) return;
        if (r.error) {
          // Si el correo no tiene cuenta, se le dice claramente y se le ofrece crearla (con el correo ya escrito)
          if (/incorrectos/.test(r.error)) {
            const existe = await Api.cliente.correoRegistrado(correo);
            if (!existe.error && existe.datos === false) {
              validarFormulario(form, [['correo', 'No existe una cuenta con este correo. Revisa que esté bien escrito o crea tu cuenta.']], 'No pudimos iniciar sesión:');
              const crear = new URLSearchParams(conVolver('registro.html', volver).split('?')[1] || '');
              crear.set('correo', correo);
              // La invitación va justo debajo del aviso de error, donde la persona está mirando
              $('.alerta-errores', form).insertAdjacentHTML('afterend', `<div class="alerta alerta--info" id="invitar-registro" style="margin-bottom:1rem">${icono('usuario')}<div><p><strong>¿Es tu primera vez en ATHLETIX?</strong> Crea tu cuenta con ${esc(correo)} en un minuto.</p>
                <a class="boton boton--principal" style="margin-top:.6rem" href="registro.html?${crear}">Crear mi cuenta</a></div></div>`);
              return;
            }
            validarFormulario(form, [['clave', `La contraseña no es correcta. Si no la recuerdas, usa «¿Olvidaste tu contraseña?»${estado.googleActivo ? '; si creaste tu cuenta con Google, entra con «Continuar con Google»' : ''}.`]], 'No pudimos iniciar sesión:');
            return;
          }
          errorGeneral(form, r.error);
          if (/confirmas tu correo/.test(r.error)) mostrarReenviar($('#zona-reenviar', main), correo);
          return;
        }
        await alIniciarSesion(r.datos.session);
        if (estado.cliente) avisoSesion('entrada', `Iniciaste sesión, ${nombreCliente()}`, `Entraste con ${correoSesion()}.`);
        else avisoSesion('entrada', 'Iniciaste sesión', 'Antes de tu primera compra te pediremos tu cédula y celular.');
        if (!estado.cliente) { ir(destinoSinPerfil(volver)); return; }
        ir(destinoTrasIngreso(volver));
      });
    }
  };
}

function mostrarReenviar(zona, correo) {
  zona.innerHTML = `<div class="alerta alerta--info" style="margin-top:1rem">${icono('correo')}<div><p>¿No te llegó el correo de confirmación?</p>
    <button class="boton boton--secundario" type="button" id="reenviar" style="margin-top:.6rem">Enviarlo otra vez</button></div></div>`;
  $('#reenviar', zona).addEventListener('click', async (e) => {
    const r = await conEspera(e.currentTarget, 'Enviando…', () => Api.auth.reenviarConfirmacion(correo));
    if (!r) return;
    if (r.error) aviso(r.error, 'error'); else aviso(`Te enviamos otro correo a ${correo}. Revisa también la carpeta de spam.`);
  });
}

/* ======================= Registro ======================= */
function vistaRegistro(partes, params) {
  const volver = volverSeguro(params.get('volver')) || paginaPrevia();
  // Desde «Crear mi cuenta» del ingreso llega el correo que la persona ya escribió
  const correoInicial = Validar.correo(params.get('correo') || '') ? '' : String(params.get('correo')).toLowerCase();
  if (estado.sesion) { ir(estado.cliente ? destinoTrasIngreso(volver) : destinoSinPerfil(volver)); return null; }
  return {
    titulo: 'Crea tu cuenta',
    seccion: 'ingresar',
    html: `
    <div class="contenedor pagina">
      <div class="panel formulario-centro" style="max-width:46rem">
        <h1 class="titulo-pagina">Crea tu cuenta</h1>
        <p class="subtitulo cabecera-pagina">Los campos con <span class="requerido">*</span> son obligatorios. Te enviaremos un correo para confirmar que es tuyo.</p>
        ${botonGoogle()}
        <form class="formulario" id="form-registro" novalidate>
          <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
          ${camposDatosPersonales({})}
          <div>${campo({ id: 'correo-r', etiqueta: 'Correo electrónico', tipo: 'email', valor: correoInicial, ayuda: 'Usa un correo al que tengas acceso: ahí te llegará la confirmación y el aviso de tus pedidos.', extra: 'autocomplete="email" inputmode="email" autocapitalize="off" spellcheck="false"' })}<div style="margin-top:.5rem">${atajosCorreo('correo-r')}</div></div>
          <div class="formulario__fila formulario__fila--doble">
            ${campoClave({ id: 'clave-r', etiqueta: 'Contraseña', ayuda: 'Mínimo 8 caracteres, con letras, números y un carácter especial (! @ # $ % * ?)', autocomplete: 'new-password' })}
            ${campoClave({ id: 'clave-r2', etiqueta: 'Confirmar contraseña', ayuda: 'Escríbela otra vez', autocomplete: 'new-password' })}
          </div>
          <button class="boton boton--principal boton--bloque" type="submit">Crear cuenta</button>
        </form>
        <p class="separador-texto" style="margin-block:1.25rem">¿Ya tienes cuenta?</p>
        <a class="boton boton--secundario boton--bloque" href="${conVolver('login.html', volver)}">Iniciar sesión</a>
      </div>
    </div>`,
    montar(main) {
      const form = $('#form-registro', main);
      activarAtajosCorreo(form); activarEnlacesError(form); activarVerClave(form); activarGoogle(main, volver);
      activarDatosPersonales(form);
      validarAlSalir(form, 'correo-r', (v) => Validar.correo(v));
      validarAlSalir(form, 'clave-r', (v) => Validar.clave(v));
      // La confirmación también se revisa al salir del campo (antes solo al enviar: el aviso viejo se quedaba aunque ya estuviera bien)
      validarAlSalir(form, 'clave-r2', (v) => (!v ? 'Confirma tu contraseña.' : v !== $('#clave-r', form).value ? 'Las contraseñas no coinciden.' : ''));
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const datos = leerDatosPersonales(form);
        const correo = $('#correo-r', form).value.trim().toLowerCase();
        const clave = $('#clave-r', form).value;
        const clave2 = $('#clave-r2', form).value;
        const ok = validarFormulario(form, [
          ...reglasDatosPersonales(datos),
          ['correo-r', Validar.correo(correo)],
          ['clave-r', Validar.clave(clave)],
          ['clave-r2', !clave2 ? 'Confirma tu contraseña.' : clave2 !== clave ? 'Las contraseñas no coinciden.' : '']
        ], 'Revisa estos datos para crear tu cuenta:');
        if (!ok) return;
        const boton = $('button[type="submit"]', form);
        const r = await conEspera(boton, 'Creando cuenta…', async () => {
          // No se permite registrar dos veces la misma cédula, el mismo celular ni el mismo correo
          const [ced, cel, cor] = await Promise.all([Api.cliente.cedulaRegistrada(datos.cedula), Api.cliente.celularRegistrado(datos.telefono), Api.cliente.correoRegistrado(correo)]);
          if (ced.error) return ced;
          if (cor.error) return cor;
          const dobles = [];
          if (ced.datos) dobles.push(['cedula', 'Ya existe una cuenta con esta cédula. Inicia sesión.']);
          if (cel.datos) dobles.push(['telefono', 'Este celular ya está registrado en otra cuenta.']);
          if (cor.datos) dobles.push(['correo-r', 'Ya existe una cuenta con este correo. Inicia sesión.']);
          if (dobles.length) return { dobles };
          return Api.auth.registrar(correo, clave, datos);
        });
        if (!r) return;
        if (r.dobles) { validarFormulario(form, r.dobles, 'Ya tienes una cuenta:'); return; }
        if (r.error) { errorGeneral(form, r.error); return; }
        if (r.datos && r.datos.session) {
          await alIniciarSesion(r.datos.session);
          ir(destinoTrasIngreso(volver));
          return;
        }
        guardarTemporal('correo-pendiente', correo);
        if (volver) guardarVolverPendiente(volver);
        ir('confirmar-correo.html');
      });
    }
  };
}

/* Campos compartidos por registro, completar perfil y editar perfil.
   Por defecto es un cliente de Ecuador (cédula y celular 09…). Solo si elige "Otro país" aparecen
   el país, el pasaporte y el celular con el código del país. */
function camposDatosPersonales(v, { cedulaFija = false } = {}) {
  const extranjero = !!(v.pais && v.pais !== 'Ecuador');
  const telNacional = extranjero && v.telefono ? String(v.telefono).replace(codigoPais(v.pais), '') : (v.telefono || '');
  return `
    <div class="formulario__fila formulario__fila--doble">
      ${campo({ id: 'nombres', etiqueta: 'Nombres', ayuda: 'Solo letras, por ejemplo: Ana', valor: v.nombres || '', max: 60, extra: 'autocomplete="given-name" autocapitalize="words"' })}
      ${campo({ id: 'apellidos', etiqueta: 'Apellidos', ayuda: 'Solo letras, por ejemplo: Pérez', valor: v.apellidos || '', max: 60, extra: 'autocomplete="family-name" autocapitalize="words"' })}
    </div>
    ${cedulaFija ? '' : `
    <fieldset class="donde-vives">
      <legend>¿Dónde vives?</legend>
      <div class="donde-vives__opciones">
        <label class="opcion opcion--caja"><input type="radio" name="residencia" value="ecuador" ${extranjero ? '' : 'checked'}> <span>Ecuador</span></label>
        <label class="opcion opcion--caja"><input type="radio" name="residencia" value="otro" ${extranjero ? 'checked' : ''}> <span>Otro país</span></label>
      </div>
    </fieldset>
    <div class="campo" id="campo-pais" ${extranjero ? '' : 'hidden'}>
      <label for="pais">País <span class="requerido" aria-hidden="true">*</span></label>
      <select id="pais" autocomplete="country-name" aria-describedby="pais-error"><option value="">Elige tu país</option>${PAISES.map(([p, c]) => `<option value="${p}" ${p === v.pais ? 'selected' : ''}>${p} (${c})</option>`).join('')}</select>
      <p class="campo__error" id="pais-error" hidden>${icono('alerta')}<span></span></p>
    </div>`}
    <div class="formulario__fila formulario__fila--doble">
      ${cedulaFija
        ? `<div class="campo"><p style="font-weight:700">${extranjero ? 'Pasaporte' : 'Cédula'}</p><p class="campo-fijo">${esc(v.cedula)}${extranjero ? ` · ${esc(v.pais)}` : ''}</p><p class="campo__ayuda">${extranjero ? 'El pasaporte' : 'La cédula'} no se puede cambiar.</p></div>`
        : campo({ id: 'cedula', etiqueta: extranjero ? 'Pasaporte' : 'Cédula', ayuda: extranjero ? '5 a 20 letras y números, sin espacios' : '10 números, sin guion', valor: v.cedula || '', max: 20, extra: 'autocomplete="off" autocapitalize="characters" spellcheck="false"' + (extranjero ? '' : ' inputmode="numeric"') })}
      <div class="campo">
        <label for="telefono">Celular <span class="requerido" aria-hidden="true">*</span></label>
        <p class="campo__ayuda" id="telefono-ayuda">${extranjero ? 'Solo el número, sin el código del país' : '10 números, empieza con 09'}</p>
        <div class="campo-telefono"><span class="campo-telefono__codigo" id="codigo-pais" ${extranjero ? '' : 'hidden'} aria-hidden="true">${esc(codigoPais(v.pais))}</span>
          <input id="telefono" name="telefono" type="tel" value="${esc(telNacional)}" maxlength="15" required aria-required="true" aria-describedby="telefono-ayuda telefono-error" autocomplete="tel-national" inputmode="numeric" data-extranjero="${extranjero ? '1' : ''}" data-pais="${esc(v.pais || 'Ecuador')}"></div>
        <p class="campo__error" id="telefono-error" hidden>${icono('alerta')}<span></span></p>
      </div>
    </div>
    ${campo({ id: 'direccion', etiqueta: 'Dirección de domicilio', ayuda: extranjero ? 'Calle, número, ciudad y país. Aparece en tu factura.' : 'Calle principal, número y calle secundaria, ciudad. Aparece en tu factura.', valor: v.direccion || '', max: 150, extra: 'autocomplete="street-address"' })}`;
}
// País elegido en el formulario ("Ecuador" si no eligió "Otro país")
function paisDelFormulario(form) {
  const otro = $('input[name="residencia"]:checked', form);
  if (otro) return otro.value === 'otro' ? ($('#pais', form).value || '') : 'Ecuador';
  return $('#telefono', form).dataset.pais || 'Ecuador';
}
function activarDatosPersonales(form) {
  filtrarEntrada($('#nombres', form), NO_LETRAS, 60);
  filtrarEntrada($('#apellidos', form), NO_LETRAS, 60);
  const tel = $('#telefono', form);
  const ced = $('#cedula', form);
  const esOtro = () => paisDelFormulario(form) !== 'Ecuador';
  tel.addEventListener('input', () => { const d = tel.value.replace(/\D/g, '').slice(0, esOtro() ? 14 : 10); if (d !== tel.value) tel.value = d; });
  if (ced) ced.addEventListener('input', () => {
    const v = esOtro() ? ced.value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 20) : ced.value.replace(/\D/g, '').slice(0, 10);
    if (v !== ced.value) ced.value = v;
  });
  validarAlSalir(form, 'nombres', (v) => Validar.nombre(v, 'nombre'));
  validarAlSalir(form, 'apellidos', (v) => Validar.nombre(v, 'apellido'));
  validarAlSalir(form, 'telefono', (v) => (esOtro() ? Validar.telefonoInternacional(v, codigoPais(paisDelFormulario(form))) : Validar.telefono(v)));
  validarAlSalir(form, 'direccion', (v) => Validar.direccion(v));
  if (ced) validarAlSalir(form, 'cedula', (v) => (esOtro() ? Validar.pasaporte(v) : Validar.cedula(v)));
  // Al cambiar entre Ecuador y otro país se cambian el documento, el celular y sus ayudas
  const pintar = () => {
    const otro = esOtro() || (($('input[name="residencia"]:checked', form) || {}).value === 'otro');
    const campoPais = $('#campo-pais', form);
    if (campoPais) campoPais.hidden = !otro;
    if (ced) {
      $('label[for="cedula"]', form).innerHTML = `${otro ? 'Pasaporte' : 'Cédula'} <span class="requerido" aria-hidden="true">*</span>`;
      $('#cedula-ayuda', form).textContent = otro ? '5 a 20 letras y números, sin espacios' : '10 números, sin guion';
      ced.inputMode = otro ? 'text' : 'numeric';
    }
    $('#telefono-ayuda', form).textContent = otro ? 'Solo el número, sin el código del país' : '10 números, empieza con 09';
    const codigo = $('#codigo-pais', form);
    codigo.textContent = otro ? codigoPais(paisDelFormulario(form)) : '';
    codigo.hidden = !otro || !codigo.textContent;
    $('#direccion-ayuda', form).textContent = otro ? 'Calle, número, ciudad y país. Aparece en tu factura.' : 'Calle principal, número y calle secundaria, ciudad. Aparece en tu factura.';
  };
  form.addEventListener('change', (e) => {
    if (e.target.name === 'residencia' || e.target.id === 'pais') {
      pintar();
      if (e.target.name === 'residencia' && e.target.value === 'otro') $('#pais', form).focus();
    }
  });
}
// Nombres con mayúscula inicial aunque se escriban con Bloq Mayús o todo en minúsculas (ANA pérez → Ana Pérez)
const limpiarNombre = (t) => t.trim().replace(/\s+/g, ' ').toLocaleLowerCase('es').replace(/(^|[ '-])([a-záéíóúüñ])/g, (m, a, b) => a + b.toUpperCase());
function leerDatosPersonales(form) {
  const ced = $('#cedula', form);
  const pais = paisDelFormulario(form);
  const tel = $('#telefono', form).value.replace(/\s+/g, '');
  return {
    nombres: limpiarNombre($('#nombres', form).value),
    apellidos: limpiarNombre($('#apellidos', form).value),
    cedula: ced ? ced.value.trim().toUpperCase() : undefined,
    pais,
    // En otro país se guarda en formato internacional: +código y número
    telefono: pais !== 'Ecuador' && tel ? codigoPais(pais) + tel : tel,
    telefonoNacional: tel,
    direccion: $('#direccion', form).value.trim().replace(/\s+/g, ' ')
  };
}
function reglasDatosPersonales(d) {
  const otro = d.pais !== 'Ecuador';
  const r = [
    ['nombres', Validar.nombre(d.nombres, 'nombre')],
    ['apellidos', Validar.nombre(d.apellidos, 'apellido')]
  ];
  if (otro && document.getElementById('pais') && !d.pais) r.push(['pais', 'Elige el país donde vives.']);
  if (d.cedula !== undefined) r.push(['cedula', otro ? Validar.pasaporte(d.cedula) : Validar.cedula(d.cedula)]);
  r.push(['telefono', otro ? Validar.telefonoInternacional(d.telefonoNacional, codigoPais(d.pais)) : Validar.telefono(d.telefonoNacional)]);
  r.push(['direccion', Validar.direccion(d.direccion)]);
  return r;
}

/* ======================= Verificación de correo ======================= */
function vistaVerificaCorreo() {
  const correo = leerTemporal('correo-pendiente');
  if (!correo) { ir('login.html'); return null; }
  return {
    titulo: 'Confirma tu correo',
    seccion: 'ingresar',
    html: `
    <div class="contenedor pagina">
      <div class="panel centro" style="max-width:38rem">
        <div class="icono-exito"><span>${icono('correo')}</span></div>
        <h1 class="titulo-pagina">Revisa tu correo</h1>
        <p class="subtitulo">Te enviamos un enlace de confirmación a <strong>${esc(correo)}</strong>.</p>
        <ol class="lista-pasos">
          <li>Abre el correo de ATHLETIX (revisa también spam o promociones).</li>
          <li>Pulsa el enlace <strong>Confirmar mi correo</strong>.</li>
          <li>Volverás a la tienda con tu sesión iniciada.</li>
        </ol>
        <div id="zona-reenviar"></div>
        <a class="boton boton--texto" href="login.html">Ya lo confirmé, iniciar sesión</a>
      </div>
    </div>`,
    montar(main) {
      mostrarReenviar($('#zona-reenviar', main), correo);
      // Si confirma el correo en otra pestaña, la sesión llega aquí también: se continúa sola (al carrito o a la tienda de retiro)
      const revisar = setInterval(async () => {
        if (!main.isConnected) { clearInterval(revisar); return; }
        const sesion = await Api.auth.sesion();
        if (!sesion) return;
        clearInterval(revisar);
        await alIniciarSesion(sesion);
        guardarTemporal('correo-pendiente', null);
        const volver = leerVolverPendiente();
        guardarVolverPendiente(null);
        if (estado.cliente) avisoSesion('entrada', `Iniciaste sesión, ${nombreCliente()}`, 'Tu correo quedó confirmado y tu perfil está guardado.');
        else avisoSesion('entrada', 'Correo confirmado: iniciaste sesión', 'Completa tu perfil para seguir.');
        ir(estado.cliente ? destinoTrasIngreso(volver) : destinoSinPerfil(volver));
      }, 3000);
    }
  };
}

/* Nombre que entrega Google: usa nombre y apellido por separado si vienen; si no, separa el nombre completo
   (4 o más palabras: dos nombres y el resto apellidos; si no, un nombre y el resto apellidos).
   Solo deja letras, espacios, apóstrofo y guion, igual que el formulario. */
function nombreDesdeGoogle(meta) {
  const limpio = (t) => String(t || '').replace(/[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]/g, ' ').replace(/\s+/g, ' ').trim().slice(0, 60);
  if (meta.given_name || meta.family_name) return { nombres: limpio(meta.given_name), apellidos: limpio(meta.family_name) };
  const partes = limpio(meta.full_name || meta.name).split(' ').filter(Boolean);
  const corte = partes.length >= 4 ? 2 : 1;
  return { nombres: partes.slice(0, corte).join(' '), apellidos: partes.slice(corte).join(' ') };
}

/* ======================= Completar perfil (si faltan datos al primer ingreso) ======================= */
function vistaCompletarPerfil(partes, params) {
  if (!estado.sesion) { ir('login.html'); return null; }
  if (estado.cliente) { ir('perfil.html'); return null; }
  const meta = estado.sesion.user.user_metadata || {};
  const google = nombreDesdeGoogle(meta);
  const v = { nombres: meta.nombres || google.nombres, apellidos: meta.apellidos || google.apellidos, cedula: meta.cedula || '', telefono: meta.telefono || '', direccion: meta.direccion || '' };
  const volver = volverSeguro(params.get('volver') || leerVolverPendiente());
  return {
    titulo: 'Completa tu perfil',
    seccion: 'perfil',
    html: `
    <div class="contenedor pagina">
      <div class="panel formulario-centro" style="max-width:46rem">
        <h1 class="titulo-pagina">Completa tu perfil</h1>
        <p class="subtitulo cabecera-pagina">Necesitamos estos datos para preparar tus pedidos. Al retirarlos te pediremos tu cédula.</p>
        <p class="texto-suave" style="margin-bottom:1rem">Cuenta: <strong>${esc(correoSesion())}</strong></p>
        <form class="formulario" id="form-completar" novalidate>
          <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
          ${camposDatosPersonales(v)}
          <button class="boton boton--principal boton--bloque" type="submit">Guardar y continuar</button>
        </form>
      </div>
    </div>`,
    montar(main) {
      const form = $('#form-completar', main);
      activarEnlacesError(form); activarDatosPersonales(form);
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const d = leerDatosPersonales(form);
        if (!validarFormulario(form, reglasDatosPersonales(d), 'Revisa estos datos:')) return;
        const r = await conEspera($('button[type="submit"]', form), 'Guardando…', async () => {
          const [ced, cel] = await Promise.all([Api.cliente.cedulaRegistrada(d.cedula), Api.cliente.celularRegistrado(d.telefono)]);
          if (ced.error) return ced;
          const dobles = [];
          if (ced.datos) dobles.push(['cedula', 'Ya existe otra cuenta con esta cédula.']);
          if (cel.datos) dobles.push(['telefono', 'Este celular ya está registrado en otra cuenta.']);
          if (dobles.length) return { dobles };
          return Api.cliente.crear({ id: estado.sesion.user.id, correo: correoSesion(), ...d });
        });
        if (!r) return;
        if (r.dobles) { validarFormulario(form, r.dobles, 'No pudimos guardar:'); return; }
        if (r.error) { errorGeneral(form, r.error); return; }
        estado.cliente = r.datos;
        renderCuenta();
        guardarVolverPendiente(null);
        aviso(`¡Listo, ${nombreCliente()}! Tu perfil está completo.`);
        ir(destinoTrasIngreso(volver));
      });
    }
  };
}

/* ======================= Recuperar y cambiar contraseña ======================= */
function vistaRecuperar() {
  return {
    titulo: 'Recuperar contraseña',
    seccion: 'ingresar',
    html: `
    <div class="contenedor pagina">
      <div class="panel formulario-centro">
        <h1 class="titulo-pagina">Recuperar contraseña</h1>
        <p class="subtitulo cabecera-pagina">Escribe el correo de tu cuenta y te enviaremos un enlace para crear una contraseña nueva.</p>
        <form class="formulario" id="form-recuperar" novalidate>
          <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
          ${campo({ id: 'correo-rec', etiqueta: 'Correo electrónico', tipo: 'email', extra: 'autocomplete="email" inputmode="email" autocapitalize="off"' })}
          <button class="boton boton--principal boton--bloque" type="submit">Enviar enlace</button>
          <a class="boton boton--texto" href="login.html">${icono('izquierda')}Volver a iniciar sesión</a>
        </form>
      </div>
    </div>`,
    montar(main) {
      const form = $('#form-recuperar', main);
      activarEnlacesError(form);
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const correo = $('#correo-rec', form).value.trim().toLowerCase();
        if (!validarFormulario(form, [['correo-rec', Validar.correo(correo)]], 'Revisa tu correo:')) return;
        const r = await conEspera($('button[type="submit"]', form), 'Enviando…', () => Api.auth.recuperarClave(correo));
        if (!r) return;
        if (r.error) { errorGeneral(form, r.error); return; }
        form.innerHTML = `<p class="alerta alerta--info" role="status">${icono('correo')}<span>Si existe una cuenta con ${esc(correo)}, te llegará un correo con el enlace en unos minutos. Revisa también la carpeta de spam.</span></p>`;
      });
    }
  };
}

function formularioNuevaClave(idForm) {
  return `
    <form class="formulario" id="${idForm}" novalidate>
      <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
      ${campoClave({ id: 'nueva', etiqueta: 'Nueva contraseña', ayuda: 'Mínimo 8 caracteres, con letras, números y un carácter especial (! @ # $ % * ?)', autocomplete: 'new-password' })}
      ${campoClave({ id: 'nueva2', etiqueta: 'Confirmar nueva contraseña', autocomplete: 'new-password' })}
      <button class="boton boton--principal boton--bloque" type="submit">Guardar contraseña</button>
    </form>`;
}
function activarNuevaClave(form, alTerminar) {
  activarEnlacesError(form); activarVerClave(form);
  validarAlSalir(form, 'nueva', (v) => Validar.clave(v));
  validarAlSalir(form, 'nueva2', (v) => (!v ? 'Confirma la contraseña.' : v !== $('#nueva', form).value ? 'Las contraseñas no coinciden.' : ''));
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const c1 = $('#nueva', form).value; const c2 = $('#nueva2', form).value;
    if (!validarFormulario(form, [
      ['nueva', Validar.clave(c1)],
      ['nueva2', !c2 ? 'Confirma la contraseña.' : c1 !== c2 ? 'Las contraseñas no coinciden.' : '']
    ], 'Revisa la contraseña:')) return;
    const r = await conEspera($('button[type="submit"]', form), 'Guardando…', () => Api.auth.cambiarClave(c1));
    if (!r) return;
    if (r.error) { errorGeneral(form, r.error); return; }
    form.reset();
    alTerminar();
  });
}

function vistaNuevaClave() {
  if (!estado.sesion) { ir('recuperar.html'); return null; }
  return {
    titulo: 'Nueva contraseña',
    seccion: 'ingresar',
    html: `<div class="contenedor pagina"><div class="panel formulario-centro">
      <h1 class="titulo-pagina">Crea tu nueva contraseña</h1>
      <p class="subtitulo cabecera-pagina">Cuenta: ${esc(correoSesion())}</p>
      ${formularioNuevaClave('form-nueva')}</div></div>`,
    montar(main) { activarNuevaClave($('#form-nueva', main), () => { aviso('Tu contraseña se cambió correctamente.'); ir('index.html'); }); }
  };
}

/* ======================= Perfil ======================= */
function protegerCuenta(volver = '') {
  if (!estado.sesion) { ir(conVolver('login.html', volver || paginaActual())); return false; }
  if (!estado.cliente) { ir(conVolver('completar-perfil.html', volver || paginaActual())); return false; }
  return true;
}

const SECCIONES_PERFIL = [
  ['', 'Mis datos', 'usuario'],
  ['pagos', 'Métodos de pago', 'tarjeta'],
  ['seguridad', 'Contraseña', 'candado']
];
/* Nombre completo, correo y cédula del cliente, con sus iniciales */
function tarjetaCliente() {
  const c = estado.cliente || {};
  const completo = `${c.nombres || ''} ${c.apellidos || ''}`.trim();
  const iniciales = ((c.nombres || ' ')[0] + (c.apellidos || ' ')[0]).trim().toUpperCase();
  return `<div class="cliente-tarjeta cabecera-pagina">
      <span class="cliente-tarjeta__avatar" aria-hidden="true">${esc(iniciales)}</span>
      <div class="cliente-tarjeta__datos">
        <p class="cliente-tarjeta__nombre">${esc(completo)}${estado.esAdmin ? ' <span class="insignia-rol">Administrador</span>' : ''}</p>
        <p class="texto-suave">${esc(c.correo || correoSesion())}${c.cedula ? ` · ${nombreDocumento(c.cedula)} ${esc(c.cedula)}` : ''}${c.pais && c.pais !== 'Ecuador' ? ` · ${esc(c.pais)}` : ''}</p>
      </div>
    </div>`;
}
function marcoPerfil(actual, contenido) {
  return `
    <div class="contenedor pagina">
      <h1 class="titulo-pagina">Mi perfil</h1>
      ${tarjetaCliente()}
      <div class="perfil">
        <nav class="perfil__menu" aria-label="Secciones del perfil">
          <ul>
            ${SECCIONES_PERFIL.map(([r, t, i]) => `<li><a href="${ARCHIVO_PERFIL[r]}" ${r === actual ? 'aria-current="page"' : ''}>${icono(i)}${t}</a></li>`).join('')}
            <li><a href="pedidos.html">${icono('paquete')}Mis pedidos</a></li>
            ${estado.esAdmin ? `<li><a href="admin.html">${icono('ajustes')}Panel de pedidos</a></li>` : ''}
            <li><button type="button" data-accion="cerrar-sesion">${icono('salir')}Cerrar sesión</button></li>
          </ul>
        </nav>
        <div class="perfil__contenido">${contenido}</div>
      </div>
    </div>`;
}

async function vistaPerfil(partes) {
  if (!protegerCuenta()) return null;
  const sub = partes[1] || '';
  if (sub === 'pagos') return vistaPagos();
  if (sub === 'seguridad') return vistaSeguridad();
  const c = estado.cliente;
  return {
    titulo: 'Mi perfil',
    seccion: 'perfil',
    html: marcoPerfil('', `
      <section class="panel" aria-labelledby="titulo-datos">
        <h2 id="titulo-datos">Mis datos</h2>
        <form class="formulario" id="form-datos" novalidate>
          <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
          ${camposDatosPersonales(c, { cedulaFija: true })}
          <div class="campo"><p style="font-weight:700">Correo electrónico</p><p class="campo-fijo">${esc(correoSesion())}</p>
            <p class="campo__ayuda">Es el correo de tu cuenta y donde te avisamos de tus pedidos.</p></div>
          <p class="texto-suave">Cliente desde el ${fecha(c.creado_en)}.</p>
          <button class="boton boton--principal" type="submit">Guardar cambios</button>
        </form>
      </section>`),
    montar(main) {
      const form = $('#form-datos', main);
      activarEnlacesError(form); activarDatosPersonales(form);
      form.addEventListener('submit', async (e) => {
        e.preventDefault();
        const d = leerDatosPersonales(form);
        delete d.cedula;
        if (!validarFormulario(form, reglasDatosPersonales(d), 'Revisa tus datos:')) return;
        const r = await conEspera($('button[type="submit"]', form), 'Guardando…', async () => {
          if (d.telefono !== c.telefono) {
            const cel = await Api.cliente.celularRegistrado(d.telefono);
            if (cel.datos) return { dobles: [['telefono', 'Este celular ya está registrado en otra cuenta.']] };
          }
          return Api.cliente.actualizar(c.id, d);
        });
        if (r && r.dobles) { validarFormulario(form, r.dobles, 'No pudimos guardar:'); return; }
        if (!r) return;
        if (r.error) { errorGeneral(form, r.error); return; }
        estado.cliente = r.datos;
        renderCuenta();
        $('#nombres', form).value = r.datos.nombres;
        $('#apellidos', form).value = r.datos.apellidos;
        aviso('Tus datos se guardaron.');
        anunciar('Tus datos se guardaron.');
      });
    }
  };
}

function vistaSeguridad() {
  const conGoogle = (estado.sesion.user.app_metadata || {}).provider === 'google';
  return {
    titulo: 'Cambiar contraseña',
    seccion: 'perfil',
    html: marcoPerfil('seguridad', `
      <section class="panel" aria-labelledby="titulo-clave">
        <h2 id="titulo-clave">${conGoogle ? 'Crear una contraseña' : 'Cambiar contraseña'}</h2>
        ${conGoogle ? '<p class="texto-suave" style="margin-bottom:1rem">Ingresas con Google. Si creas una contraseña, también podrás entrar con tu correo.</p>' : ''}
        ${formularioNuevaClave('form-clave')}
      </section>`),
    montar(main) { activarNuevaClave($('#form-clave', main), () => { aviso('Tu contraseña se cambió correctamente.'); anunciar('Tu contraseña se cambió correctamente.'); }); }
  };
}

/* ---------- Métodos de pago ---------- */
async function vistaPagos() {
  const r = await Api.cliente.tarjetas();
  if (r.error) return { titulo: 'Métodos de pago', html: errorCargaHtml(r.error) };
  const lista = r.datos || [];
  return {
    titulo: 'Métodos de pago',
    seccion: 'perfil',
    html: marcoPerfil('pagos', `
      <section class="panel" aria-labelledby="titulo-pagos">
        <div class="cabecera-seccion"><h2 id="titulo-pagos">Métodos de pago</h2>
          <button class="boton boton--principal" type="button" id="nueva-tarjeta">${icono('mas')}Agregar tarjeta</button></div>
        <p class="texto-suave" style="margin-bottom:1rem">${icono('candado')} Por seguridad solo guardamos la marca, los últimos 4 dígitos y la fecha de vencimiento. Nunca guardamos el número completo ni el CVV.</p>
        ${lista.length ? `<ul class="tarjetas-lista">${lista.map((t) => `
          <li class="tarjeta-dato">
            <div class="tarjeta-dato__info">${icono('tarjeta')}<div><p><strong>${t.marca} •••• ${t.ultimos4}</strong></p>
              <p class="texto-suave">${esc(t.titular)} · Vence ${String(t.mes_vence).padStart(2, '0')}/${String(t.anio_vence).slice(2)}</p></div></div>
            <button class="boton-icono" type="button" data-borrar-tarjeta="${t.id}">${icono('basura')}Quitar<span class="solo-lector"> ${t.marca} terminada en ${t.ultimos4}</span></button>
          </li>`).join('')}</ul>` : `<div class="panel panel--gris vacio">${icono('tarjeta')}<p>No tienes tarjetas guardadas. Se guardan al pagar o desde aquí.</p></div>`}
      </section>`),
    montar(main) {
      $('#nueva-tarjeta', main).addEventListener('click', () => {
        abrirDialogo(`
          <h2 class="dialogo__titulo" id="dialogo-titulo">Agregar tarjeta</h2>
          <form class="formulario" id="form-tarjeta-nueva" novalidate>
            <div class="alerta alerta-errores" tabindex="-1" role="alert" hidden></div>
            ${avisoTarjetasPrueba()}
            ${camposTarjeta()}
            <div class="dialogo__botones">
              <button class="boton boton--secundario" type="button" data-cerrar-dialogo>Cancelar</button>
              <button class="boton boton--principal" type="submit">Guardar tarjeta</button>
            </div>
          </form>`, {
          ancho: true,
          alAbrir: (dlg) => {
            const form = $('#form-tarjeta-nueva', dlg);
            activarCamposTarjeta(form);
            $('#tarjeta', form).focus();
            form.addEventListener('submit', async (e) => {
              e.preventDefault();
              const t = leerTarjeta(form);
              if (!t) return;
              const rg = await conEspera($('button[type="submit"]', form), 'Guardando…', () => Api.cliente.guardarTarjeta(t.registro));
              if (!rg) return;
              if (rg.error) { errorGeneral(form, rg.error); return; }
              cerrarDialogo();
              aviso('Tarjeta guardada.');
              render();
            });
          }
        });
      });
      main.addEventListener('click', async (e) => {
        const b = e.target.closest('[data-borrar-tarjeta]');
        if (!b) return;
        const t = lista.find((x) => x.id === Number(b.dataset.borrarTarjeta));
        if (!(await confirmar('¿Quitar tarjeta?', `Se quitará la ${t.marca} terminada en ${t.ultimos4}.`, 'Sí, quitar'))) return;
        const rb = await Api.cliente.borrarTarjeta(t.id);
        if (rb.error) {
          aviso(rb.tecnico && (rb.tecnico.code === '23503' || /foreign key/i.test(rb.tecnico.message || '')) ? 'No puedes quitar una tarjeta que ya usaste en un pedido; queda en tu historial.' : rb.error, 'error');
          return;
        }
        aviso('Tarjeta quitada.');
        render();
      });
    }
  };
}

/* Campos de tarjeta (compartidos por el pago y el perfil) */
function camposTarjeta() {
  return `
    ${campo({ id: 'tarjeta', etiqueta: 'Número de tarjeta', ayuda: 'Normalmente 16 dígitos. Te mostramos la marca al escribir.', max: 23, extra: 'autocomplete="cc-number" inputmode="numeric" placeholder="0000 0000 0000 0000"' })}
    <p class="marca-tarjeta texto-suave" id="marca-tarjeta" aria-live="polite"></p>
    ${campo({ id: 'titular', etiqueta: 'Nombre del titular', ayuda: 'Como aparece en la tarjeta', max: 60, extra: 'autocomplete="cc-name" autocapitalize="characters"' })}
    <div class="formulario__fila formulario__fila--doble">
      ${campo({ id: 'vence', etiqueta: 'Vencimiento', ayuda: 'MM/AA', max: 5, extra: 'autocomplete="cc-exp" inputmode="numeric" placeholder="MM/AA"' })}
      ${campo({ id: 'cvv', etiqueta: 'CVV', tipo: 'password', ayuda: '3 dígitos al reverso', max: 3, extra: 'autocomplete="cc-csc" inputmode="numeric"' })}
    </div>`;
}
/* Aviso de seguridad del pago (no se cobra dinero: solo se guardan la marca y los últimos 4 dígitos) */
function avisoTarjetasPrueba() {
  return `
    <section class="tarjetas-prueba" aria-labelledby="titulo-prueba">
      <h3 id="titulo-prueba">${icono('candado')}Pago seguro y simulado</h3>
      <p>Aceptamos todas las tarjetas de crédito y débito. Revisamos que el número sea válido, la fecha de vencimiento y el CVV. No se cobra dinero real y nunca guardamos el número completo ni el CVV: solo la marca y los últimos 4 dígitos.</p>
    </section>`;
}
function activarCamposTarjeta(form) {
  activarEnlacesError(form);
  const tarjeta = $('#tarjeta', form);
  tarjeta.addEventListener('input', () => {
    const d = tarjeta.value.replace(/\D/g, '').slice(0, 19);
    const formateado = d.replace(/(\d{4})(?=\d)/g, '$1 ');
    if (formateado !== tarjeta.value) tarjeta.value = formateado;
    const info = Validar.datosMarca(d);
    $('#marca-tarjeta', form).textContent = d.length >= 2
      ? (!info ? 'No reconocemos esta tarjeta'
        : info.largos.includes(d.length) ? `Tarjeta ${info.marca} · ${d.length} dígitos`
        : `Tarjeta ${info.marca} · llevas ${d.length} de ${info.largos.find((n) => n > d.length) || Math.max(...info.largos)} dígitos`)
      : '';
  });
  validarAlSalir(form, 'tarjeta', (v) => Validar.tarjeta(v));
  // American Express trae 4 números al frente; las demás, 3 al reverso
  const cvvCampo = $('#cvv', form);
  const largoCvv = () => Validar.largoCvv(Validar.marcaTarjeta(tarjeta.value));
  tarjeta.addEventListener('input', () => {
    const n = largoCvv();
    cvvCampo.maxLength = n;
    $('#cvv-ayuda', form).textContent = n === 4 ? '4 dígitos al frente de la tarjeta' : '3 dígitos al reverso';
    if (cvvCampo.value.length > n) cvvCampo.value = cvvCampo.value.slice(0, n);
  });
  filtrarEntrada($('#titular', form), NO_LETRAS, 60);
  const vence = $('#vence', form);
  vence.addEventListener('input', (e) => {
    let d = vence.value.replace(/\D/g, '').slice(0, 4);
    if (d.length === 1 && Number(d) > 1) d = '0' + d;
    const nuevo = d.length > 2 || (d.length === 2 && e.inputType !== 'deleteContentBackward') ? d.slice(0, 2) + '/' + d.slice(2) : d;
    if (nuevo !== vence.value) vence.value = nuevo;
  });
  validarAlSalir(form, 'vence', (v) => Validar.vencimiento(v));
  filtrarEntrada(cvvCampo, NO_DIGITOS, largoCvv);
}
/* Valida y devuelve los datos seguros de la tarjeta (sin número completo ni CVV) */
function leerTarjeta(form) {
  const numero = $('#tarjeta', form).value.replace(/\D/g, '');
  const titular = $('#titular', form).value.trim().replace(/\s+/g, ' ');
  const vence = $('#vence', form).value.trim();
  const ok = validarFormulario(form, [
    ['tarjeta', Validar.tarjeta(numero)],
    ['titular', Validar.titular(titular)],
    ['vence', Validar.vencimiento(vence)],
    ['cvv', Validar.cvv($('#cvv', form).value, Validar.marcaTarjeta(numero))]
  ], 'Revisa los datos de la tarjeta:');
  if (!ok) return null;
  const [mm, aa] = vence.split('/');
  return {
    registro: { cedula: estado.cliente.cedula, marca: Validar.marcaTarjeta(numero), ultimos4: numero.slice(-4), titular: titular.toUpperCase(), mes_vence: Number(mm), anio_vence: 2000 + Number(aa) }
  };
}

/* ======================= Mis pedidos ======================= */
function seguimiento(estadoPedido) {
  if (estadoPedido === 'Cancelado') return '<p class="alerta" style="margin-top:.75rem">Este pedido fue cancelado; el pago se anuló.</p>';
  const etapa = ESTADOS.indexOf(estadoPedido);
  return `<ol class="seguimiento" aria-label="Estado del pedido: ${nombreEstado(estadoPedido)}">${ESTADOS.map((e, i) => `
    <li class="${i < etapa ? 'hecho' : i === etapa ? 'actual hecho' : ''}" ${i === etapa ? 'aria-current="step"' : ''}>
      <span class="seguimiento__punto">${i <= etapa ? icono('check') : ''}</span>${nombreEstado(e)}
    </li>`).join('')}</ol>`;
}

async function vistaPedidos() {
  if (!protegerCuenta()) return null;
  const r = await Api.pedidos.mios();
  if (r.error) return { titulo: 'Mis pedidos', seccion: 'pedidos', html: errorCargaHtml(r.error) };
  const mios = r.datos || [];
  // Reseñas que ya escribió el cliente, para mostrar "Editar mi reseña" en vez de "Escribir reseña"
  const rr = mios.length ? await Api.resenas.mias() : { datos: [] };
  const mias = new Map(((rr.datos) || []).map((x) => [x.id, x]));
  const botonResena = (p, d, pr) => {
    if (p.estado === 'Cancelado' || !pr || !pr.dbId) return '';
    const mia = mias.get(pr.dbId);
    return `<button class="boton boton--secundario boton--chico" type="button" data-resena="${esc(pr.id)}" data-pedido="${esc(p.numero)}">${icono(mia ? 'editar' : 'estrella')}${mia ? 'Editar mi reseña' : 'Escribir reseña'}<span class="solo-lector"> de ${esc(pr.nombre)}</span></button>${mia ? `<span class="resena-mia" aria-label="Tu calificación: ${mia.estrellas} de 5 estrellas">${estrellas(mia.estrellas)}</span>` : ''}`;
  };
  return {
    titulo: 'Mis pedidos',
    seccion: 'pedidos',
    html: `
    <div class="contenedor pagina">
      <h1 class="titulo-pagina">Mis pedidos</h1>
      <p class="subtitulo">Todas tus compras, de la más reciente a la más antigua, y en qué etapa está cada una.</p>
      <p style="color:var(--verde);font-weight:700;margin-block:.75rem 1.5rem">${mios.length ? `Has realizado ${plural(mios.length, 'pedido', 'pedidos')}` : ''}</p>
      ${!mios.length ? `
        <div class="panel panel--gris vacio">${icono('paquete')}<h2 class="titulo-seccion">Aún no tienes pedidos</h2><p class="texto-suave">Cuando compres, tus pedidos aparecerán aquí.</p><a class="boton boton--principal" href="productos.html">Ver productos</a></div>` : `
        <ul class="pedidos">${mios.map((p) => `
          <li class="pedido">
            <div class="pedido__cabecera">
              <h2 class="pedido__numero">Pedido N.º ${esc(p.numero)}</h2>
              <span class="estado estado--${p.estado.toLowerCase()}">${nombreEstado(p.estado)}</span>
            </div>
            <p class="texto-suave" style="margin-top:.25rem">${fechaHora(p.creado_en)}</p>
            <ul class="pedido__productos">${p.detalle_pedido.map((d) => { const pr = productoPorDbId(d.producto_id); return `<li class="pedido__producto">${pr ? `<a class="pedido__foto" href="producto.html?id=${pr.id}" tabindex="-1" aria-hidden="true">${foto(img(pr), { ancho: 500, alto: 500, sizes: 96 })}</a>` : '<span class="pedido__foto"></span>'}<span class="pedido__info"><span class="pedido__nombre">${pr ? `<a href="producto.html?id=${pr.id}">${esc(pr.nombre)}</a>` : 'Producto'}</span><span class="texto-suave">${d.cantidad} × ${dinero(d.precio_unitario)}${d.talla ? ` · Talla ${esc(d.talla)}` : ''} · <strong>${dinero(d.precio_unitario * d.cantidad)}</strong></span></span><span class="pedido__resena">${botonResena(p, d, pr)}</span></li>`; }).join('')}</ul>
            <dl class="datos-lista datos-lista--compacta">
              <dt>Subtotal</dt><dd>${dinero(p.subtotal)}</dd>
              <dt>IVA</dt><dd>${dinero(p.iva)}</dd>
              <dt>Total</dt><dd>${dinero(p.total)}</dd>
              <dt>Retiro en</dt><dd>${esc(p.tiendas ? p.tiendas.nombre : '')}</dd>
              <dt>Código</dt><dd><strong>${esc(p.codigoRetiro || '')}</strong></dd>
              <dt>Pago</dt><dd>${esc(p.pagoTexto)}${p.pago && p.pago.estado === 'Anulado' ? ' (anulado)' : ''}</dd>
            </dl>
            ${seguimiento(p.estado)}
            <div class="botones-fila" style="margin-top:1rem">
              <a class="boton boton--secundario boton--chico" href="orden.html?pedido=${p.id}">${icono('documento')}Orden de pedido</a>
              <button class="boton boton--secundario boton--chico" type="button" data-recomprar="${esc(p.id)}">${icono('carrito')}Volver a comprar<span class="solo-lector"> lo del pedido ${esc(p.numero)}</span></button>
            </div>
          </li>`).join('')}
        </ul>
        <p class="texto-suave" style="margin-top:1rem">Te enviaremos un correo a ${esc(correoSesion())} cada vez que tu pedido cambie de estado y cuando esté listo para retirar.</p>`}
    </div>`,
    montar(main) {
      // Desde cada producto comprado se abre el formulario de reseña; la compra ya está verificada por el pedido
      main.addEventListener('click', (e) => {
        const rb = e.target.closest('[data-recomprar]');
        if (rb) { const ped = mios.find((x) => String(x.id) === rb.dataset.recomprar); if (ped) volverAComprar(ped); return; }
        const b = e.target.closest('[data-resena]');
        if (!b) return;
        const pr = producto(b.dataset.resena);
        if (!pr) return;
        abrirFormularioResena(pr, main, mias.get(pr.dbId) || null, b.dataset.pedido, () => render());
      });
    }
  };
}

/* Vuelve a poner en el carrito los productos de un pedido anterior, con la misma talla y cantidad.
   Respeta el stock de hoy: si queda menos, agrega lo que hay; si un producto ya no está a la venta o se agotó, lo avisa. */
function volverAComprar(pedido) {
  let unidades = 0;
  const faltan = [];
  const incompletos = [];
  pedido.detalle_pedido.forEach((d) => {
    const pr = productoPorDbId(d.producto_id);
    if (!pr || !producto(pr.id)) { faltan.push(pr ? pr.nombre : 'Un producto'); return; }
    const talla = pr.tallas.length ? d.talla : null;
    const n = agregarAlCarrito(pr.id, talla, d.cantidad);
    unidades += n;
    if (n <= 0) faltan.push(pr.nombre + (talla ? ` (talla ${talla})` : ''));
    else if (n < d.cantidad) incompletos.push(`${pr.nombre}${talla ? ` (talla ${talla})` : ''}: solo ${plural(n, 'unidad', 'unidades')}`);
  });
  const lista = (titulo, xs) => xs.length ? `<p style="margin-top:.75rem"><strong>${titulo}</strong></p><ul class="lista-aviso">${xs.map((x) => `<li>${esc(x)}</li>`).join('')}</ul>` : '';
  abrirDialogo(`
    <h2 class="dialogo__titulo" id="dialogo-titulo"><span class="icono-ok">${icono(unidades ? 'check' : 'info')}</span>${unidades ? `Agregamos ${plural(unidades, 'unidad', 'unidades')} al carrito` : 'No se agregó ningún producto'}</h2>
    <p>${unidades ? `Del pedido N.º ${esc(pedido.numero)}. Tienes ${plural(unidadesCarrito(), 'unidad', 'unidades')} en tu carrito · Subtotal ${dinero(subtotalCarrito())}.` : `Los productos del pedido N.º ${esc(pedido.numero)} no tienen stock ahora o ya están en tu carrito con todo lo disponible.`}</p>
    ${lista('Con menos stock del que pediste:', incompletos)}
    ${lista('Sin stock o ya en tu carrito:', faltan)}
    <div class="dialogo__botones">
      <button class="boton boton--secundario" type="button" id="seguir-pedidos">Seguir en mis pedidos</button>
      <a class="boton boton--principal" href="carrito.html">${icono('carrito')}Ver carrito</a>
    </div>`, { alAbrir: (d) => { $('#seguir-pedidos', d).addEventListener('click', cerrarDialogo); $('a.boton--principal', d).focus(); } });
}
