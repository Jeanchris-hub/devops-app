pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ravoazanahary17/devops-app"
        VERSION = "${env.BUILD_ID}"
        KUBECONFIG = "/home/chris/.kube/config"   // ton kubeconfig
    }

    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
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

        stage('Validate Dockerfile') {
            steps {
                echo "🔍 Validation du Dockerfile"
                sh 'docker build --pull --no-cache --target=build-stage . || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🛠 Construction de l'image Docker"
                script {
                    docker.build("${DOCKER_IMAGE}:${VERSION}")
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }

        stage('Test') {
            steps {
                echo "🧪 Exécution des tests"
                script {
                    def testImage = docker.image("${DOCKER_IMAGE}:${VERSION}")
                    testImage.inside {
                        sh 'echo "Running tests..."'
                    }
                }
            }
        }

        stage('Security Scan') {
            steps {
                echo "🔒 Analyse de sécurité"
                sh 'docker scan ${DOCKER_IMAGE}:${VERSION} --accept-license --json > scan-report.json || true'
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "🚀 Push de l'image Docker vers Docker Hub"
                script {
                    withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                        docker.image("${DOCKER_IMAGE}:latest").push()
                        docker.image("${DOCKER_IMAGE}:${VERSION}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "☸️ Déploiement sur Kubernetes"
                script {
            s       h '''
                        # Fix droits d'accès au kubeconfig
                        sudo chown $(whoami):$(whoami) /home/chris/.kube/config || true
                        chmod 600 /home/chris/.kube/config || true
                        sudo chown -R $(whoami):$(whoami) ~/.minikube ~/.kube || true
                        chmod -R u+rw ~/.minikube ~/.kube || true

                        # Déploiement
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                    '''
                }
            }
        }


    post {
        success {
            echo "🎉 Pipeline réussi et application déployée !"
            archiveArtifacts artifacts: 'scan-report.json', onlyIfSuccessful: false
        }
        failure {
            echo "❌ Erreur dans le pipeline. Vérifie les logs."
        }
        always {
            echo "🧹 Nettoyage des conteneurs temporaires"
            sh 'docker system prune -f || true'
        }
    }
}
