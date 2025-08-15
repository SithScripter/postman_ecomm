@echo off
echo "Starting the test execution script..."

REM --- Assign arguments to variables ---
SET "USER_EMAIL=%~1"
SET "USER_PASSWORD=%~2"

REM --- Run Newman and let it create a default report file in the 'newman' folder ---
echo "Running Newman with provided credentials..."
call newman run "E2E_Ecommerce.postman_collection.json" ^
    --env-var "USER_EMAIL=%USER_EMAIL%" ^
    --env-var "USER_PASSWORD=%USER_PASSWORD%" ^
    -r cli,htmlextra