#!/usr/bin/env bash
#
# Script: import-migrated-stats.sh
# Purpose: Import all migrated DSpace statistics CSV files into Solr
# Location: /dspace/bin/
# Author: Generated for Xolisa
# Date: March 2026
#

set -euo pipefail  # Exit on error, undefined variables, pipeline failures

# Configuration - adjust these paths if needed
DSPACE_BIN="/dspace/bin"                # path to dspace command
INPUT_DIR="/var/lib/pgsql/data/logs/tmp"
PATTERN="statistics_export_*_migrated.csv"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to DSpace bin directory
cd "$DSPACE_BIN" || {
	    echo -e "${RED}Error: Cannot cd to $DSPACE_BIN${NC}" >&2
    exit 1
}

echo "Starting import of migrated statistics CSV files..."
echo "Directory: $INPUT_DIR"
echo "Pattern:   $PATTERN"
echo "----------------------------------------"

# Check if any files exist
shopt -s nullglob  # Prevent loop if no files match
files=("$INPUT_DIR"/$PATTERN)

if [ ${#files[@]} -eq 0 ]; then
	    echo -e "${YELLOW}No files found matching pattern: $INPUT_DIR/$PATTERN${NC}"
	        echo "Nothing to import. Exiting."
		    exit 0
fi

success_count=0
failure_count=0

for csv in "${files[@]}"; do
	    filename=$(basename "$csv")
	        echo -n "Importing: $filename ... "

		    if [ ! -f "$csv" ] || [ ! -r "$csv" ]; then
			            echo -e "${RED}FAILED (file not readable)${NC}"
				            ((failure_count++))
					            continue
						        fi

							    # Run the import command
							        if ./dspace solr-import-export -i "$csv" > /dev/null 2>&1; then
									        echo -e "${GREEN}SUCCESS${NC}"
										        ((success_count++))
											    else
												            echo -e "${RED}FAILED${NC}"
													            ((failure_count++))
														            # Optional: log error details
															            echo "         Error log written to /dspace/log/dspace.log" >&2
																        fi
																done

																echo "----------------------------------------"
																echo "Import finished."
																echo -e "Successful: ${GREEN}$success_count${NC}"
																echo -e "Failed:     ${RED}$failure_count${NC}"
																echo "Total files processed: ${#files[@]}"

																if [ $failure_count -gt 0 ]; then
																    echo -e "${YELLOW}Check /dspace/log/dspace.log for details on failed imports.${NC}"
																fi
# Optional: suggest next steps
 if [ $success_count -gt 0 ]; then
    echo ""
    echo "Next recommended steps:"
    echo "  1. Update metrics in Solr:   ./dspace update-metrics-in-solr"
    echo "  2. Optimize Solr (optional): ./dspace update-metrics-in-solr -o"
    echo "  3. Reindex discovery (if needed): ./dspace index-discovery -b"
fi
