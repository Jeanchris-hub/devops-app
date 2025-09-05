pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ravoazanahary17/devops-app:latest"
    }

    options {
        skipDefaultCheckout()
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout unique avec les credentials Git SSH
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/main']], 
                          doGenerateSubmoduleConfigurations: false, 
                          extensions: [], 
                          userRemoteConfigs: [[url: 'git@github.com:Jeanchris-hub/devops-app.git', credentialsId: 'github-ssh']]])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                        docker.image("${DOCKER_IMAGE}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'kubeconfig-text', variable: 'KUBECONFIG_CONTENT')]) {
                    sh '''
                            mkdir -p $WORKSPACE/.kube
                            printf "%s" "$KUBECONFIG_CONTENT" > $WORKSPACE/.kube/config
                            export KUBECONFIG=$WORKSPACE/.kube/config
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            kubectl apply -f k8s/ingress.yaml
                        '''
            }
        }
    }
}
    }

    post {
        success {
            echo "✅ Déploiement réussi !"
        }
        failure {
            echo "❌ Erreur dans le pipeline."
        }
    }
}
