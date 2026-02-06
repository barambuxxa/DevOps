pipeline {
    agent { label 'slave' }

    environment {
        DOCKER_REGISTRY = 'gumidu'                      //Наш пользователь
        DOCKER_IMAGE_NAME = 'php-app-gurenich'          //Название нашего приложения на DockerHub
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials' // ID из настроек Jenkins
        IMAGE_TAG = "${env.BUILD_NUMBER}"  // Версия = номер сборки
    }

stages {
        // Этап 1: Проверка кода и окружения
        stage('Checkout & Setup') {
            steps {
                // Скачиваем код из Git
                git branch: 'main',
                url: 'https://github.com/barambuxxa/MyJenkins'  // адрес нашего repo на GitHub

                // Проверяем окружение
                sh '''
                    echo "=== Проверка окружения ==="
                    echo "Build Number: ${BUILD_NUMBER}"
                    docker --version
                    kubectl version --client
                    helm version
                    kubectl get nodes
                    echo "=== Проверка завершена ==="
                '''
            }
        }

// Этап 2: Сборка Docker образа
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Собираем Docker образ..."
                    // Собираем образ с тегом = номеру сборки
                    dockerImage = docker.build("${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
		}

// Этап 3: Пуш образа в Docker Hub
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Загружаем образ в Docker Hub..."
                    // Логинимся и пушим
                    docker.withRegistry('', "${DOCKER_CREDENTIALS_ID}") {
                        dockerImage.push()
                        // Также пушим как latest
                        dockerImage.push('latest')
                    }
                    echo "Образ успешно загружен: ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
// Этап 4: Деплой в Kubernetes
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Деплоим в Kubernetes..."
                    // Обновляем Helm chart с новой версией образа
                    sh """
                        helm upgrade --install my-php-app-${BUILD_NUMBER} ./helm-chart \
                            --namespace default \
                            --set image.repository=${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME} \
                            --set replicaCount=10 \
                            --timeout 5m \
                            --wait
                    """
                    echo "Деплой завершен!"
                }
            }
        }

// Этап 5: Проверка деплоя
        stage('Verify Deployment') {
            steps {
                script {
                    echo "Проверяем деплой..."
                    sh """
                        kubectl get pods -l project=my-php-app-${BUILD_NUMBER}
                        kubectl get svc -l app.kubernetes.io/managed-by=Helm
                    """
                }
            }
        }
		
	}
}
