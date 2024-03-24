REM ## This script takes one parameter, the name of a folder to contain a new UDF (User Defined Snowflake function)
REM ## This folder is created as a stand-alone npm project.
REM ## The remainder of the script does a build of a demo version of a UDF.
REM ## Python is required and must be on your Path to run this script.
REM ## This script expects a template of your Javascript UDF to be in the ./src folder with a filename 
REM ## ending in ".sql" The template defines the parameters and return value of the UDF and can
REM ## call typscript functions from other files in the ./src folder.
echo initsp create directory %1
mkdri %1
mkdir %1\src
mkdir %1\dist
mkdir %1\build
copy .\scaffold_udf\* %1
copy .\scaffold_udf\src\* .\%1\src
copy .\scaffold_udf\scripts\* .\%1
cd %1
REM ##
REM ## Run
REM ## npm install --save-dev typescript
call ..\npm_install_typescript.cmd
REM ##
REM ## Project setup is complete at this point.
REM ## The remainder of this script builds a demo UDF
REM ##
REM ## This script (1) runs the typscript transpiler tsc so that 
REM ## Typescript file(s) in your <project>/src folder are transpile into javascript under the ./dist folder.
REM ## You can run the command "npx tsc" to run the typescript transpiler, manually.
REM ## This script (2) runs a python script with "python build_udf.py" to combine
REM ## the javascipt files with the DEMO_UDF.sql file in the src folder
REM ## into a DEMO_UDF.sql file in the ./build folder.
REM ## You can just run the command "build.cmd" to repeat these steps during development.
call build.cmd
REM ##
REM ## You should now have a build/DEMO_UDF.sql file in the ./build folder.
REM ## If you compile this sql in a Snowflake worksheet, you should be able to call it like this:
REM ## select demo_udf(parse_json('[]'),1::FLOAT,1::FLOAT); 
REM ## It expects a VARIANT, and 2 FLOATS as arguments.
REM ##
REM ## You can rename/edit src/DEMO_UDF.sql, and modify (or create new) typescript files under ./src
REM ## into something useful to create a new Snowflake Javascript UDF.

