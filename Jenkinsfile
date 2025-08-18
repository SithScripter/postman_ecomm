pipeline {
    agent any

    environment {
        USER_EMAIL    = credentials('POSTMAN_ECOM_EMAIL')
        USER_PASSWORD = credentials('POSTMAN_ECOM_PASSWORD')
    }

    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker test image...'
                bat 'docker build -t postman-ecomm-tests .'
            }
        }

        stage('Run Newman API Tests') {
            steps {
                bat '''
                    if exist newman rmdir /s /q newman
                    mkdir newman
                '''

                // Run Newman with clean volume mapping
                bat '''
                    docker run --rm ^
                      -v "%WORKSPACE%/newman:/etc/newman/newman" ^
                      --env USER_EMAIL=%USER_EMAIL% ^
                      --env USER_PASSWORD=%USER_PASSWORD% ^
                      postman-ecomm-tests run E2E_Ecommerce.postman_collection.json ^
                        --env-var "USER_EMAIL=%USER_EMAIL%" ^
                        --env-var "USER_PASSWORD=%USER_PASSWORD%" ^
                        -r cli,allure ^
                        --reporter-allure-export "newman/allure-results"
                '''
            }
        }
    }

    post {
        always {
            // Generate Allure report
            allure includeProperties: false,
                   reportBuildPolicy: 'ALWAYS',
                   results: [[path: 'newman/allure-results']]
        }
    }
}
