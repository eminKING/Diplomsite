pipeline {
    agent any

    environment {
        IS_WEBHOOK = "${env.JENKINS_TRIGGERED_BY_WEBHOOK ?: 'false'}"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    sh "rm -rf /var/lib/jenkins/workspace/app/*"
                    git branch: 'main', url: 'https://github.com/your-repo.git'
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying..."
                    scp -r /var/lib/jenkins/workspace/app/ root@172.31.47.56:/var/www/app
                    scp -r /var/lib/jenkins/workspace/app/ root@172.31.39.254:/var/www/app
                    ssh ec2-user@172.31.47.56 "rm -rf /var/www/app/ansible && rm /var/www/app/Jenkinsfile"
                    ssh ec2-user@172.31.39.254 "rm -rf /var/www/app/ansible && rm /var/www/app/Jenkinsfile"
                }
            }
        }

        stage('Configure Servers') {
            when {
                expression {
                    // Выполняем стадию только если это не webhook
                    return IS_WEBHOOK != 'true'
                }
            }
            steps {
                script {
                    echo "Waiting for approval to configure servers..."
                    input message: 'Do you want to proceed with configuring servers?', submitter: 'admin'
                    withCredentials([string(credentialsId: 'vault-secret-text', variable: 'vault-password')]) {
                        echo "Configuring servers..."
                        sudo su - ansible -c "export ANSIBLE_VAULT_PASSWORD=$vault-password && cd /var/lib/jenkins/workspace/app/Ansible && ansible-playbook -i inventory Balance.yml && ansible-playbook -i inventory Upstream.yml"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Pipeline has finished"
            }
        }
    }
}
