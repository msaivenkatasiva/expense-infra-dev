pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        timeout(time: 60, unit: 'MINUTES')
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    
    stages {
        stage('init') {
            steps {
                sh """
                    cd 01-vpc
                    terraform init -reconfigure
                """
            }
        }
        stage('Test') {
            steps {
                sh 'echo this is test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo this is deploy'
            }
        }
        
    }
    post {
        always {
            echo 'I Will run always'
            deleteDir()
        }
        success {
            echo 'I will run only when code is success'
        }
        failure {
            echo 'i will run when there is failure'
        }
    }
}