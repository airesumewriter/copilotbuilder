#!/data/data/com.termux/files/usr/bin/bash
set -e

URL="https://github.com/ollama/ollama/releases/download/v0.11.4/ollama-linux-arm64.tgz"
TARGET="$HOME/storage/shared/ollama-linux-arm64.tgz"

echo "📦 Downloading Ollama binary to shared storage..."
wget -c "$URL" -O "$TARGET"

echo "✅ Download complete: $TARGET"
file "$TARGET"
ls -lh "$TARGET"

