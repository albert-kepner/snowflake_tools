rmdir dist /s /q
mkdir dist
call ..\run_snowproc_compile.cmd
rmdir build /s /q
mkdir build
python ..\build_sp.py
