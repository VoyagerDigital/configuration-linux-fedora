#!/usr/bin/env bash
set -euo pipefail

REPO_FILE="${1:-packages.yml}"

if [[ ! -f "$REPO_FILE" ]]; then
  echo "YAML file not found: $REPO_FILE" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "Missing dependency: yq" >&2
  exit 1
fi

# Read packages into array
mapfile -t PACKAGES < <(
  yq -r '.packages // [] | .[] | select(. != "")' "$REPO_FILE"
)

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  echo "No packages found in $REPO_FILE"
  exit 0
fi

echo "Installing ${#PACKAGES[@]} package(s):"
printf '  - %s\n' "${PACKAGES[@]}"

sudo dnf install -y "${PACKAGES[@]}"

echo "Done."
