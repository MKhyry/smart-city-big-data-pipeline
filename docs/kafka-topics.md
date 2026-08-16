# docs/kafka-topics.md

Broker: single-node Kafka 2.5.0, `localhost:9092`. All topics: 1 partition, replication factor 1 (created via `ingestion/kafka/topic_setup.sh`).

| Topic | Producer | Consumer | Message Schema |
|---|---|---|---|
| `smartcity-traffic` | `ingestion/producers/traffic_producer.py` | `stream_ingest_to_hdfs.py`, `validation_consumer.py` | see `docs/data-schemas.md` |
| `smartcity-weather` | `ingestion/producers/weather_producer.py` | `stream_ingest_to_hdfs.py`, `validation_consumer.py` | see `docs/data-schemas.md` |
| `smartcity-transit` | `ingestion/producers/transit_producer.py` | `stream_ingest_to_hdfs.py`, `validation_consumer.py` | see `docs/data-schemas.md` |
| `smartcity-incidents` | `ingestion/producers/incident_producer.py` | `stream_ingest_to_hdfs.py`, `validation_consumer.py` | see `docs/data-schemas.md` |

**Manual validation:**
```
python3 ingestion/consumers/validation_consumer.py smartcity-traffic
```

**List/inspect topics:**
```
kafka-topics.sh --list --bootstrap-server localhost:9092
kafka-topics.sh --describe --topic smartcity-traffic --bootstrap-server localhost:9092
```

**Known limitation:** single partition per topic means no parallel consumption within a topic — acceptable at current data volume, would need revisiting for higher throughput.
