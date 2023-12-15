pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    echo "Deploying..."
                    scp -r /var/lib/jenkins/workspace/app/ root@172.31.47.56:/var/www/app
                    scp -r /var/lib/jenkins/workspace/app/ root@172.31.39.254:/var/www/app
                    ssh ec2-user@172.31.47.56 "rm -rf /var/www/app/ansible && rm /var/www/app/Jenkinsfile"
                    ssh ec2-user@172.31.39.254 "rm -rf /var/www/app/ansible && rm /var/www/app/Jenkinsfile"
                '''
            }
        }

        stage('Configure Servers') {
            steps {
                withCredentials([string(credentialsId: 'vault-secret-text', variable: 'vault-password')]) {
                    sh '''
                        echo "Configuring servers..."
                        sudo su - ansible -c "export ANSIBLE_VAULT_PASSWORD=$vault-password && ansible-playbook -i inventory Balance.yml && ansible-playbook -i inventory Upstream.yml"
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'echo "Pipeline has finished"'
        }
    }
}
