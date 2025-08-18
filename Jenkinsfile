pipeline {
    agent any

    environment {
        USER_EMAIL    = credentials('POSTMAN_ECOM_EMAIL')
        USER_PASSWORD = credentials('POSTMAN_ECOM_PASSWORD')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker test image...'
                bat 'docker build -t postman-ecomm-tests .'
            }
        }
        
        stage('Run Newman API Tests') {
            steps {
                // *** NEW LINE: Ensure the host directory exists before running Docker ***
                bat 'if not exist newman mkdir newman'

                // This is the clean, proven command to run the tests
                bat 'docker run --rm -v "%WORKSPACE%/newman:/etc/newman/newman" --env USER_EMAIL=%USER_EMAIL% --env USER_PASSWORD=%USER_PASSWORD% postman-ecomm-tests run E2E_Ecommerce.postman_collection.json --env-var "USER_EMAIL=%USER_EMAIL%" --env-var "USER_PASSWORD=%USER_PASSWORD%" -r cli,allure --reporter-allure-export "newman/allure-results"'
            }
        }
    }

    post {
        always {
            // This script block ensures all post-run commands execute
            script {
                // This command creates the file that adds the Build Number to the report
                bat 'echo Build=%BUILD_NUMBER% > newman/allure-results/environment.properties'
                
                // This is the standard Allure command to generate the report
                allure includeProperties: false, reportBuildPolicy: 'ALWAYS', results: [[path: 'newman/allure-results']]
            }
        }
    }
}