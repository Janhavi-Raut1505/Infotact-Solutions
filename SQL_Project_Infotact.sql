use project_infotact;
SELECT *
FROM atmosync;

-- Count total sensor readings
SELECT COUNT(*) AS total_readings
FROM atmosync;

-- Count unique containers  
SELECT 
COUNT(DISTINCT Container_ID) AS total_containers
FROM atmosync;

-- Find the date range
SELECT
    MIN(Timestamp) AS start_date,
    MAX(Timestamp) AS end_date
FROM atmosync;

-- Average temperature and humidity
SELECT
    ROUND(AVG(Temperature_C), 2) AS avg_temperature,
    ROUND(AVG(Humidity_Percent), 2) AS avg_humidity
FROM atmosync;

-- Minimum and maximum temperature
SELECT
    MIN(Temperature_C) AS minimum_temperature,
    MAX(Temperature_C) AS maximum_temperature
FROM atmosync;

-- Container-wise average temperature
SELECT
    Container_ID,
    ROUND(AVG(Temperature_C), 2) AS avg_temperature
FROM atmosync
GROUP BY Container_ID
ORDER BY avg_temperature DESC;

-- Container-wise average humidity
SELECT
    Container_ID,
    ROUND(AVG(Humidity_Percent), 2) AS avg_humidity
FROM atmosync
GROUP BY Container_ID
ORDER BY avg_humidity DESC;

-- Find temperature alerts
SELECT
    Container_ID,
    Timestamp,
    Temperature_C,
    Humidity_Percent
FROM atmosync
WHERE Temperature_C < 5
   OR Temperature_C > 35
ORDER BY Temperature_C DESC;

-- Find humidity alerts
SELECT
    Container_ID,
    Timestamp,
    Temperature_C,
    Humidity_Percent
FROM atmosync
WHERE Humidity_Percent < 20
   OR Humidity_Percent > 80
ORDER BY Humidity_Percent;

-- Count temperature alerts per container
SELECT
    Container_ID,
    COUNT(*) AS temperature_alerts
FROM atmosync
WHERE Temperature_C < 5
   OR Temperature_C > 35
GROUP BY Container_ID
ORDER BY temperature_alerts DESC;

-- Count humidity alerts per container
SELECT
    Container_ID,
    COUNT(*) AS humidity_alerts
FROM atmosync
WHERE Humidity_Percent < 20
   OR Humidity_Percent > 80
GROUP BY Container_ID
ORDER BY humidity_alerts DESC;

-- Find containers with the highest number of alerts
SELECT
    Container_ID,
    COUNT(*) AS total_alerts
FROM atmosync
WHERE Temperature_C < 5
   OR Temperature_C > 35
   OR Humidity_Percent < 20
   OR Humidity_Percent > 80
GROUP BY Container_ID
ORDER BY total_alerts DESC;

-- Find containers with more than 20 alerts
SELECT
    Container_ID,
    COUNT(*) AS total_alerts
FROM atmosync
WHERE Temperature_C < 5
   OR Temperature_C > 35
   OR Humidity_Percent < 20
   OR Humidity_Percent > 80
GROUP BY Container_ID
HAVING COUNT(*) > 20
ORDER BY total_alerts DESC;

-- Classify each reading as Normal/Alert
SELECT
    Container_ID,
    Timestamp,
    Temperature_C,
    Humidity_Percent,
    CASE
        WHEN Temperature_C < 5 OR Temperature_C > 35
             OR Humidity_Percent < 20 OR Humidity_Percent > 80
        THEN 'Alert'
        ELSE 'Normal'
    END AS status
FROM atmosync;

-- Classify the type of alert
SELECT
    Container_ID,
    Timestamp,
    Temperature_C,-- 
    Humidity_Percent,
    CASE
        WHEN (Temperature_C < 5 OR Temperature_C > 35)
             AND (Humidity_Percent < 20 OR Humidity_Percent > 80)
            THEN 'Temperature + Humidity'
        WHEN Temperature_C < 5 OR Temperature_C > 35
            THEN 'Temperature'
        WHEN Humidity_Percent < 20 OR Humidity_Percent > 80
            THEN 'Humidity'
        ELSE 'Normal'
    END AS alert_type
FROM atmosync;

