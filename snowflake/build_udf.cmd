rmdir .\dist /s /q
mkdir .\dist
call ..\npx_tsc.cmd
python ..\build_udf.py
