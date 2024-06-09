pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker_credentials'
        DOCKER_TAG = 'latest'
        GITHUB_CREDENTIALS_ID = 'github_token'
        DOCKER_HUB_REPO = 'anu398/caddy-html'
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

        stage('Check Commit Messages') {
        steps {
            script {
                // Fetch all commits in the PR
                def log = sh(script: "git log --pretty=format:%s origin/main..HEAD", returnStdout: true).trim()
                def commits = log.split('\n')
                
                // Regex for Conventional Commits
                def pattern = ~/^(feat|fix|docs|style|refactor|perf|test|chore)(\(.+\))?: .+$/
                
                // Check each commit message
                for (commit in commits) {
                    if (!pattern.matcher(commit).matches()) {
                        error "Commit message does not follow Conventional Commits: ${commit}"
                    }
                }
            }
        }
    }



        stage('Build Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        sh 'docker buildx create --use'
                        sh 'docker buildx inspect --bootstrap'
                        sh "docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t ${DOCKER_HUB_REPO}:${DOCKER_TAG} . --push"
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
