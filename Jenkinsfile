pipeline {
    agent {
        docker {
            image 'python:3.10' // Use official Python image with pip preinstalled
            args '-u root'      // Run as root to allow installs if needed
        }
    }

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

        stage('Install Dependencies') {
            steps {
                sh '''
                    echo "Upgrading pip..."
                    python3 -m pip install --upgrade pip
                '''
            }
        }

        stage('Test') {
            steps {
                script {
                    if (fileExists('package.json')) {
                        sh 'apt update && apt install -y npm' // optional, if needed
                        sh 'npm install'
                        sh 'npm test'
                    } else if (fileExists('pytest.ini') || fileExists('tests')) {
                        sh 'python3 -m pip install -r requirements.txt'
                        sh 'pytest'
                    } else {
                        echo 'No recognized test framework found.'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh "echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-secret', variable: 'KUBECONFIG_FILE')]) {
                    script {
                        sh 'mkdir -p $HOME/.kube'
                        sh 'cp $KUBECONFIG_FILE $HOME/.kube/config'
                        sh 'kubectl apply -f k8s/'
                    }
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
