#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
DB="$ROOT/ipeds_practice.sqlite"

"$ROOT/scripts/doctor.sh" "$DB"
exec "$ROOT/scripts/sql.sh"
