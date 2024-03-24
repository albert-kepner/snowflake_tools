import os
import re
path = os.getcwd()

def make_drop_script(parent_dir):
    scratch_dir = os.path.join(parent_dir, "scratch")
    in_path = os.path.join(scratch_dir, "ARGUMENTS.tsv")
    out_path = os.path.join(scratch_dir, "drop_script.sql")
    with open(in_path) as in_file:
        in_lines = in_file.readlines()
    with open(out_path, 'w') as outfile:
        for line in in_lines:
            match1 = re.match(r'^2.(.*_TS\(.*\))', line)
            match3 = re.match(r'^1.(CS_ECHO|POST_KEY_VALUES|POST_MESSAGES)',line)
            if match3:
                continue;
            if(match1):
                txt = f"drop procedure {match1.groups()[0]};\n"
                outfile.write ( txt )
            else:
                match2 = re.match(r'^1.(.*\)) RETURN', line)
                if(match2):
                    txt = f"drop function {match2.groups()[0]};\n"
                    outfile.write ( txt )
                
make_drop_script(path)
