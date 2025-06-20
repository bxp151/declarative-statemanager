WITH pending_state AS (
  SELECT *,
         MAX(CASE WHEN buildStatus = 'building' THEN 1 ELSE 0 END) OVER (
           PARTITION BY stateName
         ) AS has_building
  FROM state_view
)
SELECT *
FROM (
  SELECT *,
         MIN(stateChangeTimestamp) OVER (PARTITION BY stateName) AS minStateChangeTimestamp
  FROM pending_state
  WHERE buildStatus = 'pending' AND has_building = 0
)
WHERE stateChangeTimestamp = minStateChangeTimestamp;
