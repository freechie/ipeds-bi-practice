SELECT i.inst_name, e.year, e.ft_ug, e.pt_ug, e.ug_total
FROM enrollment e
JOIN institutions i ON i.unitid = e.unitid
WHERE i.inst_name = 'Fordham University' AND e.year = 2023;
