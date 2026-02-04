---
name: pollinations-nanobanana
version: 1.1.0
description: AI image generation using Pollinations AI with NanoBanana model. Fast, high-quality images with customizable dimensions, seeds, and batch processing.
metadata: {"clawdbot":{"emoji":"🎨","requires":{"bins":["curl","jq"]}}}
---

# Pollinations NanoBanana - AI Image Generation

Generate stunning AI images using Pollinations AI's NanoBanana model. Fast generation (2-5 seconds), high quality, and fully customizable.

## Setup

### Step 1: Store API Key

Create the credentials file:
```bash
mkdir -p ~/.clawdbot/credentials/pollinations
echo '{"apiKey": "sk_tWcMDqeHEGycNG0NA6TJK34Lb3SdsZJl"}' > ~/.clawdbot/credentials/pollinations/config.json
```

### Step 2: Make Scripts Executable

```bash
chmod +x /root/clawd/skills/pollinations-flux/scripts/*.sh
```

## Usage

### Quick Generate (Simplest)

Generate an image with default settings (1024x1024):

```bash
bash /root/clawd/skills/pollinations-flux/scripts/quick-gen.sh "a futuristic cyberpunk city at sunset"
```

### Full Generate (All Options)

```bash
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "your prompt" [width] [height] [seed] [output_dir]
```

**Parameters:**
- `prompt` (required): Text description of the image
- `width` (optional): Image width in pixels (default: 1024)
- `height` (optional): Image height in pixels (default: 1024)
- `seed` (optional): Random seed for reproducibility (default: random)
- `output_dir` (optional): Where to save images (default: /root/clawd/output)

**Examples:**

```bash
# Basic generation
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "a majestic dragon flying over mountains"

# Custom size (portrait)
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "portrait of a warrior" 768 1024

# Specific seed for reproducibility
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "abstract art" 1024 1024 42

# Custom output directory
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "space station" 1024 1024 123 /home/user/images
```

### Batch Generation

Generate multiple images from a text file:

```bash
# Create prompts file
cat > prompts.txt << 'EOF'
a futuristic cityscape with neon lights
portrait of a cyberpunk samurai
abstract geometric patterns in blue and gold
underwater scene with bioluminescent creatures
steampunk airship floating above clouds
EOF

# Generate all
bash /root/clawd/skills/pollinations-flux/scripts/batch-gen.sh prompts.txt /root/clawd/output/my-batch
```

## Features

### Model: NanoBanana
- **Speed**: 2-5 seconds per image
- **Quality**: High-resolution, detailed outputs
- **Style**: Versatile - handles photorealistic, artistic, abstract, and more
- **Safety**: Disabled (safe=false) for unrestricted creativity
- **Enhancement**: Automatic prompt enhancement enabled

### Supported Dimensions
- Square: 512x512, 768x768, 1024x1024 (recommended)
- Portrait: 512x768, 768x1024, 1024x1536
- Landscape: 768x512, 1024x768, 1536x1024

### Output
- Format: PNG
- Location: Specified output directory or `/root/clawd/output/`
- Naming: `flux_{prompt}_{timestamp}.png`
- Media tag: Outputs include `MEDIA:` path for easy sharing

## API Reference

**Base URL:** `https://gen.pollinations.ai/image/{encoded_prompt}`

**Query Parameters:**
| Parameter | Default | Description |
|-----------|---------|-------------|
| `width` | 1024 | Image width in pixels |
| `height` | 1024 | Image height in pixels |
| `seed` | random | Seed for reproducible generation |
| `model` | nanobanana | Model to use (nanobanana) |
| `nologo` | true | Remove Pollinations watermark |
| `safe` | false | Disable safety filtering |
| `enhance` | true | Enable prompt enhancement |

**Headers:**
```
Authorization: Bearer {api_key}
Accept: image/png
```

## Examples

### Portrait
```bash
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "professional portrait of a woman with flowing red hair, studio lighting, 85mm lens" 768 1024
```

### Landscape
```bash
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "vast mountain range at golden hour, dramatic clouds, cinematic composition" 1536 1024
```

### Abstract
```bash
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "fractal patterns in neon colors, digital art, high detail, 8k" 1024 1024 1337
```

### Sci-Fi
```bash
bash /root/clawd/skills/pollinations-flux/scripts/generate.sh "alien planet surface with purple vegetation, two moons in sky, sci-fi concept art" 1024 1024
```

## Troubleshooting

### "API key not configured"
- Ensure `~/.clawdbot/credentials/pollinations/config.json` exists
- Verify JSON format: `{"apiKey": "your-key-here"}`
- Check file permissions: `chmod 600 ~/.clawdbot/credentials/pollinations/config.json`

### "Failed to generate image"
- Check internet connection
- Verify API key is valid
- Try again after a few seconds (rate limiting)
- Check if prompt is too long (keep under 500 characters)

### Rate Limits
- Free tier: ~10 requests/minute
- If limited, wait 60 seconds between batches

## Documentation

Full API docs: https://enter.pollinations.ai/api/docs

## Tips for Best Results

1. **Be Specific**: "a red sports car" → "a Ferrari F40 in Rosso Corsa, parked on a cobblestone street in Milan, golden hour lighting"

2. **Include Style**: Add "digital art", "photorealistic", "oil painting", "anime style", etc.

3. **Lighting Matters**: "studio lighting", "golden hour", "dramatic shadows", "soft diffused light"

4. **Use Seeds**: Same prompt + seed = same image (great for iterations)

5. **Aspect Ratio**: Match dimensions to content type:
   - Portraits: 768x1024 or 1024x1536
   - Landscapes: 1024x768 or 1536x1024
   - Social media: 1024x1024

## Integration with OpenClaw

When generating images, the script outputs:
```
MEDIA: /path/to/generated/image.png
```

This tag allows OpenClaw to automatically attach images to messages.

## Credits

- **Model**: NanoBanana (Pollinations)
- **API**: Pollinations AI
- **Documentation**: https://enter.pollinations.ai/api/docs
