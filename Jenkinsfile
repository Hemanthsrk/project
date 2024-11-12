pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Hemanthsrk/project.git'
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    sh 'docker build -t backend-image -f Dockerfile.'
                }
            }
        }
        stage('Terraform Init and Apply') {
            steps {
                script {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh "docker build -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub...'
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                        sh "docker push ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to Kubernetes...'
                    sh "kubectl --kubeconfig=${KUBECONFIG} apply -f k8s/deployment.yaml"
                }
            }
        }
    }
}
        

