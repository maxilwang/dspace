#!/bin/bash

# store-metrics-batch.sh
# Runs dspace store-metrics in batches to reduce system load

DSPACE_DIR="/dspace"   # adjust to your path
BATCH_SIZE=1000
SLEEP_SECONDS=30            # pause between batches

LOG_FILE="/dspace/log/store-metrics-batch.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Starting batched store-metrics run" | tee -a "$LOG_FILE"

OFFSET=0

while true; do
    echo "[$(date '+%H:%M:%S')] Running batch: offset=$OFFSET, limit=$BATCH_SIZE" | tee -a "$LOG_FILE"

    OUTPUT=$("$DSPACE_DIR/bin/dspace" store-metrics -l $BATCH_SIZE -o $OFFSET 2>&1)
    echo "$OUTPUT" | tee -a "$LOG_FILE"

    # Check how many were found/added in this batch
    FOUND=$(echo "$OUTPUT" | grep -oP 'Found \K[0-9]+' | head -1)

    if [ -z "$FOUND" ] || [ "$FOUND" -eq 0 ]; then
        echo "[$(date '+%H:%M:%S')] No more records found. Done." | tee -a "$LOG_FILE"
        break
    fi

    OFFSET=$((OFFSET + BATCH_SIZE))

    echo "[$(date '+%H:%M:%S')] Sleeping ${SLEEP_SECONDS}s before next batch..." | tee -a "$LOG_FILE"
    sleep "$SLEEP_SECONDS"
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Batched run complete." | tee -a "$LOG_FILE"
