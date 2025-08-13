import { NextResponse } from "next/server";

export async function GET() {
  // Supabase will handle cookies via OAuth redirect; simply route home.
  return NextResponse.redirect(new URL("/", process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"));
}

