#!/bin/bash
# scripts/setup_hdfs.sh

BASE="/data/smartcity/raw"

hdfs dfs -mkdir -p "$BASE/traffic"
hdfs dfs -mkdir -p "$BASE/weather"
hdfs dfs -mkdir -p "$BASE/transit"
hdfs dfs -mkdir -p "$BASE/incidents"

hdfs dfs -mkdir -p /data/smartcity/checkpoints/traffic
hdfs dfs -mkdir -p /data/smartcity/checkpoints/weather
hdfs dfs -mkdir -p /data/smartcity/checkpoints/transit
hdfs dfs -mkdir -p /data/smartcity/checkpoints/incidents

echo "HDFS structure created:"
hdfs dfs -ls -R /data/smartcity
