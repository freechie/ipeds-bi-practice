-- Optional: after flat-file import into SQL Server, useful indexes

-- CREATE INDEX IX_institutions_state ON dbo.institutions(state_abbr);
-- CREATE INDEX IX_enrollment_unit_year ON dbo.enrollment(unitid, year);

-- Quick sanity check
-- SELECT TOP 5 * FROM dbo.institutions WHERE state_abbr = 'NJ';
-- SELECT TOP 5 i.inst_name, e.*
-- FROM dbo.enrollment e
-- JOIN dbo.institutions i ON i.unitid = e.unitid
-- WHERE i.inst_name LIKE 'Fordham%';
