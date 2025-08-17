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
            bat '''
                if exist newman rmdir /s /q newman
                mkdir newman
                mkdir newman\\allure-results

                docker run --rm -v "%cd%:/etc/newman" postman_ecomm_tests run E2E_Ecommerce.postman_collection.json ^
                  --env-var USER_EMAIL=%USER_EMAIL% ^
                  --env-var USER_PASSWORD=%USER_PASSWORD% ^
                  --timeout-request 10000 ^
                  --bail ^
                  --reporters cli,htmlextra,allure ^
                  --reporter-htmlextra-export newman/report.html ^
                  --reporter-allure-export newman/allure-results/

                echo Build=%BUILD_NUMBER% > newman\\allure-results\\environment.properties
            '''
        }
    }
}
}

    }

    post {
        always {
            script {
                // Copy allure history into results for trend
                bat '''
                    if exist allure-report\\history xcopy /E /I /Y allure-report\\history newman\\allure-results\\history
                '''
            }

            allure([
                includeProperties: false,
                jdk: '',
                properties: [],
                reportBuildPolicy: 'ALWAYS',
                results: [[path: "newman/allure-results"]]
            ])

            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'newman',
                reportFiles: 'report.html',
                reportName: 'Newman HTML Report'
            ])

            archiveArtifacts artifacts: 'newman/**/*.*', followSymlinks: false
        }
    }
