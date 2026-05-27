#!/usr/bin/env bash
set -euo pipefail

if [ -x /home/kilisan/flutter/bin/flutter ]; then
  export PATH="/home/kilisan/flutter/bin:$PATH"
elif [ ! -d .vercel_flutter ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git .vercel_flutter
  export PATH="$PWD/.vercel_flutter/bin:$PATH"
else
  export PATH="$PWD/.vercel_flutter/bin:$PATH"
fi

if [ -f .env.client.local ]; then
  set -a
  . ./.env.client.local
  set +a
fi

flutter config --enable-web
flutter pub get
flutter build web --release \
  --no-wasm-dry-run \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-}" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-}" \
  --dart-define=PAULIENS_SKY_AI_PROXY_URL="${PAULIENS_SKY_AI_PROXY_URL:-/api/ai/neuromorphic-chat}" \
  --dart-define=PAULIENS_SKY_ACCOUNT_DELETE_URL="${PAULIENS_SKY_ACCOUNT_DELETE_URL:-/api/account/delete}" \
  --dart-define=SENTRY_DSN="${SENTRY_DSN:-}"
