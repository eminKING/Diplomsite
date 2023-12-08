pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/your-username/your-project.git'
      }
    }

    stage('Build') {
      steps {
        sh 'npm install'
        sh 'npm run build'
      }
    }

    stage('Deploy') {
      steps {
        env.ansible_inventory = '/inventory.ini'

        # Run playbook
        sh 'ansible-playbook deploy.yml -u ansible'
      }
    }
  }
}
