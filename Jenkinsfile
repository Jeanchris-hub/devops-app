pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ton-dockerhub-username/devops-app:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'git@github.com:ton-username/devops-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                                      usernameVariable: 'DOCKER_USER',
                                                      passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker build -t $DOCKER_IMAGE .
                        docker push $DOCKER_IMAGE
                        docker logout
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh """
                        kubectl --kubeconfig=$KUBECONFIG set image deployment/devops-app devops-app=$DOCKER_IMAGE --namespace=default
                        kubectl --kubeconfig=$KUBECONFIG rollout status deployment/devops-app --namespace=default
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline terminé.'
        }
        success {
            echo '✅ Déploiement réussi !'
        }
        failure {
            echo '❌ Erreur dans le pipeline.'
        }
    }
}
