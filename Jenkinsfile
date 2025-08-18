pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                echo 'Building the Docker test image...'
                bat 'docker build -t postman-ecomm-tests .'
            }
        }
        
        stage('Run Newman API Tests') {
            steps {
                // This is the simplified, standard, and more secure way to run the container.
                // It correctly uses withCredentials and a clean volume mount.
                withCredentials([
                    string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                    string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                ]) {
                    bat 'docker run --rm -v "%WORKSPACE%/newman:/etc/newman/newman" --env USER_EMAIL --env USER_PASSWORD postman-ecomm-tests run E2E_Ecommerce.postman_collection.json --env-var "USER_EMAIL=%USER_EMAIL%" --env-var "USER_PASSWORD=%USER_PASSWORD%" -r cli,allure --reporter-allure-export "newman/allure-results"'
                }
            }
        }
    }

    post {
        always {
            // This block runs after all stages to generate the report
            script {
                // This command creates the file that adds the Build Number to the report
                bat 'echo Build=%BUILD_NUMBER% > newman/allure-results/environment.properties'
                
                // This is the standard Allure command
                allure includeProperties: false, reportBuildPolicy: 'ALWAYS', results: [[path: 'newman/allure-results']]
            }
        }
    }
}