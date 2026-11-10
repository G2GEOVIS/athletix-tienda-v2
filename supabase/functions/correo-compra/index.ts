// ATHLETIX · Edge Function "correo-compra"
// Envía los correos al cliente desde el Gmail de la tienda (llegan a la bandeja de entrada, no por un servicio externo):
//   tipo "compra": correo de compra con la factura en PDF adjunta. Lo pide el propio cliente, solo para un pedido suyo,
//                  y siempre va al correo de su cuenta.
//   tipo "admin":  aviso de pedido nuevo al administrador. Lo pide el cliente que hizo el pedido y solo va al
//                  Gmail de la tienda.
//   tipo "estado": aviso de cambio de estado del pedido. Solo lo puede pedir el administrador y va al correo
//                  del cliente dueño de ese pedido (se lee de la base, no del navegador).
// Así nadie puede usar la función para escribir a cualquier dirección.
// Secretos que se configuran en Supabase → Edge Functions → Secrets:
//   GMAIL_USUARIO     correo de Gmail que envía (el de la tienda)
//   GMAIL_CLAVE_APP   contraseña de aplicación de ese Gmail (16 letras)
import { createClient } from 'npm:@supabase/supabase-js@2.45.4';
import nodemailer from 'npm:nodemailer@6.9.16';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};
const responder = (cuerpo: unknown, estado = 200) =>
  new Response(JSON.stringify(cuerpo), { status: estado, headers: { ...CORS, 'Content-Type': 'application/json' } });

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return responder({ error: 'Método no permitido.' }, 405);

  // Se limpian espacios: Google muestra la contraseña de aplicación en grupos de 4 letras ("abcd efgh ...")
  const usuarioGmail = (Deno.env.get('GMAIL_USUARIO') || '').trim().toLowerCase();
  const claveGmail = (Deno.env.get('GMAIL_CLAVE_APP') || '').replace(/\s+/g, '');
  if (!usuarioGmail || !claveGmail) return responder({ error: 'El correo de la tienda no está configurado.' }, 500);

  const autorizacion = req.headers.get('Authorization') || '';
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY') || 'sb_publishable_tdCRRgSHKJO6ADcmyeuFeQ_xuGIuhXd', {
    global: { headers: { Authorization: autorizacion } }
  });
  const { data: { user } } = await supabase.auth.getUser(autorizacion.replace(/^Bearer\s+/i, ''));
  if (!user || !user.email) return responder({ error: 'Inicia sesión para recibir tu factura.' }, 401);

  let datos: { tipo?: string; pedido?: number; asunto?: string; html?: string; pdf?: string; archivo?: string };
  try { datos = await req.json(); } catch { return responder({ error: 'Solicitud no válida.' }, 400); }
  const { tipo = 'compra', pedido, asunto, html, pdf, archivo } = datos;
  if (!Number.isInteger(pedido) || !asunto || !html) return responder({ error: 'Faltan datos del pedido.' }, 400);
  if (asunto.length > 200 || html.length > 60000 || (pdf && pdf.length > 3_000_000)) return responder({ error: 'El correo es demasiado grande.' }, 413);

  let destino = user.email;
  if (tipo === 'estado') {
    const { data: admin } = await supabase.rpc('es_admin');
    if (admin !== true) return responder({ error: 'Solo el administrador puede avisar cambios de estado.' }, 403);
    const { data: fila } = await supabase.from('pedido').select('ped_numero, cliente(cli_correo)').eq('ped_numero', pedido).maybeSingle();
    const correo = fila && (fila as { cliente?: { cli_correo?: string } }).cliente?.cli_correo;
    if (!correo) return responder({ error: 'No encontramos el correo del cliente de ese pedido.' }, 404);
    destino = correo;
  } else {
    // Con la sesión del cliente, las reglas RLS solo dejan ver sus propios pedidos
    const { data: fila } = await supabase.from('pedido').select('ped_numero').eq('ped_numero', pedido).maybeSingle();
    if (!fila) return responder({ error: 'No encontramos ese pedido en tu cuenta.' }, 404);
    if (tipo === 'admin') destino = usuarioGmail;
  }

  const adjuntos = [];
  if (pdf && tipo === 'compra') {
    const base64 = pdf.includes(',') ? pdf.slice(pdf.indexOf(',') + 1) : pdf;
    const nombre = /^[\w.\-]{1,80}\.pdf$/.test(archivo || '') ? archivo! : `Factura-${pedido}.pdf`;
    adjuntos.push({ filename: nombre, content: base64, encoding: 'base64', contentType: 'application/pdf' });
  }

  try {
    const transporte = nodemailer.createTransport({
      host: 'smtp.gmail.com', port: 465, secure: true, auth: { user: usuarioGmail, pass: claveGmail }
    });
    await transporte.sendMail({
      from: `"ATHLETIX" <${usuarioGmail}>`, to: destino, subject: asunto, html, attachments: adjuntos,
      // Versión en texto plano: los filtros de spam desconfían de los correos que solo traen HTML
      text: html.replace(/<(br|\/p|\/div|\/tr|\/h\d)[^>]*>/gi, '\n').replace(/<[^>]+>/g, '').replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&').replace(/\n\s*\n+/g, '\n\n').trim()
    });
    return responder({ ok: true });
  } catch (e) {
    // Diagnóstico sin mostrar la contraseña: solo su largo y si son 16 letras como las que entrega Google
    console.error(e, { usuario: usuarioGmail, largoClave: claveGmail.length, formatoGoogle: /^[a-z]{16}$/.test(claveGmail) });
    const credenciales = String((e as { code?: string })?.code) === 'EAUTH';
    return responder({ error: credenciales ? 'Gmail rechazó el usuario o la contraseña de aplicación de la tienda.' : 'No se pudo enviar el correo.' }, 502);
  }
});
