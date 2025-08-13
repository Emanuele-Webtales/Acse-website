#!/usr/bin/env bash
set -euo pipefail

if ! command -v supabase >/dev/null 2>&1; then
  echo 'Installing Supabase CLI...'
  brew install supabase/tap/supabase || true
fi

if [ -z "${SUPABASE_PROJECT_REF:-}" ]; then
  echo 'Usage: SUPABASE_PROJECT_REF=xxxx ./scripts/db_push.sh'
  exit 1
fi

export SUPABASE_PROJECT_REF
# Login if not already
if ! supabase projects list >/dev/null 2>&1; then
  echo 'Please run: supabase login'
  exit 1
fi

# Push migrations directly to the remote project
supabase db push --project-ref "$SUPABASE_PROJECT_REF"
