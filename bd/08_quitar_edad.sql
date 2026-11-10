/*==============================================================*/
/* ATHLETIX - Se quita la edad del producto                      */
/* El producto se clasifica solo por género:                     */
/* Hombre, Mujer o Unisex (prd_genero).                         */
/*==============================================================*/
alter table producto drop constraint if exists ckc_prd_edad;
alter table producto drop column if exists prd_edad;
