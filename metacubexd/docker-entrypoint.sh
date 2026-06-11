#!/bin/sh
set -eu

export NUXT_PUBLIC_DEFAULT_BACKEND_URL="${DEFAULT_BACKEND_URL:-http://localhost:9090}"

exec node /app/.output/server/index.mjs
