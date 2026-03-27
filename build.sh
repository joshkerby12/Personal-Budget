#!/usr/bin/env bash
set -e

# Write .env from Vercel environment variables
echo "SUPABASE_URL=$SUPABASE_URL" > .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env
echo "TELLER_APP_ID=$TELLER_APP_ID" >> .env

# Install Flutter
export FLUTTER_VERSION="3.41.2"
export FLUTTER_HOME="/vercel/flutter"

git config --global --add safe.directory "$FLUTTER_HOME"

if [ ! -d "$FLUTTER_HOME" ]; then
  curl -sL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar xJ -C "/vercel"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

flutter config --no-analytics --suppress-analytics
flutter pub get
flutter build web --release --base-href /
