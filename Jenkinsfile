pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker_credentials'
        DOCKER_TAG = 'latest'
        GITHUB_CREDENTIALS_ID = 'github_token'
        DOCKER_HUB_REPO = credentials('DOCKER_HUB_REPO')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                git credentialsId: GITHUB_CREDENTIALS_ID, url: 'https://github.com/cyse7125-su24-team16/static-site.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        sh 'docker buildx create --use'
                        sh 'docker buildx inspect --bootstrap'
                        sh "docker buildx build -t ${DOCKER_HUB_REPO}:${DOCKER_TAG} . --push"
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'The Docker image has been built and pushed successfully.'
        }
        failure {
            echo 'There was an error during the build process.'
        }
    }
}
