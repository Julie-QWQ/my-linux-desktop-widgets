#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/.config/conky"
PROJECTS=(icon datetime signature fetch music)
CAVA_PID_FILE="$HOME/.cache/conky-cava.pid"
CAVA_TMP_FILE="$HOME/.cache/cava.latest.tmp"

for p in "${PROJECTS[@]}"; do
  pkill -f "conky .*${BASE}/${p}/conky.conf" 2>/dev/null || true
done

if [[ -f "$CAVA_PID_FILE" ]]; then
  cava_pid="$(cat "$CAVA_PID_FILE" 2>/dev/null || true)"
  if [[ -n "${cava_pid:-}" ]]; then
    kill "$cava_pid" 2>/dev/null || true
  fi
  rm -f "$CAVA_PID_FILE"
fi

pkill -x cava 2>/dev/null || true
pkill -f "conky-cava-writer" 2>/dev/null || true
rm -f "$CAVA_TMP_FILE"

echo "Stopped Conky instances: ${PROJECTS[*]}"
