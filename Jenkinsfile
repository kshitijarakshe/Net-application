pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['UAT', 'PROD'], description: 'Select deployment environment')
    }

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-id')  // Jenkins global credential ID
        AWS_CREDENTIALS = credentials('aws-credentials-id')    // Jenkins global credential ID
        IMAGE_NAME = "yourdockerhubusername/dotnet-hello-world"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-username>/dotnet-hello-world.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.IMAGE_NAME}:${params.ENV}-${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'DOCKER_HUB_CREDENTIALS') {
                        docker.image("${env.IMAGE_NAME}:${params.ENV}-${env.BUILD_NUMBER}").push()
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    def host = params.ENV == 'UAT' ? 'uat-ec2-ip' : 'prod-ec2-ip'
                    def sshUser = 'ec2-user'
                    def dockerImage = "${env.IMAGE_NAME}:${params.ENV}-${env.BUILD_NUMBER}"

                    // Deploy via SSH
                    sh """
                    ssh -o StrictHostKeyChecking=no ${sshUser}@${host} '
                        docker pull ${dockerImage} &&
                        docker stop dotnet-api || true &&
                        docker rm dotnet-api || true &&
                        docker run -d --name dotnet-api -p 80:80 ${dockerImage}
                    '
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    def host = params.ENV == 'UAT' ? 'uat-ec2-ip' : 'prod-ec2-ip'
                    sh "curl -f http://${host} || echo 'Health check failed!'"
                }
            }
        }
    }
}
