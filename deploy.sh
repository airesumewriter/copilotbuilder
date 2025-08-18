#!/data/data/com.termux/files/usr/bin/bash

# Load environment variables if present
[[ -f ".copilotbuilder.env" ]] && source .copilotbuilder.env

# Validate input
ENVIRONMENT="${1:-$ENVIRONMENT}"
if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
  echo "❌ Invalid environment: $ENVIRONMENT"
  exit 1
fi

echo "🚀 Deploying to: $ENVIRONMENT"

# Dry-run mode
if [[ "$DRY_RUN" == "true" ]]; then
  echo "[DRY RUN] Would deploy to $TARGET_URL using key $DEPLOY_KEY"
  exit 0
fi

# Actual deploy logic (placeholder)
echo "🔐 Using deploy key: $DEPLOY_KEY"
echo "🌐 Target URL: $TARGET_URL"

# Simulate deploy
echo "✅ Deployment to $ENVIRONMENT complete."
