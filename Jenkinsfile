pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'git@github.com:eminKING/Diplomsite.git'
            }
        }

        stage('Deploy') {
            steps {
                sh 'ansible-playbook-u ansible UpstreamServers.yml'
            }
        }
    }
}
