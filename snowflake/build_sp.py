import os 
with os.scandir('./dist') as entries:
    for entry in entries:
        if(entry.name.endswith('.sql')):
            procname = entry.name
            print(f'Procedure found: {procname=}')
            with open('./dist/'+procname) as sqlfile:
                sql_lines = sqlfile.readlines()
                print(f'Number of lines in sql input file: {procname} {len(sql_lines)}')
            with open('./build/'+procname, 'w') as outfile:
                for line in sql_lines:
                    if(line.startswith('export') | line.startswith('import')):
                        line = '// '+line
                    # print(f'{line=}')
                    outfile.write(line)
