#!/usr/bin/env bash
#
# Runs a script of aurtomator for this repository, at the commit that
# .github/workflows/check-updates.yml pins:
#
#   ./aurtomator.sh setup                 scripts/setup.sh
#   ./aurtomator.sh validate-pkg <name>   scripts/validate-pkg.sh <name>
#   ./aurtomator.sh check-update <name>   scripts/check-update.sh <name>
#   ./aurtomator.sh update-pkg <name> <version> --dry-run
#   ./aurtomator.sh check-all             scripts/check-all.sh
#   ./aurtomator.sh sample                prints packages/example.yml.sample
#   ./aurtomator.sh pin vX.Y.Z            pins the calling workflows to a release
#
# The first run of a pin fetches aurtomator at that commit into
# ~/.cache/aurtomator/<sha>, or $XDG_CACHE_HOME/aurtomator/<sha>.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
workflow=.github/workflows/check-updates.yml
if [[ ! -f "$root/$workflow" ]]; then
  echo "No $workflow in $root" >&2
  exit 1
fi
# The repository and the commit come from one uses: line, never a comment
uses='^[[:space:]]*uses:[[:space:]]+([[:alnum:]_.-]+/[[:alnum:]_.-]+)/\.github/workflows/check-updates\.yml@([0-9a-f]{40})([[:space:]]|$)'
mapfile -t pins < <(grep -E "$uses" "$root/$workflow" || true)
if [[ ${#pins[@]} -eq 0 ]]; then
  echo "No commit SHA pinned in $workflow" >&2
  exit 1
fi
if [[ ${#pins[@]} -gt 1 ]]; then
  echo "More than one uses: line pins check-updates.yml in $workflow" >&2
  exit 1
fi
[[ "${pins[0]}" =~ $uses ]]
repo="${BASH_REMATCH[1]}"
sha="${BASH_REMATCH[2]}"

if [[ "${1:-}" == pin ]]; then
  if [[ $# -ne 2 || ! "$2" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Usage: $0 pin vX.Y.Z" >&2
    exit 1
  fi
  # An annotated tag names its commit on the line of <tag>^{}
  new=$(git ls-remote --tags "https://github.com/$repo" | awk -v ref="refs/tags/$2" '$2 == ref || $2 == ref "^{}" { sha = $1 } END { print sha }')
  if [[ -z "$new" ]]; then
    echo "No tag $2 in $repo" >&2
    exit 1
  fi
  cd "$root"
  for file in "$workflow" .github/workflows/validate.yml; do
    [[ -f "$file" ]] || continue
    sed -i -E "s|^([[:space:]]*uses:[[:space:]]+$repo/\.github/workflows/[a-z-]+\.yml@)[0-9a-f]{40}([[:space:]].*)?$|\1$new # $2|" "$file"
    grep -nHE "^[[:space:]]*uses:[[:space:]]+$repo/\.github/workflows/[a-z-]+\.yml@$new # $2\$" "$file" || true
  done
  exit 0
fi

copy="${XDG_CACHE_HOME:-$HOME/.cache}/aurtomator/$sha"
if [[ ! -d "$copy" ]]; then
  # GitHub serves the commits of every fork under the name of its parent
  if [[ $'\n'"$(git ls-remote --tags "https://github.com/$repo")" != *$'\n'"$sha"* ]]; then
    echo "Warning: no tag of $repo points to $sha, check where the pin comes from" >&2
  fi
  mkdir -p "${copy%/*}"
  tmp="$(mktemp -d "$copy.XXXXXX")"
  trap 'rm -rf "$tmp"' EXIT
  git -C "$tmp" init -q
  git -C "$tmp" fetch -q --depth 1 "https://github.com/$repo" "$sha"
  git -C "$tmp" checkout -q FETCH_HEAD
  # A run that started at the same time can make the copy first
  mv -T "$tmp" "$copy" 2>/dev/null || rm -rf "$tmp"
  # A pin still in use after 30 days is fetched again on its next run. A
  # run at the same time can remove its own directory while find reads.
  find "${copy%/*}" -mindepth 1 -maxdepth 1 -regextype posix-extended -regex '.*/[0-9a-f]{40}' -mtime +30 -exec rm -rf -- {} + 2>/dev/null || true
fi

# The documented commands. Another script of scripts/ is a step of the CI
# jobs and runs after a warning.
commands=(setup sample validate-pkg check-update update-pkg check-all pin)
cmd="${1:-}"
if [[ "$cmd" == sample ]]; then
  exec cat "$copy/packages/example.yml.sample"
fi
if [[ ! "$cmd" =~ ^[a-z]+(-[a-z]+)*$ || ! -x "$copy/scripts/$cmd.sh" ]]; then
  echo "Usage: $0 <command> [argument...]" >&2
  echo "Commands: ${commands[*]}" >&2
  exit 1
fi
if [[ " ${commands[*]} " != *" $cmd "* ]]; then
  echo "Warning: $cmd is a step of the CI jobs, not a documented command" >&2
fi
shift
AURTOMATOR_DATA_DIR="$root" AURTOMATOR_RUNNER="$0" "$copy/scripts/$cmd.sh" "$@"
