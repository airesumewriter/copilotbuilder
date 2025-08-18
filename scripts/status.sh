#!/data/data/com.termux/files/usr/bin/bash

source .copilotbuilder.env

echo "🧾 CopilotBuilder Deploy Status"
echo "-------------------------------"
echo "🌐 Environment: $ENVIRONMENT"
echo "🔐 Deploy Key: $DEPLOY_KEY"
echo "🧪 Dry Run Mode: $DRY_RUN"

LAST_LOG=$(ls -t logs/deploy_*.log 2>/dev/null | head -n 1)
if [[ -n "$LAST_LOG" ]]; then
  echo "📄 Last Log: $LAST_LOG"
  echo "🕒 Last Deploy Time: $(head -n 1 "$LAST_LOG" | cut -d' ' -f1-2)"
  echo "🔍 Preview:"
  tail -n 5 "$LAST_LOG"
else
  echo "⚠️ No deploy logs found."
fi
