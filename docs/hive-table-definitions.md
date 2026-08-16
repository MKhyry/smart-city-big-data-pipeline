# docs/hive-table-definitions.md

Reference for all tables in the `smartcity` Hive database. All are `EXTERNAL`, `STORED AS PARQUET`, pointing to HDFS paths written by Spark.

## Raw Tables (`create_raw_tables.hql`)

| Table | Location | Columns |
|---|---|---|
| `raw_traffic` | `/data/smartcity/raw/traffic` | zone_id STRING, congestion_level STRING, vehicle_count INT, avg_speed_kmh DOUBLE, timestamp TIMESTAMP |
| `raw_weather` | `/data/smartcity/raw/weather` | zone_id STRING, temperature_c DOUBLE, condition STRING, timestamp TIMESTAMP |
| `raw_transit` | `/data/smartcity/raw/transit` | route_id STRING, scheduled_time TIMESTAMP, actual_time TIMESTAMP, delay_minutes DOUBLE, passenger_count INT, timestamp TIMESTAMP |
| `raw_incidents` | `/data/smartcity/raw/incidents` | incident_id STRING, type STRING, zone_id STRING, response_time_minutes DOUBLE, severity STRING, timestamp TIMESTAMP |

Populated continuously by `processing/spark_jobs/stream_ingest_to_hdfs.py`.

## Aggregated Tables (`create_agg_tables.hql`)

| Table | Location | Columns |
|---|---|---|
| `traffic_weather_impact` | `/data/smartcity/aggregated/traffic_weather_impact` | zone_id STRING, hour_window TIMESTAMP, condition STRING, avg_speed_kmh DOUBLE, avg_vehicle_count DOUBLE, record_count BIGINT |
| `incident_summary` | `/data/smartcity/aggregated/incident_summary` | zone_id STRING, severity STRING, incident_count BIGINT, avg_response_time_minutes DOUBLE |

Populated by a single run of `processing/spark_jobs/batch_aggregate.py`.

## Export-Time Table (`export_to_csv.hql`)

| Table | Location | Columns |
|---|---|---|
| `transit_delay_summary` | Hive-managed (internal, created via `CTAS` from `raw_transit`) | route_id STRING, avg_delay_minutes DOUBLE, avg_passenger_count DOUBLE, record_count BIGINT |

Built inline during Phase 5 export — not backed by a Spark-written HDFS directory like the others.

## Rebuild Order
1. `hive -f storage/hive/create_raw_tables.hql`
2. `hive -f storage/hive/create_agg_tables.hql`
3. `hive -f storage/hive/export_to_csv.hql` (also builds `transit_delay_summary` and exports CSVs)
