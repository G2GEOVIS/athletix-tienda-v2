/* ATHLETIX - Reseñas: basta con haber comprado el producto (pedido no cancelado). Aplicado en Supabase. */
-- Solo opina quien compró el producto (un pedido suyo con ese producto que no esté cancelado)
create or replace function tib_resena() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if not exists (
    select 1 from pedido p join detalle_pedido d on d.ped_numero = p.ped_numero
     where p.cli_cedula = new.cli_cedula and d.prd_codigo = new.prd_codigo and p.ped_estado <> 'Cancelado'
  ) then
    raise exception 'No encontramos una compra de este producto en tu cuenta. Solo los clientes que compraron este producto pueden dejar una reseña';
  end if;
  if tg_op = 'UPDATE' then
    new.cli_cedula := old.cli_cedula; new.prd_codigo := old.prd_codigo;
  end if;
  new.res_fecha := now();
  return new;
end $$;
