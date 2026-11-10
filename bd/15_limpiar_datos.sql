/*==============================================================*/
/* ATHLETIX - Dejar la tienda lista para empezar de cero         */
/*  1. Devuelve al stock lo de los pedidos no cancelados         */
/*  2. Borra todos los pedidos (con su detalle y su pago)        */
/*  3. Borra los clientes y sus cuentas, menos el administrador  */
/*  4. Cierra todas las sesiones abiertas (también la del admin) */
/* El catálogo, las tiendas y el administrador se conservan.     */
/*==============================================================*/
begin;
select set_config('athletix.motivo', 'Limpieza', true);

-- 1. El stock vuelve a su total (los pedidos cancelados ya lo devolvieron)
update producto_talla t set pta_cantidad = t.pta_cantidad + x.cantidad
  from (select d.prd_codigo, d.dpe_talla, sum(d.dpe_cantidad) as cantidad
          from detalle_pedido d join pedido p on p.ped_numero = d.ped_numero
         where p.ped_estado <> 'Cancelado'
         group by d.prd_codigo, d.dpe_talla) x
 where t.prd_codigo = x.prd_codigo and t.pta_talla = x.dpe_talla;

-- 2. Pedidos, detalle y pagos
delete from pedido;
-- La numeración de pedidos y facturas NO se reinicia: así una factura nunca repite número

-- 3. Clientes (con sus tarjetas y reseñas) y sus cuentas de acceso, menos el administrador
delete from movimiento_stock;
delete from carrito;
delete from favorito;
delete from resena where cli_cedula in (select cli_cedula from cliente where cli_usuario not in (select adm_usuario from administrador));
delete from metodo_pago where cli_cedula in (select cli_cedula from cliente where cli_usuario not in (select adm_usuario from administrador));
delete from cliente where cli_usuario not in (select adm_usuario from administrador);
delete from auth.users where id not in (select adm_usuario from administrador);

-- 4. Nadie queda con la sesión iniciada: se borran las sesiones y sus tokens de renovación
delete from auth.refresh_tokens;
delete from auth.sessions;

commit;
