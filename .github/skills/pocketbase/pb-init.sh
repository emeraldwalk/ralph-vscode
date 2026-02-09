#!/bin/bash
# pb-init.sh: Initialize Go module and install dependencies for PocketBase
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../../.."
PB_DIR="$ROOT_DIR/pb"

if [ ! -d "$PB_DIR" ]; then
  echo "Error: pb/ directory not found at $PB_DIR"
  exit 1
fi

MODULE_NAME="${1:-}"
cd "$PB_DIR"

if [ ! -f "go.mod" ]; then
  if [ -z "$MODULE_NAME" ]; then
    echo "Error: go.mod does not exist and no module name provided."
    echo "Usage: bash .github/skills/pocketbase/pb-init.sh <module-name>"
    exit 1
  fi
  echo "Initializing Go module: $MODULE_NAME"
  go mod init "$MODULE_NAME"
else
  echo "go.mod already exists, skipping init."
fi

echo "Running go mod tidy..."
go mod tidy
echo "Done."
