with baseQuery as (SELECT distinct resource_id,"date",
 Cast ((
    julianday(max(end_time) over(partition by resource_id,date)) - julianday(min(start_time) over (partition by resource_id,date))
) * 24 As Integer) as "hours_worked",
min(start_time) over(partition by resource_id,date),
max(end_time) over (partition by resource_id,date)
FROm test_de where is_clock_in = 1 or is_clock_out = 1
order by resource_id,date
),

weekly_hours AS (
  SELECT
    resource_id,
    strftime('%Y-%W', date) AS year_week,
    SUM(hours_worked) AS total_hours_weekly
  FROM baseQuery
  GROUP BY resource_id, year_week
)

SELECT
  resource_id,
  ROUND(AVG(total_hours_weekly), 2) AS avg_weekly_hours
FROM weekly_hours
GROUP BY resource_id;
