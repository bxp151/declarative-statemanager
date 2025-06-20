SELECT 'grade_selection_scaffold' AS screen,
       CASE WHEN COUNT( * ) = 0 THEN 1 
       ELSE 0 
       END AS serveScreen
  FROM overall_level_log;
