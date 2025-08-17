pipeline {
    agent any

    environment {
        USER_EMAIL    = credentials('POSTMAN_ECOM_EMAIL')
        USER_PASSWORD = credentials('POSTMAN_ECOM_PASSWORD')
    }

    stages {

        stage('Docker DNS Test') {
            steps {
                bat 'docker run --rm busybox nslookup rahulshettyacademy.com'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t postman_ecomm_tests .'
            }
        }

        stage('Run Newman API Tests') {
            steps {
                script {
                    // Ensure results dir is clean
                    bat 'if exist newman rmdir /s /q newman'
                    bat 'mkdir newman'

                    // Run tests inside Docker
                    bat '''
docker run --rm ^
  -v "%WORKSPACE%:/etc/newman" ^
  postman_ecomm_tests run E2E_Ecommerce.postman_collection.json ^
  --env-var USER_EMAIL=%USER_EMAIL% ^
  --env-var USER_PASSWORD=%USER_PASSWORD% ^
  -r cli,htmlextra,allure ^
  --reporter-htmlextra-export newman/report.html ^
  --reporter-allure-export newman/allure-results
'''
                }
            }
        }
    }

    post {
        always {
            // Publish Allure dashboard
            allure([
                includeProperties: false,
                jdk: '',
                results: [[path: 'newman/allure-results']]
            ])

            // Publish fallback HTML
            publishHTML(target: [
                reportDir: 'newman',
                reportFiles: 'report.html',
                reportName: 'Newman HTML Report'
            ])

            // Archive all reports
            archiveArtifacts artifacts: 'newman/**'
        }
    }
}
