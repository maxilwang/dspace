#!/usr/bin/env python3

import subprocess
import re
import time
import sys

# Command to run
DSPACE_CMD = ["/dspace/bin/dspace", "solr-upgrade-statistics-6x"]

run_count = 1
max_runs = 200          # Safety limit - adjust as needed
batch_size = 50000      # You can increase this for faster runs (e.g. 100000)

print("🚀 Starting DSpace Solr Statistics Legacy ID Upgrade Loop...")
print(f"Batch size: {batch_size:,} records per run\n")

while run_count <= max_runs:
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] Run #{run_count} starting...")

    try:
        result = subprocess.run(
            DSPACE_CMD + ["--num-records", str(batch_size)],
            capture_output=True,
            text=True,
            timeout=600  # 10 minutes timeout per run
        )
    except subprocess.TimeoutExpired:
        print("❌ ERROR: Command timed out!")
        sys.exit(1)
    except FileNotFoundError:
        print("❌ ERROR: dspace command not found!")
        sys.exit(1)

    output = result.stdout + result.stderr
    print(output.strip())

    # Extract the TOTAL legacy records
    total_matches = re.findall(r"TOTAL\s+([\d,]+)", output)
    
    if total_matches:
        # Remove commas and convert to int
        current_total = int(total_matches[-1].replace(",", ""))
        print(f"\n📊 Current legacy records remaining: {current_total:,}")
    else:
        current_total = None
        print("\n⚠️  Could not parse total legacy records.")

    # Check if finished
    if current_total is not None and current_total == 0:
        print(f"\n✅ ✅ ✅ Upgrade completed successfully after {run_count} runs!")
        break

    # If no progress was made (rare)
    if current_total is not None and run_count > 1:
        # You could add more sophisticated progress check here if needed
        pass

    run_count += 1
    time.sleep(5)  # Short pause between runs

else:
    print(f"\n⚠️  Reached maximum runs ({max_runs}). Process stopped.")
    print("You can run the script again later to continue.")

print("\n💡 Recommendation: After completion, optimize your Solr statistics core:")
print("   ./bin/dspace index-statistics -o")
