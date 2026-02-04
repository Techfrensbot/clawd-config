---
name: video-gen
description: AI video generation using Airforce API (grok-imagine-video model)
author: Sai_revanth_12 (community contribution)
---

# Video Generation Skill

Generate AI videos from text prompts using the Airforce API with Grok's video model.

## Usage

```bash
# Basic usage
bash /root/clawd/skills/video-gen/scripts/generate-video.sh "prompt here"

# With all options
bash /root/clawd/skills/video-gen/scripts/generate-video.sh "prompt" "/output/dir" "1024x1024" "16:9"
```

## Parameters

1. **prompt** (required): Text description of the video
2. **output_dir** (optional): Where to save the video (default: /root/clawd/output)
3. **size** (optional): Resolution (default: 1024x1024)
4. **aspect_ratio** (optional): Aspect ratio (default: 3:2)

## API Key Storage

API key is stored securely at:
- Path: `~/.config/airforce/credentials.json`
- Permissions: 600 (owner read/write only)
- Format: `{"api_key": "..."}`

## Examples

```bash
# Cyberpunk robot walking
bash /root/clawd/skills/video-gen/scripts/generate-video.sh "A cyberpunk robot walking through neon-lit Tokyo streets at night"

# Space scene
bash /root/clawd/skills/video-gen/scripts/generate-video.sh "An astronaut floating in space with Earth in background" "/tmp/videos" "1024x1024" "16:9"
```

## Integration with OpenClaw

To use in cron jobs or agents:
```bash
export AIRFORCE_API_KEY=$(jq -r '.api_key' ~/.config/airforce/credentials.json)
bash /root/clawd/skills/video-gen/scripts/generate-video.sh "Breaking AI news: robots learn to dance"
```

## Notes

- Video generation takes 30-120 seconds depending on complexity
- API uses SSE (Server-Sent Events) for progress updates
- Output format: MP4
- Model: grok-imagine-video
