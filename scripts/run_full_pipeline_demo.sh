#!/bin/bash
# scripts/run_full_pipeline_demo.sh
# Automates and visually demonstrates the entire Smart City pipeline flow:
# services -> producers -> consumer proof -> Spark streaming -> Spark batch
# -> HDFS check -> Hive tables -> CSV export. Opens a separate terminal
# window per live component so each step is visible while running.

set -uo pipefail

# ============================================================
# CONFIG — edit these to match your VM
# ============================================================
PROJECT_ROOT="/home/bigdata/Desktop/project/smart_city"
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-$HADOOP_HOME/etc/hadoop}"
DATA_COLLECTION_SECONDS="${1:-90}"   # how long to let data flow before batch runs
LOG_DIR="$PROJECT_ROOT/logs"
mkdir -p "$LOG_DIR"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()  { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# ============================================================
# Terminal launcher — GUI terminal if available, else background+log
# ============================================================
detect_terminal() {
    if command -v gnome-terminal &>/dev/null; then echo "gnome-terminal"
    elif command -v xterm &>/dev/null; then echo "xterm"
    elif command -v konsole &>/dev/null; then echo "konsole"
    else echo "none"
    fi
}
TERM_CMD=$(detect_terminal)

open_step() {
    # open_step "Window Title" "shell command to run"
    local title="$1"
    local cmd="$2"
    case "$TERM_CMD" in
        gnome-terminal)
            gnome-terminal --title="$title" -- bash -c "$cmd; exec bash" ;;
        xterm)
            xterm -T "$title" -e bash -c "$cmd; exec bash" & ;;
        konsole)
            konsole --title "$title" -e bash -c "$cmd; exec bash" & ;;
        none)
            warn "No GUI terminal found — running '$title' in background, logging to $LOG_DIR"
            nohup bash -c "$cmd" > "$LOG_DIR/${title// /_}.log" 2>&1 &
            ;;
    esac
}

# ============================================================
# STEP 0 — Sanity checks
# ============================================================
[ -d "$PROJECT_ROOT" ] || fail "PROJECT_ROOT not found: $PROJECT_ROOT"
log "Terminal launcher detected: $TERM_CMD"

# ============================================================
# STEP 1 — Start core services
# ============================================================
log "Starting HDFS + YARN..."
start-all.sh >> "$LOG_DIR/services.log" 2>&1

log "Starting ZooKeeper..."
zookeeper-server-start.sh -daemon "$KAFKA_HOME/config/zookeeper.properties"
sleep 5

log "Starting Kafka..."
unset CLASSPATH
kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties
sleep 8

