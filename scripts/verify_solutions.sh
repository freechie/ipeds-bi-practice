#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ $# -eq 0 ]]; then
  DB="$ROOT/ipeds_practice.sqlite"
elif [[ $# -eq 1 ]]; then
  DB=$1
else
  echo "verify_solutions: FAIL usage: verify_solutions.sh [db_path]" >&2
  exit 2
fi

SQL="$ROOT/sql/solutions.sql"

[[ -f "$DB" ]] || { echo "verify_solutions: FAIL missing $DB" >&2; exit 1; }
[[ -f "$SQL" ]] || { echo "verify_solutions: FAIL missing $SQL" >&2; exit 1; }

run_block() {
  local n=$1
  local sql=$2
  if [[ "$sql" != *';'* ]]; then
    return 0
  fi
  if ! sqlite3 -bail -batch "$DB" >/dev/null <<<"$sql"; then
    echo "verify_solutions: FAIL prompt block $n" >&2
    exit 1
  fi
}

n=0
block=""
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" == "-- PROMPT "* ]]; then
    if [[ -n "$block" ]]; then
      run_block "$n" "$block"
    fi
    n=$((n + 1))
    block="$line"$'\n'
  else
    block+="$line"$'\n'
  fi
done < "$SQL"
run_block "$n" "$block"

if [[ "$n" -eq 0 ]]; then
  echo "verify_solutions: FAIL no prompt blocks in $SQL" >&2
  exit 1
fi

echo "verify_solutions: OK"
