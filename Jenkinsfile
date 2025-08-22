pipeline {
  agent any

  parameters {
    choice(
      name: 'EXECUTION_MODE',
      choices: ['runner', 'standalone'],
      description: 'runner = our Node+Newman image; standalone = postman/newman base'
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
        sh '''
          set -eu
          rm -rf allure-results
          mkdir -p allure-results
        '''
      }
    }

    stage('Run Tests and Generate Report') {
      steps {
        withCredentials([
          string(credentialsId: 'POSTMAN_ECOM_EMAIL',     variable: 'USER_EMAIL'),
          string(credentialsId: 'POSTMAN_ECOM_PASSWORD',  variable: 'USER_PASSWORD')
        ]) {
          script {
            def mode = params.EXECUTION_MODE ?: env.DEFAULT_EXECUTION

            // mount ONLY the results folder so Allure can read it after the container exits
            if (mode == 'runner') {
              sh '''#!/bin/sh
                set -eu
                docker run --rm \
                  --env USER_EMAIL \
                  --env USER_PASSWORD \
                  -v "$(pwd)/allure-results:/etc/newman/allure-results" \
                  postman-ecomm-runner:latest \
                  newman run E2E_Ecommerce.postman_collection.json \
                    --env-var USER_EMAIL="$USER_EMAIL" \
                    --env-var USER_PASSWORD="$USER_PASSWORD" \
                    -r cli,allure \
                    --reporter-allure-export /etc/newman/allure-results \
                    --reporter-allure-simplified-traces
              '''
            } else {
              sh '''#!/bin/sh
                set -eu
                docker run --rm \
                  --env USER_EMAIL \
                  --env USER_PASSWORD \
                  -v "$WORKSPACE/allure-results:/etc/newman/allure-results" \
                  postman-ecomm-standalone:latest \
                  newman run E2E_Ecommerce.postman_collection.json \
                    --env-var USER_EMAIL="$USER_EMAIL" \
                    --env-var USER_PASSWORD="$USER_PASSWORD" \
                    -r cli,allure \
                    --reporter-allure-export /etc/newman/allure-results \
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
            // Correct Linux syntax for env props
            sh 'echo "Build=$BUILD_NUMBER" > allure-results/environment.properties'

            // Clean JSON
            writeFile file: 'allure-results/categories.json', text: '''[
              { "name": "Assertions", "matchedStatuses": ["failed"], "messageRegex": ".*expect.*" },
              { "name": "Network Errors", "matchedStatuses": ["broken"], "messageRegex": ".*ECONN.*" },
              { "name": "Known Bugs", "matchedStatuses": ["failed"], "traceRegex": ".*BUG.*" }
            ]'''

            // Executor metadata
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

            // This step requires the Allure Jenkins Plugin
            allure includeProperties: false, reportBuildPolicy: 'ALWAYS', results: [[path: 'allure-results']]

            echo "📊 Allure report available at: ${env.BUILD_URL}AllureReport"
        }
    }
}

}
