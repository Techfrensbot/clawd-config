#!/bin/bash
# Pollinations AI Image Generator - Flux Schnell
# Fast, high-quality image generation via Pollinations API

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDENTIALS_FILE="${HOME}/.clawdbot/credentials/pollinations/config.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for API key
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo -e "${RED}Error: Pollinations API key not configured${NC}"
    echo "Create: ${CREDENTIALS_FILE}"
    echo 'Content: {"apiKey": "your-api-key"}'
    exit 1
fi

API_KEY=$(jq -r '.apiKey' "$CREDENTIALS_FILE" 2>/dev/null || echo "")

if [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ] || [ "$API_KEY" = "your-api-key" ]; then
    echo -e "${RED}Error: Invalid API key in ${CREDENTIALS_FILE}${NC}"
    exit 1
fi

# Parse arguments
PROMPT="${1:-}"
WIDTH="${2:-1024}"
HEIGHT="${3:-1024}"
SEED="${4:-$(date +%s)}"
OUTPUT_DIR="${5:-/root/clawd/output}"

if [ -z "$PROMPT" ]; then
    echo "Usage: $0 \"your image prompt\" [width] [height] [seed] [output_dir]"
    echo ""
    echo "Examples:"
    echo "  $0 \"a futuristic city at sunset\""
    echo "  $0 \"portrait of a cyberpunk warrior\" 1024 1024 42"
    echo "  $0 \"abstract geometric patterns\" 512 768 123 /custom/path"
    exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# URL encode the prompt (basic)
ENCODED_PROMPT=$(echo "$PROMPT" | sed 's/ /%20/g; s/!/%21/g; s/#/%23/g; s/\$/%24/g; s/&/%26/g; s/\*/%2A/g; s/(/%28/g; s/)/%29/g; s/\[/%5B/g; s/\]/%5D/g; s/,/%2C/g')

# Construct API URL (using gen.pollinations.ai endpoint)
API_URL="https://gen.pollinations.ai/image/${ENCODED_PROMPT}?width=${WIDTH}&height=${HEIGHT}&seed=${SEED}&nologo=true&model=nanobanana&safe=false&enhance=true&private=true"

# Generate filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SAFE_PROMPT=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | sed 's/[^a-z0-9_-]//g' | cut -c1-50)
OUTPUT_FILE="${OUTPUT_DIR}/flux_${SAFE_PROMPT}_${TIMESTAMP}.png"

echo -e "${YELLOW}🎨 Generating image with Flux Schnell...${NC}"
echo "Prompt: $PROMPT"
echo "Size: ${WIDTH}x${HEIGHT}"
echo "Seed: $SEED"
echo ""

# Download image with Authorization header
echo "⏳ Waiting for generation (typically 2-5 seconds)..."
if curl -s -L \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Accept: image/png" \
    --max-time 60 \
    "$API_URL" \
    -o "$OUTPUT_FILE"; then
    
    # Verify the file was created and is a valid image
    if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
        FILESIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
        echo -e "${GREEN}✅ Image generated successfully!${NC}"
        echo ""
        echo "📁 Saved: ${OUTPUT_FILE}"
        echo "📊 Size: ${FILESIZE}"
        echo "🔗 API URL: ${API_URL}"
        echo ""
        echo "MEDIA: ${OUTPUT_FILE}"
    else
        echo -e "${RED}❌ Error: Generated file is empty or invalid${NC}"
        rm -f "$OUTPUT_FILE"
        exit 1
    fi
else
    echo -e "${RED}❌ Error: Failed to generate image${NC}"
    rm -f "$OUTPUT_FILE"
    exit 1
fi
