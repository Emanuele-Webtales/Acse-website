"use client";
import { useEffect, useRef } from "react";
import { gsap } from "./registry";

export function useGsapScope() {
  const scopeRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    return () => {
      gsap.killTweensOf(scopeRef.current || undefined);
      gsap.globalTimeline.clear();
    };
  }, []);

  return scopeRef;
}

