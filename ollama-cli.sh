#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS] [PROMPT]

Options:
  --model MODEL        select model (default: ollama)
  --fallback MODEL     override fallback model
  --stream             enable streaming
  --log                enable logging to default file
  --logfile PATH       write JSONL events to PATH
  --json               output raw JSON instead of text
  --verbose            print payload and model info
  --debug              show curl/jq internals
  --help               display this help message
EOF
}

parse_args() {
  MODEL="ollama"
  FALLBACK=""
  STREAM=false
  LOGGING=false
  LOGFILE="./ollama-metrics.jsonl"
  OUTPUT_FORMAT="text"
  VERBOSE=false
  DEBUG=false
  PROMPT=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model)     MODEL="$2";       shift 2 ;;
      --fallback)  FALLBACK="$2";    shift 2 ;;
      --stream)    STREAM=true;      shift   ;;
      --log)       LOGGING=true;     shift   ;;
      --logfile)   LOGFILE="$2";     shift 2 ;;
      --json)      OUTPUT_FORMAT="json"; shift ;;
      --verbose)   VERBOSE=true;     shift   ;;
      --debug)     DEBUG=true;       shift   ;;
      --help)      show_help; exit 0 ;;
      --*)         echo "Unknown option: $1"; show_help; exit 1 ;;
      *)           # first non-flag is the prompt
                   PROMPT="$*"; break ;;
    esac
  done
}

# Invoke parser on all args
parse_args "$@"

# ──────────────────────────────────────────────────────────────────────────────
# Main logic: API call, fallback, logging, output
# ──────────────────────────────────────────────────────────────────────────────

# 1. Make sure we have a prompt
if [[ -z "$PROMPT" ]]; then
  echo "Error: no prompt provided."
  show_help
  exit 1
fi

# 2. Build curl base args
CURL_ARGS=(-sS)  # silent + show errors
CURL_HEADERS=(-H "Model: $MODEL")
if [[ $STREAM == true ]]; then
  CURL_ARGS+=(--no-buffer)
fi

# 3. Try primary model
RESPONSE=""
if RESPONSE=$(curl "${CURL_ARGS[@]}" "${CURL_HEADERS[@]}" \
     -d "{\"prompt\":\"$PROMPT\"}" https://api.your-llm-endpoint/v1/complete); then
  FALLBACK_USED=false
else
  # 4. Primary failed → fallback
  if [[ -n "$FALLBACK" ]]; then
    >&2 echo "⚠️ Primary model failed. Retrying with fallback: $FALLBACK"
    RESPONSE=$(curl "${CURL_ARGS[@]}" -H "Model: $FALLBACK" \
      -d "{\"prompt\":\"$PROMPT\"}" https://api.your-llm-endpoint/v1/complete)
    FALLBACK_USED=true
  else
    >&2 echo "❌ Primary model failed and no fallback configured."
    exit 1
  fi
fi

# 5. Logging to JSONL (if requested)
if [[ $LOGGING == true ]]; then
  TIMESTAMP=$(date -Iseconds)
  echo "{\"timestamp\":\"$TIMESTAMP\",\"model\":\"${FALLBACK_USED:+$FALLBACK}${FALLBACK_USED:+fallback}\"\
,\"fallback_used\":$FALLBACK_USED,\"prompt\":\"$PROMPT\",\"response\":$(jq -R -s '.' <<<"$RESPONSE")}" \
    >> "$LOGFILE"
  >&2 echo "📁 Logged to $LOGFILE"
fi

# 6. Output formatting
if [[ $OUTPUT_FORMAT == "json" ]]; then
  # print raw JSON
  echo "$RESPONSE"
else
  # pretty-print text only
  echo "$RESPONSE" | jq -r '.text // .'
fi

exit 0

# Debug print of parsed values
if [[ $DEBUG == true ]]; then
  cat <<EOF
MODEL=       $MODEL
FALLBACK=    ${FALLBACK:-none}
STREAM=      $STREAM
LOGGING=     $LOGGING
LOGFILE=     $LOGFILE
FORMAT=      $OUTPUT_FORMAT
VERBOSE=     $VERBOSE
DEBUG=       $DEBUG
PROMPT=      $PROMPT
EOF
fi

# Your CLI logic starts here...
# 🧠 Default config
MODEL="tinyllama:latest"
STREAM=false
LOG=false
PROMPT=""
AGENT=""
FALLBACK="llama2:latest"

# 🧼 Help menu
function show_help() {
  echo "🧠 Usage: ./ollama-cli.sh \"Your prompt\" [options]"
  echo "Options:"
  echo "  --model <name>      Specify model (default: $MODEL)"
  echo "  --agent <name>      Route to agent-mode prompt (e.g. 'coder', 'docgen')"
  echo "  --stream            Enable streaming response"
  echo "  --log               Save full JSON to ollama-log.json"
  echo "  --help              Show this help menu"
  exit 0
}

# 🧼 Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --stream) STREAM=true; shift ;;
    --log) LOG=true; shift ;;
    --help) show_help ;;
    *) PROMPT="$1"; shift ;;
  esac
done

# 🧪 Validate prompt
if [[ -z "$PROMPT" ]]; then
  echo "❌ No prompt provided. Use --help for usage."
  exit 1
fi

# 🧠 Agent-mode routing
if [[ -n "$AGENT" ]]; then
  PROMPT="<<agent:$AGENT>> $PROMPT"
fi

# 🚀 Build initial payload
PAYLOAD=$(jq -n \
    --arg model "$MODEL" \
    --arg prompt "$PROMPT" \
  '{model: $model, prompt: $prompt, stream: '"$STREAM"'}')

# 🚀 Send request
RESPONSE=$(curl -s http://localhost:11434/api/generate -d "$PAYLOAD")
USED_MODEL="$MODEL"

# 🛟 Fallback if empty
if [[ -z "$RESPONSE" || "$RESPONSE" == "null" ]]; then
  echo "⚠️ Primary model failed. Retrying with fallback: $FALLBACK"
  USED_MODEL="$FALLBACK"
  PAYLOAD=$(jq -n \
    --arg model "$FALLBACK" \
    --arg prompt "$PROMPT" \
    '{model: $model, prompt: $prompt, stream: '"$STREAM"'}')
  RESPONSE=$(curl -s http://localhost:11434/api/generate -d "$PAYLOAD")
fi

# 📝 Optional logging
if $LOG; then
  echo "$RESPONSE" >> ollama-log.json
  echo -e "\n📁 Logged to ollama-log.json"
fi
