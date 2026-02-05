#!/usr/bin/env python3
"""
Pocket TTS Audio Generator
Text-to-speech generator using Revanth_12's Pocket TTS API
Triggered when someone says "make audio pls" or similar

Author: Revanth_12
API Key: sk-pocket-8x7Kd2Pq9WmN5vLcR3tY6zFjH4bG1aE0
API Docs: http://216.9.224.204:8000/docs
"""

import requests
import sys
import os
from pathlib import Path

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
        Path to generated audio file
    """
    # Create output directory if it doesn't exist
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Generate output filename if not provided
    if output_filename is None:
        # Create filename based on timestamp
        from datetime import datetime
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_filename = f"tts_{timestamp}.wav"

    output_path = OUTPUT_DIR / output_filename

    try:
        # Make API request
        headers = {
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json"
        }

        # Try different endpoint patterns
        endpoints = [
            f"{API_BASE_URL}/api/generate",
            f"{API_BASE_URL}/api/tts",
            f"{API_BASE_URL}/api/synthesize",
            f"{API_BASE_URL}/tts",
        ]

        for endpoint in endpoints:
            try:
                response = requests.post(
                    endpoint,
                    json={"text": text},
                    headers=headers,
                    timeout=30
                )

                if response.status_code == 200:
                    # Save audio response
                    audio_content = response.content

                    # Check if it's JSON with audio data or direct binary
                    content_type = response.headers.get('content-type', '')

                    if 'application/json' in content_type:
                        # Try to parse as JSON and extract audio
                        data = response.json()
                        if 'audio' in data:
                            # Write base64 or binary audio data
                            import base64
                            if isinstance(data['audio'], str):
                                audio_content = base64.b64decode(data['audio'])
                            else:
                                audio_content = data['audio']
                        elif 'url' in data:
                            # Download from returned URL
                            audio_url = data['url']
                            audio_response = requests.get(audio_url, timeout=30)
                            audio_content = audio_response.content
                            output_filename = Path(audio_url).name
                    else:
                        # Direct binary audio response
                        audio_content = response.content

                    # Write audio to file
                    with open(output_path, 'wb') as f:
                        f.write(audio_content)

                    print(f"✅ Audio generated successfully: {output_path}")
                    return str(output_path)

                elif response.status_code == 401:
                    print(f"❌ Unauthorized: Check API key")
                    continue
                else:
                    print(f"❌ API returned status {response.status_code}: {response.text}")
                    continue

            except requests.exceptions.RequestException as e:
                print(f"❌ Error connecting to {endpoint}: {e}")
                continue

        print(f"❌ All endpoints failed to generate audio")
        return None

    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return None

def list_triggers():
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
    ]
    print("🎤 Triggers that activate this script:")
    for trigger in triggers:
        print(f"  • '{trigger}'")
    print("💡 Usage: python pocket_tts.py 'your text here'")

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
        list_triggers()
        sys.exit(1)
