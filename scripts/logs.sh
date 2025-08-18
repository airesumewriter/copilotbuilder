#!/data/data/com.termux/files/usr/bin/bash

TYPE="${1:-all}"
LOG_DIR="logs"

echo "📜 CopilotBuilder Logs"
echo "------------------------"

# Validate type
if [[ ! "$TYPE" =~ ^(deploy|rollback|all)$ ]]; then
  echo "❌ Invalid log type: $TYPE"
  echo "Usage: logs.sh [deploy|rollback|all]"
  exit 1
fi

# List logs
case "$TYPE" in
  deploy)
    FILES=$(ls -t $LOG_DIR/deploy_*.log 2>/dev/null)
    ;;
  rollback)
    FILES=$(ls -t $LOG_DIR/rollback_*.log 2>/dev/null)
    ;;
  all)
    FILES=$(ls -t $LOG_DIR/*.log 2>/dev/null)
    ;;
esac

if [[ -z "$FILES" ]]; then
  echo "⚠️ No $TYPE logs found."
  exit 0
fi

# Display logs
for FILE in $FILES; do
  echo "🗂️ $FILE"
  tail -n 5 "$FILE"
  echo "------------------------"
done
