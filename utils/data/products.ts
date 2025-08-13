import { cookies } from "next/headers";
import { createClient } from "@/utils/supabase/server";

export type ProductListItem = {
  id: string;
  slug: string;
  title: string;
  status: string;
  min_price_cents?: number | null;
};

export async function getActiveProducts(limit = 24): Promise<ProductListItem[]> {
  const cookieStore = await cookies();
  const supabase = createClient(cookieStore);

  // Simple example: select products. Extend later with joins/aggregations.
  const { data, error } = await supabase
    .from("products")
    .select("id, slug, title, status")
    .eq("status", "active")
    .limit(limit);

  if (error) throw new Error(error.message);
  return data ?? [];
}

