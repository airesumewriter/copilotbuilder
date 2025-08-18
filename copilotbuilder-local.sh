#!/bin/bash
PROMPT="$*"
echo "🧠 [Local] Prompt received: $PROMPT"
ollama run llama3 "$PROMPT"
