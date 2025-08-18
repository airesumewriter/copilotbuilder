#!/bin/bash
set -e

# Config
VERSION="v0.11.4"
ARCHIVE="ollama-linux-arm64.tgz"
URL="https://github.com/ollama/ollama/releases/download/$VERSION/$ARCHIVE"
INSTALL_DIR="/usr/local/bin"
TMP_DIR="/tmp/ollama-install"

# Prep
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

echo "📦 Downloading Ollama $VERSION for ARM64..."
curl -LO "$URL"

echo "📂 Extracting..."
tar -xvzf "$ARCHIVE"

echo "🚀 Installing to $INSTALL_DIR..."
install -m 755 ollama "$INSTALL_DIR/ollama"

echo "✅ Verifying install..."
ollama --version || echo "⚠️ Ollama not found in PATH"

# Cleanup
rm -rf "$TMP_DIR"
echo "🎉 Done!"
