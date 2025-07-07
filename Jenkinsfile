pipeline {
    agent any

    environment {
        // DockerHub credentials stored in Jenkins
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = "${DOCKERHUB_CREDENTIALS_USR}"
        DOCKERHUB_PASSWORD = "${DOCKERHUB_CREDENTIALS_PSW}"
        DOCKER_IMAGE = 'manojphaju/flask-app:latest'

        // Kubernetes kubeconfig file stored as secret file
        KUBECONFIG = 'kubeconfig.yaml'
    }

    triggers {
        // Auto-trigger the job using SCM polling
        pollSCM('H/2 * * * *')  // Every 2 minutes
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/manojphaju/OESON.git', branch: 'main'
            }
        }

        stage('Test') {
            steps {
                script {
                    if (fileExists('package.json')) {
                        echo '📦 Node.js project detected — running npm test...'
                        sh 'npm install'
                        sh 'npm test'
                    } else if (fileExists('requirements.txt')) {
                        echo '🐍 Python project detected — running pytest...'
                        sh 'pip install -r requirements.txt'
                        sh 'pytest'
                    } else {
                        echo '⚠️ No known test configuration found. Skipping tests.'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🐳 Building Docker image: ${DOCKER_IMAGE}"
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    echo "🔐 Logging in to DockerHub..."
                    sh "echo ${DOCKERHUB_PASSWORD} | docker login -u ${DOCKERHUB_USERNAME} --password-stdin"
                    echo "📤 Pushing Docker image..."
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "🚀 Deploying to Kubernetes cluster..."
                withCredentials([file(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG')]) {
                    sh 'kubectl apply -f k8s/'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check the logs for more information.'
        }
    }
}
