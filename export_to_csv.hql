-- storage/hive/export_to_csv.hql

USE smartcity;

-- Export traffic_weather_impact
INSERT OVERWRITE LOCAL DIRECTORY '/tmp/export/traffic_weather_impact'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT zone_id, hour_window, condition, avg_speed_kmh, avg_vehicle_count, record_count
FROM traffic_weather_impact;

-- Export incident_summary
INSERT OVERWRITE LOCAL DIRECTORY '/tmp/export/incident_summary'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT zone_id, severity, incident_count, avg_response_time_minutes
FROM incident_summary;

-- Export transit_summary
INSERT OVERWRITE LOCAL DIRECTORY '/tmp/export/transit_summary'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT route_id, avg_delay_minutes, avg_passenger_count, record_count
FROM transit_summary;
