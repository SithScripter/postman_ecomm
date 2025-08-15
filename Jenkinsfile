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
            // This new block will securely load our credentials
            environment {
                USER_EMAIL = credentials('POSTMAN_EMAIL')
                USER_PASSWORD = credentials('POSTMAN_PASSWORD')
            }
            steps {
                echo 'Running API tests inside the container...'
                // This new docker command injects the secrets as environment variables
                bat 'docker run --rm -v "%WORKSPACE%/newman-reports:/etc/newman/newman" --env USER_EMAIL --env USER_PASSWORD postman-ecomm-tests "E2E_Ecommerce.postman_collection.json" -r cli,htmlextra'
            }
        }
        stage('Publish HTML Report') {
            steps {
                // This stage remains the same
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