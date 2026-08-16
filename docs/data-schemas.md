# docs/data-schemas.md

Schemas as emitted by the generators/producers and parsed by Spark. All timestamps are ISO 8601 UTC.

## Traffic
```json
{"zone_id": "Zone_10", "congestion_level": "low", "vehicle_count": 217, "avg_speed_kmh": 21.3, "timestamp": "2026-08-15T18:11:34.284496+00:00"}
```
| Field | Type | Notes |
|---|---|---|
| zone_id | string | `Zone_1`–`Zone_10` |
| congestion_level | string | low / medium / high / severe |
| vehicle_count | int | 5–300 |
| avg_speed_kmh | double | 5–110 |
| timestamp | timestamp | record time |

## Weather
```json
{"zone_id": "Zone_9", "temperature_c": 6.6, "condition": "rain", "timestamp": "2026-08-15T18:11:34.321585+00:00"}
```
| Field | Type | Notes |
|---|---|---|
| zone_id | string | `Zone_1`–`Zone_10` |
| temperature_c | double | 5–42 |
| condition | string | clear / rain / fog / cloudy / storm |
| timestamp | timestamp | record time |

## Transit
```json
{"route_id": "Route_2", "scheduled_time": "2026-08-15T18:11:34.352258+00:00", "actual_time": "2026-08-15T18:11:34.398100+00:00", "delay_minutes": 4.6, "passenger_count": 11, "timestamp": "2026-08-15T18:11:34.352386+00:00"}
```
| Field | Type | Notes |
|---|---|---|
| route_id | string | `Route_1`–`Route_20` |
| scheduled_time | timestamp | planned arrival |
| actual_time | timestamp | scheduled + delay |
| delay_minutes | double | ≥ 0 |
| passenger_count | int | 0–80 |
| timestamp | timestamp | record time |

## Incidents
```json
{"incident_id": "84708018-aed7-4419-8b30-a619de0be969", "type": "accident", "zone_id": "Zone_10", "response_time_minutes": 38.0, "severity": "low", "timestamp": "2026-08-15T18:11:34.386070+00:00"}
```
| Field | Type | Notes |
|---|---|---|
| incident_id | string | UUID |
| type | string | accident / breakdown / hazard / fire / medical |
| zone_id | string | `Zone_1`–`Zone_10` |
| response_time_minutes | double | 2–45 |
| severity | string | low / medium / high / critical |
| timestamp | timestamp | record time |

## Shared Join Keys
- `zone_id` — links traffic, weather, incidents
- `timestamp` (truncated to hour) — links traffic and weather in `traffic_weather_impact`
- `route_id` — transit-only, no direct zone link currently
