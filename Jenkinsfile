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

        stage('Restore Allure History') {
            steps {
                script {
                    if (fileExists("allure-history.zip")) {
                        unzip zipFile: 'allure-history.zip', dir: 'newman/allure-results'
                    }
                }
            }
        }

        stage('Run Newman API Tests') {
            steps {
                script {
                    // Clean previous results
                    bat 'if exist newman rmdir /s /q newman'
                    bat 'mkdir newman'

                    // Run tests inside Docker
                    bat '''
docker run --rm -v "%cd%:/etc/newman" postman_ecomm_tests run E2E_Ecommerce.postman_collection.json ^
  --env-var USER_EMAIL=%USER_EMAIL% ^
  --env-var USER_PASSWORD=%USER_PASSWORD% ^
  --timeout-request 10000 ^
  --bail ^
  --reporters cli,htmlextra,allure ^
  --reporter-htmlextra-export newman/report.html ^
  --reporter-allure-export newman/allure-results
'''

                    // Add Jenkins metadata to Allure
                    bat 'echo "Jenkins Build: %BUILD_NUMBER%" > newman\\allure-results\\environment.properties'
                    bat 'echo "Job Name: %JOB_NAME%" >> newman\\allure-results\\environment.properties'
                    bat 'echo "Executor: Jenkins on %COMPUTERNAME%" >> newman\\allure-results\\environment.properties'
                }
            }
        }
    }

    post {
        always {
            script {
                // Copy history forward
                if (fileExists("allure-report/history")) {
                    bat 'xcopy /E /I /Y allure-report\\history newman\\allure-results\\history'
                }

                // Archive history for next run
                zip zipFile: 'allure-history.zip', archive: true, dir: 'newman/allure-results/history'
            }

            // Publish Allure Report
            allure([
                includeProperties: false,
                jdk: '',
                results: [[path: 'newman/allure-results']]
            ])

            // Publish HTML fallback
            publishHTML(target: [
                reportDir: 'newman',
                reportFiles: 'report.html',
                reportName: 'Newman HTML Report'
            ])
            archiveArtifacts artifacts: 'newman/report.html'
        }
    }
}
