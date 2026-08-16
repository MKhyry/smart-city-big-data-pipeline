# ingestion/producers/transit_producer.py
import random
import time
import json
import argparse
from datetime import datetime, timedelta, timezone
from kafka import KafkaProducer

ROUTES = [f"Route_{i}" for i in range(1, 21)]
TOPIC = "smartcity-transit"

def generate_record():
    scheduled = datetime.now(timezone.utc)
    delay_minutes = max(0, round(random.gauss(4, 6), 1))
    actual = scheduled + timedelta(minutes=delay_minutes)
    return {
        "route_id": random.choice(ROUTES),
        "scheduled_time": scheduled.isoformat(),
        "actual_time": actual.isoformat(),
        "delay_minutes": delay_minutes,
        "passenger_count": random.randint(0, 80),
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
    parser = argparse.ArgumentParser(description="Transit Kafka producer")
    parser.add_argument("--interval", type=float, default=3.0)
    parser.add_argument("--count", type=int, default=0)
    parser.add_argument("--bootstrap-servers", type=str, default="localhost:9092")
    args = parser.parse_args()
    run(args.interval, args.count, args.bootstrap_servers)
