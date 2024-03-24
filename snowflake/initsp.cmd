echo initsp create directory %1
mkdir %1
mkdir %1\src
mkdir %1\dist
mkdir %1\build
copy .\scaffold\* %1
copy .\scaffold\src\* .\%1\src
copy .\scaffold\scripts\* .\%1
cd %1
npm install snowproc
