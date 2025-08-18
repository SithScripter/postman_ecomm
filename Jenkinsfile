pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker test image...'
                bat 'docker build -t postman-ecomm-tests .'
            }
        }

        stage('Prepare Workspace') {
            steps {
                // Clean up old allure-results before running tests
                bat 'if exist allure-results rmdir /s /q allure-results'
                bat 'mkdir allure-results'
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
  -r cli,allure --reporter-allure-export "allure-results" ^
  --reporter-allure-simplified-traces
'''
                }
            }
        }
    }

post {
    always {
        script {
            // Clean old results
            bat 'if exist allure-results rmdir /s /q allure-results'
            bat 'mkdir allure-results'

            // Add Build + Executor info
            bat '''
echo Build=%BUILD_NUMBER% > allure-results/environment.properties
echo Executor=Jenkins >> allure-results/environment.properties
echo BuildUrl=%BUILD_URL% >> allure-results/environment.properties
echo JobName=%JOB_NAME% >> allure-results/environment.properties
'''

            // Add categories.json for failure grouping
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
