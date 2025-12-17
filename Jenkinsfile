pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['UAT', 'PROD'],
            description: 'Select deployment environment'
        )
    }

    environment {
        DOCKER_IMAGE = "kshitijadock/dotnet-hello-world"
        DOCKER_TAG   = "${BUILD_NUMBER}"
        DOCKER_CREDS = credentials('dock-cred')

        AWS_SSH = credentials('ec2-ssh-key')

        UAT_IP  = "51.20.134.44"
        PROD_IP = "51.20.134.44"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: '/dotnet-hello-world.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                """
            }
        }

        stage('Docker Login & Push') {
            steps {
                sh """
                echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin
                docker push $DOCKER_IMAGE:$DOCKER_TAG
                """
            }
        }

       stage('Deploy to EC2') {
    steps {
        sh """
        ssh -o StrictHostKeyChecking=no ubuntu@51.20.134.44 << EOF
          docker pull kshitijadock/dotnet-hello-world:${BUILD_NUMBER}
          docker stop dotnet-app || true
          docker rm dotnet-app || true
          docker run -d -p 80:5000 --name dotnet-app kshitijadock/dotnet-hello-world:${BUILD_NUMBER}
        EOF
        """
    }
}

        stage('Health Check') {
            steps {
                script {
                    def TARGET_IP = (params.ENVIRONMENT == 'UAT') ? env.UAT_IP : env.PROD_IP
                    sh "curl -f http://${TARGET_IP}/ || exit 1"
                }
            }
        }
    }
}
