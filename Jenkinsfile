pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        KUBECONFIG_CREDENTIALS = credentials('kubeconfig-secret')
        IMAGE_NAME = 'manojphaju/flask-app'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/manojphaju/OESON.git'
            }
        }

        stage('Test in Python Container') {
            steps {
                sh '''
                    docker run --rm -v "$PWD":/app -w /app python:3.10 bash -c "
                        pip install --upgrade pip &&
                        pip install -r requirements.txt &&
                        pytest
                    "
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                        mkdir -p $HOME/.kube
                        cp $KUBECONFIG_FILE $HOME/.kube/config
                        kubectl apply -f k8s/
                    '''
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed.'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
    }
}