log "Verifying services (jps)..."
NEEDED=("NameNode" "DataNode" "ResourceManager" "NodeManager" "QuorumPeerMain" "Kafka")
for i in {1..10}; do
    RUNNING=$(jps)
    MISSING=()
    for svc in "${NEEDED[@]}"; do
        echo "$RUNNING" | grep -q "$svc" || MISSING+=("$svc")
    done
    [ ${#MISSING[@]} -eq 0 ] && break
    sleep 3
done
if [ ${#MISSING[@]} -eq 0 ]; then
    ok "All services up: ${NEEDED[*]}"
else
    fail "Missing services after wait: ${MISSING[*]}. Check $LOG_DIR/services.log"
fi

# ============================================================
# STEP 2 — Launch producers (one terminal each, live output)
# ============================================================
log "Launching Kafka producers (traffic, weather, transit, incidents)..."
cd "$PROJECT_ROOT/ingestion/producers" || fail "producers dir not found"
open_step "Producer - Traffic"   "cd $PROJECT_ROOT/ingestion/producers && python3 traffic_producer.py"
open_step "Producer - Weather"   "cd $PROJECT_ROOT/ingestion/producers && python3 weather_producer.py"
open_step "Producer - Transit"   "cd $PROJECT_ROOT/ingestion/producers && python3 transit_producer.py"
open_step "Producer - Incidents" "cd $PROJECT_ROOT/ingestion/producers && python3 incident_producer.py"
sleep 3
ok "Producers launched."

# ============================================================
# STEP 3 — Launch console consumer (proof of data flow)
# ============================================================
log "Launching Kafka console consumer for smartcity-traffic (proof of flow)..."
open_step "Consumer - smartcity-traffic" \
    "kafka-console-consumer.sh --topic smartcity-traffic --bootstrap-server localhost:9092 --from-beginning"
sleep 3
ok "Consumer launched — check its window for live messages."

# ============================================================
# STEP 4 — Launch Spark Structured Streaming job (long-running)
# ============================================================
log "Launching Spark streaming job (stream_ingest_to_hdfs.py)..."
open_step "Spark Streaming - Kafka to HDFS" \
    "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR && cd $PROJECT_ROOT/processing/spark_jobs && spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.0.1 stream_ingest_to_hdfs.py"

log "Waiting for streaming job to start writing to HDFS raw/traffic (timeout 90s)..."
for i in {1..18}; do
    if hdfs dfs -test -e /data/smartcity/raw/traffic 2>/dev/null && \
       [ "$(hdfs dfs -ls /data/smartcity/raw/traffic 2>/dev/null | wc -l)" -gt 1 ]; then
        ok "Streaming job is writing data to HDFS."
        break
    fi
    sleep 5
done

# ============================================================
# STEP 5 — Let data accumulate
# ============================================================
log "Collecting live data for ${DATA_COLLECTION_SECONDS}s before running batch aggregation..."
for ((s=DATA_COLLECTION_SECONDS; s>0; s-=10)); do
    echo -ne "  ...${s}s remaining\r"
    sleep 10
done
echo ""
ok "Data collection window complete."

# ============================================================
# STEP 6 — Run Spark batch aggregation (foreground, synchronous)
# ============================================================
log "Running Spark batch aggregation job..."
cd "$PROJECT_ROOT/processing/spark_jobs" || fail "spark_jobs dir not found"
export HADOOP_CONF_DIR="$HADOOP_CONF_DIR"
spark-submit batch_aggregate.py | tee "$LOG_DIR/batch_aggregate.log"
[ ${PIPESTATUS[0]} -eq 0 ] || fail "batch_aggregate.py failed — see $LOG_DIR/batch_aggregate.log"
ok "Batch aggregation complete."

# ============================================================
# STEP 7 — Show HDFS state
# ============================================================
log "HDFS raw + aggregated contents:"
hdfs dfs -ls /data/smartcity/raw/traffic
hdfs dfs -ls /data/smartcity/aggregated/traffic_weather_impact
hdfs dfs -ls /data/smartcity/aggregated/incident_summary
hdfs dfs -ls /data/smartcity/aggregated/transit_summary

# ============================================================
# STEP 8 — Create/verify Hive tables (idempotent)
# ============================================================
log "Creating/verifying Hive tables..."
cd "$PROJECT_ROOT/storage/hive" || fail "hive dir not found"
hive -f create_raw_tables.hql | tee "$LOG_DIR/create_raw_tables.log"
hive -f create_agg_tables.hql | tee "$LOG_DIR/create_agg_tables.log"
ok "Hive tables ready."

# ============================================================
# STEP 9 — Export to CSV
# ============================================================
log "Exporting aggregated tables to CSV..."
hive -f export_to_csv.hql | tee "$LOG_DIR/export_to_csv.log"
cd "$PROJECT_ROOT/scripts" || fail "scripts dir not found"
bash finalize_csv_exports.sh | tee "$LOG_DIR/finalize_csv_exports.log"
ok "CSV export complete."

# ============================================================
# STEP 10 — Final summary
# ============================================================
log "Final CSV files:"
ls -la ~/smartcity_exports/
echo ""
log "Preview of each file:"
for f in ~/smartcity_exports/*.csv; do
    echo "--- $f ---"
    head -3 "$f"
    echo ""
done

echo ""
ok "PIPELINE DEMO COMPLETE."
warn "Producers, consumer, and the Spark streaming job are still running in their own terminal windows."
warn "Run scripts/stop_pipeline_demo.sh to stop them when you're done."
