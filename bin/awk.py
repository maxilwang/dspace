
import csv
with open('/var/lib/pgsql/data/logs/tmp/statistics_export_2021-10_000.csv') as f:
    reader = csv.DictReader(f)
    fields = ['actor','epersonid','submitter','type','workflowItemId','fiscalYear','solarYear']
    for i, row in enumerate(reader):
        if i >= 3: break
        for field in fields:
            if field in row:
                print(f'{field}: {repr(row[field])}')
        print('---')

