# data-generation/transit_generator.py
import random
import time
import json
import argparse
from datetime import datetime, timedelta, timezone

ROUTES = [f"Route_{i}" for i in range(1, 21)]

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
    parser = argparse.ArgumentParser(description="Transit data generator")
    parser.add_argument("--interval", type=float, default=3.0, help="Seconds between records")
    parser.add_argument("--count", type=int, default=0, help="Number of records (0 = infinite)")
    parser.add_argument("--output", type=str, default="stdout", help="'stdout' or file path")
    args = parser.parse_args()
    run(args.interval, args.count, args.output)
