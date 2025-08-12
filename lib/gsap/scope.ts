"use client";
import { useEffect, useRef } from "react";
import { gsap } from "./registry";

export function useGsapScope() {
  const scopeRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    return () => {
      if (scopeRef.current) {
        gsap.killTweensOf(scopeRef.current);
      }
    };
  }, []);

  return scopeRef;
}

