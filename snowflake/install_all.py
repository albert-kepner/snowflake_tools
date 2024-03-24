import os
from subprocess import check_output
import time
import re
import shutil


## pattern for directory names to scan to find Stored Procedures and UDFT(s)
pattern = r'[\w]+_TS$|[\w]+_UDTF$'

def install_jest(parent_path):
    path = os.path.join(parent_path, 'JEST_POC')
    os.chdir(path)
    result = check_output("jest_setup.cmd", shell=True)
    for line in result.decode('utf-8').split("\r\n"):
            print(line)

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

def install_dirs(parent_dir):
    time1 = time.perf_counter()

    dirs = filter_dirs(parent_dir,pattern)
    for dir in dirs:
        os.chdir(dir)
        if(dir.endswith("_UDTF")):
            result = check_output("npm install typescript ^4", shell=True)
        else:
            result = check_output("npm install snowproc", shell=True)
        continue
        
        for line in result.decode('utf-8').split("\r\n"):
            print(line)
    time2 = time.perf_counter()
    print(f"Build Completed in {time2 - time1:0.2f} seconds)")
    return 0
                        
def install_all():
    path = os.getcwd()
    install_jest(path)
    install_dirs(path)
       
install_all()