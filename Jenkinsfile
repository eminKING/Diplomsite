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
                    sh "git clone git@github.com:eminKING/Diplomsite.git /var/lib/jenkins/workspace/app/"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Deploying..."
                     scp -r /var/lib/jenkins/workspace/app/ ec2-user@172.31.44.15:/var/www/app
                     scp -r /var/lib/jenkins/workspace/app/ ec2-user@172.31.35.168:/var/www/app
                     ssh ec2-user@172.31.44.15 "rm -rf /var/www/app/ansible && rm /var/www/app/Jenkinsfile"
                     ssh ec2-user@172.31.35.168 "rm -rf /var/www/app/ansible && rm /var/www/app/Jenkinsfile"
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
