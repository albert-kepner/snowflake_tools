import os
import re

def walk_dir(path):
    codeFiles = []
    with os.scandir(path) as entries:
        for entry in entries:
            if(entry.name.endswith('.js')):
                print(f'Javascript found: {entry.name=}')
                codeFiles.append(path + '/' + entry.name)
            if(entry.is_dir()):
                print(f'Directory found: {entry.name=}')
                dir_path = path + '/' + entry.name
                moreFiles = walk_dir(dir_path)
                codeFiles.extend(moreFiles)
    return codeFiles
            
def build_udf(procname):
    codeFiles = walk_dir('./dist')
    with open('./src/'+procname) as sqlfile:
        sql_lines = sqlfile.readlines()
        # print(f'Number of lines in sql input file: {len(sql_lines)}')
    if not os.path.exists('./build'):
        os.makedirs('./build')
    with open('./build/'+procname, 'w') as outfile:
        # print(f'{outfile=}')
        for i in range(len(sql_lines)):
            sql_line = sql_lines[i]
            if re.search('<placeholder>',sql_line):
                placeholder_index = i
                break;
            outfile.write(sql_line)
        for codeFile in codeFiles:
            # print(f'{codeFile}')
            with open(codeFile) as infile:
                for line in infile.readlines():
                    if(line.startswith('export') | line.startswith('import')):
                        line = '// '+line
                    # print(f'{line=}')
                    outfile.write(line)
        for sql_line in sql_lines[placeholder_index+1:]:
            outfile.write(sql_line)
 
with os.scandir('./src') as entries:
    for entry in entries:
        if(entry.name.endswith('.sql')):
            procname = entry.name
            print(f'Procedure found: {procname=}')
            build_udf(procname)
            
