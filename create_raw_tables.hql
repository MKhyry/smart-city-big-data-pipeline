-- storage/hive/create_raw_tables.hql

CREATE DATABASE IF NOT EXISTS smartcity;
USE smartcity;

CREATE EXTERNAL TABLE IF NOT EXISTS raw_traffic (
    zone_id STRING,
    congestion_level STRING,
    vehicle_count INT,
    avg_speed_kmh DOUBLE,
    `timestamp` TIMESTAMP
)
STORED AS PARQUET
LOCATION '/data/smartcity/raw/traffic';

CREATE EXTERNAL TABLE IF NOT EXISTS raw_weather (
    zone_id STRING,
    temperature_c DOUBLE,
    condition STRING,
    `timestamp` TIMESTAMP
)
STORED AS PARQUET
LOCATION '/data/smartcity/raw/weather';

CREATE EXTERNAL TABLE IF NOT EXISTS raw_transit (
    route_id STRING,
    scheduled_time TIMESTAMP,
    actual_time TIMESTAMP,
    delay_minutes DOUBLE,
    passenger_count INT,
    `timestamp` TIMESTAMP
)
STORED AS PARQUET
LOCATION '/data/smartcity/raw/transit';

CREATE EXTERNAL TABLE IF NOT EXISTS raw_incidents (
    incident_id STRING,
    type STRING,
    zone_id STRING,
    response_time_minutes DOUBLE,
    severity STRING,
    `timestamp` TIMESTAMP
)
STORED AS PARQUET
LOCATION '/data/smartcity/raw/incidents';

SHOW TABLES;
