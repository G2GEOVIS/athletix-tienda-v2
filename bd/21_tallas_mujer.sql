/*==============================================================*/
/* ATHLETIX - Tallas de calzado de mujer                         */
/* Todo el calzado de mujer maneja las mismas tallas, las más    */
/* usadas: 36, 36.5, 37, 37.5, 38, 38.5, 39 y 40 (EU).           */
/*  - Se quitan las tallas que no están en esa lista (35, 41)    */
/*  - Se agregan las que faltan con 10 unidades                  */
/* Las tallas que ya existían conservan su stock.                */
/*==============================================================*/
begin;

delete from producto_talla t
 using producto p
 where p.prd_codigo = t.prd_codigo and p.cat_codigo = 1 and p.prd_genero = 'Mujer'
   and t.pta_talla not in ('36', '36.5', '37', '37.5', '38', '38.5', '39', '40');

select set_config('athletix.motivo', 'Alta', true);
insert into producto_talla (prd_codigo, pta_talla, pta_cantidad)
select p.prd_codigo, x.talla, 10
  from producto p cross join unnest(array['36', '36.5', '37', '37.5', '38', '38.5', '39', '40']) as x(talla)
 where p.cat_codigo = 1 and p.prd_genero = 'Mujer'
on conflict (prd_codigo, pta_talla) do nothing;

commit;
