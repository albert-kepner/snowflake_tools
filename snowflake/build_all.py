import os
from subprocess import check_output
import time
import re
import shutil


## pattern for directory names to scan to find Stored Procedures and UDFT(s)
pattern = r'[\w]+_TS$|[\w]+_UDTF$'

def  filter_dirs(parent_path, pattern):
    target_dirs = [];
    with os.scandir(parent_path) as entries:
        for entry in entries:
            if(entry.is_dir()):
                name = entry.name
                if (re.match(pattern, name)):
                    target =  os.path.join(parent_path, name)
                    target_dirs.append(target)
    return target_dirs

def build_dirs(parent_dir):
    time1 = time.perf_counter()

    dirs = filter_dirs(parent_dir,pattern)
    for dir in dirs:
        os.chdir(dir)
        result = check_output("build.cmd", shell=True)
        for line in result.decode('utf-8').split("\r\n"):
            print(line)
    time2 = time.perf_counter()
    print(f"Build Completed in {time2 - time1:0.2f} seconds)")
    return 0

def copy_dirs(parent_dir):
    out_dir = os.path.join(parent_dir, "OUTPUT")
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    
    folder = out_dir
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)    
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))
    
    time1 = time.perf_counter()
    dirs = filter_dirs(parent_dir,pattern)
    for dir in dirs:
        build_dir = os.path.join(dir, "build")
        with os.scandir(build_dir) as entries:
            for entry in entries:
                if entry.is_file() and entry.name.endswith(".sql"):
                    copy_from = os.path.join(build_dir, entry.name)
                    copy_to = os.path.join(out_dir, 'R__'+entry.name)
                    print(f'copy_dirs {copy_from} to: {copy_to}')
                    shutil.copy(copy_from, copy_to)
    time2 = time.perf_counter()
    print(f"Copy Completed in {time2 - time1:0.2f} seconds)")
    return 0

def combine_udf(parent_dir):
    combine_dir = os.path.join(parent_dir, "COMBINED_UDF")
    if not os.path.exists(combine_dir):
        os.makedirs(combine_dir)
    combine_path = os.path.join(combine_dir, "R__CombinedUDFScript.sql")
    time1 = time.perf_counter()
    ## Also copy manually created sql UDFs from SQL_UDF dir...
    build_dir = os.path.join(parent_dir, "SQL_UDF")
    with open(combine_path, 'w') as outfile:
        with os.scandir(build_dir) as entries:
            for entry in entries:
                if entry.is_file() and entry.name.endswith(".sql"):
                    with open(os.path.join(build_dir, entry.name)) as sqlfile:
                        sql_lines = sqlfile.readlines()
                        for line in sql_lines:
                            outfile.write(line)
                        outfile.write('\n\n')
    time2 = time.perf_counter()
    print(f"Copy Completed in {time2 - time1:0.2f} seconds)")
    return 0

def combine_output(parent_dir):
    udf_dir = os.path.join(parent_dir, "COMBINED_UDF")
    udf_path = os.path.join(udf_dir, "R__CombinedUDFScript.sql")
    combine_dir = os.path.join(parent_dir, "COMBINED")
    if not os.path.exists(combine_dir):
        os.makedirs(combine_dir)
    combine_path = os.path.join(combine_dir, "R__CombinedScript.sql")
    out_dir = os.path.join(parent_dir, "OUTPUT")
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    with open(combine_path, 'w') as outfile:
        with os.scandir(out_dir) as entries:
            with open(udf_path) as sqlfile:
                sql_lines = sqlfile.readlines()
                for line in sql_lines:
                    outfile.write(line)
                outfile.write('\n\n')
            for entry in entries:
                if entry.is_file() and entry.name.endswith(".sql"):
                    with open(os.path.join(out_dir, entry.name)) as sqlfile:
                        sql_lines = sqlfile.readlines()
                        for line in sql_lines:
                            outfile.write(line)
                        outfile.write('\n\n')
                        
def build_all():
    path = os.getcwd()
    build_dirs(path)
    copy_dirs(path)
    combine_udf(path)
    combine_output(path)
       
build_all()