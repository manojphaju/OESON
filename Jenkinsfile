pipeline {

    environment {
        DOCKER_IMAGE = 'manojphaju/flask-app:latest'
    }

    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/manojphaju/OESON.git'
            }
        }

        stage('Test') {
            steps {
                script {
                    if (fileExists('requirements.txt')) {
                        echo '🐍 Python project detected — running pytest...'
                        sh 'pip install -r requirements.txt'
                        sh 'pytest'
                    } else {
                        echo '⚠️ No requirements.txt found. Skipping test stage.'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $DOCKER_IMAGE:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh "echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin"
                    sh "docker push $DOCKER_IMAGE:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh 'kubectl apply -f k8s/'
                }
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed. Check the logs for more information."
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
    }
}
