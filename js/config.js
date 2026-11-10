/* ATHLETIX · Configuración de servicios externos
   Las claves de este archivo son PÚBLICAS por diseño:
   - La clave "publishable" de Supabase solo permite lo que autorizan las reglas de seguridad (RLS) de la base.
   - La "Public Key" de EmailJS solo permite enviar con las plantillas creadas en tu cuenta. */
'use strict';

const CONFIG = {
  supabase: {
    url: 'https://umujfngetzifneqerirl.supabase.co',
    clave: 'sb_publishable_tdCRRgSHKJO6ADcmyeuFeQ_xuGIuhXd'
  },
  emailjs: {
    servicio: 'service_n3b8qkn',
    plantillaCliente: 'template_xgi77wu',     // correo al cliente: compra confirmada y pedido listo
    plantillaNuevoPedido: 'template_mjzl46j',
    clavePublica: 'byyIpSC8iBjJs4sU3'
  },
  iva: 0.15,
  tiempoEsperaMs: 15000
};

/* Se guarda el fragmento de la URL antes de que Supabase lo procese
   (enlaces de confirmación de correo y de recuperación de contraseña) */
window.HASH_INICIAL = location.hash;
