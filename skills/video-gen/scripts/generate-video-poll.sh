#!/bin/bash
# Video Generation Skill with Polling - Airforce API
# Handles async video generation and returns the final video URL

set -e

PROMPT="${1:-A robot walking through a cyberpunk city}"
OUTPUT_DIR="${2:-/root/clawd/output}"
SIZE="${3:-1024x1024}"
ASPECT_RATIO="${4:-3:2}"
MAX_WAIT_MINUTES="${5:-10}"

# Load API key from secure storage
if [ -f ~/.config/airforce/credentials.json ]; then
    API_KEY=$(jq -r '.api_key' ~/.config/airforce/credentials.json)
else
    echo "❌ Error: Airforce API key not found in ~/.config/airforce/credentials.json"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
DATE=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/video_${DATE}.mp4"

echo "🎬 Video Generation with Polling"
echo "================================"
echo "Prompt: ${PROMPT}"
echo "Size: ${SIZE}"
echo "Aspect Ratio: ${ASPECT_RATIO}"
echo "Max Wait: ${MAX_WAIT_MINUTES} minutes"
echo ""

# Submit video generation request
echo "📤 Submitting request..."
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

RESPONSE=$(curl -s -X POST "https://api.airforce/v1/images/generations" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")

# Check for immediate errors
ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // empty')
if [ -n "$ERROR_MSG" ]; then
    echo "❌ API Error: $ERROR_MSG"
    exit 1
fi

# Check if video URL is immediately available
VIDEO_URL=$(echo "$RESPONSE" | jq -r '.data[0].url // empty')

if [ -n "$VIDEO_URL" ] && [ "$VIDEO_URL" != "null" ]; then
    echo "✅ Video URL received immediately!"
    echo ""
    echo "🔗 Video URL: ${VIDEO_URL}"
    
    # Download the video
    echo "⬇️ Downloading video..."
    curl -sL "$VIDEO_URL" -o "$OUTPUT_FILE"
    
    FILESIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null || echo 0)
    
    if [ "$FILESIZE" -gt 1000 ]; then
        echo "✅ Downloaded: $(du -h "$OUTPUT_FILE" | cut -f1)"
        echo "📁 File: ${OUTPUT_FILE}"
        echo ""
        echo "MEDIA: ${OUTPUT_FILE}"
    else
        echo "⚠️ Warning: Downloaded file seems small, but URL is: ${VIDEO_URL}"
    fi
    exit 0
fi

# Video is processing asynchronously - poll for completion
echo "⏳ Video is processing asynchronously..."
echo "🔄 Polling for completion (checking every 30 seconds)..."
echo ""

SECONDS_WAITED=0
MAX_SECONDS=$((MAX_WAIT_MINUTES * 60))

while [ $SECONDS_WAITED -lt $MAX_SECONDS ]; do
    sleep 30
    SECONDS_WAITED=$((SECONDS_WAITED + 30))
    
    MINUTES=$((SECONDS_WAITED / 60))
    SECS=$((SECONDS_WAITED % 60))
    
    echo "⏱️  Waiting... (${MINUTES}m ${SECS}s elapsed)"
    
    # Retry same request to check status
    RESPONSE=$(curl -s -X POST "https://api.airforce/v1/images/generations" \
      -H "Authorization: Bearer ${API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$JSON_PAYLOAD")
    
    VIDEO_URL=$(echo "$RESPONSE" | jq -r '.data[0].url // empty')
    
    if [ -n "$VIDEO_URL" ] && [ "$VIDEO_URL" != "null" ]; then
        echo ""
        echo "✅ Video is ready!"
        echo ""
        echo "🔗 Video URL: ${VIDEO_URL}"
        echo ""
        
        # Download the video
        echo "⬇️ Downloading video..."
        curl -sL "$VIDEO_URL" -o "$OUTPUT_FILE"
        
        FILESIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null || echo 0)
        
        if [ "$FILESIZE" -gt 1000 ]; then
            echo "✅ Downloaded: $(du -h "$OUTPUT_FILE" | cut -f1)"
            echo "📁 File: ${OUTPUT_FILE}"
            echo ""
            echo "MEDIA: ${OUTPUT_FILE}"
        else
            echo "⚠️ Warning: Downloaded file seems small"
            echo "🔗 Direct URL: ${VIDEO_URL}"
        fi
        exit 0
    fi
done

echo ""
echo "⏰ Timeout after ${MAX_WAIT_MINUTES} minutes"
echo "The video is still processing. Try again later with the same prompt."
echo "You can also check your Airforce API dashboard for status."
exit 1
