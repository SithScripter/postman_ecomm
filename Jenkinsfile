pipeline {
    agent any

    stages {
        stage('Build Newman Docker Image') {
            steps {
                // Build the Docker image with Newman and htmlextra reporter
                bat 'docker build -t postman_ecomm_tests .'
				
            }
        }
        stage('Run Newman API Tests') {
            steps {
                script {
                    // Ensure folder exists for HTML report output
                    bat 'if not exist newman mkdir newman'
                    // Run the tests using your custom Docker image, mounting the workspace
                    bat '''
                    docker run --rm -v "%cd%:/etc/newman" postman_ecomm_tests run E2E_Ecommerce.postman_collection.json ^
                     --reporters cli,htmlextra ^
                     --reporter-htmlextra-export newman/report.html
                    '''
                }
            }
        }
    }

    post {
        always {
            // Publish the htmlextra HTML report
            publishHTML(target: [
                reportDir: 'newman',
                reportFiles: 'report.html',
                reportName: 'Newman HTML Report'
            ])
            // Optionally archive the report HTML so you can download it
            archiveArtifacts artifacts: 'newman/report.html'
        }
    }
}
