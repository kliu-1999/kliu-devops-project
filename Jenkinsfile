pipeline {
    agent any

    environment {
        GO_VERSION = '1.22'
        DOCKER_IMAGE = "${DOCKER_USERNAME}/product-catalog:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Go') {
            steps {
                sh "wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
                sh "sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz"
                sh 'export PATH=$PATH:/usr/local/go/bin'
            }
        }

        stage('Build') {
            steps {
                dir('src/product-catalog') {
                    sh 'go mod download'
                    sh 'go build -o product-catalog-service main.go'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                dir('src/product-catalog') {
                    sh 'go test ./...'
                }
            }
        }

        stage('Code Quality - golangci-lint') {
            steps {
                dir('src/product-catalog') {
                    sh '''
                        curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2
                        $(go env GOPATH)/bin/golangci-lint run
                    '''
                }
            }
        }

        stage('Docker Build and Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
                    sh "docker build -t ${DOCKER_IMAGE} -f src/product-catalog/Dockerfile src/product-catalog"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                    sh """
                        git config --global user.email "kevinliu1999@gmail.com"
                        git config --global user.name "Kevin Liu"
                        sed -i 's|image: .*|image: ${DOCKER_IMAGE}|' kubernetes/productcatalog/deploy.yaml
                        git add kubernetes/productcatalog/deploy.yaml
                        git commit -m "[CI]: Update product catalog image tag" || echo "No changes to commit"
                        git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/kliu-devops-project.git HEAD:main
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}
