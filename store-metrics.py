#!/usr/bin/env python3

import subprocess
import re
import time

DSPACE_CMD = "/dspace/bin/dspace store-metrics"

run_count = 1

while True:
    print(f"\n[{time.strftime('%H:%M:%S')}] Run #{run_count} starting...")

    result = subprocess.run(
        DSPACE_CMD.split(),
        capture_output=True,
        text=True
    )

    output = result.stdout + result.stderr
    print(output)

    found_matches = re.findall(r"Found\s+(\d+)", output)
    added_matches = re.findall(r"Added\s+(\d+)\s+metrics", output)

    total_found = sum(int(x) for x in found_matches)
    total_added = sum(int(x) for x in added_matches)

    print(f"Summary: Found={total_found}, Added={total_added}")

    if total_added == 0:
        print("No more metrics added. Finished.")
        break

    run_count += 1

    # Optional pause
    time.sleep(5)
