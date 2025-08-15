pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'postman-ecomm-tests'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker test image...'
                bat "docker build -t %DOCKER_IMAGE% ."
            }
        }

        stage('Run Newman Tests') {
            steps {
                withCredentials([
                    string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                    string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                ]) {
                    echo 'Running API tests inside the container...'

                    // Ensure reports directory exists
                    bat 'if not exist "%WORKSPACE%\\newman-reports" mkdir "%WORKSPACE%\\newman-reports"'

                    // Run Newman via the ENTRYPOINT
                    bat '''
                        docker run --rm ^
                        -v "%WORKSPACE%\\newman-reports:/etc/newman/newman" ^
                        %DOCKER_IMAGE% ^
                        E2E_Ecommerce.postman_collection.json ^
                        --env-var "USER_EMAIL=%USER_EMAIL%" ^
                        --env-var "USER_PASSWORD=%USER_PASSWORD%" ^
                        --timeout-request 10000 --bail --verbose ^
                        -r cli,htmlextra ^
                        --reporter-htmlextra-export "/etc/newman/newman/E2E_Ecommerce.html"
                    '''
                }
            }
        }

        stage('Publish HTML Report') {
            steps {
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'newman-reports',
                    reportFiles: 'E2E_Ecommerce.html',
                    reportName: 'API Test Report'
                ])
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker containers and images...'
            bat 'docker system prune -f'
        }
    }
}
