#!/usr/bin/env bash
# Sync the forked Omarchy plugins (dh.bar, dh.menu, dh.active-window) with
# upstream omacom/omarchy. Each tracked file keeps a snapshot of the upstream
# version it was last synced with in .upstream/, so an update is a 3-way merge:
# your edits + upstream's changes since that snapshot.
#
#   sync-upstream.sh           show which files changed upstream
#   sync-upstream.sh --apply   merge them in (conflicts get <<<<<<< markers)
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
snap=$here/.upstream
cache=${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-upstream
repo=https://github.com/omacom/omarchy.git
# Track release tags, not the dev branch: the plugins must match the installed
# shell (Commons, Ui, ...), which ships from a tag.

# local plugin | upstream directory | file
MAP=(
  "dh.bar|shell/plugins/bar|Bar.qml"
  "dh.menu|shell/plugins/menu|Menu.qml"
  "dh.menu|shell/plugins/menu|MenuModel.js"
  "dh.active-window|shell/plugins/bar/widgets|ActiveWindow.qml"
)

apply=0
[[ ${1:-} == --apply ]] && apply=1

if [[ -d $cache ]]; then
  git -C "$cache" fetch --quiet --tags origin
else
  git clone --quiet --filter=blob:none --no-checkout "$repo" "$cache"
fi

tag=${TAG:-$(git -C "$cache" tag -l 'v*' --sort=-v:refname | head -1)}
new=$(git -C "$cache" rev-parse "$tag^{commit}")
old=$(cat "$snap/BASE")
echo "upstream: ${old:0:9} -> $tag (${new:0:9})"

changed=0 conflicts=0
for entry in "${MAP[@]}"; do
  IFS='|' read -r plugin dir file <<<"$entry"
  base=$snap/$plugin/$file
  local_file=$here/$plugin/$file
  theirs=$(mktemp)
  git -C "$cache" show "$new:$dir/$file" >"$theirs"

  if cmp -s "$base" "$theirs"; then
    rm -f "$theirs"
    continue
  fi

  changed=1
  echo "changed upstream: $plugin/$file"
  if ((apply)); then
    if ! git merge-file "$local_file" "$base" "$theirs"; then
      echo "  conflicts in $plugin/$file, resolve the markers"
      conflicts=1
    fi
    cp "$theirs" "$base"
  else
    diff -u "$base" "$theirs" | diffstat 2>/dev/null || diff "$base" "$theirs" | grep -c '^[<>]' | sed 's/^/  changed lines: /'
  fi
  rm -f "$theirs"
done

if ((apply)); then
  echo "$new" >"$snap/BASE"
  ((conflicts)) && echo "done with conflicts" || echo "done"
elif ((changed)); then
  echo "run with --apply to merge"
else
  echo "up to date"
fi
