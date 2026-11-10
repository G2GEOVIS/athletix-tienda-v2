/*==============================================================*/
/* ATHLETIX - Reglas del producto también en la base de datos    */
/* El formulario del administrador ya las valida; aquí se        */
/* repiten para que nadie las salte llamando directo a la API.   */
/*==============================================================*/
alter table producto drop constraint if exists ckc_prd_codigo;
alter table producto add constraint ckc_prd_codigo check (prd_codigo ~ '^[a-z0-9]{2,10}$');

alter table producto drop constraint if exists ckc_prd_nombre;
alter table producto add constraint ckc_prd_nombre check (length(trim(prd_nombre)) >= 3);

alter table producto drop constraint if exists ckc_prd_descripcion;
alter table producto add constraint ckc_prd_descripcion check (length(trim(prd_descripcion)) between 20 and 600);

alter table producto drop constraint if exists ckc_prd_precio_max;
alter table producto add constraint ckc_prd_precio_max check (prd_precio < 100000);

alter table producto_imagen drop constraint if exists ckc_pim_url;
alter table producto_imagen add constraint ckc_pim_url check (length(trim(pim_url)) > 0);
