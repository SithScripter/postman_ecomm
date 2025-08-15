pipeline {
    agent any // This will run directly on your main Jenkins machine

    stages {
        stage('Run API Tests via Batch File') {
steps {
    echo 'Executing the run_tests.bat script...'
    withCredentials([
        string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
        string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
    ]) {
        // Pass the credentials to the batch script as arguments
        bat "call run_tests.bat \"%USER_EMAIL%\" \"%USER_PASSWORD%\""
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