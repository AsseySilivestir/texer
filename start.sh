#!/usr/bin/env bash
# Launch the Bantu web app on http://localhost:${PORT:-8080}.
set -eu
cd "$(dirname "$0")"

# Find the bantu binary: prefer ./bantu (project-local), else PATH.
BANTU="./bantu"
if [[ ! -x "$BANTU" ]]; then
    if command -v bantu >/dev/null 2>&1; then
        BANTU="bantu"
    else
        echo "bantu binary not found."
        echo "  Either place a 'bantu' binary in this folder, or install it system-wide."
        exit 1
    fi
fi

export PORT="${PORT:-8080}"
echo "Starting on http://localhost:${PORT}"
exec "$BANTU" run main.b
