
This folder holds the CSV exports produced in Phase 5 by `storage/hive/export_to_csv.hql` + `scripts/finalize_csv_exports.sh`. No real data files are committed here — CSVs are `.gitignore`d; this README documents the expected format only.

## Files & Columns

**traffic_weather_impact.csv**
```
zone_id,hour_window,condition,avg_speed_kmh,avg_vehicle_count,record_count
```

**incident_summary.csv**
```
zone_id,severity,incident_count,avg_response_time_minutes
```

**transit_summary.csv**
```
route_id,avg_delay_minutes,avg_passenger_count,record_count
```

## Regenerating
Run on the VM:
```
hive -f storage/hive/export_to_csv.hql
bash scripts/finalize_csv_exports.sh
```
Output lands in `~/smartcity_exports/` on the VM — transfer to Windows before opening in Power BI (see `Phase5_Visualization_Execution_Guide.md`).
