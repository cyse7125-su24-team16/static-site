pipeline {
    agent any
 
    environment {
        DOCKER_CREDENTIALS_ID = 'docker_credentials'
        DOCKER_TAG = 'latest'
        GITHUB_CREDENTIALS_ID = 'github_token'
        DOCKER_HUB_REPO = '118a3025/img1'
    }
 
    stages {      
       stages {
        stage('Checkout PR Branch') {
            steps {
                script {
                    // Fetch the latest changes from the origin using credentials
                    withCredentials([usernamePassword(credentialsId: GITHUB_CREDENTIALS_ID, usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                        sh 'git config --global credential.helper store'
                        sh 'echo "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com" > ~/.git-credentials'
                        // Fetch all branches including PR branches
                        sh 'git fetch origin +refs/pull/*/head:refs/remotes/origin/pr/*'
                        // Dynamically fetch the current PR branch name using environment variables
                        def prBranch = env.CHANGE_BRANCH
                        echo "PR Branch: ${prBranch}"
                        // Checkout the PR branch
                        sh "git checkout -B ${prBranch} origin/pr/${env.CHANGE_ID}"
                    }
                }
            }
        }

        stage('Check Commit Messages') {
            steps {
                script {
                    // Fetch the latest commit message in the PR branch
                    def latestCommitMessage = sh(script: "git log -1 --pretty=format:%s", returnStdout: true).trim()
                    echo "Latest commit message: ${latestCommitMessage}"
                   
                    // Regex for Conventional Commits
                    def pattern = ~/^\s*(feat|fix|docs|style|refactor|perf|test|chore)(\(.+\))?: .+\s*$/
                   
                    // Check the latest commit message
                    if (!pattern.matcher(latestCommitMessage).matches()) {
                        error "Commit message does not follow Conventional Commits: ${latestCommitMessage}"
                    }
                }
            }
        }

        stage('Compare Changes') {
            steps {
                script {
                    // Compare the PR branch with the main branch
                    def diff = sh(script: 'git diff origin/main...HEAD', returnStdout: true).trim()
                    echo "Git Diff: ${diff}"
                    if (diff == "") {
                        echo "No differences found."
                    } else {
                        echo "Differences found:\n${diff}"
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

        stage('Clean Workspace') {
            steps {
                cleanWs()
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
