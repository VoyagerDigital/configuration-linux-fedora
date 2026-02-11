#!/usr/bin/env bash
set -euo pipefail

REPO_FILE="${1:-../../files/config.yaml}"

if [[ ! -f "$REPO_FILE" ]]; then
  echo "Repo file not found: $REPO_FILE" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "Missing dependency: yq (YAML parser). Install it (e.g., 'sudo dnf install yq')." >&2
  exit 1
fi

# Read YAML into array. This expects: copr_repos: [ ... ]
mapfile -t COPR_REPOS < <(yq -r '.copr_repositories // [] | .[] | select(. != "")' "$REPO_FILE")

if [[ ${#COPR_REPOS[@]} -eq 0 ]]; then
  echo "No repositories found in $REPO_FILE"
  exit 0
fi

echo "Enabling ${#COPR_REPOS[@]} COPR repo(s) from: $REPO_FILE"

for repo in "${COPR_REPOS[@]}"; do
  [[ -z "${repo//[[:space:]]/}" ]] && continue

  echo "-> Enabling: $repo"

  # Skip ones already enabled
  if dnf repolist --enabled | grep -qE "(^|[[:space:]])copr:copr\.fedorainfracloud\.org:${repo//\//:}"; then
    echo "   already enabled, skipping"
    continue
  fi

  sudo dnf copr enable -y "$repo"
done

echo "Done."
