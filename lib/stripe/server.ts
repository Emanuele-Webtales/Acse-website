import Stripe from "stripe";

export function getStripeServer() {
  const key = process.env.STRIPE_SECRET_KEY!;
  return new Stripe(key, { apiVersion: "2024-12-18.acacia" as any });
}

