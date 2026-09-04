-- Schema for ipeds_practice.sqlite (also target for SQL Server import)
-- Grain notes:
--   institutions: 1 row per UNITID (latest HD directory attributes)
--   enrollment: unitid x year (25 intentional duplicate rows seeded for dedupe drills)
--   completions: unitid x year x award_level

CREATE TABLE institutions (
  unitid INTEGER PRIMARY KEY,
  inst_name TEXT NOT NULL,
  state_abbr TEXT NOT NULL,
  control TEXT,          -- public | private_nonprofit | private_forprofit
  level TEXT,            -- 4-year | 2-year | less-than-2-year
  city TEXT
);

CREATE TABLE enrollment (
  unitid INTEGER NOT NULL,
  year INTEGER NOT NULL,
  ft_ug INTEGER NOT NULL,      -- fall full-time undergrad (EFALEVEL 22)
  pt_ug INTEGER NOT NULL,      -- fall part-time undergrad (EFALEVEL 42)
  ug_total INTEGER NOT NULL,   -- fall undergrad total (EFALEVEL 2)
  grad_enroll INTEGER NOT NULL -- approx: all_students - ug_total
);

CREATE TABLE completions (
  unitid INTEGER NOT NULL,
  year INTEGER NOT NULL,
  award_level INTEGER NOT NULL,
  count INTEGER NOT NULL
);
