pipeline {
    agent any

    parameters {
        choice(
            name: 'EXECUTION_MODE',
            choices: ['runner', 'standalone'],
            description: 'Choose Docker execution mode (main=runner, others=standalone)'
        )
    }

    environment {
        DEFAULT_EXECUTION = "${env.BRANCH_NAME == 'main' ? 'runner' : 'standalone'}"
    }

    stages {
        stage('Verify Workspace') {
            steps {
                sh '''
                echo "=== Host workspace contents ==="
                ls -l $WORKSPACE
                echo "=== Subfolders ==="
                find $WORKSPACE -maxdepth 2 -type f
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def mode = params.EXECUTION_MODE ?: env.DEFAULT_EXECUTION
                    echo "=== Running in ${mode.toUpperCase()} mode (branch: ${env.BRANCH_NAME}) ==="

                    if (mode == 'runner') {
                        sh "docker build -f $WORKSPACE/Dockerfile.runner -t postman-ecomm-runner:latest $WORKSPACE"
                    } else {
                        sh "docker build -f $WORKSPACE/Dockerfile -t postman-ecomm-standalone:latest $WORKSPACE"
                    }
                }
            }
        }

        stage('Prepare Workspace') {
            steps {
                sh 'rm -rf allure-results && mkdir -p allure-results'
            }
        }

        stage('Run Tests and Generate Report') {
            steps {
                checkout scm   // always pull latest repo state

                withCredentials([
                    string(credentialsId: 'POSTMAN_ECOM_EMAIL', variable: 'USER_EMAIL'),
                    string(credentialsId: 'POSTMAN_ECOM_PASSWORD', variable: 'USER_PASSWORD')
                ]) {
                    script {
                        def mode = params.EXECUTION_MODE ?: env.DEFAULT_EXECUTION
                        def image = (mode == 'runner') ? 'postman-ecomm-runner:latest' : 'postman-ecomm-standalone:latest'

                        sh """
docker run --rm \
  -v $WORKSPACE:/etc/newman \
  -w /etc/newman \
  --env USER_EMAIL=$USER_EMAIL \
  --env USER_PASSWORD=$USER_PASSWORD \
  --entrypoint sh \
  $image -c '
    echo "=== Inside container /etc/newman contents ==="
    ls -l /etc/newman
    newman run E2E_Ecommerce.postman_collection.json \
      --env-var USER_EMAIL=$USER_EMAIL \
      --env-var USER_PASSWORD=$USER_PASSWORD \
      -r cli,allure \
      --reporter-allure-export allure-results \
      --reporter-allure-simplified-traces
  '
"""
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Allure environment
                sh 'echo Build=$BUILD_NUMBER > allure-results/environment.properties'

                // Categories file
                writeFile file: 'allure-results/categories.json', text: '''
                [
                  { "name": "Assertions", "matchedStatuses": ["failed"], "messageRegex": ".*expect.*" },
                  { "name": "Network Errors", "matchedStatuses": ["broken"], "messageRegex": ".*ECONN.*" },
                  { "name": "Known Bugs", "matchedStatuses": ["failed"], "traceRegex": ".*BUG.*" }
                ]
                '''

                // Executor info
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
