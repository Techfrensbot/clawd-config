#!/bin/bash
# Batch generate multiple images from a list of prompts
# Usage: batch-gen.sh prompts.txt

PROMPTS_FILE="${1:-}"
OUTPUT_DIR="${2:-/root/clawd/output/batch}"

if [ -z "$PROMPTS_FILE" ] || [ ! -f "$PROMPTS_FILE" ]; then
    echo "Usage: $0 prompts.txt [output_dir]"
    echo ""
    echo "File format (one prompt per line):"
    echo '  a futuristic cityscape'
    echo '  portrait of a cyberpunk warrior'
    echo '  abstract geometric art'
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINE_NUM=0
TOTAL=$(wc -l < "$PROMPTS_FILE")

echo "🎨 Batch generating $TOTAL images..."
echo "Output: $OUTPUT_DIR"
echo ""

while IFS= read -r prompt; do
    LINE_NUM=$((LINE_NUM + 1))
    
    # Skip empty lines and comments
    [[ -z "$prompt" || "$prompt" =~ ^[[:space:]]*# ]] && continue
    
    echo "[$LINE_NUM/$TOTAL] Generating: $prompt"
    bash "${SCRIPT_DIR}/generate.sh" "$prompt" 1024 1024 $((RANDOM + LINE_NUM)) "$OUTPUT_DIR"
    echo ""
    
    # Small delay to avoid rate limiting
    sleep 1
done < "$PROMPTS_FILE"

echo "✅ Batch complete! Generated images in: $OUTPUT_DIR"
