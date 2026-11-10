/* ATHLETIX · Validaciones de datos (sin dependencias, se pueden probar por separado) */
'use strict';

const Validar = (() => {
  const LETRAS = /^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?:[ '\-][A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$/;

  /* Cédula ecuatoriana: 10 dígitos, provincia 01-24 o 30, tercer dígito 0-5 y dígito verificador (módulo 10) */
  function cedula(valor) {
    const c = String(valor || '').trim();
    if (!c) return 'Escribe tu número de cédula.';
    if (!/^\d{10}$/.test(c)) return 'La cédula debe tener 10 números.';
    const provincia = Number(c.slice(0, 2));
    if (provincia < 1 || (provincia > 24 && provincia !== 30)) return 'Los dos primeros números no corresponden a ninguna provincia.';
    if (Number(c[2]) > 5) return 'El tercer número de una cédula de persona debe estar entre 0 y 5.';
    let suma = 0;
    for (let i = 0; i < 9; i++) {
      let d = Number(c[i]);
      if (i % 2 === 0) { d *= 2; if (d > 9) d -= 9; }
      suma += d;
    }
    const verificador = (10 - (suma % 10)) % 10;
    if (verificador !== Number(c[9])) return 'La cédula no es válida. Revisa que esté bien escrita.';
    return '';
  }

  function nombre(valor, campo) {
    const v = String(valor || '').trim().replace(/\s+/g, ' ');
    if (!v) return `Escribe tu ${campo}.`;
    if (v.length < 2) return `Tu ${campo} debe tener al menos 2 letras.`;
    if (v.length > 60) return `Tu ${campo} puede tener hasta 60 letras.`;
    if (!LETRAS.test(v)) return `Tu ${campo} solo puede tener letras y espacios.`;
    return '';
  }

  /* Clientes de otros países: pasaporte de 5 a 20 letras y números */
  function pasaporte(valor) {
    const v = String(valor || '').trim().toUpperCase();
    if (!v) return 'Escribe tu número de pasaporte.';
    if (!/^[A-Z0-9]{5,20}$/.test(v)) return 'El pasaporte debe tener de 5 a 20 letras y números, sin espacios ni guiones.';
    return '';
  }
  /* Celular de otro país: solo el número, sin el código del país (ese se elige con el país) */
  function telefonoInternacional(valor, codigo) {
    const t = String(valor || '').replace(/\s+/g, '');
    if (!t) return 'Escribe tu número de celular.';
    if (!/^\d+$/.test(t)) return 'Escribe solo números, sin el código del país.';
    if (t.length < 6 || (String(codigo).replace(/\D/g, '') + t).length > 15) return 'El número no tiene un largo válido. Escríbelo sin el código del país.';
    return '';
  }

  function telefono(valor) {
    const t = String(valor || '').trim();
    if (!t) return 'Escribe tu número de celular.';
    if (!/^\d{10}$/.test(t)) return 'El celular debe tener 10 números.';
    if (!t.startsWith('09')) return 'El celular debe empezar con 09.';
    return '';
  }

  function correo(valor) {
    const c = String(valor || '').trim();
    if (!c) return 'Escribe tu correo electrónico.';
    if (c.length > 120) return 'El correo es demasiado largo.';
    if (!/^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$/.test(c) || c.includes('..')) {
      return 'Escribe un correo completo, por ejemplo nombre@gmail.com.';
    }
    const dominio = c.split('@')[1].toLowerCase();
    const sugerencias = { 'gmial.com': 'gmail.com', 'gmal.com': 'gmail.com', 'gmail.co': 'gmail.com', 'gmail.con': 'gmail.com', 'hotmal.com': 'hotmail.com', 'hotmail.co': 'hotmail.com', 'hotmail.con': 'hotmail.com', 'outlok.com': 'outlook.com', 'yaho.com': 'yahoo.com' };
    if (sugerencias[dominio]) return `¿Quisiste decir ${c.split('@')[0]}@${sugerencias[dominio]}?`;
    return '';
  }

  function clave(valor) {
    const v = String(valor || '');
    if (!v) return 'Escribe una contraseña.';
    if (v.length < 8) return 'La contraseña debe tener al menos 8 caracteres.';
    if (v.length > 72) return 'La contraseña puede tener hasta 72 caracteres.';
    if (!/[A-Za-zÁÉÍÓÚÑáéíóúñ]/.test(v) || !/\d/.test(v)) return 'La contraseña debe tener letras y números.';
    if (!/[^A-Za-zÁÉÍÓÚÑÜáéíóúñü0-9\s]/.test(v)) return 'Para que sea más segura, agrega al menos un carácter especial, por ejemplo: ! @ # $ % * ? .';
    return '';
  }

  /* ---------- Tarjetas ---------- */
  // Algoritmo de Luhn: el que usan los bancos para detectar números mal escritos
  function luhn(numero) {
    let suma = 0;
    for (let i = 0; i < numero.length; i++) {
      let d = Number(numero[numero.length - 1 - i]);
      if (i % 2 === 1) { d *= 2; if (d > 9) d -= 9; }
      suma += d;
    }
    return suma % 10 === 0;
  }

  /* Marca de la tarjeta según sus primeros dígitos (rangos públicos de cada red) y largos válidos */
  const MARCAS = [
    ['American Express', (n) => /^3[47]/.test(n), [15]],
    ['Diners Club', (n) => /^3(0[0-5]|[689])/.test(n), [14, 15, 16, 17, 18, 19]],
    ['JCB', (n) => { const c = Number(n.slice(0, 4)); return c >= 3528 && c <= 3589; }, [16, 17, 18, 19]],
    ['Visa', (n) => /^4/.test(n), [13, 16, 19]],
    ['Mastercard', (n) => { const d = Number(n.slice(0, 2)), c = Number(n.slice(0, 4)); return (d >= 51 && d <= 55) || (c >= 2221 && c <= 2720); }, [16]],
    ['Discover', (n) => /^(6011|65|64[4-9])/.test(n), [16, 17, 18, 19]],
    ['UnionPay', (n) => /^62/.test(n), [16, 17, 18, 19]],
    ['Maestro', (n) => /^(50|5[6-9]|6[0-9])/.test(n), [12, 13, 14, 15, 16, 17, 18, 19]]
  ];
  function datosMarca(numero) {
    const n = String(numero || '').replace(/\D/g, '');
    if (n.length < 2) return null;
    const m = MARCAS.find(([, prueba]) => prueba(n));
    return m ? { marca: m[0], largos: m[2] } : null;
  }
  function marcaTarjeta(numero) { const d = datosMarca(numero); return d ? d.marca : ''; }
  const unir = (l) => (l.length === 1 ? String(l[0]) : `${l.slice(0, -1).join(', ')} o ${l[l.length - 1]}`);

  function tarjeta(valor) {
    const n = String(valor || '').replace(/\D/g, '');
    if (!n) return 'Escribe el número de la tarjeta.';
    const d = datosMarca(n);
    if (!d) return 'No reconocemos este número de tarjeta. Revisa que esté bien escrito.';
    if (!d.largos.includes(n.length)) return `Una tarjeta ${d.marca} tiene ${unir(d.largos)} dígitos. La tuya tiene ${n.length}.`;
    if (!luhn(n)) return 'El número de la tarjeta no es válido. Revisa que esté bien escrito.';
    return '';
  }

  function vencimiento(valor, hoy = new Date()) {
    const v = String(valor || '').trim();
    if (!v) return 'Escribe la fecha de vencimiento.';
    const m = /^(\d{2})\/(\d{2})$/.exec(v);
    if (!m) return 'Escribe la fecha como MM/AA, por ejemplo 08/29.';
    const mes = Number(m[1]); const anio = 2000 + Number(m[2]);
    if (mes < 1 || mes > 12) return 'El mes debe estar entre 01 y 12.';
    if (anio < hoy.getFullYear() || (anio === hoy.getFullYear() && mes < hoy.getMonth() + 1)) return 'La tarjeta está vencida. Usa una tarjeta vigente.';
    if (anio > hoy.getFullYear() + 15) return 'Revisa el año de vencimiento.';
    return '';
  }

  /* CVV: 3 números al reverso; American Express usa 4 números al frente */
  const largoCvv = (marca) => (marca === 'American Express' ? 4 : 3);
  function cvv(valor, marca = '') {
    const v = String(valor || '').trim();
    const n = largoCvv(marca);
    if (!v) return 'Escribe el CVV.';
    if (!new RegExp(`^\\d{${n}}$`).test(v)) return `El CVV debe tener ${n} números.`;
    return '';
  }

  function titular(valor) {
    return nombre(valor, 'nombre').replace('Tu nombre', 'El nombre del titular').replace('tu nombre', 'el nombre del titular');
  }

  function texto(valor, { campo, min = 1, max = 120 }) {
    const v = String(valor || '').trim();
    if (v.length < min) return min <= 1 ? `Escribe ${campo}.` : `${campo[0].toUpperCase() + campo.slice(1)} debe tener al menos ${min} caracteres.`;
    if (v.length > max) return `${campo[0].toUpperCase() + campo.slice(1)} puede tener hasta ${max} caracteres.`;
    return '';
  }

  function direccion(valor) {
    const v = String(valor || '').trim();
    if (!v) return 'Escribe tu dirección.';
    if (v.length < 8) return 'Escribe la dirección completa: calle principal, número y calle secundaria.';
    if (v.length > 150) return 'La dirección puede tener hasta 150 caracteres.';
    return '';
  }

  return { cedula, pasaporte, nombre, telefono, telefonoInternacional, correo, clave, tarjeta, marcaTarjeta, datosMarca, luhn, vencimiento, cvv, largoCvv, titular, direccion, texto };
})();

if (typeof module !== 'undefined') module.exports = Validar;
