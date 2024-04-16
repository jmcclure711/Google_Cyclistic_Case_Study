 mon/*
1. First, I will be creating the cleaned dataset from a temporary table containing extracted date values, then filtering out the outlier trips and null station names.
*/

WITH extracted_tripdata AS (
   SELECT 
      ride_id,
      started_at,
      ended_at,
      rideable_type,
      start_station_name,
      end_station_name,
      CASE
         WHEN EXTRACT(DAYOFWEEK FROM started_at) = 1 THEN 'Sunday'
         WHEN EXTRACT(DAYOFWEEK FROM started_at) = 2 THEN 'Monday'
         WHEN EXTRACT(DAYOFWEEK FROM started_at) = 3 THEN 'Tuesday'
         WHEN EXTRACT(DAYOFWEEK FROM started_at) = 4 THEN 'Wednesday'
         WHEN EXTRACT(DAYOFWEEK FROM started_at) = 5 THEN 'Thursday'
         WHEN EXTRACT(DAYOFWEEK FROM started_at) = 6 THEN 'Friday'
         ELSE'Saturday' 
      END AS day_of_week,
      CASE
         WHEN EXTRACT(MONTH FROM started_at) = 1 THEN 'January'
         WHEN EXTRACT(MONTH FROM started_at) = 2 THEN 'February'
         WHEN EXTRACT(MONTH FROM started_at) = 3 THEN 'March'
         WHEN EXTRACT(MONTH FROM started_at) = 4 THEN 'April'
         WHEN EXTRACT(MONTH FROM started_at) = 5 THEN 'May'
         WHEN EXTRACT(MONTH FROM started_at) = 6 THEN 'June'
         WHEN EXTRACT(MONTH FROM started_at) = 7 THEN 'July'
         WHEN EXTRACT(MONTH FROM started_at) = 8 THEN 'August'
         WHEN EXTRACT(MONTH FROM started_at) = 9 THEN 'September'
         WHEN EXTRACT(MONTH FROM started_at) = 10 THEN 'October'
         WHEN EXTRACT(MONTH FROM started_at) = 11 THEN 'November'
         ELSE 'December'
      END AS month,
      EXTRACT(DAY FROM started_at) as day,
      EXTRACT(YEAR FROM started_at) AS year,
      TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_time_minutes,
      member_casual AS member_type
   FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data` 
),
cleaned_tripdata AS (
SELECT
  *
FROM
  extracted_tripdata
WHERE
  ride_time_minutes BETWEEN 1 AND 1440 
  AND start_station_name IS NOT NULL
  AND end_station_name IS NOT NULL 
),

-- This leaves a total of 4,258,846 trips to conduct analysis on.

-------------------------------------------ANALYSIS-------------------------------------------------------------

/*
1. Bike Type: Find out the different bikes used per customer type
*/

bike_type_data AS(
  SELECT
    rideable_type AS bike_type,
    member_casual AS member_type,
    COUNT(*) AS num_of_trips
  FROM cleaned_tripdata
  GROUP BY 
    rideable_type,
    member_casual
),

-----------------------------------------------------------------------------------------------

/*
2. Rides per month: How many rides were taken per month by both customer types?
*/

rides_per_month AS (
  SELECT
    month,
    member_casual AS member_type,
    COUNT(*) AS num_of_trips
  FROM cleaned_tripdata
  GROUP BY
    month,
    member_type
  ORDER BY month
),

-------------------------------------------------------------------------------------------------

/*
3. Rides per day: What was the ride distribution per each customer type by day of the week?
*/

rides_per_day AS (
  SELECT
   day_of_week,
   member_casual AS member_type,
   COUNT(*) AS num_of_trips
  FROM cleaned_tripdata
  GROUP BY 
    day_of_week,
    member_type
  ORDER BY 
    day_of_week 
),

--------------------------------------------------------------------------------------------------

/*
4. Rides per hour: What was the distribution of rides per hour of the day among both customer types?
*/

rides_per_hour AS (
  SELECT
    EXTRACT(HOUR FROM started_at) AS time_of_day,
    member_casual AS member_type,
    COUNT(*) AS num_of_trips
  FROM cleaned_tripdata
  GROUP BY
    member_type,
    time_of_day
), 

---------------------------------------------------------------------------------------------------

/*
5. Trip Duration: What is the difference among how long each ride took between each customer type?
*/

trip_duration AS (
  SELECT
    ride_time_minutes,
    member_casual AS member_type,
    COUNT(*) AS num_of_trips
  FROM cleaned_tripdata
  GROUP BY
    ride_time_minutes,
    member_type
)
