@echo off
echo "Starting the test execution script..."

REM --- Run Newman to generate the report ---
echo "Running Newman..."
call newman run "E2E_Ecommerce.postman_collection.json" -r cli,htmlextra --reporter-htmlextra-export newman/E2E_Ecommerce.html