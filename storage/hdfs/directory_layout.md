# storage/hdfs/directory_layout.md

Actual HDFS structure as created by `scripts/setup_hdfs.sh` and populated by the Spark jobs.

```
/data/smartcity/
│
├── raw/                          # written continuously by stream_ingest_to_hdfs.py
│   ├── traffic/                  # Parquet, append mode
│   ├── weather/                  # Parquet, append mode
│   ├── transit/                  # Parquet, append mode
│   └── incidents/                # Parquet, append mode
│
├── checkpoints/                  # Spark Structured Streaming checkpoint state (one per stream)
│   ├── traffic/
│   ├── weather/
│   ├── transit/
│   └── incidents/
│
└── aggregated/                   # written once per run by batch_aggregate.py, overwrite mode
    ├── traffic_weather_impact/
    └── incident_summary/
```

**Notes:**
- `checkpoints/` must never be deleted while a stream is running — it tracks Kafka offsets already processed.
- `aggregated/` is overwritten on every `batch_aggregate.py` run — re-run it after new raw data accumulates for updated numbers.
- `raw/` grows indefinitely; no retention/cleanup policy defined yet — acceptable for a graduation-project scope.

**Quick inspection commands:**
```
hdfs dfs -ls -R /data/smartcity
hdfs dfs -du -h /data/smartcity/raw
```
