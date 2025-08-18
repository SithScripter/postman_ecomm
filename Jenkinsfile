pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker test image...'
                // This builds the image with all the tools installed
                bat 'docker build -t postman-ecomm-tests .'
            }
        }
        
        stage('Run Tests and Generate Report') {
            steps {
                // This single command runs the tests using the LATEST code from GitHub
                withCredentials([
                    string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                    string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                ]) {
                    bat 'docker run --rm -v "%WORKSPACE%:/etc/newman" -w "/etc/newman" --env USER_EMAIL --env USER_PASSWORD postman-ecomm-tests run E2E_Ecommerce.postman_collection.json --env-var "USER_EMAIL=%USER_EMAIL%" --env-var "USER_PASSWORD=%USER_PASSWORD%" -r cli,allure --reporter-allure-export "allure-results"'
                }
            }
        }
    }

    post {
        always {
            // This block runs after all stages to generate the final report
            script {
                // This adds the Build Number to the report
                bat 'echo Build=%BUILD_NUMBER% > allure-results/environment.properties'
                
                // This generates and serves the Allure report
                allure includeProperties: false, reportBuildPolicy: 'ALWAYS', results: [[path: 'allure-results']]
            }
        }
    }
}