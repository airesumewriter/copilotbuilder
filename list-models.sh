#!/bin/bash
echo "🧠 Available models:"
curl -s http://localhost:11434/api/tags | jq -r '.models[].name'

