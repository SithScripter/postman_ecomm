@echo off
echo "Starting the test execution script..."

REM --- Assign arguments to variables ---
SET "USER_EMAIL=%~1"
SET "USER_PASSWORD=%~2"

REM --- Run Newman using the passed-in credentials ---
echo "Running Newman with provided credentials..."
call newman run "E2E_Ecommerce.postman_collection.json" ^
    --env-var "USER_EMAIL=%USER_EMAIL%" ^
    --env-var "USER_PASSWORD=%USER_PASSWORD%" ^
    -r cli,htmlextra --reporter-htmlextra-export newman/E2E_Ecommerce.html