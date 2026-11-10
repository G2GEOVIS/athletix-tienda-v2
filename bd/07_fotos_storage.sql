/*==============================================================*/
/* ATHLETIX - Carpeta pública de fotos de productos (Storage)    */
/* Todos pueden ver las fotos; solo el administrador las sube,   */
/* cambia o borra desde el panel de productos.                   */
/*==============================================================*/
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('productos', 'productos', true, 3145728, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = 3145728, allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

drop policy if exists "fotos productos ver" on storage.objects;
create policy "fotos productos ver" on storage.objects for select using (bucket_id = 'productos');
drop policy if exists "fotos productos subir" on storage.objects;
create policy "fotos productos subir" on storage.objects for insert to authenticated with check (bucket_id = 'productos' and public.es_admin());
drop policy if exists "fotos productos cambiar" on storage.objects;
create policy "fotos productos cambiar" on storage.objects for update to authenticated using (bucket_id = 'productos' and public.es_admin());
drop policy if exists "fotos productos borrar" on storage.objects;
create policy "fotos productos borrar" on storage.objects for delete to authenticated using (bucket_id = 'productos' and public.es_admin());
