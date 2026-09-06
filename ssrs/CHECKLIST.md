# SSRS rebuild checklist (Monday)

Target dataset: import `data/clean/institutions_nynj.csv` + `enrollment_nynj.csv` into **SQL Server Express**, or use a linked process from SQLite via a one-time load.

Suggested SQL Server database name: `IpedsPractice`

## Parameterized report SQL

```sql
SELECT
  i.inst_name,
  e.year,
  (e.ft_ug + e.pt_ug) AS ug_headcount,
  e.ft_ug,
  e.pt_ug
FROM dbo.enrollment e
JOIN dbo.institutions i ON i.unitid = e.unitid
WHERE e.year = @Year
  AND i.state_abbr = @State
ORDER BY ug_headcount DESC;
```

If you only loaded NY/NJ clean files, `@State` values are `NY` or `NJ`.

## Build steps

1. [ ] Data source → `IpedsPractice` (test connection)
2. [ ] Dataset → paste SQL above; map `@Year`, `@State`
3. [ ] Report params: `@Year` (Int, default 2023), `@State` (Text, default NJ)
4. [ ] Tablix: Institution, Year, Headcount (+ optional FT/PT)
5. [ ] Total row: `Sum(Fields!ug_headcount.Value)`
6. [ ] Title: `Undergraduate Headcount — [@State] / [@Year]`
7. [ ] Preview; change params; export Excel + PDF
8. [ ] Rebuild from blank in <40 minutes while narrating

## Import tip (SSMS)

1. Create DB `IpedsPractice`
2. Tasks → Import Flat File → `institutions_nynj.csv` → table `institutions`
3. Repeat for `enrollment_nynj.csv` → `enrollment`
4. Or use `sql/load_sqlserver.sql` as a column reference after import

## 60-second talk track

Data source → dataset (SQL + params) → report params → tablix/groups/totals → preview edge cases → deploy/export. Validate row counts against the database before stakeholder handoff.
