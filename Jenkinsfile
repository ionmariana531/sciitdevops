pipeline {
    agent any

    environment {
        GIT_REPO = "https://github.com/ionmariana531/sciitdevops.git"
        GIT_BRANCH = "add-terraform-github-actions-Mariana-fe"
        CLONE_DIR = "/home/jenkins/sciitdevops"
        PYTHON_APP = "/home/jenkins/sciitdevops/app.py"
        ARGOCd_PASS_FILE = "/mnt/s3/passwd-s3fs"
    }

    stages {
        stage('Fetch ArgoCD Password') {
            steps {
                script {
                    echo "Reading ArgoCD password..."
                    def argocdPassword = sh(script: "cat ${ARGOCd_PASS_FILE}", returnStdout: true).trim()
                    env.ARGOCD_PASS = argocdPassword
                }
            }
        }

        stage('Clone App from Git') {
            steps {
                script {
                    echo "Cloning repository from branch ${GIT_BRANCH} using GitHub Token..."
                    withCredentials([string(credentialsId: 'GITHUB_TOKEN', variable: 'GITHUB_TOKEN')]) {
                        sh """
                            rm -rf ${CLONE_DIR}
                            git clone -b ${GIT_BRANCH} https://\$GITHUB_TOKEN@github.com/ionmariana531/sciitdevops.git ${CLONE_DIR}
                        """
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    echo "Running the weather application..."
                    sh "pkill -f 'python3 app.py' || true"
                    sh "nohup python3 ${PYTHON_APP} > app.log 2>&1 &"
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
