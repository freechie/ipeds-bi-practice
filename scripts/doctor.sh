#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ $# -eq 0 ]]; then
  DB="$ROOT/ipeds_practice.sqlite"
elif [[ $# -eq 1 ]]; then
  DB=$1
else
  echo "doctor: FAIL usage: doctor.sh [db_path]" >&2
  exit 2
fi

fail() {
  echo "doctor: FAIL $1" >&2
  exit 1
}

check_tools() {
  command -v sqlite3 >/dev/null || fail "sqlite3 not on PATH"
}

check_db_exists() {
  [[ -f "$ROOT/ipeds_practice.sqlite" ]] || fail "ipeds_practice.sqlite missing at repo root"
  [[ -f "$DB" ]] || fail "database missing: $DB"
}

check_tables() {
  local n
  n=$(sqlite3 "$DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name IN ('institutions','enrollment','completions');")
  [[ "$n" == "3" ]] || fail "tables institutions, enrollment, completions missing (found $n of 3)"
}

check_row_counts() {
  local inst enr comp
  inst=$(sqlite3 "$DB" "SELECT COUNT(*) FROM institutions;")
  enr=$(sqlite3 "$DB" "SELECT COUNT(*) FROM enrollment;")
  comp=$(sqlite3 "$DB" "SELECT COUNT(*) FROM completions;")
  [[ "${inst:-0}" -ge 6000 ]] || fail "institutions row count ${inst:-0} < 6000"
  [[ "${enr:-0}" -ge 10000 ]] || fail "enrollment row count ${enr:-0} < 10000"
  [[ "${comp:-0}" -ge 30000 ]] || fail "completions row count ${comp:-0} < 30000"
}

check_fordham_smoke() {
  local n row
  n=$(sqlite3 "$DB" "SELECT COUNT(*) FROM enrollment e JOIN institutions i ON i.unitid = e.unitid WHERE i.inst_name = 'Fordham University' AND e.year = 2023;")
  [[ "$n" == "1" ]] || fail "expected 1 Fordham 2023 enrollment row, found ${n:-empty}"
  row=$(sqlite3 "$DB" "SELECT e.ft_ug, e.pt_ug, e.ug_total FROM enrollment e JOIN institutions i ON i.unitid = e.unitid WHERE i.inst_name = 'Fordham University' AND e.year = 2023;")
  [[ "$row" == "9863|444|10307" ]] || fail "Fordham 2023 smoke expected 9863|444|10307, got ${row:-empty}"
}

check_enrollment_dupes() {
  local n
  n=$(sqlite3 "$DB" "SELECT COUNT(*) FROM (SELECT unitid, year FROM enrollment GROUP BY unitid, year HAVING COUNT(*) > 1);")
  [[ "$n" == "25" ]] || fail "expected 25 duplicate unitid+year groups, found ${n:-empty}"
}

check_sql_files() {
  [[ -f "$ROOT/sql/prompts.sql" ]] || fail "sql/prompts.sql missing"
  [[ -f "$ROOT/sql/solutions.sql" ]] || fail "sql/solutions.sql missing"
}

check_scripts_executable() {
  [[ -x "$ROOT/scripts/download_ipeds.sh" ]] || fail "scripts/download_ipeds.sh not executable"
  [[ -x "$ROOT/scripts/build_db.py" ]] || fail "scripts/build_db.py not executable"
}

check_solutions_run() {
  "$ROOT/scripts/verify_solutions.sh" "$DB" || fail "sql/solutions.sql did not run against the DB"
}

CHECKS=(
  check_tools
  check_db_exists
  check_tables
  check_row_counts
  check_fordham_smoke
  check_enrollment_dupes
  check_sql_files
  check_scripts_executable
  check_solutions_run
)

for check in "${CHECKS[@]}"; do
  "$check"
done

echo "doctor: OK"
