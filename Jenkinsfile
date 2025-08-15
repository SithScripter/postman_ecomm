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
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                        string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                    ]) {
                        bat 'if not exist "%WORKSPACE%\\newman-reports" mkdir "%WORKSPACE%\\newman-reports"'

                        bat '''
docker run --rm ^
    -v "%WORKSPACE%\\newman-reports:/etc/newman/newman" ^
    --env USER_EMAIL=%USER_EMAIL% ^
    --env USER_PASSWORD=%USER_PASSWORD% ^
    postman-ecomm-tests ^
    E2E_Ecommerce.postman_collection.json ^
    --env-var "USER_EMAIL=%USER_EMAIL%" ^
    --env-var "USER_PASSWORD=%USER_PASSWORD%" ^
    --timeout-request 10000 ^
    --bail ^
    -r cli,htmlextra ^
    --reporter-htmlextra-export "/etc/newman/newman/E2E_Ecommerce.html"
'''
                    }
                }
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
