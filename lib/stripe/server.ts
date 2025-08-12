import Stripe from "stripe";

export function getStripeServer() {
  const key = process.env.STRIPE_SECRET_KEY!;
  // Use library default pinned version to avoid type mismatch during scaffold; adjust later if needed.
  return new Stripe(key);
}

