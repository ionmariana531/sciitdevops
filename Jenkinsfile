pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'add-terraform-github-actions-Mariana-fe', url: 'https://github.com/ionmariana531/sciitdevops.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'sudo apt update && sudo apt install -y python3 python3-pip'
            }
        }

        stage('Run Application') {
            steps {
                sh 'nohup python3 app.py &'
            }
        }
    }
}

