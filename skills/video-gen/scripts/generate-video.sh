#!/bin/bash
# Video Generation Skill using Airforce API
# Model: grok-imagine-video
# Requires: AIRFORCE_API_KEY in environment

set -e

PROMPT="${1:-A robot walking through a cyberpunk city}"
OUTPUT_DIR="${2:-/root/clawd/output}"
SIZE="${3:-1024x1024}"
ASPECT_RATIO="${4:-3:2}"

# Load API key from secure storage
if [ -f ~/.config/airforce/credentials.json ]; then
    API_KEY=$(jq -r '.api_key' ~/.config/airforce/credentials.json)
else
    echo "Error: Airforce API key not found in ~/.config/airforce/credentials.json"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
DATE=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/video_${DATE}.mp4"

echo "🎬 Generating video..."
echo "Prompt: ${PROMPT}"
echo "Size: ${SIZE}"
echo "Aspect Ratio: ${ASPECT_RATIO}"

# Call Airforce API
JSON_PAYLOAD=$(cat <<EOF
{
  "model": "grok-imagine-video",
  "prompt": "${PROMPT}",
  "n": 1,
  "size": "${SIZE}",
  "response_format": "url",
  "mode": "normal",
  "aspectRatio": "${ASPECT_RATIO}"
}
EOF
)

echo "⏳ Submitting video generation request..."
RESPONSE=$(curl -s -X POST "https://api.airforce/v1/images/generations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")

# Check for errors
ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // empty')
if [ -n "$ERROR_MSG" ]; then
    echo "❌ API Error: $ERROR_MSG"
    exit 1
fi

# Extract video URL
VIDEO_URL=$(echo "$RESPONSE" | jq -r '.data[0].url // empty')

if [ -z "$VIDEO_URL" ] || [ "$VIDEO_URL" = "null" ]; then
    echo "⚠️ Video is being processed asynchronously."
    echo "Response: $RESPONSE"
    echo ""
    echo "Note: Video generation may take 1-5 minutes. The API returns empty data for async processing."
    echo "Try checking the API dashboard or retrying with the same prompt to get the completed video."
    exit 0
fi

# Download video
echo "⬇️ Downloading video..."
curl -sL "$VIDEO_URL" -o "$OUTPUT_FILE"

# Verify file
FILESIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null || echo 0)

if [ "$FILESIZE" -gt 1000 ]; then
    echo "✅ Video generated successfully!"
    echo "📁 Saved: ${OUTPUT_FILE}"
    echo "📊 Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
    echo ""
    echo "MEDIA: ${OUTPUT_FILE}"
else
    echo "❌ Error: Downloaded file is too small or empty"
    rm -f "$OUTPUT_FILE"
    exit 1
fi
