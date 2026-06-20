#!/bin/bash

DSPACE_DIR="/dspace"
LOG_FILE="/dspace/log/store-metrics-batch.log"

mkdir -p "$(dirname "$LOG_FILE")"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting store-metrics batch loop" | tee -a "$LOG_FILE"

ROUND=1

while true; do
    echo "--------------------------------------------------" | tee -a "$LOG_FILE"
    echo "[$(date '+%H:%M:%S')] Run #$ROUND starting..." | tee -a "$LOG_FILE"

    OUTPUT=$("$DSPACE_DIR/bin/dspace" store-metrics 2>&1)
    echo "$OUTPUT" | tee -a "$LOG_FILE"

    # Extract "Found XXXX"
    FOUND=$(echo "$OUTPUT" | grep -i "Found" | awk '{print $2}' | tail -1)

    # Safety check
    if ! [[ "$FOUND" =~ ^[0-9]+$ ]]; then
        FOUND=0
    fi

    echo "[$(date '+%H:%M:%S')] Found = $FOUND" | tee -a "$LOG_FILE"

    # Stop condition
    if [ "$FOUND" -eq 0 ]; then
        echo "[$(date '+%H:%M:%S')] No more records left. Finished." | tee -a "$LOG_FILE"
        break
    fi

    ROUND=$((ROUND + 1))

    # optional small pause to avoid CPU spike
    sleep 10
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] store-metrics batch processing complete" | tee -a "$LOG_FILE"
