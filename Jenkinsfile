pipeline {
    agent any

    environment {
        BUILD_CONFIGURATION = 'Release'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'git@github.com:kornel53/mirror.git'
            }
        }

        stage('Build Docker Image') {
            environment {
                DOCKER_IMAGE = credentials('docker-image')
            }
            steps {
                sh '''
                docker build --build-arg BUILD_CONFIGURATION=${BUILD_CONFIGURATION} -t ${DOCKER_IMAGE} .
                '''
            }
        }

        stage('Push to Docker Hub') {
            environment {
                DOCKER_IMAGE = credentials('docker-image')
            }
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: 'https://index.docker.io/v1/']) {
                    sh 'docker push ${DOCKER_IMAGE}'
                }
            }
        }

        stage('Deploy to Server') {
            environment {
                SERVER_IP = credentials('server-ip')
                SERVER_USER = credentials('server-user')
                DOCKER_IMAGE = credentials('docker-image')
            }
            steps {
                sshagent(['server-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << EOF
                    docker pull ${DOCKER_IMAGE}
                    docker stop mirror-app || true
                    docker rm mirror-app || true
                    docker run -d --name mirror-app -p 8080:8080 -p 8081:8081 ${DOCKER_IMAGE}
                    EOF
                    '''
                }
            }
        }
    }
}
