# ingestion/producers/traffic_producer.py
import random
import time
import json
import argparse
from datetime import datetime, timezone
from kafka import KafkaProducer

ZONES = [f"Zone_{i}" for i in range(1, 11)]
TOPIC = "smartcity-traffic"

def generate_record():
    return {
        "zone_id": random.choice(ZONES),
        "congestion_level": random.choice(["low", "medium", "high", "severe"]),
        "vehicle_count": random.randint(5, 300),
        "avg_speed_kmh": round(random.uniform(5, 110), 1),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

def run(interval, count, bootstrap_servers):
    producer = KafkaProducer(
        bootstrap_servers=bootstrap_servers,
        value_serializer=lambda v: json.dumps(v).encode("utf-8")
    )
    n = 0
    while count == 0 or n < count:
        record = generate_record()
        producer.send(TOPIC, value=record)
        print(f"Sent: {record}", flush=True)
        n += 1
        time.sleep(interval)
    producer.flush()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Traffic Kafka producer")
    parser.add_argument("--interval", type=float, default=2.0)
    parser.add_argument("--count", type=int, default=0)
    parser.add_argument("--bootstrap-servers", type=str, default="localhost:9092")
    args = parser.parse_args()
    run(args.interval, args.count, args.bootstrap_servers)
