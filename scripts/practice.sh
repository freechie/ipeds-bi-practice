#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
DB="$ROOT/ipeds_practice.sqlite"

"$ROOT/scripts/doctor.sh" "$DB"

export SQLITE_HISTORY="$ROOT/.sqlite_history"

exec sqlite3 -init "$ROOT/sql/sqlite3.init" "$DB"
