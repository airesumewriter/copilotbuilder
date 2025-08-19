#!/data/data/com.termux/files/usr/bin/bash

# Load environment variables
[[ -f ".copilotbuilder.env" ]] && source .copilotbuilder.env

# Setup logging
LOG_FILE="logs/deploy_$(date +%F_%T).log"
mkdir -p logs
exec > >(tee -a "$LOG_FILE") 2>&1

# Validate input
ENVIRONMENT="${1:-$ENVIRONMENT}"
if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
  echo "❌ Invalid environment: $ENVIRONMENT"
  exit 1
fi

# Set target URL based on environment
case "$ENVIRONMENT" in
  staging)
    TARGET_URL="https://staging.example.com"
    ;;
  production)
    TARGET_URL="https://prod.example.com"
    ;;
esac

echo "🚀 Starting deployment to $ENVIRONMENT"
echo "🌐 Target URL: $TARGET_URL"

# Check for dry run mode
if [[ "$DRY_RUN" == "true" ]]; then
  echo "[DRY RUN] Would deploy to $TARGET_URL using key $DEPLOY_KEY"
  exit 0
fi

# Validate deploy key
if [[ ! -f "$DEPLOY_KEY" ]]; then
  echo "❌ Deploy key not found: $DEPLOY_KEY"
  exit 1
fi

# Simulate deployment (replace with real logic)
echo "🔐 Using deploy key: $DEPLOY_KEY"
echo "📦 Deploying files..."
sleep 2  # Simulate work
echo "✅ Deployment to $ENVIRONMENT complete"

