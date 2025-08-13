"use client";
import { createClient } from "@/utils/supabase/client";
import { useState } from "react";

export default function SignInPage() {
  const supabase = createClient();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState<string | null>(null);

  async function handleEmailPassword(e: React.FormEvent) {
    e.preventDefault();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setMessage(error ? error.message : "Signed in");
  }

  async function handleGoogle() {
    await supabase.auth.signInWithOAuth({ provider: "google", options: { redirectTo: window.location.origin } });
  }

  return (
    <main className="max-w-md mx-auto p-8 space-y-4">
      <h1 className="text-2xl font-semibold">Sign in</h1>
      <form onSubmit={handleEmailPassword} className="space-y-3">
        <input className="w-full border border-[--color-border] rounded p-2" placeholder="Email" type="email" value={email} onChange={(e)=>setEmail(e.target.value)} />
        <input className="w-full border border-[--color-border] rounded p-2" placeholder="Password" type="password" value={password} onChange={(e)=>setPassword(e.target.value)} />
        <button className="w-full rounded bg-[--color-accent] text-black py-2" type="submit">Sign in</button>
      </form>
      <button className="w-full rounded border border-[--color-border] py-2" onClick={handleGoogle}>Continue with Google</button>
      {message && <p className="text-sm text-[--color-muted]">{message}</p>}
    </main>
  );
}

