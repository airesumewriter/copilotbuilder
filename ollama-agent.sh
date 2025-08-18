#!/bin/bash

# Modular Ollama Agent
MODEL="${1:-tinyllama}"
PROMPT="${2:-"Hello, world!"}"

# Optional: Live preview (requires gum)
if command -v gum >/dev/null; then
  PROMPT=$(gum input --placeholder "Enter your prompt")
fi

# Check if Ollama is running
if curl --fail -s http://localhost:11434/health >/dev/null; then
  echo "🧠 Using local model: $MODEL"
  curl -s http://localhost:11434/api/generate -d '{
    "model": "'"$MODEL"'",
    "prompt": "'"$PROMPT"'"
  }' | jq -r '.response'
else
  echo "🌐 Fallback: Remote API not configured yet"
  # You can add remote fallback here
fi

