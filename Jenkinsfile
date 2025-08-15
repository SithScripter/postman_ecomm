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

                    // Create reports directory if not exists
                    bat 'if not exist "%WORKSPACE%\\newman-reports" mkdir "%WORKSPACE%\\newman-reports"'

                    // Run Newman explicitly (no ENTRYPOINT dependency)
                    bat '''
                        docker run --rm --tty=false ^
                        -v "%WORKSPACE%\\newman-reports:/etc/newman/reports" ^
                        --workdir /etc/newman ^
                        %DOCKER_IMAGE% newman run E2E_Ecommerce.postman_collection.json ^
                        --env-var "USER_EMAIL=%USER_EMAIL%" ^
                        --env-var "USER_PASSWORD=%USER_PASSWORD%" ^
                        --timeout-request 10000 --bail --verbose ^
                        -r cli,htmlextra ^
                        --reporter-htmlextra-export "/etc/newman/reports/E2E_Ecommerce.html"
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
                    reportName: 'Newman HTML Report'
                ])
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            bat "docker rmi %DOCKER_IMAGE% || exit 0"
        }
    }
}
