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

def clean_dist_and_build_dirs(parent_dir):
    
    for filename in os.listdir(parent_dir):
        if filename in ['dist','build']:
            print(filename+' can be removed')
            file_path = os.path.join(parent_dir, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)    
            except Exception as e:
                print('Failed to delete %s. Reason: %s' % (file_path, e))

def clean_dirs_for_parent(parent_dir):
    dirs = filter_dirs(parent_dir,pattern)
    for dir in dirs:
        clean_dist_and_build_dirs(dir)
        
def clean_dirs():
    path = os.getcwd()
    clean_dirs_for_parent(path)
    
clean_dirs()
