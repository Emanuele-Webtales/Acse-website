import Stripe from "stripe";

export function constructWebhookEvent(stripe: Stripe, body: Buffer, signature: string) {
  const secret = process.env.STRIPE_WEBHOOK_SECRET!;
  return stripe.webhooks.constructEvent(body, signature, secret);
}

