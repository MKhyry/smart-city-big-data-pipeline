# docs/architecture.md

## End-to-End Flow

```
[Python Generators] → [Kafka Topics] → [Spark Structured Streaming] → [HDFS raw/]
                                                                            │
                                                              [Spark Batch Aggregation]
                                                                            │
                                                                   [HDFS aggregated/]
                                                                            │
                                                                    [Hive External Tables]
                                                                            │
                                                                    [CSV Export]
                                                                            │
                                                              [Power BI Desktop (Windows)]
```

## Layer-by-Layer

**1. Data Generation** — 4 Python scripts (`data-generation/`) simulate traffic, weather, transit, and incident records with realistic, timestamped, zone-tagged JSON.

**2. Ingestion** — Each generator's logic is embedded in a matching Kafka producer (`ingestion/producers/`), publishing to one of 4 topics (`smartcity-traffic`, `-weather`, `-transit`, `-incidents`) on a single-broker Kafka 2.5.0 instance.

**3. Stream Processing & Storage** — `processing/spark_jobs/stream_ingest_to_hdfs.py` consumes all 4 topics via Spark Structured Streaming, parses JSON against explicit schemas, and writes Parquet continuously to `/data/smartcity/raw/` on HDFS 2.7.3.

**4. Batch Aggregation** — `processing/spark_jobs/batch_aggregate.py` reads the raw Parquet, joins traffic+weather by zone/hour and summarizes incidents by zone/severity, writing results to `/data/smartcity/aggregated/`.

**5. SQL Access Layer** — Hive 2.1.0 external tables (`storage/hive/`) expose both raw and aggregated data for SQL querying without moving the data.

**6. Export & Visualization** — Aggregated tables are exported to CSV (`storage/hive/export_to_csv.hql` + `scripts/finalize_csv_exports.sh`), transferred to Windows, and modeled in Power BI Desktop for the final dashboard.

## Execution Environment
All processing runs on a single CentOS VM (Java 8, Hadoop 2.7.3, Hive 2.1.0, Spark 3.0.1, Kafka 2.5.0). Development happens on 4 Windows laptops; code reaches the VM via `git pull` or VMware drag-and-drop (see `docs/team-workflow.md`).
