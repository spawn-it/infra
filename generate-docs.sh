#!/bin/bash

# Fail fast
set -e

# Recurse into all modules and generate docs if README.md has markers
find modules -type f -name 'main.tf' | while read -r main_tf; do
  module_dir=$(dirname "$main_tf")
  if grep -q 'BEGIN_TF_DOCS' "$module_dir/README.md" 2>/dev/null; then
    echo "Generating docs in $module_dir"
    terraform-docs markdown --output-mode inject --output-file README.md "$module_dir"
  fi
done
