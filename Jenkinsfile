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
                    // ✅ Restore trend history if archive exists
                    if (fileExists("allure-history.zip")) {
                        unzip zipFile: 'allure-history.zip', dir: 'newman/allure-results'
                    }
                }
            }
        }

        stage('Run Newman API Tests') {
            steps {
                script {
                    // Clean results
                    bat 'if exist newman rmdir /s /q newman'
                    bat 'mkdir newman'

                    // Run Newman with Allure + HTML reporters
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

                    // Add Jenkins build info
                    bat 'echo Build=%BUILD_NUMBER% > newman\\allure-results\\environment.properties'
                }
            }
        }
    }

    post {
        always {
            script {
                // ✅ Copy old history forward for trend charts
                if (fileExists("allure-report/history")) {
                    bat 'xcopy /E /I /Y allure-report\\history newman\\allure-results\\history'
                }

                // ✅ Archive updated history for next build
                zip zipFile: 'allure-history.zip', archive: true, dir: 'newman/allure-results/history'
            }

            // ✅ Publish Allure Report (with trend)
            allure([
                includeProperties: false,
                jdk: '',
                results: [[path: 'newman/allure-results']]
            ])

            // ✅ Publish Newman HTML report as fallback
            publishHTML(target: [
                reportDir: 'newman',
                reportFiles: 'report.html',
                reportName: 'Newman HTML Report'
            ])
            archiveArtifacts artifacts: 'newman/report.html'
        }
    }
}
