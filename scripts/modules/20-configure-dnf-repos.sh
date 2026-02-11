# Apply DNF/YUM repo files from YAML
mapfile -t REPO_IDS < <(yq -r '.dnf_repos // [] | .[].id' "$YAML_FILE")

for id in "${REPO_IDS[@]}"; do
  repo_file="$(yq -r ".dnf_repos[] | select(.id == \"$id\") | .filename" "$YAML_FILE")"
  repo_path="$(yq -r ".dnf_repos[] | select(.id == \"$id\") | .path" "$YAML_FILE")"
  gpgkey_url="$(yq -r ".dnf_repos[] | select(.id == \"$id\") | .gpgkey_url // \"\"" "$YAML_FILE")"
  repo_body="$(yq -r ".dnf_repos[] | select(.id == \"$id\") | .repo" "$YAML_FILE")"

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