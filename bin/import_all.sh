LOG_DIR="/var/lib/pgsql/data/logs/"
mkdir -p "$LOG_DIR"

for csv in /var/lib/pgsql/data/logs/tmp/statistics_export_*.csv; do
    filename=$(basename "$csv")
       logfile="$LOG_DIR/${filename%.csv}_import.log"
   echo "Importing: $filename"
   ./dspace solr-import-statistics -i "$csv" > "$logfile" 2>&1
    if [ $? -eq 0 ]; then
      echo "  ✔ Success: $filename"
     else
     echo "  ✘ FAILED: $filename"
    echo "  --- Error log ---"
    cat "$logfile"
    echo "  -----------------"
    fi
done
