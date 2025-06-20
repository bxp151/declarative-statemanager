WITH never_set AS (
       Select
       CASE 
           -- If no entries          
           WHEN COUNT(*) = 0 THEN 1
                      ELSE 0 
       END AS serveScreen
       FROM claimed_progress_level_log
),
not_set_in_30 AS (
       Select 
        CASE 
           -- If last entry is over 30 days ago
           WHEN CAST(STRFTIME('%s','now') AS INTEGER) * 1000 - timestamp > 2592000000 THEN 1
           ELSE 0 
       END AS serveScreen
       FROM claimed_progress_level_log
), combined_set AS(
select * from never_set
UNION ALL
select * from not_set_in_30
)
select 'claimed_progress_scaffold' AS screen,
    CASE 
        WHEN SUM(serveScreen) > 0 THEN 1 -- if one CTE is triggered
    ELSE 0
    END AS serveScreen
from combined_set

