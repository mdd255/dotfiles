#!/bin/bash
# Push exports from secret-env into launchd so GUI apps (e.g. Neovide) inherit them.
secret_env="$HOME/.config/secret-env"

[ -f "$secret_env" ] || exit 0
source "$secret_env"

grep "^export " "$secret_env" | sed "s/^export //" | while IFS= read -r line; do
  key="${line%%=*}"
  eval "val=\$$key"
  launchctl setenv "$key" "$val"
done
