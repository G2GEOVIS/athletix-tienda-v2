/* ATHLETIX · Factura en PDF (se adjunta al correo de compra y se puede descargar desde la orden de pedido)
   Documento sin validez tributaria: no está autorizado por el SRI. Usa jsPDF, que se carga solo cuando hace falta. */
'use strict';

const Factura = (() => {
  let cargando = null;
  // jsPDF pesa ~360 KB: se descarga una sola vez y solo al pagar o al descargar la factura
  function cargarJsPDF() {
    if (window.jspdf) return Promise.resolve(window.jspdf);
    if (!cargando) {
      cargando = new Promise((ok, mal) => {
        const s = document.createElement('script');
        s.src = 'js/vendor/jspdf.umd.min.js';
        s.onload = () => ok(window.jspdf);
        s.onerror = () => { cargando = null; mal(new Error('No se pudo cargar el generador de PDF.')); };
        document.head.appendChild(s);
      });
    }
    return cargando;
  }

  // Formato de numeración de facturas en Ecuador: establecimiento-punto de emisión-secuencial
  const numero = (id) => `001-001-${String(id).padStart(9, '0')}`;
  const plata = (n) => '$' + Number(n || 0).toFixed(2);
  const fechaLarga = (f) => new Date(f).toLocaleDateString('es-EC', { day: 'numeric', month: 'long', year: 'numeric' });

  /* d = { id (número de factura, propio y secuencial: PEDIDO.ped_factura), pedido, fecha, cliente: {nombres, apellidos, cedula, direccion, telefono, correo},
           tienda: {nombre, direccion}, items: [{codigo, nombre, talla, cantidad, precio}],
           subtotal, iva, total, pago, codigoRetiro } */
  async function generar(d) {
    const { jsPDF } = await cargarJsPDF();
    const doc = new jsPDF({ unit: 'mm', format: 'a4' });
    const AZUL = [11, 31, 58], VERDE = [15, 118, 110], GRIS = [243, 245, 247], TEXTO = [30, 41, 59], SUAVE = [69, 85, 107];
    const ancho = 210, m = 15;

    // Encabezado
    doc.setFillColor(...AZUL); doc.rect(0, 0, ancho, 32, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFont('helvetica', 'bolditalic'); doc.setFontSize(22); doc.text('ATHLETIX', m, 16);
    doc.setFont('helvetica', 'normal'); doc.setFontSize(9); doc.text('Tienda deportiva en línea · Quito y Guayaquil', m, 23);
    doc.setFont('helvetica', 'bold'); doc.setFontSize(15); doc.text('FACTURA', ancho - m, 15, { align: 'right' });
    doc.setFont('helvetica', 'normal'); doc.setFontSize(9); doc.text(`N.º ${numero(d.id)}`, ancho - m, 22, { align: 'right' });

    // Datos de la factura y del cliente
    let y = 44;
    doc.setTextColor(...TEXTO);
    const bloque = (titulo, filas, x, w) => {
      let yy = y;
      doc.setFont('helvetica', 'bold'); doc.setFontSize(10); doc.text(titulo, x, yy); yy += 6;
      doc.setFontSize(9);
      filas.forEach(([k, v]) => {
        doc.setFont('helvetica', 'bold'); doc.text(`${k}:`, x, yy);
        doc.setFont('helvetica', 'normal');
        const lineas = doc.splitTextToSize(String(v || '—'), w - 27);
        doc.text(lineas, x + 27, yy);
        yy += 5 * lineas.length;
      });
      return yy;
    };
    const c = d.cliente || {};
    const y1 = bloque('Datos de la factura', [
      ['Número', numero(d.id)], ['Pedido', d.pedido], ['Fecha', fechaLarga(d.fecha)], ['Pago', d.pago],
      ['Entrega', `Retiro en ${d.tienda.nombre}`], ['Código retiro', d.codigoRetiro]
    ], m, 88);
    const y2 = bloque('Cliente', [
      ['Nombre', `${c.nombres || ''} ${c.apellidos || ''}`.trim()], [nombreDocumento(c.cedula), c.cedula], ['Dirección', c.direccion],
      ['Celular', c.telefono], ['Correo', c.correo]
    ], 110, 85);
    y = Math.max(y1, y2) + 4;

    // Tabla de productos
    const cols = [{ t: 'Producto', x: m, w: 92 }, { t: 'Talla', x: 109, w: 16 }, { t: 'Cant.', x: 135, w: 12, der: true },
      { t: 'P. unitario', x: 167, w: 26, der: true }, { t: 'Subtotal', x: ancho - m, w: 26, der: true }];
    const cabecera = () => {
      doc.setFillColor(...GRIS); doc.rect(m - 2, y - 5, ancho - 2 * m + 4, 8, 'F');
      doc.setFont('helvetica', 'bold'); doc.setFontSize(9); doc.setTextColor(...TEXTO);
      cols.forEach((col) => doc.text(col.t, col.x, y, col.der ? { align: 'right' } : undefined));
      y += 8;
    };
    cabecera();
    doc.setFont('helvetica', 'normal');
    d.items.forEach((it) => {
      const nombre = doc.splitTextToSize(`${it.nombre} (${it.codigo})`, cols[0].w);
      const alto = 5 * nombre.length + 2;
      if (y + alto > 255) { doc.addPage(); y = 20; cabecera(); doc.setFont('helvetica', 'normal'); }
      doc.text(nombre, cols[0].x, y);
      doc.text(it.talla || 'Única', cols[1].x, y);
      doc.text(String(it.cantidad), cols[2].x, y, { align: 'right' });
      doc.text(plata(it.precio), cols[3].x, y, { align: 'right' });
      doc.text(plata(it.precio * it.cantidad), cols[4].x, y, { align: 'right' });
      y += alto;
      doc.setDrawColor(221, 227, 234); doc.line(m - 2, y - 4, ancho - m + 2, y - 4);
    });

    // Totales
    y += 3;
    const total = (k, v, fuerte) => {
      doc.setFont('helvetica', fuerte ? 'bold' : 'normal'); doc.setFontSize(fuerte ? 12 : 10);
      doc.text(k, 150, y, { align: 'right' }); doc.text(v, ancho - m, y, { align: 'right' }); y += fuerte ? 8 : 6;
    };
    total('Subtotal', plata(d.subtotal)); total('IVA 15 %', plata(d.iva)); total('Retiro en tienda', 'Gratis');
    doc.setDrawColor(...VERDE); doc.setLineWidth(.6); doc.line(120, y - 3, ancho - m, y - 3); doc.setLineWidth(.2); y += 2;
    total('TOTAL', plata(d.total), true);

    // Pie
    y = Math.max(y + 6, 262);
    doc.setFont('helvetica', 'normal'); doc.setFontSize(9); doc.setTextColor(...SUAVE);
    doc.text(`Retira tu pedido en ${d.tienda.nombre}${d.tienda.direccion ? ' (' + d.tienda.direccion + ')' : ''} con tu cédula y tu número de pedido ${d.pedido} (o el código ${d.codigoRetiro}).`, m, y, { maxWidth: ancho - 2 * m });
    doc.text('Documento sin validez tributaria: no está autorizado por el SRI. Pago simulado, sin cobro real.', m, y + 10);
    doc.setTextColor(...VERDE); doc.setFont('helvetica', 'bold'); doc.text('¡Gracias por comprar en ATHLETIX!', m, y + 16);

    const nombre = `Factura-${numero(d.id)}.pdf`;
    return { doc, nombre, dataUri: doc.output('datauristring', { filename: nombre }) };
  }

  async function descargar(d) {
    const f = await generar(d);
    f.doc.save(f.nombre);
  }

  /* Datos de la factura a partir de un pedido guardado (orden de pedido, Mis pedidos) */
  function desdePedido(p, cliente) {
    return {
      id: p.factura || p.id, pedido: p.numero, fecha: p.creado_en, cliente, codigoRetiro: p.codigoRetiro,
      tienda: { nombre: p.tiendas ? p.tiendas.nombre : '', direccion: p.tiendas ? p.tiendas.direccion : '' },
      items: p.detalle_pedido.map((x) => { const pr = productoPorDbId(x.producto_id); return { codigo: x.producto_id, nombre: pr ? pr.nombre : x.producto_id, talla: x.talla, cantidad: x.cantidad, precio: Number(x.precio_unitario) }; }),
      subtotal: p.subtotal, iva: p.iva, total: p.total, pago: p.pagoTexto
    };
  }

  return { generar, descargar, desdePedido, numero };
})();
