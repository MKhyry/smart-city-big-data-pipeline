#!/bin/bash
# scripts/stop_pipeline_demo.sh
# Stops all producers, the console consumer, and the Spark streaming job
# started by run_full_pipeline_demo.sh. Does not stop Hadoop/Kafka/ZooKeeper
# services themselves.

echo "Stopping producers..."
pkill -f "traffic_producer.py"
pkill -f "weather_producer.py"
pkill -f "transit_producer.py"
pkill -f "incident_producer.py"

echo "Stopping console consumer..."
pkill -f "kafka-console-consumer.sh --topic smartcity-traffic"

echo "Stopping Spark streaming job..."
pkill -f "stream_ingest_to_hdfs.py"

echo "Done. Services (HDFS/YARN/ZooKeeper/Kafka) were left running."
echo "To stop those too: stop-all.sh"
