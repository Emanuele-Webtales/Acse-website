"use client";
import { createClient } from "@/utils/supabase/client";
import { useEffect } from "react";

export default function SignOutPage() {
  const supabase = createClient();
  useEffect(() => {
    supabase.auth.signOut().then(() => {
      window.location.href = "/";
    });
  }, []);
  return <p className="p-8">Signing out…</p>;
}

