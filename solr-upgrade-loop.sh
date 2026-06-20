#!/bin/bash

echo "Starting Solr statistics UUID migration loop..."
echo "Started at: $(date)"
echo "=============================================="

ITERATION=0

while true; do
   ITERATION=$((ITERATION + 1))
   echo ""
   echo "--- Iteration $ITERATION at $(date) ---"

    OUTPUT=$(sudo -u tomcat /dspace/bin/dspace solr-upgrade-statistics-6x 2>&1)
    echo "$OUTPUT"
    TOTAL=$(echo "$OUTPUT" | grep "TOTAL\.\.\." | grep -oP '[\d,]+(?=\s+TOTAL)' | tr -d ',')
    echo "Remaining legacy records: $TOTAL"
    if [ "$TOTAL" = "0" ] || [ -z "$TOTAL" ]; then
        echo ""
        echo "=============================================="
        echo "Migration complete at: $(date)"
        echo "Total iterations run: $ITERATION"
        echo "=============================================="
        break
    fi

    sleep 5
done
