import { getActiveProducts } from "@/utils/data/products";

export const dynamic = "force-dynamic";

export default async function ProductsPage() {
  const products = await getActiveProducts(50);
  return (
    <main className="max-w-5xl mx-auto p-8">
      <h1 className="text-3xl font-semibold mb-6">Products</h1>
      <ul className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
        {products.map((p) => (
          <li key={p.id} className="border border-[--color-border] rounded p-4">
            <div className="text-lg font-medium">{p.title}</div>
            <div className="text-sm text-[--color-muted]">/{p.slug}</div>
          </li>
        ))}
      </ul>
    </main>
  );
}

