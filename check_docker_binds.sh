# File: check_docker_binds.sh
#!/bin/bash
set -euo pipefail

echo "🔎 Checking docker-compose config for non-localhost binds..."
bad_cfg=$(docker compose config \
  | grep -E '^[[:space:]]*-[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:' \
  | grep -v '127\.0\.0\.1' || true)

echo "🔎 Checking running containers for non-localhost binds..."
bad_run=$(docker ps --format '{{.Names}} -> {{.Ports}}' \
  | grep '0.0.0.0' || true)

if [[ -z "$bad_cfg" && -z "$bad_run" ]]; then
  echo "✅ SAFE: All ports are bound to 127.0.0.1 only"
else
  echo "❌ UNSAFE: Found non-localhost bindings"
  [[ -n "$bad_cfg" ]] && echo "Config issues:" && echo "$bad_cfg"
  [[ -n "$bad_run" ]] && echo "Running containers:" && echo "$bad_run"
  exit 1
fi