# File: check_local_exposure.sh
#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# check_local_exposure.sh
# Scans for non-localhost exposures from:
#   - docker compose config (host binds)
#   - running docker containers
#   - host TCP LISTEN sockets (non-loopback)
#   - host UDP sockets bound to * / :: / 0.0.0.0
#
# Config: ~/.config/check_local_exposure/allowlist.env
# Exit: 0 = no unexpected exposure; 1 = exposure(s) found
# Requires: bash, awk, grep, lsof, docker (optional for docker checks)
# -----------------------------------------------------------------------------

say() { printf '%s\n' "$*"; }

# --------------------------- config loading ---------------------------
CONF_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/check_local_exposure/allowlist.env"
if [ -f "$CONF_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONF_FILE"
fi

# Explicit defaults if not provided by env/config (empty = strict)
: "${ALLOW_PROCS:=}"
: "${ALLOW_TCP_PORTS:=}"
: "${ALLOW_UDP_PORTS:=}"

# ------------------------------ helpers ------------------------------
port_allowed() {
    local port="$1" list="$2" p
    IFS=',' read -r -a arr <<< "$list"
    for p in "${arr[@]}"; do
        [ -z "$p" ] && continue
        if [ "$p" = "$port" ]; then
            return 0
        fi
    done
    return 1
}

# lsof COMMAND is often truncated; treat allow-list entries as literal/prefixes
proc_allowed() {
    local cmd="$1" item
    IFS=',' read -r -a arr <<< "$ALLOW_PROCS"
    for item in "${arr[@]}"; do
        [ -z "$item" ] && continue
        case "$cmd" in
            "$item"|"$item"*) return 0 ;;
        esac
    done
    return 1
}

# --------------------- docker compose (intended cfg) -----------------
say "🔎 Checking docker-compose merged config for non-localhost host binds…"
bad_cfg=""
if command -v docker >/dev/null 2>&1; then
    # Match "- \"IP:host:container\"" where IP is IPv4 or [IPv6]; exclude 127.0.0.1 and [::1]
    bad_cfg="$(docker compose config 2>/dev/null \
        | grep -E '^[[:space:]]*-[[:space:]]*\"(\[[^]]+\]|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):' \
        | grep -Ev '127\.0\.0\.1|\[::1\]' || true)"
else
    say "ℹ️ docker not found; skipping compose config check."
fi

# ---------------------- docker runtime (actual) ----------------------
say "🔎 Checking running containers for 0.0.0.0/::: publishes…"
bad_run=""
if command -v docker >/dev/null 2>&1; then
    bad_run="$(docker ps --format '{{.Names}} -> {{.Ports}}' 2>/dev/null \
        | grep -E '0\.0\.0\.0|:::' || true)"
else
    say "ℹ️ docker not found; skipping running containers check."
fi

# --------------- host TCP listeners (non-loopback) -------------------
say "🔎 Scanning host TCP listeners not on localhost…"
tcp_rows="$(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null \
    | awk 'NR>1 {print $1, $2, $3, $9}' || true)"

bad_tcp=""
if [ -n "${tcp_rows}" ]; then
    while read -r cmd pid user name; do
        [ -z "${cmd:-}" ] || [ -z "${name:-}" ] && continue
        # Skip loopback/localhost
        if [[ "$name" =~ ^127\.0\.0\.1: ]] || [[ "$name" =~ ^localhost: ]] || [[ "$name" =~ ^\[::1\]: ]]; then
            continue
        fi
        port="${name##*:}"; port="${port%\]}"
        if proc_allowed "$cmd" || port_allowed "$port" "$ALLOW_TCP_PORTS"; then
            continue
        fi
        bad_tcp+="$cmd (pid $pid, user $user) -> TCP $name"$'\n'
    done <<< "$tcp_rows"
fi

# -------- host UDP listeners (bound to * / [::] / 0.0.0.0) ----------
say "🔎 Scanning host UDP sockets bound to all interfaces…"
udp_rows="$(lsof -nP -iUDP 2>/dev/null \
    | awk 'NR>1 {print $1, $2, $3, $9}' || true)"

bad_udp=""
if [ -n "${udp_rows}" ]; then
    while read -r cmd pid user name; do
        [ -z "${cmd:-}" ] || [ -z "${name:-}" ] && continue
        # Flag "*:PORT", "[::]:PORT", or "0.0.0.0:PORT"
        if [[ ! "$name" =~ ^\*\: ]] && [[ ! "$name" =~ ^\[::\]\: ]] && [[ ! "$name" =~ ^0\.0\.0\.0\: ]]; then
            continue
        fi
        port="${name##*:}"
        if proc_allowed "$cmd" || port_allowed "$port" "$ALLOW_UDP_PORTS"; then
            continue
        fi
        bad_udp+="$cmd (pid $pid, user $user) -> UDP $name"$'\n'
    done <<< "$udp_rows"
fi

# ------------------------------- results -----------------------------
echo
status=0
if [ -z "$bad_cfg" ] && [ -z "$bad_run" ] && [ -z "$bad_tcp" ] && [ -z "$bad_udp" ]; then
    say "✅ SAFE: Only allow-listed services are exposed; all other listeners are localhost-only."
else
    say "❌ ATTENTION: Found non-allowlisted exposures."
    [ -n "$bad_cfg" ] && say $'\n— Compose config (host binds not on 127.0.0.1/[::1]):' && say "$bad_cfg"
    [ -n "$bad_run" ] && say $'\n— Running containers (published on 0.0.0.0/:::):' && say "$bad_run"
    [ -n "$bad_tcp" ] && say $'\n— Host TCP listeners (not on localhost):' && say "$bad_tcp"
    [ -n "$bad_udp" ] && say $'\n— Host UDP sockets (bound to *:, [::]:, or 0.0.0.0:):' && say "$bad_udp"
    status=1
fi

echo
say "ℹ️ Effective allow-lists → Processes: ${ALLOW_PROCS:-<empty>} | TCP: ${ALLOW_TCP_PORTS:-<empty>} | UDP: ${ALLOW_UDP_PORTS:-<empty>}"
exit "$status"