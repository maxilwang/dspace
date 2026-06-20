# col 3=submitter, 10=type, 18=workflowItemId, 22=solarYear, 25=actor, 31=epersonid, 32=fisc
import csv
with open('/var/lib/pgsql/data/logs/tmp/statistics_export_2021-10_000.csv') as f:
    rows = list(csv.reader(f))
    cols = {3:'submitter', 10:'type', 18:'workflowItemId', 22:'solarYear', 25:'actor', 31:'epersonid', 32:'fiscalYear'}
    for r in rows[1:4]:
        for col, name in cols.items():
            val = r[col-1] if len(r) >= col else 'N/A'
            print(f'{name}: {val}')
        print('---')

