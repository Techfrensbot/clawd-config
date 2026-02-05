#!/usr/bin/env python3
"""
Pocket TTS Audio Generator - Enhanced Version
Text-to-speech generator using Revanth_12's Pocket TTS API
Auto-detects and handles API structure

API: http://216.9.224.204:8000
Key: sk-pocket-8x7Kd2Pq9WmN5vLcR3tY6zFjH4bG1aE0
"""

import requests
import sys
import os
from pathlib import Path
from datetime import datetime

# Configuration
API_BASE_URL = "http://216.9.224.204:8000"
API_KEY = "sk-pocket-8x7Kd2Pq9WmN5vLcR3tY6zFjH4bG1aE0"
OUTPUT_DIR = Path.home() / "tts_output"

def generate_audio(text: str, output_filename: str = None) -> str:
    """
    Generate audio from text using Pocket TTS API

    Args:
        text: Text to convert to speech
        output_filename: Optional custom output filename

    Returns:
        Path to generated audio file, or None if failed
    """
    # Create output directory if it doesn't exist
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Generate output filename if not provided
    if output_filename is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_filename = f"tts_{timestamp}.wav"

    output_path = OUTPUT_DIR / output_filename

    try:
        # Try different request formats and endpoints
        request_formats = [
            # Format 1: JSON with 'text' field
            {
                "url": f"{API_BASE_URL}/api/tts/generate",
                "headers": {
                    "Authorization": f"Bearer {API_KEY}",
                    "Content-Type": "application/json"
                },
                "json": {"text": text}
            },
            # Format 2: JSON with 'input' field
            {
                "url": f"{API_BASE_URL}/api/generate",
                "headers": {
                    "Authorization": f"Bearer {API_KEY}",
                    "Content-Type": "application/json"
                },
                "json": {"input": text}
            },
            # Format 3: JSON with 'content' field
            {
                "url": f"{API_BASE_URL}/api/synthesize",
                "headers": {
                    "Authorization": f"Bearer {API_KEY}",
                    "Content-Type": "application/json"
                },
                "json": {"content": text}
            },
            # Format 4: Form data
            {
                "url": f"{API_BASE_URL}/tts",
                "headers": {
                    "Authorization": f"Bearer {API_KEY}"
                },
                "data": {"text": text}
            },
            # Format 5: Query parameter
            {
                "url": f"{API_BASE_URL}/speak",
                "headers": {
                    "Authorization": f"Bearer {API_KEY}"
                },
                "params": {"text": text}
            },
        ]

        for i, config in enumerate(request_formats, 1):
            try:
                response = requests.post(
                    config["url"],
                    json=config.get("json", None),
                    data=config.get("data", None),
                    params=config.get("params", None),
                    headers=config["headers"],
                    timeout=30
                )

                if response.status_code == 200:
                    # Save audio response
                    audio_content = response.content
                    content_type = response.headers.get('content-type', '')

                    # Save to file
                    with open(output_path, 'wb') as f:
                        f.write(audio_content)

                    print(f"✅ Audio generated successfully: {output_path}")
                    print(f"📡 Used endpoint: {config['url'].split('/')[-1]}")
                    print(f"🎯 Attempt {i} of {len(request_formats)} succeeded!")
                    return str(output_path)

                elif response.status_code == 401:
                    print(f"❌ Unauthorized: Check API key")
                elif response.status_code == 404:
                    print(f"❌ Endpoint not found: {config['url'].split('/')[-1]}")
                elif response.status_code == 422:
                    print(f"❌ Validation error: {response.text}")
                else:
                    print(f"❌ Attempt {i}: Status {response.status_code} - {response.text[:100]}")

            except requests.exceptions.RequestException as e:
                print(f"❌ Attempt {i}: Error - {str(e)[:100]}")

        print(f"❌ All {len(request_formats)} request formats failed")
        return None

    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return None

def show_triggers():
    """Print trigger phrases that activate this script"""
    triggers = [
        "make audio",
        "make audio pls",
        "generate audio",
        "text to speech",
        "tts",
        "speak",
        "say this",
        "audio please",
        "pocket tts",
    ]
    print("🎤 Triggers that activate this script:")
    for trigger in triggers:
        print(f"  • '{trigger}'")
    print("💡 Usage: python pocket_tts_enhanced.py 'your text here'")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Get text from command line
        text = " ".join(sys.argv[1:])

        # Generate audio
        result = generate_audio(text)

        if result:
            print(f"🎵 Audio file: {result}")
    else:
        # Show usage
        print("❌ No text provided")
        show_triggers()
        sys.exit(1)
