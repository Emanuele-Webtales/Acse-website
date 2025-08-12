import type { Metadata } from "next";

export function buildDefaultMetadata(): Metadata {
  return {
    title: {
      default: "Acsé – E‑commerce",
      template: "%s – Acsé",
    },
    description: "Acsé – award‑grade ecommerce experience.",
    metadataBase: new URL("https://example.com"),
    openGraph: {
      type: "website",
      siteName: "Acsé",
    },
    twitter: { card: "summary_large_image" },
  };
}

