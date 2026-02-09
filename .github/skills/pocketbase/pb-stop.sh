#!/bin/bash
# pb-stop.sh: Kill any existing PocketBase instance on the configured port
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../../.."
ENV_FILE="$ROOT_DIR/pb/.env"

if [ -f "$ENV_FILE" ]; then
  set -a; source "$ENV_FILE"; set +a
fi
PORT="${PB_PORT:-8090}"

PID=$(lsof -ti :"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then
  echo "Stopping PocketBase on port $PORT (PID: $PID)"
  kill "$PID" 2>/dev/null || true
  sleep 1
fi
