# PROJECT_GUIDELINES

This document is the single source of truth for building, operating, and evolving the Acsé ecommerce platform. It is designed for a senior engineering team to execute flawlessly.

## 0. Progress Log and To‑Do Checklist

Status legend: [x] done, [~] in progress, [ ] pending, [⏩] optional/phase later

### Phase 0 — Setup
- [x] Initialize Next.js (App Router, TS) with Tailwind and pnpm
- [x] Fix project name and lockfile issues
- [x] Install core deps: Next, React, Tailwind
- [x] Install platform deps: GSAP, Supabase, Stripe, zod
- [x] Install testing stack: Vitest, Testing Library, Playwright (+ browsers)
- [x] Configure `tsconfig.json` (strict), `.gitignore`, helpful npm scripts
- [x] Add base design tokens in `app/globals.css`
- [x] Update `app/layout.tsx` metadata; simplify `app/page.tsx`
- [x] Scaffold architecture directories under `components/*`, `lib/*`, `types`, `scripts`
- [x] Implement initial helpers: `lib/gsap/*`, `lib/supabase/*`, `lib/stripe/*`, `lib/seo/*`
- [x] Write `PROJECT_GUIDELINES.md`
- [x] Typecheck green; dev server runs

### Phase 1 — Data and Auth
- [x] Supabase migrations for schema (products, variants, inventory, carts, orders, discounts, content) — initial migration added
- [ ] Enable RLS on all tables
- [ ] Implement RLS policies for public/product read and account/order ownership
- [ ] Seed script in `scripts/seed.ts`
- [ ] Supabase Storage buckets and policies
- [ ] Auth flow: email/password + OAuth
- [ ] Profiles bootstrap on sign-in; default role `customer`
- [ ] Guest cart merge on login

### Phase 2 — Storefront foundation
- [ ] Global layouts, header/footer, nav
- [ ] SEO metadata utilities per route; sitemap/robots
- [ ] Homepage: hero with GSAP, featured collections, content blocks
- [ ] PLP: server-rendered filters, pagination/infinite scroll
- [ ] PDP: gallery with GSAP Flip, variant selection, pricing
- [ ] Content blocks read from `content_blocks`

### Phase 3 — Cart and Checkout
- [ ] Cart model (guest + user), server actions, optimistic UI
- [ ] Stripe Checkout session API route
- [ ] Success/cancel pages
- [ ] Webhook route: create orders, decrement inventory, idempotent
- [ ] Discounts validation and application

### Phase 4 — Account
- [ ] Orders list/detail with downloads
- [ ] Address management
- [ ] Payment methods (optional via Setup Intents)
- [ ] Profile updates

### Phase 5 — Admin CMS
- [ ] Admin layout + RBAC guard
- [ ] Products CRUD (images upload, variants, pricing)
- [ ] Inventory adjustments and low-stock alerts
- [ ] Orders management (status updates, refunds)
- [ ] Discounts management
- [ ] Content blocks editor with preview
- [ ] Audit logs and cache revalidation

### Phase 6 — Polish and Awards pass
- [ ] Motion polish across hero/PLP/PDP/cart
- [ ] Performance tuning (bundle, fonts, image budgets)
- [ ] Accessibility audit and fixes
- [ ] Cross-device QA

### Phase 7 — Testing, Docs, Launch
- [ ] Unit/integration coverage for critical modules
- [ ] E2E coverage for storefront, checkout, admin
- [ ] Visual baselines and a11y checks in CI
- [ ] Observability & error boundaries
- [ ] Final CI gates and production deploy

### Ongoing
- [ ] Documentation updates alongside features
- [ ] Performance and accessibility regression checks on PRs

## 1. Tech Stack and Principles
- Next.js App Router (RSC-first), TypeScript strict.
- Tailwind CSS v4 with CSS variables design tokens.
- GSAP (ScrollTrigger, Flip) for motion islands.
- Supabase (Postgres, Auth, Storage) with RLS.
- Stripe (Checkout + Webhooks) for payments.
- pnpm as package manager.

Principles: performance-first, accessibility, modular domains, typed contracts, minimal client JS.

## 2. Project Structure
See the repository folders: `app`, `components`, `lib`, `types`, `public`, `scripts`. Domains live under `lib/data` (reads), `lib/actions` (mutations), and UI in `components/*`.

## 3. Environment Variables
Create `.env.local` with:
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

