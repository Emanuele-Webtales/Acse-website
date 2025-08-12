import { createClient } from "@/utils/supabase/server";
import { cookies } from "next/headers";

export default async function Page() {
  const cookieStore = await cookies();
  const supabase = createClient(cookieStore);
  const { data: products, error } = await supabase
    .from("products")
    .select("id, title, slug, status")
    .eq("status", "active")
    .limit(10);

  if (error) {
    return <pre>Supabase error: {error.message}</pre>;
  }

  if (!products || products.length === 0) {
    return <p>No active products yet. Seed one in Supabase Studio.</p>;
  }

  return (
    <ul>
      {products.map((p) => (
        <li key={p.id}>{p.title}</li>
      ))}
    </ul>
  );
}