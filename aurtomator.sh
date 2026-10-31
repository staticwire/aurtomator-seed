#!/usr/bin/env bash
#
# Runs a script of aurtomator for this repository, at the commit that
# .github/workflows/check-updates.yml pins:
#
#   ./aurtomator.sh setup                 scripts/setup.sh
#   ./aurtomator.sh validate-pkg <name>   scripts/validate-pkg.sh <name>
#   ./aurtomator.sh sample                prints packages/example.yml.sample
#
# The first run of a pin fetches aurtomator at that commit into
# ~/.cache/aurtomator/<sha>, or $XDG_CACHE_HOME/aurtomator/<sha>.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
uses='[[:alnum:]_.-]+/[[:alnum:]_.-]+/\.github/workflows/check-updates\.yml@[0-9a-f]{40}'
pin="$(grep -s -oE "$uses" "$root/.github/workflows/check-updates.yml" || true)"
if [[ -z "$pin" ]]; then
  echo "No commit SHA pinned in .github/workflows/check-updates.yml" >&2
  exit 1
fi
sha="${pin##*@}"
copy="${XDG_CACHE_HOME:-$HOME/.cache}/aurtomator/$sha"

if [[ ! -d "$copy" ]]; then
  mkdir -p "${copy%/*}"
  tmp="$(mktemp -d "$copy.XXXXXX")"
  trap 'rm -rf "$tmp"' EXIT
  git -C "$tmp" init -q
  git -C "$tmp" fetch -q --depth 1 "https://github.com/${pin%%/.github/*}" "$sha"
  git -C "$tmp" checkout -q FETCH_HEAD
  mv "$tmp" "$copy"
fi

cmd="${1:-}"
if [[ "$cmd" == sample ]]; then
  exec cat "$copy/packages/example.yml.sample"
fi
if [[ ! "$cmd" =~ ^[a-z]+(-[a-z]+)*$ || ! -x "$copy/scripts/$cmd.sh" ]]; then
  commands=(sample)
  for script in "$copy"/scripts/*.sh; do
    if [[ -x "$script" ]]; then
      script="${script##*/}"
      commands+=("${script%.sh}")
    fi
  done
  echo "Usage: $0 <command> [argument...]" >&2
  echo "Commands: ${commands[*]}" >&2
  exit 1
fi
shift
AURTOMATOR_DATA_DIR="$root" AURTOMATOR_RUNNER="$0" "$copy/scripts/$cmd.sh" "$@"
