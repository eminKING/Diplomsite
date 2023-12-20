pipeline {
    agent any

    environment {
        IS_WEBHOOK = "${env.JENKINS_TRIGGERED_BY_WEBHOOK ?: 'false'}"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Удаляем текущую рабочую директорию
                    deleteDir()
                    // Клонируем новый репозиторий
                    checkout scm
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying..."
                     ssh ec2-user@172.31.44.15 "rm -rf app/"
                     ssh ec2-user@172.31.35.168 "rm -rf app/"
                     scp -r /var/lib/jenkins/workspace/app/ ec2-user@172.31.44.15:/home/ec2-user/
                     scp -r /var/lib/jenkins/workspace/app/ ec2-user@172.31.35.168:/home/ec2-user/
                     ssh ec2-user@172.31.44.15 "rm -rf app/Ansible && rm app/Jenkinsfile"
                     ssh ec2-user@172.31.35.168 "rm -rf app/Ansible && rm app/Jenkinsfile"
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
                        sudo su - ansible -c "export ANSIBLE_VAULT_PASSWORD=$vault-password && cd /var/lib/jenkins/workspace/app/Ansible && ansible-playbook -i inventory.ini Balance.yml --user ec2-user && ansible-playbook -i inventory.ini Upstream.yml --user ec2-user"
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
