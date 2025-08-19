pipeline {
    agent any

    parameters {
        choice(
            name: 'EXECUTION_MODE',
            choices: ['runner', 'standalone'],
            description: 'Choose Docker execution mode (defaults: main=runner, others=standalone)'
        )
    }

    environment {
        DEFAULT_EXECUTION = "${env.BRANCH_NAME == 'main' ? 'runner' : 'standalone'}"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    def mode = params.EXECUTION_MODE ?: env.DEFAULT_EXECUTION
                    echo "=== Running in ${mode.toUpperCase()} mode (branch: ${env.BRANCH_NAME}) ==="

                    if (mode == 'runner') {
                        sh 'docker build -f Dockerfile.runner -t postman-ecomm-runner:latest .'
                    } else {
                        sh 'docker build -f Dockerfile -t postman-ecomm-standalone:latest .'
                    }
                }
            }
        }

        stage('Prepare Workspace') {
            steps {
                sh 'rm -rf allure-results'
                sh 'mkdir -p allure-results'
            }
        }

        stage('Run Tests and Generate Report') {
            steps {
                withCredentials([
                    string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                    string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                ]) {
                    script {
                        def mode = params.EXECUTION_MODE ?: env.DEFAULT_EXECUTION
                        if (mode == 'runner') {
						sh 'ls -l $WORKSPACE/E2E_Ecommerce.postman_collection.json'

                            sh '''
docker run --rm \
  -v "$(pwd):/etc/newman" \
  -w /etc/newman \
  --env USER_EMAIL --env USER_PASSWORD \
  postman-ecomm-runner:latest run /etc/newman/E2E_Ecommerce.postman_collection.json \
  --env-var "USER_EMAIL=$USER_EMAIL" \
  --env-var "USER_PASSWORD=$USER_PASSWORD" \
  -r cli,allure --reporter-allure-export /etc/newman/allure-results \
  --reporter-allure-simplified-traces
'''
                        } else {
                            sh '''
docker run --rm \
  -v "$WORKSPACE:/etc/newman" \
  -w /etc/newman \
  postman-ecomm-standalone:latest run /etc/newman/E2E_Ecommerce.postman_collection.json \
  --env-var "USER_EMAIL=$USER_EMAIL" \
  --env-var "USER_PASSWORD=$USER_PASSWORD" \
  -r cli,allure --reporter-allure-export /etc/newman/allure-results \
  --reporter-allure-simplified-traces
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
                sh 'echo Build=$BUILD_NUMBER > allure-results/environment.properties'

                writeFile file: 'allure-results/categories.json', text: '''
                [
                  { "name": "Assertions", "matchedStatuses": ["failed"], "messageRegex": ".*expect.*" },
                  { "name": "Network Errors", "matchedStatuses": ["broken"], "messageRegex": ".*ECONN.*" },
                  { "name": "Known Bugs", "matchedStatuses": ["failed"], "traceRegex": ".*BUG.*" }
                ]
                '''

                writeFile file: 'allure-results/executor.json', text: """
                {
                  "name": "Jenkins",
                  "type": "jenkins",
                  "url": "${env.BUILD_URL}",
                  "buildOrder": ${env.BUILD_NUMBER},
                  "buildName": "Build #${env.BUILD_NUMBER}",
                  "buildUrl": "${env.BUILD_URL}",
                  "reportUrl": "${env.BUILD_URL}AllureReport",
                  "executorInfo": "Jenkins job ${env.JOB_NAME}"
                }
                """

                allure includeProperties: false, reportBuildPolicy: 'ALWAYS', results: [[path: 'allure-results']]
                echo "📊 Allure report available at: ${env.BUILD_URL}AllureReport"
            }
        }
    }
}
