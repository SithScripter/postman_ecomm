pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker test image...'
                bat 'docker build -t postman-ecomm-tests .'
            }
        }

        stage('Run Newman Tests') {
            environment {
                USER_EMAIL = credentials('POSTMAN_ECOM_EMAIL')
                USER_PASSWORD = credentials('POSTMAN_ECOM_PASSWORD')
            }
            steps {
                echo 'Running API tests inside the container...'

                // Ensure report directory exists on host for Docker volume mount
                bat 'if not exist "%WORKSPACE%\\newman-reports" mkdir "%WORKSPACE%\\newman-reports"'

                // Updated single-line docker command with the -t flag to fix hanging issue
                bat 'docker run --rm -t -v "%WORKSPACE%\\newman-reports:/etc/newman/newman" --env USER_EMAIL=%USER_EMAIL% --env USER_PASSWORD=%USER_PASSWORD% postman-ecomm-tests "E2E_Ecommerce.postman_collection.json" --env-var "USER_EMAIL=%USER_EMAIL%" --env-var "USER_PASSWORD=%USER_PASSWORD%" -r cli,htmlextra --reporter-htmlextra-export "/etc/newman/newman/E2E_Ecommerce.html"'
            }
        }

        stage('Publish HTML Report') {
            steps {
                echo 'Publishing the HTML report...'
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'newman-reports',
                    reportFiles: 'E2E_Ecommerce.html',
                    reportName: 'Newman Test Report'
                ])
            }
        }
    }
}