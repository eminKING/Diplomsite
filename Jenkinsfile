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
                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-user-ssh', keyFileVariable: 'KEYFILE')]) {
                    echo "Deploying..."
                        sh '''
                            ssh ec2-user@172.31.44.15 "rm -rf /home/ec2-user/app/"
                            ssh ec2-user@172.31.35.168 "rm -rf /home/ec2-user/app/"
                            scp -r /var/lib/jenkins/workspace/app/ ec2-user@172.31.44.15:/home/ec2-user/
                            scp -r /var/lib/jenkins/workspace/app/ ec2-user@172.31.35.168:/home/ec2-user/
                            ssh ec2-user@172.31.44.15 "rm -rf /home/ec2-user/app/Ansible && rm /home/ec2-user/app/Jenkinsfile"
                            ssh ec2-user@172.31.35.168 "rm -rf /home/ec2-user/app/Ansible && rm /home/ec2-user/app/Jenkinsfile"
                        '''
                    }
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
                    timeout(time: 30, unit: 'SECONDS') {
                        input message: 'Do you want to proceed with configuring servers?', submitter: 'admin'
                    }
                }

                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-user-ssh', keyFileVariable: 'KEYFILE'), string(credentialsId: 'vault-secret-text', variable: 'vault-password')]) {
                        sh '''
                            echo "Configuring servers..."
                            ssh ec2-user@172.31.40.24 "rm -rf /home/ec2-user/nginx.conf"
                            ssh ec2-user@172.31.40.24 "rm -rf /home/ec2-user/server.conf" && ssh ec2-user@172.31.44.15 "rm -rf /home/ec2-user/server.conf" && ssh ec2-user@172.31.35.168 "rm -rf /home/ec2-user/server.conf"
                            scp -r /var/lib/jenkins/workspace/app/Ansible/nginx.conf ec2-user@172.31.40.24:/home/ec2-user/
                            scp -r /var/lib/jenkins/workspace/app/Ansible/server.conf ec2-user@172.31.40.24:/home/ec2-user/ && scp -r /var/lib/jenkins/workspace/app/Ansible/server.conf ec2-user@172.31.44.15:/home/ec2-user/ && scp -r /var/lib/jenkins/workspace/app/Ansible/server.conf ec2-user@172.31.35.168:/home/ec2-user/
                            ssh ec2-user@172.31.40.24 "cp /home/ec2-user/nginx.conf /etc/nginx/nginx.conf"
                            ssh ec2-user@172.31.40.24 "cp /home/ec2-user/server.conf /etc/nginx/conf.d/server.conf" && ssh ec2-user@172.31.44.15 "cp /home/ec2-user/server.conf /etc/nginx/conf.d/server.conf" && ssh ec2-user@172.31.35.168 "cp /home/ec2-user/server.conf /etc/nginx/conf.d/server.conf"
                            sudo su - ansible -c "export ANSIBLE_VAULT_PASSWORD=$vault-password && cd /var/lib/jenkins/workspace/app/Ansible && ansible-playbook -i inventory.ini Balance.yml --user ec2-user && ansible-playbook -i inventory.ini Upstream.yml --user ec2-user"
                        '''
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
