/*==============================================================*/
/* ATHLETIX - Un celular por cuenta                              */
/*  - No se permiten dos clientes con el mismo celular           */
/*    (la cédula ya es única porque es la clave de CLIENTE y el  */
/*     correo es único en las cuentas de Supabase Auth)          */
/*  - celular_registrado(): la página revisa antes de guardar    */
/*    si el celular ya es de otra cuenta                         */
/*==============================================================*/
begin;

alter table cliente drop constraint if exists ak_cliente_celular;
alter table cliente add constraint ak_cliente_celular unique (cli_celular);

-- Devuelve true si el celular ya pertenece a OTRA cuenta (el propio cliente puede volver a guardar el suyo)
create or replace function celular_registrado(p_celular text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from cliente where cli_celular = trim(p_celular) and cli_usuario is distinct from auth.uid());
$$;
grant execute on function celular_registrado(text) to anon, authenticated;

commit;
