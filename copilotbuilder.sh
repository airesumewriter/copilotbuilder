#!/data/data/com.termux/files/usr/bin/bash

# Load environment config
[[ -f .copilotbuilder.env ]] && source .copilotbuilder.env

CMD=$1
ARG=$2

echo "🚀 Welcome to CopilotBuilder"
echo "📂 Directory: $(pwd)"
echo "🌿 Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "📝 Last commit: $(git log -1 --pretty=format:'%s')"

if [[ -n $(git status --porcelain) ]]; then
  echo "⚠️  You have uncommitted changes!"
else
  echo "✅ Working directory clean"
fi

if grep -q '"conclusion": "success"' .copilotbuilder/status.json 2>/dev/null; then
  echo "✅ Last CI run passed"
else
  echo "❌ Last CI run failed or unknown"
fi

echo ""

case "$CMD" in
  deploy)
    ENV=${ARG:-staging}
    URL_VAR="${ENV^^}_URL"  # Converts to STAGING_URL or PROD_URL
    TARGET_URL=${!URL_VAR}
    echo "📜 CopilotBuilder Logs"
    echo "------------------------"
    LOGFILE="logs/deploy_$(date +%Y-%m-%d_%H:%M:%S).log"
    echo "🗂️ $LOGFILE"
    echo "🚀 Starting deployment to $ENV"
    echo "🌐 Target URL: $TARGET_URL"
    echo "[DRY RUN] Would deploy to $TARGET_URL using key $DEPLOY_KEY"
    ;;

  rollback)
    ENV=${ARG:-staging}
    echo "🔄 Rolling back deployment for $ENV"
    echo "[DRY RUN] Would rollback last deploy for $ENV"
    ;;

  status)
    echo "📊 Deployment Status"
    cat .copilotbuilder/status.json 2>/dev/null || echo "No status file found."
    ;;

  logs)
    echo "📜 CopilotBuilder Logs"
    echo "------------------------"
    if [[ "$ARG" == "deploy" ]]; then
      ls logs/deploy_*.log 2>/dev/null
    elif [[ "$ARG" == "rollback" ]]; then
      ls logs/rollback_*.log 2>/dev/null
    else
      ls logs/*.log 2>/dev/null
    fi
    ;;

prompt)
  PROMPT="$ARG"
  echo "🧠 Generating script for: $PROMPT"

  RESPONSE=$(ollama run llama3 "$PROMPT")
  echo "$RESPONSE" > generated.sh
  echo "✅ Saved to generated.sh"
  ;;

 help)
    echo "🧭 CopilotBuilder CLI — Available Commands"
    echo "----------------------------------------"
    echo "  deploy [env]     → Run deployment (staging|production)"
    echo "  rollback [env]   → Rollback last deploy"
    echo "  status           → Show current deploy status"
    echo "  logs [type]      → View logs (deploy|rollback|all)"
    echo "  help             → Show this help message"
    ;;

  *)
    echo "❓ Unknown command: $CMD"
    echo "Run './copilotbuilder.sh help' for usage."
    ;;
esac

