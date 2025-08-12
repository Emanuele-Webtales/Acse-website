-- Minimal seed for products and variants
insert into public.products (id, slug, title, subtitle, status)
values
  (gen_random_uuid(), 'acse-tee', 'Acsé Tee', 'Organic Cotton', 'active'),
  (gen_random_uuid(), 'acse-tote', 'Acsé Tote', 'Everyday Carry', 'active')
on conflict (slug) do nothing;

insert into public.product_variants (id, product_id, sku, title, price_cents, currency)
select gen_random_uuid(), p.id, 'TEE-BLACK-S', 'Black / Small', 2900, 'USD'
from public.products p where p.slug = 'acse-tee'
on conflict do nothing;

insert into public.inventory (variant_id, quantity, low_stock_threshold)
select v.id, 25, 3 from public.product_variants v
where v.sku = 'TEE-BLACK-S'
on conflict (variant_id) do nothing;

