-- storage/hive/create_agg_tables.hql

USE smartcity;

CREATE EXTERNAL TABLE IF NOT EXISTS traffic_weather_impact (
    zone_id STRING,
    hour_window TIMESTAMP,
    condition STRING,
    avg_speed_kmh DOUBLE,
    avg_vehicle_count DOUBLE,
    record_count BIGINT
)
STORED AS PARQUET
LOCATION '/data/smartcity/aggregated/traffic_weather_impact';

CREATE EXTERNAL TABLE IF NOT EXISTS incident_summary (
    zone_id STRING,
    severity STRING,
    incident_count BIGINT,
    avg_response_time_minutes DOUBLE
)
STORED AS PARQUET
LOCATION '/data/smartcity/aggregated/incident_summary';

CREATE EXTERNAL TABLE IF NOT EXISTS transit_summary (
    route_id STRING,
    avg_delay_minutes DOUBLE,
    avg_passenger_count DOUBLE,
    record_count BIGINT
)
STORED AS PARQUET
LOCATION '/data/smartcity/aggregated/transit_summary';

SHOW TABLES;
