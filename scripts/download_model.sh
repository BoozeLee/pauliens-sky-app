#!/usr/bin/env bash
# Download a recommended GGUF model for AETHER local AI
# Usage: bash scripts/download_model.sh [phi3-mini|mistral-7b|gemma-2b]

set -euo pipefail

MODEL=${1:-phi3-mini}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELS_DIR="$HOME/.local/share/pauliens_sky/models"
mkdir -p "$MODELS_DIR"

case "$MODEL" in
  phi3-mini)
    URL="https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"
    FNAME="phi-3-mini-4k-instruct.Q4_K_M.gguf"
    SIZE="2.2GB"
    ;;
  mistral-7b)
    URL="https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
    FNAME="mistral-7b-instruct-v0.3.Q4_K_M.gguf"
    SIZE="4.1GB"
    ;;
  gemma-2b)
    URL="https://huggingface.co/google/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf"
    FNAME="gemma-2-2b-it-Q4_K_M.gguf"
    SIZE="1.6GB"
    ;;
  *)
    echo "Unknown model: $MODEL"
    echo "Available: phi3-mini, mistral-7b, gemma-2b"
    exit 1
    ;;
esac

DEST="$MODELS_DIR/$FNAME"

if [ -f "$DEST" ]; then
    echo "✓ Model already downloaded: $DEST"
    exit 0
fi

echo "Downloading $MODEL ($SIZE)..."
echo "Destination: $DEST"
echo "Source: $URL"
echo ""

if command -v aria2c &>/dev/null; then
    aria2c -x16 -s16 --continue=true -d "$MODELS_DIR" -o "$FNAME" "$URL"
elif command -v wget &>/dev/null; then
    wget --continue -O "$DEST" "$URL"
else
    curl -L --progress-bar -C - -o "$DEST" "$URL"
fi

echo ""
echo "✓ Downloaded: $DEST ($(du -sh "$DEST" | cut -f1))"
echo ""
echo "Launch the app and go to Settings → AETHER Local AI → Select Model"
