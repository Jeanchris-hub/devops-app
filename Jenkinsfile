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
                echo "📥 Checkout du code depuis GitHub"
                checkout([$class: 'GitSCM', 
                          branches: [[name: '*/main']], 
                          doGenerateSubmoduleConfigurations: false, 
                          extensions: [], 
                          userRemoteConfigs: [[
                              url: 'git@github.com:Jeanchris-hub/devops-app.git', 
                              credentialsId: 'github-ssh'
                          ]]])
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🛠 Construction de l'image Docker"
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "🚀 Push de l'image Docker vers Docker Hub"
                script {
                    withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                        docker.image("${DOCKER_IMAGE}").push()
                    }
                }
            }
        }
        
    }

    post {
        success {
            echo "🎉 Déploiement réussi !"
        }
        failure {
            echo "❌ Erreur dans le pipeline. Vérifie les logs."
        }
        always {
            echo "🧹 Nettoyage si nécessaire"
            // Si tu veux supprimer le kubeconfig temporaire :
            sh 'rm -f $KUBECONFIG_FILE || true'
        }
    }
}
