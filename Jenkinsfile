pipeline {
    agent any // This will run directly on your main Jenkins machine

    stages {
        stage('Run API Tests via Batch File') {
            steps {
                echo 'Executing the run_tests.bat script...'
                // This command simply runs the batch file from your repository
                // It also injects the secrets as environment variables for the script to use
                withCredentials([
                    string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                    string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                ]) {
                    bat 'call run_tests.bat'
                }
            }
        }
        stage('Publish HTML Report') {
            steps {
                echo 'Publishing the HTML report...'
                // This looks for the 'newman' folder created by your batch script
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'newman', 
                    reportFiles: 'E2E_Ecommerce.html', 
                    reportName: 'Newman Test Report'
                ])
            }
        }
    }
}