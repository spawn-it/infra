#!/usr/bin/env bash

set -euo pipefail

ACTION=${1:-apply}
DIR="./instances"

if [[ ! -d "$DIR" ]]; then
  echo "Error: '$DIR' directory not found."
  exit 1
fi

cd "$DIR"

case "$ACTION" in
  apply)
    echo "Initializing and applying Opentofu configuration..."
    tofu init -upgrade
    tofu apply -auto-approve
    ;;
  destroy)
    echo "Destroying Opentofu-managed infrastructure..."
    tofu init -upgrade
    tofu destroy -auto-approve
    ;;
  *)
    echo "Usage: $0 [apply|destroy]"
    exit 1
    ;;
esac
