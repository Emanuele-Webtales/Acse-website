-- Initial schema for Acsé ecommerce
create extension if not exists pg_trgm;
create extension if not exists pgcrypto;

-- Profiles
create table if not exists public.profiles (
  id uuid primary key,
  email text not null unique,
  name text,
  avatar_url text,
  role text not null default 'customer',
  created_at timestamptz not null default now()
);

-- Addresses
create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete cascade,
  type text not null check (type in ('shipping','billing')),
  line1 text not null,
  line2 text,
  city text not null,
  region text,
  postal_code text not null,
  country text not null,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

-- Catalog
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text,
  parent_id uuid references public.categories(id)
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  subtitle text,
  description_rich jsonb,
  status text not null default 'draft' check (status in ('draft','active','archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists products_slug_idx on public.products (slug);
create index if not exists products_trgm_title_idx on public.products using gin (title gin_trgm_ops);

create table if not exists public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products(id) on delete cascade,
  url text not null,
  alt text,
  position int not null default 0
);

create table if not exists public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products(id) on delete cascade,
  sku text not null unique,
  title text,
  price_cents int not null,
  currency text not null default 'USD',
  compare_at_price_cents int,
  weight_g int,
  options jsonb,
  created_at timestamptz not null default now()
);

create index if not exists variants_sku_idx on public.product_variants (sku);

create table if not exists public.inventory (
  variant_id uuid primary key references public.product_variants(id) on delete cascade,
  quantity int not null default 0,
  low_stock_threshold int not null default 3
);

-- Cart & Orders
create table if not exists public.carts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id),
  client_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists carts_client_idx on public.carts (client_id);

create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  cart_id uuid references public.carts(id) on delete cascade,
  variant_id uuid references public.product_variants(id),
  quantity int not null check (quantity > 0)
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id),
  email_snapshot text not null,
  shipping_address_snapshot jsonb,
  billing_address_snapshot jsonb,
  status text not null default 'pending' check (status in ('pending','paid','fulfilled','canceled','refunded')),
  subtotal_cents int not null default 0,
  shipping_cents int not null default 0,
  tax_cents int not null default 0,
  discount_cents int not null default 0,
  total_cents int not null default 0,
  currency text not null default 'USD',
  stripe_payment_intent_id text,
  created_at timestamptz not null default now()
);

create index if not exists orders_profile_created_idx on public.orders (profile_id, created_at desc);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references public.orders(id) on delete cascade,
  variant_id uuid references public.product_variants(id),
  title_snapshot text not null,
  sku_snapshot text not null,
  unit_price_cents int not null,
  quantity int not null check (quantity > 0)
);

-- Discounts
create table if not exists public.discounts (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  type text not null check (type in ('percent','fixed')),
  value int not null,
  starts_at timestamptz,
  ends_at timestamptz,
  usage_limit int,
  used_count int not null default 0,
  status text not null default 'active' check (status in ('active','disabled'))
);

-- Content blocks
create table if not exists public.content_blocks (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  type text not null,
  data jsonb not null default '{}',
  published boolean not null default false,
  updated_by uuid references public.profiles(id),
  updated_at timestamptz not null default now()
);

-- Audit logs
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id),
  action text not null,
  resource text not null,
  before jsonb,
  after jsonb,
  created_at timestamptz not null default now()
);

-- RLS (enable and add minimal policies; expand in later migrations)
alter table public.profiles enable row level security;
alter table public.addresses enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.product_variants enable row level security;
alter table public.inventory enable row level security;
alter table public.carts enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.discounts enable row level security;
alter table public.content_blocks enable row level security;
alter table public.audit_logs enable row level security;

-- Example policies (tighten in follow-ups)
create policy if not exists profiles_self on public.profiles for select using (id = auth.uid());
create policy if not exists addresses_owner on public.addresses for all using (profile_id = auth.uid()) with check (profile_id = auth.uid());
create policy if not exists products_public on public.products for select using (status = 'active');
create policy if not exists orders_owner on public.orders for select using (profile_id = auth.uid());

