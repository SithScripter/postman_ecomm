pipeline {
    agent any
    environment {
        USER_EMAIL = credentials('POSTMAN_ECOM_EMAIL')
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
                    bat 'if not exist newman mkdir newman'
                    bat """
                    docker run --rm -v "%cd%:/etc/newman" postman_ecomm_tests run E2E_Ecommerce.postman_collection.json ^
                     --env-var USER_EMAIL=%USER_EMAIL% ^
                     --env-var USER_PASSWORD=%USER_PASSWORD% ^
                     --reporters cli,htmlextra ^
                     --reporter-htmlextra-export newman/report.html
                    """
                }
            }
        }
    }
    post {
        always {
            publishHTML(target: [
                reportDir: 'newman',
                reportFiles: 'report.html',
                reportName: 'Newman HTML Report'
            ])
            archiveArtifacts artifacts: 'newman/report.html'
        }
    }
}
