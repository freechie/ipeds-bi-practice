-- Peek only AFTER you attempt prompts.sql

-- PROMPT 1
WITH base AS (
  SELECT
    i.unitid,
    i.inst_name,
    (e.ft_ug + e.pt_ug) AS ug_headcount
  FROM institutions i
  JOIN enrollment e ON e.unitid = i.unitid
  WHERE i.state_abbr = 'NJ'
    AND i.control = 'public'
    AND i.level = '4-year'
    AND e.year = 2023
),
dedup AS (
  -- enrollment may have seeded duplicates
  SELECT unitid, inst_name, MAX(ug_headcount) AS ug_headcount
  FROM base
  GROUP BY unitid, inst_name
)
SELECT
  inst_name,
  ug_headcount,
  RANK() OVER (ORDER BY ug_headcount DESC) AS rnk
FROM dedup
ORDER BY rnk, inst_name;

-- PROMPT 2
WITH y2022 AS (
  SELECT unitid, MAX(ft_ug + pt_ug) AS hc_2022
  FROM enrollment
  WHERE year = 2022
  GROUP BY unitid
),
y2023 AS (
  SELECT unitid, MAX(ft_ug + pt_ug) AS hc_2023
  FROM enrollment
  WHERE year = 2023
  GROUP BY unitid
)
SELECT
  i.inst_name,
  y2022.hc_2022,
  y2023.hc_2023,
  (y2023.hc_2023 - y2022.hc_2022) AS yoy_change,
  CASE
    WHEN y2023.hc_2023 > y2022.hc_2022 THEN 'up'
    WHEN y2023.hc_2023 < y2022.hc_2022 THEN 'down'
    ELSE 'flat'
  END AS direction
FROM y2022
JOIN y2023 ON y2023.unitid = y2022.unitid
JOIN institutions i ON i.unitid = y2022.unitid
ORDER BY yoy_change DESC;

-- PROMPT 3
WITH ranked AS (
  SELECT
    unitid,
    year,
    ft_ug,
    pt_ug,
    ug_total,
    grad_enroll,
    ROW_NUMBER() OVER (
      PARTITION BY unitid, year
      ORDER BY ft_ug DESC
    ) AS rn
  FROM enrollment
)
SELECT unitid, year, ft_ug, pt_ug, ug_total, grad_enroll
FROM ranked
WHERE rn = 1;

-- PROMPT 4
WITH c2023 AS (
  SELECT
    unitid,
    SUM(count) AS completion_count,
    COUNT(DISTINCT award_level) AS award_levels
  FROM completions
  WHERE year = 2023
  GROUP BY unitid
)
SELECT
  i.inst_name,
  COALESCE(c.completion_count, 0) AS completion_count,
  COALESCE(c.award_levels, 0) AS award_levels
FROM institutions i
LEFT JOIN c2023 c ON c.unitid = i.unitid
WHERE i.state_abbr = 'NJ'
ORDER BY completion_count DESC, i.inst_name;

-- PROMPT 5
WITH base AS (
  SELECT
    i.inst_name,
    i.state_abbr,
    MAX(e.ft_ug + e.pt_ug) AS ug_headcount,
    MAX(e.ft_ug) AS ft_ug,
    MAX(e.pt_ug) AS pt_ug
  FROM institutions i
  JOIN enrollment e ON e.unitid = i.unitid
  WHERE i.control = 'private_nonprofit'
    AND i.level = '4-year'
    AND i.state_abbr IN ('NY', 'NJ')
    AND e.year = 2023
  GROUP BY i.inst_name, i.state_abbr
)
SELECT
  inst_name,
  state_abbr,
  ug_headcount,
  ROUND(1.0 * ft_ug / NULLIF(ft_ug + pt_ug, 0), 3) AS ft_share
FROM base
WHERE ug_headcount >= 1000
ORDER BY ug_headcount DESC;
