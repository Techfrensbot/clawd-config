#!/bin/bash
# AI News Visual Summary Generator v3.0 - Fixed timeout and retry logic
# Generates a professional news headline graphic with Tech Friend branding

set -e

NEWS_SUMMARY="${1:-}"
OUTPUT_DIR="${2:-/root/clawd/output}"
DATE=$(date +%Y%m%d_%H%M%S)

if [ -z "$NEWS_SUMMARY" ]; then
    echo "Usage: $0 \"news summary text\" [output_dir]"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${OUTPUT_DIR}/ai_news_visual_${DATE}.png"

# Simplified prompt for better reliability - Tech Friend branded
PROMPT="Breaking AI news headline graphic. ${NEWS_SUMMARY}. Dark background, neon purple and teal accents, Tech Friend branded, professional graphic design, bold text, high contrast, clean layout, tech news aesthetic"

# URL encode the prompt
ENCODED_PROMPT=$(echo "$PROMPT" | sed 's/ /%20/g; s/!/%21/g; s/#/%23/g; s/\$/%24/g; s/&/%26/g; s/\*/%2A/g; s/(/%28/g; s/)/%29/g; s/\[/%5B/g; s/\]/%5D/g; s/,/%2C/g; s/:/%3A/g; s/"/%22/g; s/\n/%20/g')

# API URL - using 1280x720 for faster generation
API_URL="https://gen.pollinations.ai/image/${ENCODED_PROMPT}?width=1280&height=720&seed=${RANDOM}&nologo=true&model=nanobanana&safe=false&enhance=true"

echo "🎨 Generating AI News Visual..."
echo "Prompt: ${NEWS_SUMMARY:0:60}..."
echo "Output: ${OUTPUT_FILE}"
echo ""

# Try generation with retries
MAX_RETRIES=3
RETRY_COUNT=0
SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$SUCCESS" = false ]; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "⏳ Attempt $RETRY_COUNT/$MAX_RETRIES (timeout: 180s)..."
    
    if timeout 180 curl -s -L \
        -H "Authorization: Bearer sk_tWcMDqeHEGycNG0NA6TJK34Lb3SdsZJl" \
        -H "Accept: image/png" \
        "$API_URL" \
        -o "$OUTPUT_FILE" 2>/dev/null; then
        
        # Check file size
        FILESIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo 0)
        
        if [ "$FILESIZE" -gt 10000 ]; then
            echo "✅ Success! Generated ${FILESIZE} bytes"
            SUCCESS=true
        else
            echo "⚠️ File too small (${FILESIZE} bytes), retrying..."
            rm -f "$OUTPUT_FILE"
            sleep 5
        fi
    else
        echo "⚠️ Timeout or error, retrying..."
        rm -f "$OUTPUT_FILE"
        sleep 5
    fi
done

if [ "$SUCCESS" = true ]; then
    HUMAN_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
    echo ""
    echo "📁 Saved: ${OUTPUT_FILE}"
    echo "📊 Size: ${HUMAN_SIZE}"
    echo "MEDIA: ${OUTPUT_FILE}"
    exit 0
else
    echo "❌ Failed after $MAX_RETRIES attempts"
    exit 1
fi