Never expose the Supabase service role to the client.

## 4. Supabase Setup
1. Create a Supabase project.
2. Apply migrations to create tables: `profiles, addresses, categories, products, product_images, product_variants, inventory, carts, cart_items, orders, order_items, discounts, content_blocks, audit_logs`.
3. Enable RLS on all tables. Implement policies:
   - `profiles`: self read/update; admins full.
   - `orders`: `select` where `profile_id = auth.uid()`.
   - Public products `select` where `status='active'`.
4. Storage buckets: `product-images`, `content`.
5. Seed data via `scripts/seed.ts`.

Recommended indexes: `products.slug`, `product_variants.sku`, `orders.profile_id, created_at`, trigram on `products.title`.

## 5. Data Access Patterns
- Reads: server-only repositories under `lib/data/*`. Co-locate query builders with mapping to `types/domain.ts`.
- Writes: Next.js Server Actions under `lib/actions/*` with zod validation. Invalidate cache tags via `revalidateTag`.
- Use integer cents for money. Snapshot order item data.

## 6. Authentication
- Use Supabase Auth (email/password + OAuth). On sign-in, ensure `profiles` row exists with role `customer`.
- Merge guest cart by `client_id` cookie into user cart on login server-side.
- Admin routes guard: layout-level server check + RLS + UI guards.

## 7. Payments with Stripe
- Create Checkout Sessions from cart server-side with validated prices from DB.
- Webhook handler:
  - `checkout.session.completed` → create `orders` and `order_items`, decrement inventory atomically, mark `paid`.
  - Idempotency: use `checkout_session_id`/cart id; `ON CONFLICT DO NOTHING` when appropriate.
- Optional subscriptions: mirror Stripe subscription state to DB.

## 8. Animations (GSAP)
- Register plugins in `lib/gsap/registry.ts` and call from client islands.
- Build reusable primitives in `components/motion`: `Reveal`, `SplitTextHeadline`, `ParallaxMedia`, `RouteTransition`.
- Respect `prefers-reduced-motion`; disable heavy effects for low-power.

Usage pattern example:
```tsx
"use client";
import { useEffect, useRef } from "react";
import { gsap } from "@/lib/gsap/registry";

export function Reveal({ children }: { children: React.ReactNode }) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    gsap.fromTo(el.children, { y: 20, opacity: 0 }, { y: 0, opacity: 1, stagger: 0.08, duration: 0.6, ease: "power3.out" });
  }, []);
  return <div ref={ref}>{children}</div>;
}
```

## 9. Styling
- Tailwind utility-first. Use CSS variables in `app/globals.css` as tokens: `--background`, `--foreground`, `--accent`, `--border`, spacings, radius.
- No ad-hoc colors; extend via tokens only.

## 10. Routing and Caching
- RSC for pages/data-heavy UI. Client islands for interactions only.
- Use `revalidateTag` and tag patterns: `product:{id}`, `category:{id}`, `plp:{filters}`, `content:{key}`.
- Revalidate admin changes via `app/api/revalidate/route.ts`.

## 11. Accessibility & SEO
- Visible focus, keyboard operable drawers/modals.
- Motion-safe fallbacks.
- `generateMetadata` per route; product JSON-LD; sitemap and robots.

## 12. Testing
- Unit: Vitest + RTL (components, utils, actions with mocks).
- E2E: Playwright (browse→PDP→add→checkout; admin CRUD; auth flows).
- Accessibility: `@testing-library/jest-dom` and axe checks on critical pages.

Scripts: `pnpm test`, `pnpm test:ui`, `pnpm typecheck`, `pnpm lint`.

## 13. Local Development
1. `pnpm install`
2. Create `.env.local` (see above).
3. Run `pnpm dev`.
4. Optional: run Playwright `pnpm exec playwright install` for browsers.

## 14. Deployment
- Vercel: environment variables, Node runtime for webhooks, Edge for storefront where possible.
- Supabase: separate projects per environment or separate schemas.

## 15. Roadmap Tickets (Initial)
- Implement DB migrations and RLS.
- Build repositories (`lib/data/*`) for products, variants, carts.
- Implement server actions (`lib/actions/*`) for cart and admin mutations.
- Stripe session route and webhook.
- Admin products CRUD and content blocks editor.
- Homepage hero with GSAP.

This document should evolve with the codebase—treat it as a living spec.