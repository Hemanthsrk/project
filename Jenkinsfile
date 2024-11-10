pipeline {
    agent any
	tools {
        maven 'Maven 3.9.5' 
    }
    stages {
        stage('Clone Repository') {
            steps {
               git clone 'https://github.com/Hemanthsrk/project.git'
            }
        }
        stage('Build Docker Images') {
            steps {
                script {
                    sh 'docker build -t Dockerfile.frontend'
                    sh 'docker build -t Dockerfile.backend'
                }
            }
        }
        stage('Deploy using Terraform') {
            steps {
                script {
                    sh 'cd terraform && terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f frontend-deployment.yaml'
		sh 'kubectl apply -f backend-deployment.yaml'
		sh 'kubectl apply -f service,yaml'
            }
        }    
    }
}
                     
