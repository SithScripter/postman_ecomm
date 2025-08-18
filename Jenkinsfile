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
                // Run container and export Allure results
                bat '''
                if not exist newman mkdir newman
                if not exist newman\\allure-results mkdir newman\\allure-results

                docker run --rm ^
                  -v "%WORKSPACE%/newman:/etc/newman/newman" ^
                  --env USER_EMAIL=%USER_EMAIL% ^
                  --env USER_PASSWORD=%USER_PASSWORD% ^
                  postman-ecomm-tests run E2E_Ecommerce.postman_collection.json ^
                  --env-var "USER_EMAIL=%USER_EMAIL%" ^
                  --env-var "USER_PASSWORD=%USER_PASSWORD%" ^
                  -r cli,allure --reporter-allure-export "newman/allure-results"
                '''
            }
        }
    }

    post {
        always {
            script {
                // Ensure results dir exists
                bat '''
                if not exist newman mkdir newman
                if not exist newman\\allure-results mkdir newman\\allure-results
                '''

                // Preserve history
                bat '''
                if exist newman\\allure-report\\history (
                    xcopy newman\\allure-report\\history newman\\allure-results\\history /E /I /Y
                )
                '''

                // Write environment.properties
                bat '''
                echo Build=%BUILD_NUMBER% > newman\\allure-results\\environment.properties
                echo UserEmail=%USER_EMAIL% >> newman\\allure-results\\environment.properties
                '''

                // Write executor.json
                bat '''
                echo { "name": "Jenkins", "type": "pipeline", "url": "%BUILD_URL%", "buildNumber": "%BUILD_NUMBER%" } > newman\\allure-results\\executor.json
                '''
            }

            // Publish Allure report
            allure includeProperties: false, reportBuildPolicy: 'ALWAYS', results: [[path: 'newman/allure-results']]
        }
    }
}
