#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RAW="$ROOT/data/raw"
mkdir -p "$RAW"
cd "$RAW"

FILES=(
  HD2022
  HD2023
  EF2022A
  EF2023A
  C2022_A
  C2023_A
)

for f in "${FILES[@]}"; do
  if [[ -f "${f}.zip" ]]; then
    echo "have ${f}.zip"
  else
    echo "downloading ${f}.zip"
    curl -fsSL -o "${f}.zip" "https://nces.ed.gov/ipeds/datacenter/data/${f}.zip"
  fi
  mkdir -p "$f"
  unzip -o -q "${f}.zip" -d "$f"
done

echo "done. next: python3 scripts/build_db.py"
