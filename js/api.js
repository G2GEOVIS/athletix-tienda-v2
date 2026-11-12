/* ATHLETIX · Acceso a datos (Supabase) y envío de correos (EmailJS)
   Toda la comunicación con el servidor pasa por aquí. Cada función devuelve
   { datos } o { error } con un mensaje en español; nunca lanza excepciones
   a la interfaz, así un fallo de red no rompe la página. */
'use strict';

const Api = (() => {
  let sb = null;
  try {
    if (window.supabase && CONFIG.supabase.url && CONFIG.supabase.clave) {
      // La sesión vive solo mientras la tienda está abierta: se guarda en sessionStorage y se comparte entre
      // las pestañas abiertas de la tienda (BroadcastChannel). Al cerrar todas, al volver a abrir el enlace
      // nadie aparece con la sesión iniciada. Se borra la sesión que antes quedaba guardada en localStorage.
      try { Object.keys(localStorage).filter((k) => /^sb-.*-auth-token/.test(k)).forEach((k) => localStorage.removeItem(k)); } catch (e) { /* sin almacenamiento */ }
      let almacen;
      try {
        sessionStorage.setItem('athletix-prueba', '1'); sessionStorage.removeItem('athletix-prueba');
        const canal = 'BroadcastChannel' in window ? new BroadcastChannel('athletix-sesion') : null;
        const preguntas = {};
        if (canal) {
          canal.onmessage = ({ data }) => {
            if (!data || !/^sb-.*-auth-token/.test(data.clave || '')) return;
            if (data.tipo === 'pedir') { const v = sessionStorage.getItem(data.clave); if (v) canal.postMessage({ tipo: 'dar', clave: data.clave, valor: v }); }
            else if (data.tipo === 'dar' || data.tipo === 'guardar') sessionStorage.setItem(data.clave, data.valor);
            else if (data.tipo === 'borrar') sessionStorage.removeItem(data.clave);
          };
        }
        almacen = {
          getItem(clave) {
            const v = sessionStorage.getItem(clave);
            if (v || !canal || !/^sb-.*-auth-token$/.test(clave)) return v;
            // Pestaña nueva: pregunta una sola vez a las otras pestañas abiertas si ya hay una sesión
            if (!preguntas[clave]) {
              canal.postMessage({ tipo: 'pedir', clave });
              preguntas[clave] = new Promise((ok) => setTimeout(ok, 250));
            }
            return preguntas[clave].then(() => sessionStorage.getItem(clave));
          },
          setItem(clave, valor) { sessionStorage.setItem(clave, valor); if (canal) canal.postMessage({ tipo: 'guardar', clave, valor }); },
          removeItem(clave) { sessionStorage.removeItem(clave); if (canal) canal.postMessage({ tipo: 'borrar', clave }); }
        };
      } catch (e) { almacen = undefined; }
      sb = window.supabase.createClient(CONFIG.supabase.url, CONFIG.supabase.clave, {
        auth: { persistSession: true, storage: almacen, autoRefreshToken: true, detectSessionInUrl: true, flowType: 'implicit' }
      });
    }
  } catch (e) { sb = null; }

  const disponible = () => !!sb;

  /* Traduce los errores técnicos a mensajes claros */
  function traducir(error) {
    const m = String((error && (error.message || error.error_description || error)) || '').toLowerCase();
    if (!navigator.onLine || m.includes('failed to fetch') || m.includes('network') || m.includes('tiempo de espera')) {
      return 'No hay conexión con la tienda. Revisa tu internet e inténtalo de nuevo.';
    }
    if (m.includes('invalid login credentials')) return 'Correo o contraseña incorrectos.';
    if (m.includes('email not confirmed')) return 'Todavía no confirmas tu correo. Revisa tu bandeja de entrada (y la carpeta de spam).';
    if (m.includes('user already registered') || m.includes('already been registered')) return 'Ya existe una cuenta con este correo. Inicia sesión.';
    if (m.includes('pk_cliente') || (m.includes('duplicate') && m.includes('cedula'))) return 'Ya existe una cuenta con esta cédula.';
    if (m.includes('ak_cliente_correo') || m.includes('ak_cliente_usuario')) return 'Ya existe una cuenta con este correo.';
    if (m.includes('ak_cliente_celular')) return 'Este celular ya está registrado en otra cuenta.';
    if (m.includes('cedula_valida') || m.includes('ckc_cli_cedula')) return 'La cédula no es válida.';
    if (m.includes('rate limit') || m.includes('too many') || m.includes('security purposes')) return 'Hiciste demasiados intentos seguidos. Espera un minuto y vuelve a intentarlo.';
    if (m.includes('password should be') || m.includes('weak')) return 'La contraseña es muy débil. Usa al menos 8 caracteres con letras y números.';
    if (m.includes('same password') || m.includes('should be different')) return 'La nueva contraseña debe ser diferente a la actual.';
    if (m.includes('jwt') || m.includes('not authenticated') || m.includes('inicia sesión') || m.includes('iniciar sesión')) return 'Tu sesión terminó. Vuelve a iniciar sesión.';
    if (m.includes('ak_metodo_pago_cliente')) return 'Ya tienes guardada esta tarjeta.';
    if (m.includes('ckc_prd_genero_categoria')) return 'El calzado debe ser de Hombre o de Mujer; tecnología y entrenamiento son Unisex (para todos).';
    if (m.includes('fk_producto_detallepedido') || (m.includes('foreign key') && m.includes('detalle_pedido'))) return 'Este producto ya tiene ventas registradas: no se puede borrar. Ocúltalo para que no se muestre en la tienda.';
    if (m.includes('pk_producto') && m.includes('duplicate')) return 'Ya existe un producto con ese código.';
    if (m.includes('row-level security') && m.includes('storage')) return 'Solo el administrador puede subir fotos.';
    if (m.includes('payload too large') || m.includes('exceeded the maximum')) return 'La foto pesa demasiado (máximo 3 MB).';
    if (m.includes('pk_resena')) return 'Ya dejaste una reseña de este producto. Puedes editarla.';
    if (m.includes('ak_producto_nombre')) return 'Ya existe un producto con ese nombre. Usa otro nombre.';
    if (m.includes('ak_cliente_correo_minusculas')) return 'Ya existe una cuenta con este correo.';
    if (m.includes('ckc_prd_codigo')) return 'El código debe tener de 2 a 10 letras minúsculas o números, sin espacios.';
    if (m.includes('ckc_prd_nombre')) return 'Escribe el nombre del producto (mínimo 3 caracteres).';
    if (m.includes('ckc_prd_descripcion')) return 'La descripción debe tener entre 20 y 600 caracteres.';
    if (m.includes('ckc_prd_precio_max')) return 'El precio debe ser menor a $100.000.';
    if (m.includes('ckc_pim_url')) return 'Cada foto necesita una dirección.';
    if (m.includes('ckc_res_comentario_max')) return 'Tu reseña puede tener hasta 1000 caracteres.';
    if (m.includes('ckc_res_estrellas')) return 'Elige de 1 a 5 estrellas.';
    if (m.includes('ckc_pta_cantidad')) return 'El stock debe ser un número entre 0 y 100000.';
    if (m.includes('ckc_cli_nombres') || m.includes('ckc_cli_apellidos')) return 'Escribe nombres y apellidos solo con letras.';
    if (m.includes('ckc_cli_celular')) return 'El número de celular no es válido.';
    // Mensajes propios de la base de datos (ya vienen en español)
    const propio = String((error && error.message) || '');
    // P0001 = mensaje escrito por las funciones de la tienda (raise exception): siempre es un texto para el cliente.
    // Antes dependía de las palabras del mensaje y, por ejemplo, "Hiciste demasiados pedidos seguidos" salía como error genérico
    if (error && error.code === 'P0001' && propio) return propio;
    if (/^[A-ZÁÉÍÓÚ¿¡]/.test(propio) && /[áéíóúñ]|\b(el|la|de|para|debes|no)\b/i.test(propio)) return propio;
    return 'No pudimos completar la acción. Inténtalo de nuevo en unos segundos.';
  }

  /* Ejecuta una consulta con tiempo límite y errores traducidos */
  async function ejecutar(promesa) {
    if (!sb) return { error: 'La tienda no pudo conectarse con el servidor. Recarga la página.' };
    let temporizador;
    const limite = new Promise((_, rechazar) => { temporizador = setTimeout(() => rechazar(new Error('tiempo de espera')), CONFIG.tiempoEsperaMs); });
    try {
      const r = await Promise.race([promesa, limite]);
      if (r && r.error) return { error: traducir(r.error), tecnico: r.error };
      return { datos: r ? r.data : null };
    } catch (e) {
      return { error: traducir(e), tecnico: e };
    } finally {
      clearTimeout(temporizador);
    }
  }

  // Los enlaces de los correos (confirmar cuenta, recuperar clave) siempre regresan a la página de inicio
  const urlRegreso = () => location.origin + location.pathname.replace(/[^/]*$/, '') + 'index.html';

  /* ---------- Sesión ---------- */
  const auth = {
    async sesion() {
      if (!sb) return null;
      try { const { data } = await sb.auth.getSession(); return data.session; } catch (e) { return null; }
    },
    alCambiar(fn) { if (sb) sb.auth.onAuthStateChange((evento, sesion) => fn(evento, sesion)); },
    registrar(correo, clave, perfil) {
      return ejecutar(sb.auth.signUp({ email: correo, password: clave, options: { data: perfil, emailRedirectTo: urlRegreso() } }));
    },
    ingresar(correo, clave) { return ejecutar(sb.auth.signInWithPassword({ email: correo, password: clave })); },
    /* Ingreso con Google (OAuth): Google confirma el correo y Supabase crea la cuenta */
    ingresarConGoogle() {
      return ejecutar(sb.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: urlRegreso() } }));
    },
    /* El botón de Google solo aparece si el proveedor está activado en Supabase */
    async googleActivo() {
      try {
        const r = await fetch(CONFIG.supabase.url + '/auth/v1/settings', { headers: { apikey: CONFIG.supabase.clave } });
        const d = await r.json();
        return !!(d.external && d.external.google);
      } catch (e) { return false; }
    },
    reenviarConfirmacion(correo) {
      return ejecutar(sb.auth.resend({ type: 'signup', email: correo, options: { emailRedirectTo: urlRegreso() } }));
    },
    recuperarClave(correo) { return ejecutar(sb.auth.resetPasswordForEmail(correo, { redirectTo: urlRegreso() })); },
    cambiarClave(clave) { return ejecutar(sb.auth.updateUser({ password: clave })); },
    salir() { return ejecutar(sb.auth.signOut()); }
  };

  /* ---------- Traducción entre la base (columnas CLI_, PRD_, PED_...) y la interfaz ---------- */
  const mapear = (r, fn) => (r.error || !r.datos ? r : { datos: Array.isArray(r.datos) ? r.datos.map(fn) : fn(r.datos) });
  const codigoPedido = (numero, fecha) => `AX-${new Date(fecha).getFullYear()}-${String(numero).padStart(5, '0')}`;
  const aCliente = (c) => ({ id: c.cli_usuario, cedula: c.cli_cedula, pais: c.cli_pais || 'Ecuador', tipoDocumento: c.cli_tipo_documento || 'Cédula', nombres: c.cli_nombres, apellidos: c.cli_apellidos, telefono: c.cli_celular, direccion: c.cli_direccion || '', correo: c.cli_correo, creado_en: c.cli_fecha_registro });
  const aTarjeta = (t) => ({ id: t.mtp_codigo, marca: t.mtp_marca, ultimos4: t.mtp_ultimos4, titular: t.mtp_titular, mes_vence: t.mtp_mes_vence, anio_vence: t.mtp_anio_vence });
  const CAMPOS_PEDIDO = 'ped_numero, ped_factura, ped_estado, ped_subtotal, ped_iva, ped_total, ped_fecha, ped_codigo_retiro, ped_hora_estimada, '
    + 'tienda(tie_nombre, tie_direccion, tie_horario, tie_ciudad), pago(pag_forma, pag_marca, pag_ultimos4, pag_monto, pag_fecha, pag_estado), '
    + 'detalle_pedido(prd_codigo, dpe_talla, dpe_cantidad, dpe_precio)';
  const textoDePago = (g) => (!g ? 'Sin registro de pago' : g.pag_forma === 'En tienda' ? `Efectivo en la tienda al retirar${g.pag_estado === 'Pendiente' ? ' (pendiente)' : ''}` : `Tarjeta ${g.pag_marca} •••• ${g.pag_ultimos4}`);
  const aPedido = (p) => {
    const g = Array.isArray(p.pago) ? p.pago[0] : p.pago;
    const c = p.cliente;
    return {
      id: p.ped_numero, factura: p.ped_factura || p.ped_numero, numero: codigoPedido(p.ped_numero, p.ped_fecha), estado: p.ped_estado,
      subtotal: p.ped_subtotal, iva: p.ped_iva, total: p.ped_total, creado_en: p.ped_fecha,
      codigoRetiro: p.ped_codigo_retiro, horaEstimada: p.ped_hora_estimada,
      tiendas: p.tienda ? { nombre: p.tienda.tie_nombre, direccion: p.tienda.tie_direccion, horario: p.tienda.tie_horario, ciudad: p.tienda.tie_ciudad } : null,
      pago: g ? { estado: g.pag_estado, fecha: g.pag_fecha, monto: g.pag_monto } : null,
      pagoTexto: textoDePago(g),
      cliente: c ? { id: c.cli_usuario, cedula: c.cli_cedula, nombres: c.cli_nombres, apellidos: c.cli_apellidos, telefono: c.cli_celular, direccion: c.cli_direccion || '', correo: c.cli_correo } : null,
      detalle_pedido: (p.detalle_pedido || []).map((d) => ({ producto_id: d.prd_codigo, talla: d.dpe_talla === 'U' ? null : d.dpe_talla, cantidad: d.dpe_cantidad, precio_unitario: d.dpe_precio }))
    };
  };
  const SLUG_CATEGORIA = { 1: 'calzado', 2: 'tecnologia', 3: 'entrenamiento' };
  const lineas = (t) => String(t || '').split('\n').map((x) => x.trim()).filter(Boolean);
  const aProducto = (p) => ({
    id: p.prd_codigo, codigo: p.prd_codigo, categoria: SLUG_CATEGORIA[p.cat_codigo] || 'entrenamiento', cat_codigo: p.cat_codigo,
    nombre: p.prd_nombre, descripcion: p.prd_descripcion, publico: p.prd_genero,
    precio: p.prd_precio, activo: p.prd_visible, usa_talla: p.prd_tiene_talla, etiqueta: p.prd_etiqueta || '',
    caracteristicas: lineas(p.prd_caracteristicas),
    ficha: lineas(p.prd_ficha).map((l) => { const i = l.indexOf(':'); return i > 0 ? [l.slice(0, i).trim(), l.slice(i + 1).trim()] : [l, '']; }),
    producto_tallas: (p.producto_talla || []).map((t) => ({ talla: t.pta_talla, stock: t.pta_cantidad })),
    imagenes: (p.producto_imagen || []).slice().sort((x, y) => x.pim_orden - y.pim_orden).map((i) => ({ orden: i.pim_orden, url: i.pim_url, descripcion: i.pim_descripcion }))
  });
  const aTienda = (t) => ({ id: t.tie_codigo, nombre: t.tie_nombre, direccion: t.tie_direccion, ciudad: t.tie_ciudad, horario: t.tie_horario });
  const aResena = (r) => ({ id: r.prd_codigo, mia: !!r.es_mia, autor: r.autor, estrellas: r.res_estrellas, comentario: r.res_comentario, creado_en: r.res_fecha });

  /* ---------- Catálogo ---------- */
  const catalogo = {
    async productos() {
      const r = await ejecutar(sb.from('producto').select('prd_codigo, cat_codigo, prd_nombre, prd_descripcion, prd_genero, prd_precio, prd_visible, prd_tiene_talla, prd_etiqueta, prd_caracteristicas, prd_ficha, producto_talla(pta_talla, pta_cantidad), producto_imagen(pim_orden, pim_url, pim_descripcion)'));
      return mapear(r, aProducto);
    },
    async calificaciones() {
      const r = await ejecutar(sb.from('vista_calificaciones').select('prd_codigo, promedio, opiniones'));
      return mapear(r, (c) => ({ producto_id: c.prd_codigo, promedio: c.promedio, opiniones: c.opiniones }));
    },
    async tiendas() { return mapear(await ejecutar(sb.from('tienda').select('*').order('tie_codigo')), aTienda); }
  };

  /* ---------- Cliente ---------- */
  const cliente = {
    async cedulaRegistrada(cedula) { const r = await ejecutar(sb.rpc('cedula_registrada', { p_cedula: cedula })); return r.error ? r : { datos: !!r.datos }; },
    // Si la función todavía no existe en la base, se deja pasar (la regla única de la tabla igual lo impide)
    async celularRegistrado(celular) { const r = await ejecutar(sb.rpc('celular_registrado', { p_celular: celular })); return r.error ? { datos: false } : { datos: !!r.datos }; },
    async correoRegistrado(correo) { const r = await ejecutar(sb.rpc('correo_registrado', { p_correo: correo })); return r.error ? r : { datos: !!r.datos }; },
    async perfil(usuario) { return mapear(await ejecutar(sb.from('cliente').select('*').eq('cli_usuario', usuario).maybeSingle()), aCliente); },
    async crear(d) {
      return mapear(await ejecutar(sb.from('cliente').insert({ cli_cedula: d.cedula, ...(d.pais && d.pais !== 'Ecuador' ? { cli_pais: d.pais, cli_tipo_documento: 'Pasaporte' } : {}), cli_usuario: d.id, cli_nombres: d.nombres, cli_apellidos: d.apellidos, cli_celular: d.telefono, cli_direccion: d.direccion || null, cli_correo: d.correo }).select().single()), aCliente);
    },
    async actualizar(usuario, d) {
      return mapear(await ejecutar(sb.from('cliente').update({ cli_nombres: d.nombres, cli_apellidos: d.apellidos, cli_celular: d.telefono, cli_direccion: d.direccion || null }).eq('cli_usuario', usuario).select().single()), aCliente);
    },
    async esAdmin() { const r = await ejecutar(sb.rpc('es_admin')); return !r.error && r.datos === true; },

    async tarjetas() { return mapear(await ejecutar(sb.from('metodo_pago').select('*').order('mtp_codigo', { ascending: false })), aTarjeta); },
    async guardarTarjeta(d) {
      const fila = { cli_cedula: d.cedula, mtp_marca: d.marca, mtp_ultimos4: d.ultimos4, mtp_titular: d.titular, mtp_mes_vence: d.mes_vence, mtp_anio_vence: d.anio_vence };
      const existente = await ejecutar(sb.from('metodo_pago').select('mtp_codigo').match(fila).maybeSingle());
      if (existente.error) return existente;
      if (existente.datos) return { datos: { id: existente.datos.mtp_codigo } };
      return mapear(await ejecutar(sb.from('metodo_pago').insert(fila).select('mtp_codigo').single()), (t) => ({ id: t.mtp_codigo }));
    },
    borrarTarjeta(id) { return ejecutar(sb.from('metodo_pago').delete().eq('mtp_codigo', id)); }
  };

  /* ---------- Pedidos ---------- */
  const pedidos = {
    // "clave" identifica el intento de pago: si se reenvía (doble clic, recarga, red lenta) la base devuelve el mismo pedido
    async crear({ items, clave, tienda, tarjeta }) {
      const r = await ejecutar(sb.rpc('crear_pedido', { p_items: items, p_clave: clave, p_tienda: tienda, p_tarjeta: tarjeta }));
      if (r.error) return r;
      // La función devuelve una tabla (lista) con una sola fila: se toma esa fila
      const x = Array.isArray(r.datos) ? r.datos[0] : r.datos;
      if (!x || !x.ped_numero) return { error: 'No se pudo confirmar el pedido. Revisa "Mis pedidos" antes de intentar de nuevo.' };
      return { datos: { id: x.ped_numero, numero: x.ped_codigo, total: x.ped_total, codigoRetiro: x.ped_codigo_retiro, horaEstimada: x.ped_hora_estimada, factura: x.ped_factura || x.ped_numero } };
    },
    async nuevos() { const r = await ejecutar(sb.rpc('pedidos_nuevos')); return r.error ? 0 : Number(r.datos) || 0; },
    async mios() {
      const r = await ejecutar(sb.from('pedido').select(CAMPOS_PEDIDO).order('ped_fecha', { ascending: false }));
      return mapear(r, aPedido);
    },
    /* Un pedido con todos sus datos (confirmación y orden de pedido). El cliente solo ve los suyos; el administrador, todos */
    async uno(numero) {
      const r = await ejecutar(sb.from('pedido').select(CAMPOS_PEDIDO + ', cliente(cli_usuario, cli_cedula, cli_nombres, cli_apellidos, cli_celular, cli_direccion, cli_correo)').eq('ped_numero', numero).maybeSingle());
      return mapear(r, aPedido);
    },
    /* Verifica en la base si el cliente compró este producto (cualquier pedido que no esté cancelado) */
    async compro(codigo) {
      const r = await ejecutar(sb.from('detalle_pedido').select('ped_numero, pedido!inner(ped_estado, ped_fecha)')
        .eq('prd_codigo', codigo).neq('pedido.ped_estado', 'Cancelado').order('ped_numero', { ascending: false }).limit(1));
      if (r.error) return r;
      const f = r.datos[0];
      return { datos: f ? codigoPedido(f.ped_numero, f.pedido.ped_fecha) : null };
    },
    async todos() {
      return mapear(await ejecutar(sb.rpc('pedidos_admin')), (p) => ({
        id: p.ped_numero, numero: p.ped_codigo, estado: p.ped_estado, total: p.ped_total, creado_en: p.ped_fecha,
        cliente: p.cliente, correo: p.cli_correo, telefono: p.cli_celular, cedula: p.cli_cedula, tienda: p.tie_nombre, horario: p.tie_horario, productos: p.productos,
        codigoRetiro: p.ped_codigo_retiro, horaEstimada: p.ped_hora_estimada, pagoTexto: p.pago || ''
      }));
    },
    /* Productos de varios pedidos a la vez (para ver sus fotos en el panel del administrador) */
    async detalles(numeros) {
      if (!numeros.length) return { datos: {} };
      const r = await ejecutar(sb.from('detalle_pedido').select('ped_numero, prd_codigo, dpe_talla, dpe_cantidad, dpe_precio').in('ped_numero', numeros));
      if (r.error) return r;
      const porPedido = {};
      (r.datos || []).forEach((d) => { (porPedido[d.ped_numero] = porPedido[d.ped_numero] || []).push({ producto_id: d.prd_codigo, talla: d.dpe_talla === 'U' ? null : d.dpe_talla, cantidad: d.dpe_cantidad, precio_unitario: Number(d.dpe_precio) }); });
      return { datos: porPedido };
    },
    cambiarEstado(numero, estado) { return ejecutar(sb.rpc('cambiar_estado_pedido', { p_numero: numero, p_estado: estado })); }
  };

  /* ---------- Administrador: productos y pagos ---------- */
  const CATEGORIA_CODIGO = { calzado: 1, tecnologia: 2, entrenamiento: 3 };
  const admin = {
    /* Stock actual de cada talla y los últimos movimientos (tabla MOVIMIENTO_STOCK, la llena un trigger de la base) */
    async stock() {
      const [rt, rm] = await Promise.all([
        ejecutar(sb.from('producto_talla').select('prd_codigo, pta_talla, pta_cantidad')),
        ejecutar(sb.from('movimiento_stock').select('mst_codigo, prd_codigo, pta_talla, mst_motivo, mst_cantidad, mst_stock_anterior, mst_stock_nuevo, ped_numero, mst_fecha, pedido(ped_fecha)').order('mst_codigo', { ascending: false }).limit(400))
      ]);
      if (rt.error) return rt;
      return {
        datos: {
          tallas: (rt.datos || []).map((t) => ({ producto: t.prd_codigo, talla: t.pta_talla === 'U' ? null : t.pta_talla, cantidad: t.pta_cantidad })),
          movimientos: rm.error ? null : (rm.datos || []).map((m) => ({
            id: m.mst_codigo, producto: m.prd_codigo, talla: m.pta_talla === 'U' ? null : m.pta_talla, motivo: m.mst_motivo, cantidad: m.mst_cantidad,
            antes: m.mst_stock_anterior, despues: m.mst_stock_nuevo, fecha: m.mst_fecha,
            pedido: m.ped_numero ? { id: m.ped_numero, numero: codigoPedido(m.ped_numero, m.pedido ? m.pedido.ped_fecha : m.mst_fecha) } : null
          }))
        }
      };
    },
    activar(codigo, activo) { return ejecutar(sb.from('producto').update({ prd_visible: activo }).eq('prd_codigo', codigo)); },
    async borrarProducto(codigo) {
      const r = await ejecutar(sb.from('producto').delete().eq('prd_codigo', codigo).select('prd_codigo'));
      if (r.error) return r;
      return r.datos && r.datos.length ? r : { error: 'No se pudo borrar el producto.' };
    },
    /* Crea o actualiza el producto con sus tallas y fotos */
    async guardarProducto(d, nuevo) {
      const fila = {
        prd_codigo: d.codigo, cat_codigo: CATEGORIA_CODIGO[d.categoria], prd_nombre: d.nombre, prd_descripcion: d.descripcion,
        prd_genero: d.publico, prd_precio: d.precio, prd_tiene_talla: d.usaTalla, prd_visible: d.activo,
        prd_etiqueta: d.etiqueta || null, prd_caracteristicas: d.caracteristicas || null, prd_ficha: d.ficha || null
      };
      const rp = nuevo ? await ejecutar(sb.from('producto').insert(fila)) : await ejecutar(sb.from('producto').update(fila).eq('prd_codigo', d.codigo));
      if (rp.error) return rp;
      // Tallas: se guardan las nuevas y se quitan las que ya no están
      const rt = await ejecutar(sb.from('producto_talla').upsert(d.tallas.map((t) => ({ prd_codigo: d.codigo, pta_talla: t.talla, pta_cantidad: t.stock }))));
      if (rt.error) return rt;
      const nombres = d.tallas.map((t) => t.talla);
      const rq = await ejecutar(sb.from('producto_talla').delete().eq('prd_codigo', d.codigo).not('pta_talla', 'in', `(${nombres.map((n) => `"${n.replace(/"/g, '')}"`).join(',')})`));
      if (rq.error) return rq;
      // Fotos: se reemplazan en el orden del formulario
      const rb = await ejecutar(sb.from('producto_imagen').delete().eq('prd_codigo', d.codigo));
      if (rb.error) return rb;
      if (d.fotos.length) {
        const ri = await ejecutar(sb.from('producto_imagen').insert(d.fotos.slice(0, 6).map((f, i) => ({ prd_codigo: d.codigo, pim_orden: i + 1, pim_url: f.url, pim_descripcion: f.descripcion.slice(0, 80) }))));
        if (ri.error) return ri;
      }
      return { datos: true };
    },
    async subirFoto(archivo, codigo) {
      if (!sb) return { error: 'La tienda no pudo conectarse con el servidor.' };
      const ext = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' }[archivo.type] || 'jpg';
      const ruta = `${codigo}/${Date.now()}.${ext}`;
      const r = await ejecutar(sb.storage.from('productos').upload(ruta, archivo, { contentType: archivo.type, upsert: false }));
      if (r.error) return r;
      return { datos: sb.storage.from('productos').getPublicUrl(ruta).data.publicUrl };
    },
    async pagos() {
      const r = await ejecutar(sb.from('pago')
        .select('pag_codigo, ped_numero, pag_forma, pag_marca, pag_ultimos4, pag_monto, pag_fecha, pag_estado, pedido(ped_fecha, cliente(cli_nombres, cli_apellidos))')
        .order('pag_fecha', { ascending: false }).limit(500));
      return mapear(r, (g) => ({
        codigo: g.pag_codigo, pedido: g.ped_numero, numeroPedido: codigoPedido(g.ped_numero, g.pedido ? g.pedido.ped_fecha : g.pag_fecha),
        cliente: g.pedido && g.pedido.cliente ? `${g.pedido.cliente.cli_nombres} ${g.pedido.cliente.cli_apellidos}` : '',
        detalle: g.pag_forma === 'En tienda' ? 'Efectivo en la tienda al retirar' : `${g.pag_marca} •••• ${g.pag_ultimos4}`,
        monto: g.pag_monto, fecha: g.pag_fecha, estado: g.pag_estado
      }));
    }
  };

  /* ---------- Reseñas ---------- */
  const resenas = {
    /* Reseñas que escribió el cliente con sesión abierta (para mostrarlas en Mis pedidos) */
    async mias() {
      return mapear(await ejecutar(sb.from('vista_resenas').select('*').eq('es_mia', true)), aResena);
    },
    async deProducto(codigo) {
      return mapear(await ejecutar(sb.from('vista_resenas').select('*').eq('prd_codigo', codigo).order('res_fecha', { ascending: false }).limit(50)), aResena);
    },
    /* Una reseña por cliente y producto: si ya existe se edita, si no se crea */
    async guardar(existe, d) {
      const r = existe
        ? await ejecutar(sb.from('resena').update({ res_estrellas: d.estrellas, res_comentario: d.comentario }).eq('cli_cedula', d.cedula).eq('prd_codigo', d.producto))
        : await ejecutar(sb.from('resena').insert({ cli_cedula: d.cedula, prd_codigo: d.producto, res_estrellas: d.estrellas, res_comentario: d.comentario }));
      return r.error ? r : { datos: true };
    },
    borrar(cedula, producto) { return ejecutar(sb.from('resena').delete().eq('cli_cedula', cedula).eq('prd_codigo', producto)); }
  };

  /* ---------- Favoritos y carrito de la cuenta (tablas FAVORITO y CARRITO) ----------
     Se guardan en la base para que el cliente vea lo mismo en la computadora y en el celular. */
  const cuenta = {
    async favoritos() {
      const r = await ejecutar(sb.from('favorito').select('prd_codigo').order('fav_fecha'));
      return r.error ? r : { datos: (r.datos || []).map((x) => x.prd_codigo) };
    },
    async carrito() {
      const r = await ejecutar(sb.from('carrito').select('prd_codigo, car_talla, car_cantidad').order('car_fecha'));
      return r.error ? r : { datos: (r.datos || []).map((x) => ({ id: x.prd_codigo, talla: x.car_talla === 'U' ? null : x.car_talla, cantidad: x.car_cantidad })) };
    },
    /* Deja en la base exactamente la lista de la pantalla: agrega o actualiza lo que está y borra lo que ya no */
    async guardarFavoritos(cedula, ids) {
      if (ids.length) {
        const r = await ejecutar(sb.from('favorito').upsert(ids.map((id) => ({ cli_cedula: cedula, prd_codigo: id })), { onConflict: 'cli_cedula,prd_codigo', ignoreDuplicates: true }));
        if (r.error) return r;
      }
      let q = sb.from('favorito').delete().eq('cli_cedula', cedula);
      if (ids.length) q = q.not('prd_codigo', 'in', `(${ids.map((x) => `"${x}"`).join(',')})`);
      return ejecutar(q);
    },
    async guardarCarrito(cedula, lineas) {
      const filas = lineas.map((l) => ({ cli_cedula: cedula, prd_codigo: l.id, car_talla: l.talla || 'U', car_cantidad: l.cantidad }));
      if (filas.length) {
        const r = await ejecutar(sb.from('carrito').upsert(filas, { onConflict: 'cli_cedula,prd_codigo,car_talla' }));
        if (r.error) return r;
      }
      const r2 = await ejecutar(sb.from('carrito').select('prd_codigo, car_talla').eq('cli_cedula', cedula));
      if (r2.error) return r2;
      const sobran = (r2.datos || []).filter((x) => !filas.some((f) => f.prd_codigo === x.prd_codigo && f.car_talla === x.car_talla));
      for (const x of sobran) {
        const r3 = await ejecutar(sb.from('carrito').delete().eq('cli_cedula', cedula).eq('prd_codigo', x.prd_codigo).eq('car_talla', x.car_talla));
        if (r3.error) return r3;
      }
      return { datos: true };
    }
  };

  /* ---------- Correos (EmailJS) ---------- */
  // EmailJS solo es el respaldo si falla el correo por Gmail: su archivo se descarga recién cuando hace falta enviar
  let cargandoEmailjs = null;
  const cargarEmailjs = () => {
    if (window.emailjs) return Promise.resolve(window.emailjs);
    if (!cargandoEmailjs) {
      cargandoEmailjs = new Promise((ok, mal) => {
        const s = document.createElement('script');
        s.src = 'js/vendor/emailjs.min.js';
        s.onload = () => ok(window.emailjs);
        s.onerror = () => { cargandoEmailjs = null; mal(new Error('No se pudo cargar EmailJS.')); };
        document.head.appendChild(s);
      });
    }
    return cargandoEmailjs;
  };
  const enviar = async (plantilla, datos) => {
    if (!(CONFIG.emailjs.servicio && plantilla && CONFIG.emailjs.clavePublica)) return { error: 'El envío de correos no está configurado.' };
    try {
      await cargarEmailjs();
      await window.emailjs.send(CONFIG.emailjs.servicio, plantilla, datos, { publicKey: CONFIG.emailjs.clavePublica });
      return { datos: true };
    } catch (e) {
      return { error: 'No se pudo enviar el correo' + (e && e.text ? ` (${e.text})` : '') + '.' };
    }
  };
  /* ---------- Partes comunes de los correos al cliente ---------- */
  const BASE = () => location.origin + location.pathname.replace(/[^/]*$/, '');
  const enlaceOrden = (id) => `${BASE()}orden.html?pedido=${id}`;
  const h = (t) => String(t ?? '').replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const plata = (n) => '$' + Number(n || 0).toFixed(2);
  const absoluta = (src) => { try { return new URL(src, BASE()).href; } catch (e) { return ''; } };
  const horaCorta = (iso) => (iso ? new Date(iso).toLocaleTimeString('es-EC', { hour: '2-digit', minute: '2-digit' }) : '');
  const CORREO_TIENDA = 'geovannymorocho621@gmail.com';
  const VERDE = '#0F766E', NARANJA = '#F97316', GRIS = '#DDE3EA', SUAVE = '#45556B';

  // Barra de avance del pedido (como en las tiendas en línea): 1 recibido, 2 preparando, 3 listo, 4 retirado, 5 todo completo
  const progreso = (paso) => {
    const pasos = ['Recibido', 'Preparando', 'Listo para retirar', 'Retirado'];
    return `<table role="presentation" cellpadding="0" cellspacing="0" style="width:100%;margin:4px 0 20px;table-layout:fixed"><tr>${pasos.map((t, i) => {
      const n = i + 1; const color = n < paso ? VERDE : n === paso ? NARANJA : GRIS;
      return `<td style="padding:0 3px;text-align:center;vertical-align:top"><div style="height:6px;border-radius:3px;background:${color}"></div><div style="margin-top:6px;font-size:11px;line-height:1.3;color:${n <= paso ? '#1E293B' : SUAVE};font-weight:${n === paso ? 'bold' : 'normal'}">${n < paso ? '✓ ' : ''}${t}</div></td>`;
    }).join('')}</tr></table>`;
  };

  // Detalle con foto de cada producto y totales
  const tablaDetalle = (items, t) => {
    const celda = `padding:10px 6px;border-bottom:1px solid ${GRIS};vertical-align:middle;`;
    const filas = items.map((it) => `<tr>
      <td style="${celda}width:60px">${it.foto ? `<img src="${it.foto}" alt="" width="56" height="56" style="display:block;width:56px;height:56px;object-fit:cover;border-radius:6px;background:#F3F5F7">` : ''}</td>
      <td style="${celda}font-size:14px"><b>${h(it.nombre)}</b><br><span style="color:${SUAVE};font-size:13px">${it.talla ? `Talla ${h(it.talla)} · ` : ''}${it.cantidad} × ${plata(it.precio)}</span></td>
      <td style="${celda}text-align:right;font-size:14px;white-space:nowrap">${plata(it.precio * it.cantidad)}</td></tr>`).join('');
    return `<table role="presentation" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;color:#1E293B">${filas}
      <tr><td></td><td style="padding:8px 6px 2px;text-align:right;font-size:14px">Subtotal</td><td style="padding:8px 6px 2px;text-align:right;font-size:14px">${plata(t.subtotal)}</td></tr>
      <tr><td></td><td style="padding:2px 6px;text-align:right;font-size:14px">IVA 15 %</td><td style="padding:2px 6px;text-align:right;font-size:14px">${plata(t.iva)}</td></tr>
      <tr><td></td><td style="padding:2px 6px;text-align:right;font-size:14px">Retiro en tienda</td><td style="padding:2px 6px;text-align:right;font-size:14px;color:${VERDE}">Gratis</td></tr>
      <tr><td></td><td style="padding:8px 6px;text-align:right;font-size:17px;font-weight:bold">${t.pendiente ? 'Total a pagar en la tienda' : 'Total pagado'}</td><td style="padding:8px 6px;text-align:right;font-size:17px;font-weight:bold">${plata(t.total)}</td></tr></table>`;
  };

  // Datos del retiro: tienda con dirección, horario, número de pedido y código
  const cajaRetiro = ({ numero, codigo, tienda, nota = '' }) => {
    return `<div style="margin:20px 0;padding:16px;background:#E6F4F2;border-left:4px solid ${VERDE};border-radius:6px;line-height:1.6;font-size:14px">
      <div style="font-size:15px;font-weight:bold;margin-bottom:6px">📍 Retiro en local físico</div>
      <b>${h(tienda.nombre)}</b>${tienda.direccion ? `<br>${h(tienda.direccion)}${tienda.ciudad ? `, ${h(tienda.ciudad)}` : ''}` : ''}
      ${tienda.horario ? `<br><b>Horario:</b> ${h(tienda.horario)}` : ''}
      <br><b>Número de pedido:</b> ${h(numero)}
      ${codigo ? `<br><b>Código de retiro:</b> <span style="font-size:20px;font-weight:bold;letter-spacing:3px;color:#0B1F3A">${h(codigo)}</span>` : ''}
      ${nota ? `<br>${nota}` : ''}
    </div>`;
  };
  const queLlevar = () => `<div style="margin:0 0 18px;font-size:14px;line-height:1.7"><b>Para retirar trae:</b><br>
    ✔ Tu <b>cédula o pasaporte</b> (el pedido está a tu nombre)<br>✔ Tu <b>número de pedido</b> o el <b>código de retiro</b> (puedes mostrar este correo)<br>✔ Revisa tus productos en el mostrador antes de irte</div>`;
  const ayuda = () => `<p style="margin:18px 0 0;font-size:13px;color:${SUAVE};line-height:1.5">¿Tienes dudas? Responde a este correo, escríbenos a <a href="mailto:${CORREO_TIENDA}" style="color:${VERDE}">${CORREO_TIENDA}</a> o visita nuestra <a href="${BASE()}ayuda.html" style="color:${VERDE}">sección de Ayuda</a>.</p>`;
  const botonHtml = ([texto, url], principal = true) => `<table role="presentation" cellpadding="0" cellspacing="0" style="margin:8px 8px 8px 0;display:inline-table"><tr><td style="background:${principal ? VERDE : '#ffffff'};border:2px solid ${VERDE};border-radius:6px"><a href="${url}" style="display:inline-block;color:${principal ? '#ffffff' : VERDE};text-decoration:none;padding:10px 20px;font-weight:bold;font-size:15px">${h(texto)}</a></td></tr></table>`;

  const plantillaCorreo = ({ nombre, titulo, parrafo, paso = 0, cuerpo = '', boton, boton2, pie = '', conAyuda = true }) => `<div style="background:#F3F5F7;padding:24px 12px;font-family:Arial,Helvetica,sans-serif;color:#1E293B">
<div style="max-width:620px;margin:0 auto;background:#ffffff;border-radius:10px;overflow:hidden;border:1px solid ${GRIS}">
  <div style="background:#0B1F3A;padding:20px 24px;color:#ffffff"><div style="font-size:24px;font-weight:bold;font-style:italic">ATHLETIX</div><div style="font-size:13px;opacity:.85">Tienda deportiva en línea</div></div>
  <div style="padding:24px">
    ${titulo ? `<h1 style="margin:0 0 14px;font-size:22px;line-height:1.3;color:#0B1F3A">${titulo}</h1>` : ''}
    ${paso ? progreso(paso) : ''}
    <p style="margin:0 0 12px;font-size:16px">Hola ${h(nombre)},</p>
    <p style="margin:0 0 16px;line-height:1.55">${parrafo}</p>
    ${cuerpo}
    ${boton ? `<div style="margin:6px 0 0">${botonHtml(boton)}${boton2 ? botonHtml(boton2, false) : ''}</div>
    <p style="margin:10px 0 0;font-size:12px;color:${SUAVE}">Si el botón no abre, copia este enlace en tu navegador: <a href="${boton[1]}" style="color:${VERDE}">${boton[1]}</a></p>` : ''}
    ${conAyuda ? ayuda() : ''}
  </div>
  <div style="padding:14px 24px;background:#F3F5F7;font-size:12px;color:${SUAVE};line-height:1.5">${pie || 'Te escribimos porque hiciste un pedido en ATHLETIX.'} Pago simulado, sin cobro real.</div>
</div></div>`;

  // Datos del pedido para los correos: totales, hora estimada, tienda y productos (el administrador puede leer cualquier pedido)
  async function datosPedidoCorreo(numero) {
    const vacio = { items: [], tienda: {}, subtotal: 0, iva: 0, total: 0, horaEstimada: '' };
    if (!sb) return vacio;
    const [rp, rd] = await Promise.all([
      ejecutar(sb.from('pedido').select('ped_subtotal, ped_iva, ped_total, ped_hora_estimada, tienda(tie_nombre, tie_direccion, tie_ciudad, tie_horario), pago(pag_forma, pag_estado)').eq('ped_numero', numero).maybeSingle()),
      ejecutar(sb.from('detalle_pedido').select('prd_codigo, dpe_talla, dpe_cantidad, dpe_precio').eq('ped_numero', numero))
    ]);
    const p = rp.datos || {}; const t = p.tienda || {}; const g = Array.isArray(p.pago) ? p.pago[0] : p.pago;
    return {
      pendiente: !!(g && g.pag_forma === 'En tienda' && g.pag_estado === 'Pendiente'),
      subtotal: p.ped_subtotal, iva: p.ped_iva, total: p.ped_total, horaEstimada: p.ped_hora_estimada,
      tienda: { nombre: t.tie_nombre || '', direccion: t.tie_direccion || '', ciudad: t.tie_ciudad || '', horario: t.tie_horario || '' },
      items: (rd.datos || []).map((d) => {
        const pr = typeof productoPorDbId === 'function' ? productoPorDbId(d.prd_codigo) : null;
        return { id: pr ? pr.id : d.prd_codigo, nombre: pr ? pr.nombre : d.prd_codigo, foto: pr ? absoluta(fotoCorreo(img(pr))) : '', talla: d.dpe_talla === 'U' ? '' : d.dpe_talla, cantidad: d.dpe_cantidad, precio: Number(d.dpe_precio) };
      })
    };
  }
  // Envía por el Gmail de la tienda (función de Supabase). Devuelve null si no se pudo, para usar EmailJS.
  async function porGmail(cuerpo) {
    if (!sb) return null;
    try {
      const { data, error } = await Promise.race([
        sb.functions.invoke('correo-compra', { body: cuerpo }),
        new Promise((ok) => setTimeout(() => ok({ error: 'tiempo' }), 12000))
      ]);
      return !error && data && data.ok ? { datos: true } : null;
    } catch (e) { return null; }
  }
  // Tabla sencilla para el correo de respaldo de EmailJS
  const detalleRespaldo = (items, t) => tablaDetalle(items.map((x) => ({ ...x, foto: '' })), t);

  const correo = {
    configurado() { return !!(CONFIG.emailjs.servicio && CONFIG.emailjs.plantillaCliente && CONFIG.emailjs.clavePublica); },
    /* Al cliente, apenas paga: detalle de lo que pidió, datos del retiro y la factura en PDF adjunta.
       Sale desde el Gmail de la tienda con la función "correo-compra" de Supabase (EmailJS gratis no adjunta archivos);
       si la función falla, se envía igual por EmailJS con el detalle, pero sin el PDF. */
    async compraConfirmada(p) {
      const enlace = enlaceOrden(p.id);
      const d = await datosPedidoCorreo(p.id);
      const items = (p.items || []).map((it) => { const pr = typeof productoPorDbId === 'function' ? productoPorDbId(it.codigo) : null; return { ...it, foto: pr ? absoluta(fotoCorreo(img(pr))) : '' }; });
      const totales = { subtotal: p.subtotal, iva: p.iva, total: p.total, pendiente: !!p.enTienda };
      const tienda = d.tienda.nombre ? d.tienda : { nombre: p.tienda, horario: p.horario };
      const listo = d.horaEstimada ? ` aprox. a las ${horaCorta(d.horaEstimada)}` : '';
      const asunto = `Pedido ${p.numero} confirmado · código de retiro ${p.codigo}`;
      const html = plantillaCorreo({
        nombre: p.nombre, titulo: '¡Gracias por tu compra! 🎉', paso: 1,
        parrafo: p.enTienda ? `Recibimos tu pedido <b>${h(p.numero)}</b> y ya reservamos tus productos. <b>Pagas ${plata(p.total)} en efectivo en la caja de la tienda</b> cuando lo retires. Este es el detalle:` : `Recibimos tu pedido <b>${h(p.numero)}</b> y tu pago con ${h(p.pagoTexto)} fue aprobado. Este es el detalle:`,
        cuerpo: `${tablaDetalle(items, totales)}
          ${cajaRetiro({ numero: p.numero, codigo: p.codigo, tienda, nota: `Estará listo${listo || ` ${h(ENTREGA.retiro)}`}. Te avisaremos por correo.` })}
          <div style="margin:0 0 18px;font-size:14px;line-height:1.7"><b>¿Qué sigue?</b><br>1. Preparamos tus productos.<br>2. Te escribimos cuando esté <b>listo para retirar</b>.<br>3. Vas a la tienda con tu cédula y tu número de pedido.</div>
          <p style="margin:0 0 16px;font-size:14px">📄 Adjuntamos tu <b>factura en PDF</b> (N.º ${h(p.numeroFactura)}).</p>`,
        boton: ['Ver mi orden de pedido', enlace], boton2: ['Mis pedidos', `${BASE()}pedidos.html`]
      });
      const r = await porGmail({ tipo: 'compra', pedido: p.id, asunto, html, pdf: p.factura || '', archivo: `Factura-${p.numeroFactura}.pdf` });
      if (r) return r;
      return enviar(CONFIG.emailjs.plantillaCliente, {
        to_email: p.correo, nombre: p.nombre, numero: p.numero, tienda: p.tienda, horario: p.horario, total: Number(p.total).toFixed(2),
        asunto, enlace,
        mensaje: `Gracias por tu compra. ${p.enTienda ? `Pagas $${Number(p.total).toFixed(2)} en efectivo en la tienda al retirar.` : `Tu pago con ${p.pagoTexto} fue aprobado.`} Retira tu pedido en ${p.tienda} con tu cédula y tu número de pedido ${p.numero} (código de retiro ${p.codigo}). Descarga tu factura en PDF desde tu orden de pedido.`,
        detalle_html: detalleRespaldo(items, totales)
      });
    },
    /* Al cliente, cada vez que el administrador cambia el estado de su pedido (desde el Gmail de la tienda).
       Cada estado tiene su propio mensaje; el detalle del pedido solo va en la compra y en "listo para retirar".
       El de "retirado" trae un botón por producto que abre directo el formulario de reseña. */
    async pedidoActualizado(p, estadoNuevo) {
      const enlace = enlaceOrden(p.id);
      const nombre = String(p.cliente || '').split(' ')[0];
      const d = await datosPedidoCorreo(p.id);
      const tienda = d.tienda.nombre ? d.tienda : { nombre: p.tienda, horario: p.horario };
      let asunto, html, texto, detalle = '';
      if (estadoNuevo === 'Preparando') {
        const hora = horaCorta(d.horaEstimada || p.horaEstimada);
        asunto = `Estamos preparando tu pedido ${p.numero}`;
        texto = `Ya empezamos a preparar tu pedido ${p.numero}${hora ? `; estará listo aprox. a las ${hora}` : ''}. Te avisaremos cuando puedas retirarlo.`;
        html = plantillaCorreo({
          nombre, titulo: 'Estamos preparando tu pedido 📦', paso: 2,
          parrafo: `Nuestro equipo ya está alistando tu pedido <b>${h(p.numero)}</b> en <b>${h(tienda.nombre)}</b>.`,
          cuerpo: `<div style="margin:0 0 18px;padding:14px 16px;background:#FFF7ED;border-left:4px solid ${NARANJA};border-radius:6px;font-size:14px;line-height:1.6">⏱️ ${hora ? `Estará listo aproximadamente a las <b>${hora}</b>.` : `Estará listo ${h(ENTREGA.retiro)}.`}<br>No necesitas hacer nada: te enviaremos otro correo cuando puedas retirarlo.</div>`,
          boton: ['Ver mi pedido', enlace]
        });
      } else if (estadoNuevo === 'Listo') {
        asunto = `Tu pedido ${p.numero} está listo para retirar`;
        texto = `Tu pedido ${p.numero} ya está listo. Retíralo en ${tienda.nombre} presentando tu cédula y tu número de pedido.`;
        detalle = d.items.length ? tablaDetalle(d.items, d) : '';
        html = plantillaCorreo({
          nombre, titulo: '¡Tu pedido está listo para retirar! ✅', paso: 3,
          parrafo: `Tu pedido <b>${h(p.numero)}</b> ya te espera en la tienda. Esto es lo que vas a retirar:`,
          cuerpo: `${detalle}${cajaRetiro({ numero: p.numero, codigo: p.codigoRetiro, tienda, nota: d.pendiente ? `💵 <b>Recuerda:</b> pagas ${plata(d.total)} en efectivo en la caja al retirar.` : '' })}${queLlevar()}`,
          boton: ['Ver mi orden de pedido', enlace]
        });
      } else if (estadoNuevo === 'Retirado') {
        asunto = `Gracias por retirar tu pedido ${p.numero} · cuéntanos qué te pareció`;
        texto = `Registramos el retiro de tu pedido ${p.numero}. ¡Gracias por comprar en ATHLETIX! Cuéntanos qué te pareció.`;
        const vistos = new Set(); const productos = d.items.filter((x) => !vistos.has(x.id) && vistos.add(x.id));
        const resenas = productos.length ? `<p style="margin:0 0 10px;font-weight:bold">⭐ ¿Qué te pareció? Califica tu compra:</p>${productos.map((x) => `<table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 10px;width:100%;border:1px solid ${GRIS};border-radius:8px"><tr>
            <td style="padding:8px;width:56px">${x.foto ? `<img src="${x.foto}" alt="" width="48" height="48" style="display:block;width:48px;height:48px;object-fit:cover;border-radius:6px">` : ''}</td>
            <td style="padding:8px;font-size:14px"><b>${h(x.nombre)}</b></td>
            <td style="padding:8px 12px;text-align:right"><a href="${BASE()}producto.html?id=${encodeURIComponent(x.id)}&resenar=1" style="display:inline-block;background:${NARANJA};color:#ffffff;text-decoration:none;padding:9px 14px;border-radius:6px;font-weight:bold;font-size:14px;white-space:nowrap">★ Dejar reseña</a></td></tr></table>`).join('')}
            <p style="margin:4px 0 18px;font-size:13px;color:${SUAVE}">Tu reseña aparece con la marca «Compra verificada» y ayuda a otros clientes a elegir.</p>` : '';
        html = plantillaCorreo({
          nombre, titulo: '¡Gracias por retirar tu pedido! 🙌', paso: 5,
          parrafo: `Registramos el retiro de tu pedido <b>${h(p.numero)}</b> en <b>${h(tienda.nombre)}</b>. ¡Esperamos que disfrutes tus productos!`,
          cuerpo: `${resenas}<p style="margin:0 0 16px;font-size:14px">📄 Tu factura sigue disponible en tu orden de pedido, por si la necesitas.</p>`,
          boton: productos.length ? ['Seguir comprando', `${BASE()}productos.html`] : ['Dejar mi reseña', `${BASE()}pedidos.html`],
          boton2: ['Ver mi orden de pedido', enlace]
        });
      } else if (estadoNuevo === 'Cancelado') {
        asunto = `Tu pedido ${p.numero} fue cancelado`;
        texto = `Tu pedido ${p.numero} fue cancelado y el pago simulado quedó anulado: no se realizó ningún cobro.`;
        html = plantillaCorreo({
          nombre, titulo: 'Tu pedido fue cancelado',
          parrafo: `Tu pedido <b>${h(p.numero)}</b> fue cancelado.`,
          cuerpo: `<div style="margin:0 0 18px;padding:14px 16px;background:#F3F5F7;border-left:4px solid ${SUAVE};border-radius:6px;font-size:14px;line-height:1.6">💳 El pago quedó <b>anulado</b>: no se realizó ningún cobro a tu tarjeta.<br>📦 Los productos volvieron a estar disponibles en la tienda, por si quieres pedirlos de nuevo.</div>`,
          boton: ['Volver a la tienda', `${BASE()}productos.html`], boton2: ['Ir a Ayuda', `${BASE()}ayuda.html`]
        });
      } else return {};
      const r = await porGmail({ tipo: 'estado', pedido: p.id, asunto, html });
      if (r) return r;
      return enviar(CONFIG.emailjs.plantillaCliente, {
        to_email: p.correo, nombre: p.cliente, numero: p.numero, total: Number(p.total).toFixed(2), tienda: p.tienda, horario: p.horario,
        asunto, mensaje: texto, enlace, detalle_html: detalle ? detalleRespaldo(d.items, d) : ''
      }).then((x) => (x.error ? { error: x.error + ' El estado sí se guardó.' } : x));
    },
    /* Al administrador (Gmail de la tienda), cada vez que un cliente hace un pedido: mismo diseño que el correo del cliente,
       con el detalle y las fotos, los datos del cliente, el pago y la hora en que debe estar listo. */
    async nuevoPedido(p) {
      const d = await datosPedidoCorreo(p.id);
      const items = (p.items || []).map((it) => { const pr = typeof productoPorDbId === 'function' ? productoPorDbId(it.codigo) : null; return { ...it, foto: pr ? absoluta(fotoCorreo(img(pr))) : '' }; });
      const tienda = d.tienda.nombre ? d.tienda : { nombre: p.tienda };
      const hora = horaCorta(d.horaEstimada);
      const fila = (k, v) => `<tr><td style="padding:3px 10px 3px 0;color:${SUAVE};white-space:nowrap;vertical-align:top">${k}</td><td style="padding:3px 0"><b>${v}</b></td></tr>`;
      const html = plantillaCorreo({
        nombre: 'equipo ATHLETIX', titulo: `🛒 Nuevo pedido ${h(p.numero)}`,
        parrafo: `Llegó un pedido nuevo de <b>${h(p.cliente)}</b> por <b>${plata(p.total)}</b>. ${hora ? `Debe estar listo para retirar a las <b>${hora}</b>.` : ''}`,
        cuerpo: `${tablaDetalle(items.length ? items : d.items, { subtotal: p.subtotal ?? d.subtotal, iva: p.iva ?? d.iva, total: p.total, pendiente: !!p.enTienda })}
          <div style="margin:20px 0;padding:16px;background:#F3F5F7;border-left:4px solid #0B1F3A;border-radius:6px;font-size:14px">
            <div style="font-size:15px;font-weight:bold;margin-bottom:6px">👤 Cliente</div>
            <table role="presentation" cellpadding="0" cellspacing="0" style="font-size:14px">${fila('Nombre', h(p.cliente))}${fila(nombreDocumento(p.cedula, false), h(p.cedula))}${fila('Celular', h(p.telefono))}${fila('Correo', h(p.correo))}${p.direccion ? fila('Dirección', h(p.direccion)) : ''}${fila('Pago', h(p.pagoTexto || ''))}</table>
          </div>
          ${cajaRetiro({ numero: p.numero, codigo: p.codigo, tienda, nota: p.enTienda ? `💵 El cliente paga ${plata(p.total)} en efectivo al retirar.` : '✅ Pago con tarjeta aprobado.' })}`,
        boton: ['Abrir panel de pedidos', `${BASE()}admin.html?estado=Recibido`], boton2: ['Ver orden de pedido', enlaceOrden(p.id)],
        pie: 'Aviso automático para el administrador de ATHLETIX.', conAyuda: false
      });
      const r = await porGmail({ tipo: 'admin', pedido: p.id, asunto: `🛒 Nuevo pedido ${p.numero} · ${p.cliente} · ${plata(p.total)}`, html });
      if (r) return r;
      return enviar(CONFIG.emailjs.plantillaNuevoPedido, {
        numero: p.numero, cliente: p.cliente, cedula: p.cedula, correo_cliente: p.correo, telefono: p.telefono,
        tienda: p.tienda, productos: p.productos, total: Number(p.total).toFixed(2)
      });
    }
  };

  return { disponible, auth, catalogo, cliente, cuenta, pedidos, resenas, correo, admin, traducir };
})();
