# Count how many files we have
ls /dspace/solr-export/*.csv | wc -l

# Import all files with progress tracking
for csv in /dspace/solr-export/*.csv; do
	    filename=$(basename "$csv")
	        echo -n "Importing $filename ... "
		    result=$(curl -s "http://localhost:8983/solr/statistics/update?commit=true" \
			            -H "Content-Type: application/csv" \
				            --data-binary @"$csv")
		        status=$(echo "$result" | grep -o '"status":[0-9]*' | head -1 | cut -d: -f2)
			    if [ "$status" = "0" ]; then
				            echo "✔ OK"
					        else
							        echo "✘ FAILED: $result"
								    fi
							    done

							    echo "=== All done ==="

							    # Check total documents imported
							    curl -s "http://localhost:8983/solr/statistics/select?q=*:*&rows=0" | grep numFound
