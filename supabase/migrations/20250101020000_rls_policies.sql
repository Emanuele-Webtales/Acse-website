-- RLS and policies for public storefront reads and ownership (renamed)
-- Products: public can read only active products
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'products' and polname = 'products_public_select'
  ) then
    create policy products_public_select on public.products for select using (status = 'active');
  end if;
end $$;

-- Product variants: readable when parent product is active
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'product_variants' and polname = 'variants_public_select'
  ) then
    create policy variants_public_select on public.product_variants for select
    using (
      exists (
        select 1 from public.products p where p.id = product_id and p.status = 'active'
      )
    );
  end if;
end $$;

-- Product images: readable when parent product is active
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'product_images' and polname = 'product_images_public_select'
  ) then
    create policy product_images_public_select on public.product_images for select
    using (
      exists (
        select 1 from public.products p where p.id = product_id and p.status = 'active'
      )
    );
  end if;
end $$;

-- Orders: owner can select
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'orders' and polname = 'orders_owner_select'
  ) then
    create policy orders_owner_select on public.orders for select using (profile_id = auth.uid());
  end if;
end $$;

-- Storage: public read access for specific buckets
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and polname = 'public read product_images'
  ) then
    create policy "public read product_images" on storage.objects for select using (bucket_id = 'product_images');
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and polname = 'public read content'
  ) then
    create policy "public read content" on storage.objects for select using (bucket_id = 'content');
  end if;
end $$;

