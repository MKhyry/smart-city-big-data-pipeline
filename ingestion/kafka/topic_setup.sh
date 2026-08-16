#!/bin/bash
# ingestion/kafka/topic_setup.sh

BROKER="localhost:9092"
TOPICS=("smartcity-traffic" "smartcity-weather" "smartcity-transit" "smartcity-incidents")

for TOPIC in "${TOPICS[@]}"; do
    kafka-topics.sh --create \
        --topic "$TOPIC" \
        --bootstrap-server "$BROKER" \
        --partitions 1 \
        --replication-factor 1
done

echo "Topics created:"
kafka-topics.sh --list --bootstrap-server "$BROKER"
