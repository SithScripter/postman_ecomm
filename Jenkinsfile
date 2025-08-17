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
                // This correctly loads the credentials into the environment
                USER_EMAIL = credentials('POSTMAN_ECOM_EMAIL')
                USER_PASSWORD = credentials('POSTMAN_ECOM_PASSWORD')
            }
            steps {
                echo 'Running API tests inside the container...'
                
                // This is the most robust way to run the container from Jenkins on Windows
                bat 'docker run --rm -v "%WORKSPACE%/newman:/etc/newman/newman" --env USER_EMAIL=%USER_EMAIL% --env USER_PASSWORD=%USER_PASSWORD% postman-ecomm-tests run E2E_Ecommerce.postman_collection.json --env-var "USER_EMAIL=%USER_EMAIL%" --env-var "USER_PASSWORD=%USER_PASSWORD%" -r cli,htmlextra --reporter-htmlextra-export "newman/report.html"'
            }
        }

        stage('Publish HTML Report') {
            steps {
                echo 'Publishing the HTML report...'
                // This is the standard way to publish the report so it displays correctly
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'newman',
                    reportFiles: 'report.html',
                    reportName: 'Newman Test Report'
                ])
            }
        }
    }
}