#!/bin/bash
# Quick image generation - simplified interface
# Usage: quick-gen.sh "prompt"

PROMPT="${1:-}"

if [ -z "$PROMPT" ]; then
    echo "Usage: quick-gen.sh \"your image prompt\""
    exit 1
fi

# Source the main script with defaults
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/generate.sh" "$PROMPT"
