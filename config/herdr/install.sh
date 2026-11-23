#!/usr/bin/env bash
# Installs the herdr helper scripts from bin/ into ~/.local/bin (as symlinks).
# Safe to run again: links that already point here are left alone, anything
# else in the way is moved to <name>.bak.<timestamp>.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
target="$HOME/.local/bin"
mkdir -p "$target"

for src in "$here"/bin/*; do
  name=$(basename "$src")
  dst="$target/$name"
  chmod +x "$src"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok       $dst"
    continue
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    echo "backup   $dst -> $backup"
  fi
  ln -s "$src" "$dst"
  echo "linked   $dst -> $src"
done

case ":$PATH:" in
  *":$target:"*) ;;
  *) echo "note: $target is not in your PATH" ;;
esac

for cmd in herdr jq claude lazygit; do
  command -v "$cmd" >/dev/null || echo "missing: $cmd (needed by hws)"
done
