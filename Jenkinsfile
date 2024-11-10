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
                    sh 'docker build -t backend-image -f Dockerfile.backend .'
                    sh 'docker build -t frontend-image -f Dockerfile.frontend .'
                }
            }
        }
    }    
}
