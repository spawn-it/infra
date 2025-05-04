#!/usr/bin/env bash

set -euo pipefail

ACTION=${1:-apply}

echo "Running all deployment steps with action: $ACTION"

if [[ "$ACTION" == "apply" ]]; then
  echo "==> Deploying volumes..."
  ./volumes-deploy.sh apply

  echo "==> Deploying instances..."
  ./instances-deploy.sh apply

  echo "==> Deploying configs..."
  ./configs-deploy.sh apply

  echo "Infrastructure successfully deployed."

elif [[ "$ACTION" == "destroy" ]]; then
  echo "==> Destroying configs..."
  ./configs-deploy.sh destroy

  echo "==> Destroying instances..."
  ./instances-deploy.sh destroy

  echo "==> Destroying volumes..."
  ./volumes-deploy.sh destroy

  echo "Infrastructure successfully destroyed."

else
  echo "Usage: $0 [apply|destroy]"
  exit 1
fi
