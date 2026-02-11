#!/usr/bin/env bash
set -euo pipefail

REPO_FILE="${1:-../../files/config.yaml}"

# Apply DNF/YUM repo files from YAML
mapfile -t REPO_IDS < <(yq -r '.dnf_repos // [] | .[].id' "$REPO_FILE")

for id in "${REPO_IDS[@]}"; do
  repo_file="$(yq -r ".dnf_repos[] | select(.id == \"$id\") | .filename" "$REPO_FILE")"
  repo_path="$(yq -r ".dnf_repos[] | select(.id == \"$id\") | .path" "$REPO_FILE")"
  gpgkey_url="$(yq -r ".dnf_repos[] | select(.id == \"$id\") | .gpgkey_url // \"\"" "$REPO_FILE")"
  repo_body="$(yq -r ".dnf_repos[] | select(.id == \"$id\") | .repo" "$REPO_FILE")"

  dest="${repo_path%/}/$repo_file"

  echo "-> Installing repo: $id -> $dest"

  # Import GPG key (safe to re-run)
  if [[ -n "$gpgkey_url" ]]; then
    sudo rpm --import "$gpgkey_url"
  fi

  # Write repo file only if content differs (idempotent)
  tmp="$(mktemp)"
  printf '%s\n' "$repo_body" > "$tmp"
  if [[ ! -f "$dest" ]] || ! cmp -s "$tmp" "$dest"; then
    sudo install -m 0644 "$tmp" "$dest"
    echo "   wrote $dest"
  else
    echo "   unchanged, skipping"
  fi
  rm -f "$tmp"
done

# Refresh metadata after adding repos
sudo dnf -y makecache
