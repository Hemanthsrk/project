pipeline {
    agent any
   stages {
        stage('Checkout') {
            steps {
                sh 'https://github.com/Hemanthsrk/project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .'
                }
            }
        }
                
