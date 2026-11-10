/*==============================================================*/
/* ATHLETIX - Calzado y tecnología solo de Hombre o de Mujer     */
/* Entrenamiento es para todos (Unisex). Una regla en la base    */
/* impide crear calzado o tecnología como Unisex.                */
/*==============================================================*/
begin;

update producto set prd_genero = 'Hombre' where prd_codigo in ('tn', 'sa', 'cb', 'sp');
update producto set prd_genero = 'Mujer'  where prd_codigo = 'hb';

-- Calzado (1) y tecnología (2): Hombre o Mujer · Entrenamiento (3): Unisex
alter table producto drop constraint if exists ckc_prd_genero_categoria;
alter table producto add constraint ckc_prd_genero_categoria check ((cat_codigo = 3) = (prd_genero = 'Unisex'));

commit;
