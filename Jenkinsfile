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
                    bat 'if exist newman rmdir /s /q newman'
                    bat 'mkdir newman'

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

                    // Ensure allure-results exists before echo
                    bat 'if not exist newman\\allure-results mkdir newman\\allure-results'
                    bat 'echo Build=%BUILD_NUMBER% > newman\\allure-results\\environment.properties'
                }
            }
        }
    }

    post {
        always {
            script {
                if (fileExists("allure-report/history")) {
                    bat 'xcopy /E /I /Y allure-report\\history newman\\allure-results\\history'
                }

                // delete old zip if exists
                bat 'if exist allure-history.zip del /f /q allure-history.zip'

                // zip up history for next run
                zip zipFile: 'allure-history.zip', archive: true, dir: 'newman/allure-results/history'
            }

            allure([
                includeProperties: false,
                jdk: '',
                results: [[path: 'newman/allure-results']]
            ])

            publishHTML(target: [
                reportDir: 'newman',
                reportFiles: 'report.html',
                reportName: 'Newman HTML Report'
            ])
            archiveArtifacts artifacts: 'newman/report.html'
        }
    }
}
