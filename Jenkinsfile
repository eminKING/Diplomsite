pipeline {
    agent any

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-repo.git'
            }
        }

        stage('Deploy to Nginx') {
            steps {
                // Здесь должны быть шаги для копирования файлов вашего веб-приложения на сервер Nginx
                // Например, если вы используете scp, то:
                // sh 'scp -r ./* user@nginx-server:/path/to/your/app'
            }
        }
    }
}
