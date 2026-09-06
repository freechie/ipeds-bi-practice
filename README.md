# IPEDS BI Practice

Sunday SQL and Monday SSRS drill kit for Fordham-style technical rounds.

Data source: [IPEDS Complete Data Files](https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx) (NCES).

## Sunday

```bash
make practice
```

That runs `make doctor`, then opens sqlite3 with headers and a timer. Or run the steps apart:

```bash
make doctor
make sql
```

`doctor: OK` means tools, row counts, Fordham smoke (`9863` / `444` / `10307`), 25 seeded enrollment dupes, and `sql/solutions.sql` all checked out.

Inside sqlite3, run `.read sql/smoke.sql`, then work `sql/prompts.sql` (15 minutes each). Open `sql/solutions.sql` only after you attempt the drill.

## Tables

- `institutions` has `unitid`, `inst_name`, `state_abbr`, `control`, `level`, `city`
- `enrollment` has `unitid`, `year`, `ft_ug`, `pt_ug`, `ug_total`, `grad_enroll` for 2022 and 2023, plus 25 seeded duplicate `unitid`+`year` rows for dedupe practice
- `completions` has `unitid`, `year`, `award_level`, `count`

`control` is `public`, `private_nonprofit`, or `private_forprofit`.
`level` is `4-year`, `2-year`, or `less-than-2-year`.

## Monday SSRS

1. Install SQL Server Express and Report Builder, or SSDT, if you do not have them.
2. Import `data/clean/institutions_nynj.csv` and `enrollment_nynj.csv`.
3. Follow `ssrs/CHECKLIST.md`.

## Rebuild

```bash
make rebuild
```

You need `curl`, `unzip`, Python 3, and pandas for rebuild. Install pandas with `pip3 install -r requirements.txt`. Sunday SQL practice does not need pandas.

Enrollment FT and PT come from fall enrollment (`EF*A`) EFALEVEL 22 and 42, not EFFY.
Completions are summed by award level. Use them for join and null drills, not CIP analysis.
Raw IPEDS files stay under `data/raw/` and are gitignored.
