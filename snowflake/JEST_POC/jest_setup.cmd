REM JEST_POC
REM roughly following this link: https://medium.com/swlh/jest-with-typescript-446ea996cc68
npm install yarn
npx yarn init -y
npx yarn add -D typescript jest @types/jest ts-jest
npx tsc --init
npx yarn ts-jest config:init
REM run jest with 'npx jest' (after creating some tests...)
npx jest


