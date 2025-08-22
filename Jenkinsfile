pipeline {
    agent any

    parameters {
        choice(
            name: 'EXECUTION_MODE',
            choices: ['runner', 'standalone'],
            description: 'Choose Docker execution mode (defaults to runner)'
        )
    }

    environment {
        EXECUTION_MODE = "${params.EXECUTION_MODE ?: 'runner'}"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    echo "=== Running in ${env.EXECUTION_MODE.toUpperCase()} mode ==="
                    if (env.EXECUTION_MODE == 'runner') {
                        sh 'docker build -f Dockerfile.runner -t postman-ecomm-runner:latest .'
                    } else {
                        sh 'docker build -f Dockerfile -t postman-ecomm-standalone:latest .'
                    }
                }
            }
        }

        stage('Run API Tests') {
            steps {
                withCredentials([
                    string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                    string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                ]) {
                    script {
                        if (env.EXECUTION_MODE == 'runner') {
                            sh '''
                                docker run --rm \
                                -v "$WORKSPACE:/etc/newman" \
                                -w /etc/newman \
                                --env USER_EMAIL \
                                --env USER_PASSWORD \
                                postman-ecomm-runner:latest run E2E_Ecommerce.postman_collection.json \
                                --env-var "USER_EMAIL=$USER_EMAIL" \
                                --env-var "USER_PASSWORD=$USER_PASSWORD" \
                                -r cli,allure --reporter-allure-export allure-results
                            '''
                        } else {
                            // Standalone logic
                            sh '''
                                docker run --rm \
                                -v "$WORKSPACE/allure-results:/etc/newman/allure-results" \
                                --env USER_EMAIL \
                                --env USER_PASSWORD \
                                postman-ecomm-standalone:latest \
                                --env-var "USER_EMAIL=$USER_EMAIL" \
                                --env-var "USER_PASSWORD=$USER_PASSWORD" \
                                -r cli,allure --reporter-allure-export allure-results
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // This correctly adds the Build Number and other info to the report
                sh 'echo "Build=$BUILD_NUMBER" > allure-results/environment.properties'
                
                // This is the standard Allure command
                allure includeProperties: false, reportBuildPolicy: 'ALWAYS', results: [[path: 'allure-results']]
            }
        }
    }
}