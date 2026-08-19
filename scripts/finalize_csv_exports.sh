#!/bin/bash
# scripts/finalize_csv_exports.sh

OUT="$HOME/smartcity_exports"
mkdir -p "$OUT"

# traffic_weather_impact
echo "zone_id,hour_window,condition,avg_speed_kmh,avg_vehicle_count,record_count" > "$OUT/traffic_weather_impact.csv"
cat /tmp/export/traffic_weather_impact/* >> "$OUT/traffic_weather_impact.csv"

# incident_summary
echo "zone_id,severity,incident_count,avg_response_time_minutes" > "$OUT/incident_summary.csv"
cat /tmp/export/incident_summary/* >> "$OUT/incident_summary.csv"

# transit_summary
echo "route_id,avg_delay_minutes,avg_passenger_count,record_count" > "$OUT/transit_summary.csv"
cat /tmp/export/transit_summary/* >> "$OUT/transit_summary.csv"

echo "CSV files ready in: $OUT"
ls -la "$OUT"
