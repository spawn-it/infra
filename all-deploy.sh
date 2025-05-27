#!/usr/bin/env bash
set -euo pipefail

ACTION=${1:-apply}
DELAY=10

echo "Running all deployment steps with action: $ACTION"

pause() {
  echo "Waiting for $DELAY seconds before proceeding in order to allow previous operations to stabilize..."
  sleep "$DELAY"
}

if [[ "$ACTION" == "apply" ]]; then
  echo "==> Deploying volumes..."
  ./volumes-deploy.sh apply
  pause

  echo "==> Deploying network..."
  ./network-deploy.sh apply
  pause

  echo "==> Deploying instances..."
  ./instances-deploy.sh apply
  pause

  echo "==> Deploying configs..."
  ./configs-deploy.sh apply

  echo "Infrastructure successfully deployed."

elif [[ "$ACTION" == "destroy" ]]; then
  echo "==> Destroying configs..."
  ./configs-deploy.sh destroy
  pause

  echo "==> Destroying instances..."
  ./instances-deploy.sh destroy
  pause

  echo "==> Destroying network..."
  ./network-deploy.sh destroy
  pause

  echo "==> Destroying volumes..."
  ./volumes-deploy.sh destroy

  echo "Infrastructure successfully destroyed."

else
  echo "Usage: $0 [apply|destroy]"
  exit 1
fi