-- Count each type of alert
SELECT
    CASE
        WHEN (Temperature_C < 5 OR Temperature_C > 35)
             AND (Humidity_Percent < 20 OR Humidity_Percent > 80)
            THEN 'Temperature + Humidity'
        WHEN Temperature_C < 5 OR Temperature_C > 35
            THEN 'Temperature'
        WHEN Humidity_Percent < 20 OR Humidity_Percent > 80
            THEN 'Humidity'
        ELSE 'Normal'
    END AS alert_type,
    COUNT(*) AS reading_count
FROM atmosync
GROUP BY
    CASE
        WHEN (Temperature_C < 5 OR Temperature_C > 35)
             AND (Humidity_Percent < 20 OR Humidity_Percent > 80)
            THEN 'Temperature + Humidity'
        WHEN Temperature_C < 5 OR Temperature_C > 35
            THEN 'Temperature'
        WHEN Humidity_Percent < 20 OR Humidity_Percent > 80
            THEN 'Humidity'
        ELSE 'Normal'
    END
ORDER BY reading_count DESC;

-- Find the hottest readings
SELECT
    Container_ID,
    Timestamp,
    Temperature_C,
    Humidity_Percent
FROM atmosync
ORDER BY Temperature_C DESC
LIMIT 10;

-- Find the coldest readings
SELECT
    Container_ID,
    Timestamp,
    Temperature_C,
    Humidity_Percent
FROM atmosync
ORDER BY Temperature_C ASC
LIMIT 10;

-- Find the most humid readings
SELECT
    Container_ID,
    Timestamp,
    Temperature_C,
    Humidity_Percent
FROM atmosync
ORDER BY Humidity_Percent DESC
LIMIT 10;

-- Hourly temperature analysis
SELECT
    EXTRACT(HOUR FROM Timestamp) AS hour_of_day,
    ROUND(AVG(Temperature_C), 2) AS avg_temperature,
    ROUND(AVG(Humidity_Percent), 2) AS avg_humidity
FROM atmosync
GROUP BY EXTRACT(HOUR FROM Timestamp)
ORDER BY hour_of_day;

-- Hourly alert analysis
SELECT
    EXTRACT(HOUR FROM Timestamp) AS hour_of_day,
    COUNT(*) AS alert_count
FROM atmosync
WHERE Temperature_C < 5
   OR Temperature_C > 35
   OR Humidity_Percent < 20
   OR Humidity_Percent > 80
GROUP BY EXTRACT(HOUR FROM Timestamp)
ORDER BY alert_count DESC;

-- Daily monitoring summary
SELECT
    CAST(Timestamp AS DATE) AS reading_date,
    COUNT(*) AS total_readings,
    ROUND(AVG(Temperature_C), 2) AS avg_temperature,
    ROUND(AVG(Humidity_Percent), 2) AS avg_humidity,
    SUM(
        CASE
            WHEN Temperature_C < 5 OR Temperature_C > 35
                 OR Humidity_Percent < 20 OR Humidity_Percent > 80
            THEN 1 ELSE 0
        END
    ) AS alerts
FROM atmosync
GROUP BY CAST(Timestamp AS DATE)
ORDER BY reading_date;

-- Find containers with unusually high average temperature
SELECT
    Container_ID,
    ROUND(AVG(Temperature_C), 2) AS avg_temperature
FROM atmosync
GROUP BY Container_ID
HAVING AVG(Temperature_C) > 30
ORDER BY avg_temperature DESC;

-- Create a container risk ranking
SELECT
    Container_ID,
    COUNT(*) AS total_readings,

    SUM(
        CASE
            WHEN Temperature_C < 5 OR Temperature_C > 35
            THEN 1 ELSE 0
        END
    ) AS temperature_alerts,

    SUM(
        CASE
            WHEN Humidity_Percent < 20 OR Humidity_Percent > 80
            THEN 1 ELSE 0
        END
    ) AS humidity_alerts,

    SUM(
        CASE
            WHEN Temperature_C < 5 OR Temperature_C > 35
              OR Humidity_Percent < 20 OR Humidity_Percent > 80
            THEN 1 ELSE 0
        END
    ) AS total_alerts,

    ROUND(AVG(Temperature_C), 2) AS avg_temperature,
    ROUND(AVG(Humidity_Percent), 2) AS avg_humidity

FROM atmosync

GROUP BY Container_ID

ORDER BY total_alerts DESC;