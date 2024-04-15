-- To start, I need to union the 12 monthly files containing the 2023 trip data into one table

CREATE TABLE Capstone_Cyclistic.2023_trip_data AS 
SELECT *
FROM (
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Jan_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Feb_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Mar_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Apr_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.May_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Jun_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Jul_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Aug_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Sep_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Oct_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Nov_2023_trip_data`
      UNION ALL
      SELECT * FROM `singular-backup-413521.Capstone_Cyclistic.Dec_2023_trip_data`
    );

SELECT *
FROM `singular-backup-413521. Capstone_Cyclistic.2023_trip_data;

-- This returned 5,719,877 rows of data which matches the sum of the twelve tables combined, so the union was successful.

---------------------------------------Preliminary Exploration------------------------------------------------------------

/* 1. ride_id
- Check the length opf all ID's and see if there are any outliers.
*/

SELECT
  LENGTH(ride_id) AS id_length,
  COUNT(*) AS #_of_ids
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`
GROUP BY LENGTH(ride_id)

-- Check to see if all ID's are unique.

SELECT
  COUNT(DISTINCT ride_id) AS distinct_ids
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`

-- There are 5,719,877 ID's, meaning all are distinct.
--------------------------------------------------------------------------------------------
/* 2. rideable_type
- Check the number of different types of bikes offered and the amount of trips taken with each.
*/

SELECT
  rideable_type,
  COUNT(rideable_type) AS biketype_trips
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`
GROUP BY rideable_type

-- There are three different types of bikes: electric, classic and docked. Most popular is electric, followed by classic and then docked as a distant third.

--------------------------------------------------------------------------------------------
/* 3. start_station/end_station
- Check for naming inconsistencies or null values
*/

SELECT
  start_station_name,
  COUNT(*) AS starting_trips
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`
GROUP BY start_station_name
ORDER BY start_station_name;

SELECT
  end_station_name,
  COUNT(*) AS ending_trips
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`
GROUP BY end_station_name
ORDER BY end_station_name;

-- There are over 875,000 null values for start_station_names and over 900,000 null values for end_station_names.
-- Over 400,000 of these instances occur where both are null at once. This information is too incomplete to use in my analysis in my opinion, so I will drop it from the set.

----------------------------------------------------------------------------------------------

/* 4. member_casual
- Will confirm there are only two rider types and check the amount of each through the year.
*/

SELECT 
  DISTINCT(member_casual)
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`;

SELECT 
  COUNT(member_casual) AS member_rides
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`
WHERE member_casual = 'member';

SELECT
  COUNT(member_casual) AS casual_rides
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`
WHERE member_casual = 'casual';

/* It is confirmed there are only member and casual rider types.
- There's record of 3,660,698 rides from members and 2,059,179 rides from casual customers
*/

-----------------------------------------------------------------------------------------------

/* 5. start_time + end_time
- Check for outliers for trip duration (under a minute and over a day)
*/

SELECT
  COUNT(*) AS outlier_trips
FROM `singular-backup-413521.Capstone_Cyclistic.2023_trip_data`
WHERE 
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1
  OR TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1440

-- There are 269,711 trips that are outliers and will be removed from the data. 

-----------------------------------------------------------------------------------------------



