pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        REPO_URL = 'https://github.com/ionmariana531/sciitdevops.git'  // Adresa repo-ului tău
        BRANCH_NAME = 'add-terraform-github-actions-Mariana-fe' // Branch-ul
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout([$class: 'GitSCM',
                              branches: [[name: env.BRANCH_NAME]],
                              userRemoteConfigs: [[url: env.REPO_URL]]])
                }
            }
        }

        stage('Get EC2 IP') {
            steps {
                script {
                    // Obținem IP-ul instanței EC2 folosind output-ul Terraform
                    def ec2_ip = sh(script: "terraform output -json instance_ips | jq -r '.[0]'", returnStdout: true).trim()
                    env.DEPLOY_SERVER = "ubuntu@${ec2_ip}"  // Setăm adresa IP a serverului
                    echo "Deploy server IP: ${DEPLOY_SERVER}"  // Afișăm IP-ul pentru verificare
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Construim imaginea Docker pentru aplicația Python
                    sh 'docker build -t python-web-app:latest .'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    // Folosim cheia SSH corectă pentru autentificare pe serverul EC2
                    sh """
                    scp -o StrictHostKeyChecking=no -i ~/.ssh/app-ssh-key.pem Dockerfile ${DEPLOY_SERVER}:/home/ubuntu/
                    scp -o StrictHostKeyChecking=no -i ~/.ssh/app-ssh-key.pem app.py ${DEPLOY_SERVER}:/home/ubuntu/
                    scp -o StrictHostKeyChecking=no -i ~/.ssh/app-ssh-key.pem requirements.txt ${DEPLOY_SERVER}:/home/ubuntu/
                    """
                    // Rulăm aplicația Docker pe instanța EC2
                    sh """
                    ssh -o StrictHostKeyChecking=no -i ~/.ssh/app-ssh-key.pem ${DEPLOY_SERVER} "
                        # Oprim și ștergem orice instanță existentă
                        docker stop python-web-app || true &&
                        docker rm python-web-app || true &&

                        # Construim și rulăm un container Docker pentru aplicația Python
                        docker build -t python-web-app:latest /home/ubuntu/ &&
                        docker run -d --name python-web-app -p 80:5000 python-web-app:latest
                    "
                    """
                }
            }
        }

        stage('ArgoCD Sync') {
            steps {
                script {
                    // Sincronizează aplicația cu ArgoCD
                    sh '''
                    argocd login argocd-server --username admin --password $ARGOCD_PASSWORD --insecure
                    argocd app sync weather-app --prune --strategy apply
                    '''
                }
            }
        }

        stage('Notify Success') {
            steps {
                script {
                    echo "Deployment successful!"
                }
            }
        }

        stage('Notify Failure') {
            when {
                expression {
                    currentBuild.result == 'FAILURE'
                }
            }
            steps {
                script {
                    echo "Pipeline failed!"
                }
            }
        }
    }
}
