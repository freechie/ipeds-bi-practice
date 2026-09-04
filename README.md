# IPEDS BI Practice

Weekend SQL + SSRS drill kit for Fordham-style technical rounds (live SQL, CTEs, windows, SSRS report build).

Data source: [IPEDS Complete Data Files](https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx) (NCES).

## What's already built

| Path | Purpose |
|------|---------|
| `ipeds_practice.sqlite` | Ready-to-query practice DB |
| `data/clean/*.csv` | Full clean tables |
| `data/clean/*_nynj.csv` | NY/NJ subset for lighter SSRS import |
| `data/raw/` | Downloaded IPEDS zips + extracts (gitignored; large) |
| `sql/prompts.sql` | 5 timed drills |
| `sql/solutions.sql` | Answers — peek after attempting |
| `ssrs/CHECKLIST.md` | Sunday SSRS rebuild |

### Tables

- **institutions** — `unitid`, `inst_name`, `state_abbr`, `control`, `level`, `city`
- **enrollment** — `unitid`, `year`, `ft_ug`, `pt_ug`, `ug_total`, `grad_enroll` (2022–2023). Includes **25 seeded duplicate** `unitid`+`year` rows for dedupe practice.
- **completions** — `unitid`, `year`, `award_level`, `count`

`control`: `public` | `private_nonprofit` | `private_forprofit`  
`level`: `4-year` | `2-year` | `less-than-2-year`

## Saturday — SQL

```bash
cd ~/Sites/ipeds-bi-practice
sqlite3 ipeds_practice.sqlite
```

Or open the DB in DB Browser for SQLite / VS Code.

```bash
# run prompts file in your editor; attempt each in 15 minutes
open sql/prompts.sql
```

Smoke test:

```sql
SELECT i.inst_name, e.year, e.ft_ug, e.pt_ug, e.ug_total
FROM enrollment e
JOIN institutions i ON i.unitid = e.unitid
WHERE i.inst_name = 'Fordham University' AND e.year = 2023;
-- expect ~9863 / 444 / 10307
```

## Sunday — SSRS

1. Install/use SQL Server Express + Report Builder (or SSDT) if you don't have them.
2. Import `data/clean/institutions_nynj.csv` and `enrollment_nynj.csv`.
3. Follow `ssrs/CHECKLIST.md`.

## Rebuild from scratch

```bash
./scripts/download_ipeds.sh
python3 scripts/build_db.py
```

Requires: `curl`, `unzip`, Python 3 + `pandas`.

## Notes

- Enrollment FT/PT comes from fall enrollment (`EF*A`) EFALEVEL 22 / 42, not EFFY.
- Completions are summed by award level (CIP rolled up) — good enough for join/null drills, not CIP analysis.
- Raw IPEDS files stay local under `data/raw/` and are gitignored.
