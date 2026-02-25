#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/.config/conky"
PROJECTS=(icon datetime signature fetch music)

CAVA_FILE="$HOME/cava.txt"
CACHE_DIR="$HOME/.cache"
CAVA_PID_FILE="$CACHE_DIR/conky-cava.pid"
CAVA_CONFIG="${CAVA_CONFIG:-$HOME/.config/cava/config}"
CAVA_ERR_LOG="${CAVA_ERR_LOG:-$CACHE_DIR/cava.err.log}"

mkdir -p "$CACHE_DIR"

stop_existing_cava_writer() {
  if [[ -f "$CAVA_PID_FILE" ]]; then
    local old_pid
    old_pid="$(cat "$CAVA_PID_FILE" 2>/dev/null || true)"
    if [[ -n "${old_pid:-}" ]]; then
      kill "$old_pid" 2>/dev/null || true
    fi
    rm -f "$CAVA_PID_FILE"
  fi

  pkill -x cava 2>/dev/null || true
  pkill -f "conky-cava-writer" 2>/dev/null || true
}

start_cava_writer() {
  : > "$CAVA_FILE"
  (
    exec -a conky-cava-writer bash -c '
      set +e
      while true; do
        if [[ -f "$1" ]]; then
          stdbuf -oL -eL cava -p "$1" 2>>"$2"
        else
          stdbuf -oL -eL cava 2>>"$2"
        fi | while IFS= read -r line; do
          printf "%s\n" "$line" > "$3"
        done

        cava_status=${PIPESTATUS[0]}
        printf "[%s] cava exited (status=%s), restarting in 1s\n" "$(date "+%F %T")" "$cava_status" >> "$2"
        sleep 1
      done
    ' -- "$CAVA_CONFIG" "$CAVA_ERR_LOG" "$CAVA_FILE"
  ) &
  echo $! > "$CAVA_PID_FILE"
}

restart_conky_instances() {
  local p
  for p in "${PROJECTS[@]}"; do
    pkill -f "conky .*${BASE}/${p}/conky.conf" 2>/dev/null || true
  done

  for p in "${PROJECTS[@]}"; do
    conky -c "${BASE}/${p}/conky.conf" -d
  done
}

stop_existing_cava_writer
start_cava_writer
restart_conky_instances

echo "Started Conky instances: ${PROJECTS[*]}"
