# ingestion/consumers/validation_consumer.py
import json
import argparse
from kafka import KafkaConsumer

def run(topic, bootstrap_servers):
    consumer = KafkaConsumer(
        topic,
        bootstrap_servers=bootstrap_servers,
        auto_offset_reset="earliest",
        value_deserializer=lambda v: json.loads(v.decode("utf-8"))
    )
    print(f"Listening on topic: {topic}")
    for message in consumer:
        print(message.value, flush=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Kafka validation consumer")
    parser.add_argument("topic", type=str, help="Topic to consume from")
    parser.add_argument("--bootstrap-servers", type=str, default="localhost:9092")
    args = parser.parse_args()
    run(args.topic, args.bootstrap_servers)
