#!/usr/bin/env bash
# Export the website files to a fresh directory suitable for initializing a
# new public GitHub repo. Leaves the private /2026/ folder and all other
# organizing materials behind. Run from the repo root.
#
# Usage:
#   scripts/export-public.sh [target_dir]
#
# Default target_dir: ../sti26-public-export
set -euo pipefail

target="${1:-../sti26-public-export}"

if [ -e "$target" ]; then
  echo "Error: '$target' already exists. Remove it or pass a different path." >&2
  exit 1
fi

mkdir -p "$target"

# Items that go to the public site repo.
paths=(
  .github
  .gitignore
  .env.example
  README.md
  astro.config.mjs
  package.json
  package-lock.json
  public
  scripts
  src
  tsconfig.json
)

for p in "${paths[@]}"; do
  if [ -e "$p" ]; then
    cp -R "$p" "$target/"
  fi
done

echo
echo "Exported to: $target"
echo
echo "Next steps:"
echo "  1. Create a new PUBLIC repo on GitHub (e.g. dvh147/sti-summerschool)"
echo "  2. cd '$target'"
echo "  3. git init && git add -A && git commit -m 'Initial website'"
echo "  4. git branch -M main"
echo "  5. git remote add origin https://github.com/<you>/<new-repo>.git"
echo "  6. git push -u origin main"
echo "  7. On GitHub: Settings -> Pages -> Source: GitHub Actions"
echo "  8. Settings -> Actions -> Variables -> add BASE_PATH = '/<new-repo-name>'"
echo "     (or leave it set to /sti26 if you named the new repo sti26)"
