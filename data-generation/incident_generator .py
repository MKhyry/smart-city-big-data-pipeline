# data-generation/incident_generator.py
import random
import time
import json
import uuid
import argparse
from datetime import datetime, timezone

ZONES = [f"Zone_{i}" for i in range(1, 11)]
INCIDENT_TYPES = ["accident", "breakdown", "hazard", "fire", "medical"]
SEVERITIES = ["low", "medium", "high", "critical"]

def generate_record():
    return {
        "incident_id": str(uuid.uuid4()),
        "type": random.choice(INCIDENT_TYPES),
        "zone_id": random.choice(ZONES),
        "response_time_minutes": round(random.uniform(2, 45), 1),
        "severity": random.choice(SEVERITIES),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

def run(interval, count, output):
    n = 0
    while count == 0 or n < count:
        record = generate_record()
        line = json.dumps(record)
        if output == "stdout":
            print(line, flush=True)
        else:
            with open(output, "a") as f:
                f.write(line + "\n")
        n += 1
        time.sleep(interval)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Incident data generator")
    parser.add_argument("--interval", type=float, default=15.0, help="Seconds between records")
    parser.add_argument("--count", type=int, default=0, help="Number of records (0 = infinite)")
    parser.add_argument("--output", type=str, default="stdout", help="'stdout' or file path")
    args = parser.parse_args()
    run(args.interval, args.count, args.output)
