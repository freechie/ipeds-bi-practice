#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB="$ROOT/ipeds_practice.sqlite"
DBEAVER="/Applications/DBeaver.app/Contents/MacOS/dbeaver"

if [[ ! -f "$DB" ]]; then
  echo "sql: FAIL missing $DB" >&2
  exit 1
fi

if [[ ! -x "$DBEAVER" ]]; then
  echo "sql: FAIL DBeaver is not installed at /Applications/DBeaver.app" >&2
  echo "sql: install DBeaver, then rerun make sql" >&2
  exit 1
fi

"$DBEAVER" -q \
  -con "driver=sqlite:database=${DB}|name=IPEDS practice|openConsole=true" \
  -f "$ROOT/sql/smoke.sql" \
  -f "$ROOT/sql/prompts.sql" \
  -bringToFront=true \
  >/dev/null 2>&1 &

echo "sql: opened IPEDS practice in DBeaver (SQL editor is highlighted)"
echo "sql: run sql/smoke.sql first, then work sql/prompts.sql"
