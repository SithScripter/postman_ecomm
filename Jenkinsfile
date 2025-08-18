pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker test image...'
                bat 'docker build -t postman-ecomm-tests .'
            }
        }
        
        stage('Run Tests and Generate Report') {
            steps {
                withCredentials([
                    string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                    string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                ]) {
                    bat '''
                    docker run --rm ^
                      -v "%WORKSPACE%:/etc/newman" ^
                      -w "/etc/newman" ^
                      --env USER_EMAIL --env USER_PASSWORD ^
                      postman-ecomm-tests run E2E_Ecommerce.postman_collection.json ^
                      --env-var "USER_EMAIL=%USER_EMAIL%" ^
                      --env-var "USER_PASSWORD=%USER_PASSWORD%" ^
                      -r cli,allure --reporter-allure-export "allure-results"
                    '''
                }
            }
        }
    }

    post {
        always {
            script {
                // Add Build info
                bat 'echo Build=%BUILD_NUMBER% > allure-results/environment.properties'

                // Add categories.json (for classifying failures)
                writeFile file: 'allure-results/categories.json', text: '''
                [
                  { "name": "Assertions", "matchedStatuses": ["failed"], "messageRegex": ".*expect.*" },
                  { "name": "Network Errors", "matchedStatuses": ["broken"], "messageRegex": ".*ECONN.*" },
                  { "name": "Known Bugs", "matchedStatuses": ["failed"], "traceRegex": ".*BUG.*" }
                ]
                '''

                // Publish report
                allure includeProperties: false, reportBuildPolicy: 'ALWAYS', results: [[path: 'allure-results']]
            }
        }
    }
}
