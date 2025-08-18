#!/data/data/com.termux/files/usr/bin/bash

# Load environment variables
[[ -f ".copilotbuilder.env" ]] && source .copilotbuilder.env

# Setup logging
LOG_FILE="logs/rollback_$(date +%F_%T).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

# Validate input
ENVIRONMENT="${1:-$ENVIRONMENT}"
if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
  echo "❌ Invalid environment: $ENVIRONMENT"
  exit 1
fi

echo "⏪ Starting rollback for $ENVIRONMENT"

# Dry-run mode
if [[ "$DRY_RUN" == "true" ]]; then
  echo "[DRY RUN] Would rollback deployment on $ENVIRONMENT"
  exit 0
fi

# Simulated rollback logic
echo "🔄 Reverting last deployment on $ENVIRONMENT..."
sleep 1
echo "✅ Rollback complete."
