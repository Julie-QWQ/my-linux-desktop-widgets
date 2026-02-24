#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/.config/conky"
PROJECTS=(icon datetime signature fetch music)
CAVA_FILE="$HOME/cava.txt"
CAVA_TMP_FILE="$HOME/.cache/cava.latest.tmp"
CAVA_PID_FILE="$HOME/.cache/conky-cava.pid"

mkdir -p "$(dirname "$CAVA_PID_FILE")"

# stop previously managed cava pipeline if any
if [[ -f "$CAVA_PID_FILE" ]]; then
  old_pid="$(cat "$CAVA_PID_FILE" 2>/dev/null || true)"
  if [[ -n "${old_pid:-}" ]]; then
    kill "$old_pid" 2>/dev/null || true
  fi
  rm -f "$CAVA_PID_FILE"
fi

# avoid duplicate cava producers
pkill -x cava 2>/dev/null || true
pkill -f "conky-cava-writer" 2>/dev/null || true

# keep only the latest cava line in file (overwrite on each frame)
: > "$CAVA_FILE"
bash -c '
  exec -a conky-cava-writer stdbuf -oL cava 2>/dev/null | \
  while IFS= read -r line; do
    printf "%s\n" "$line" > "'"$CAVA_TMP_FILE"'"
    mv -f "'"$CAVA_TMP_FILE"'" "'"$CAVA_FILE"'"
  done
' >/dev/null 2>&1 &
echo $! > "$CAVA_PID_FILE"

for p in "${PROJECTS[@]}"; do
  pkill -f "conky .*${BASE}/${p}/conky.conf" 2>/dev/null || true
done

for p in "${PROJECTS[@]}"; do
  conky -c "${BASE}/${p}/conky.conf" -d
done

echo "Started Conky instances: ${PROJECTS[*]}"
