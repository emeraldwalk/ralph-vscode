#!/bin/bash
# pb-dev.sh: Start PocketBase dev server (kills existing instance first)
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../../.."
ENV_FILE="$ROOT_DIR/pb/.env"

if [ -f "$ENV_FILE" ]; then
  set -a; source "$ENV_FILE"; set +a
fi
PORT="${PB_PORT:-8090}"

# Kill existing instance
PID=$(lsof -ti :"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then
  echo "Stopping PocketBase on port $PORT (PID: $PID)"
  kill "$PID" 2>/dev/null || true
  sleep 1
fi

# Start server
echo "Starting PocketBase on port $PORT..."
cd "$ROOT_DIR/pb"
exec go run . serve --http="127.0.0.1:$PORT"
