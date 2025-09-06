pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ravoazanahary17/devops-app"
        VERSION = "${env.BUILD_ID}"
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
                        // Ajoutez vos commandes de test ici
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
   
    }


    post {
        success {
            echo "🎉 Déploiement réussi !"
            archiveArtifacts artifacts: 'scan-report.json', onlyIfSuccessful: false
        }
        failure {
            echo "❌ Erreur dans le pipeline. Vérifie les logs."
        }
        always {
            echo "🧹 Nettoyage des conteneurs temporaires"
            sh 'docker system prune -f || true'
        }
    }}