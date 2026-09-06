-- Sunday timed drills. Start with make practice then solve WITHOUT peeking at solutions.sql
-- sqlite3 -init sql/sqlite3.init ipeds_practice.sqlite
-- Or: DB Browser / VS Code SQLite Viewer / Azure Data Studio

-- =============================================================================
-- PROMPT 1 — CTE filter → aggregate → rank (15 min)
-- NJ public 4-years: 2023 undergrad headcount (ft_ug + pt_ug), rank largest→smallest
-- =============================================================================

-- YOUR SOLUTION HERE


-- =============================================================================
-- PROMPT 2 — Multi-CTE YoY (15 min)
-- Institutions with BOTH 2022 and 2023 enrollment: name, both headcounts, YoY change
-- =============================================================================

-- YOUR SOLUTION HERE


-- =============================================================================
-- PROMPT 3 — Window dedupe (15 min)
-- enrollment has duplicate unitid+year rows. Keep one: highest ft_ug wins.
-- =============================================================================

-- YOUR SOLUTION HERE


-- =============================================================================
-- PROMPT 4 — Left join + null trap (15 min)
-- All NJ institutions + 2023 completion total (0 if none) + distinct award_level count
-- Year filter must NOT turn the left join into an inner join
-- =============================================================================

-- YOUR SOLUTION HERE


-- =============================================================================
-- PROMPT 5 — Messy stakeholder ask (15 min)
-- Private nonprofit 4-years in NY or NJ, 2023 ug headcount >= 1000,
-- ft share = ft_ug / (ft_ug + pt_ug) with divide-by-zero guard, sort by headcount desc
-- =============================================================================

-- YOUR SOLUTION HERE
