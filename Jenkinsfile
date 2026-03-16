pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REGISTRY = credentials('ecr-registry')
        SONAR_TOKEN = credentials('sonar-token')
        SONAR_HOST_URL = credentials('sonar-host-url')
        COSIGN_PRIVATE_KEY = credentials('cosign-private-key')
        COSIGN_PASSWORD = credentials('cosign-password')
    }

    stages {

        // ---------------- CHECKOUT ----------------
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        // ---------------- LINTING ----------------
        stage('Linting') {
            steps {
                sh '''
                echo "Running YAML Lint"
                yamllint .

                echo "Running Dockerfile Lint"
                docker run --rm -i hadolint/hadolint < Dockerfile || true
                '''
            }
        }

        // ---------------- SECRET SCAN ----------------
        stage('Secrets Scan') {
            steps {
                sh '''
                echo "Running Gitleaks"
                gitleaks detect --source . --exit-code 1
                '''
            }
        }

        // ---------------- IAC SECURITY ----------------
        stage('Trivy IaC Scan') {
            steps {
                sh '''
                echo "Running Trivy IaC scan"
                trivy config . --severity HIGH,CRITICAL --exit-code 1
                '''
            }
        }

        // ---------------- SAST ----------------
        stage('SonarQube Scan') {
            steps {

                withSonarQubeEnv('SonarQube') {

                    sh '''
                    sonar-scanner \
                    -Dsonar.projectKey=OnlineBoutique \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=$SONAR_HOST_URL \
                    -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        // ---------------- SCA ----------------
        stage('OWASP Dependency Check') {
            steps {

                sh '''
                dependency-check.sh \
                --project OnlineBoutique \
                --scan . \
                --format HTML \
                --failOnCVSS 7
                '''
            }
        }

        // ---------------- BUILD + SECURITY ----------------
        stage('Build Secure Images') {
            steps {

                script {

                    def services = [
                        "adservice",
                        "cartservice",
                        "checkoutservice",
                        "currencyservice",
                        "emailservice",
                        "frontend",
                        "paymentservice",
                        "productcatalogservice",
                        "recommendationservice",
                        "shippingservice"
                    ]

                    for(service in services){

                        sh """
                        echo "Building ${service}"

                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REGISTRY}

                        docker build -t ${ECR_REGISTRY}/boutique-${service}:${BUILD_NUMBER} ./src/${service}
                        """

                        // -------- IMAGE SECURITY SCAN --------
                        sh """
                        echo "Running Trivy Image Scan"

                        trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 1 \
                        ${ECR_REGISTRY}/boutique-${service}:${BUILD_NUMBER}
                        """

                        // -------- SBOM GENERATION --------
                        sh """
                        echo "Generating SBOM"

                        syft ${ECR_REGISTRY}/boutique-${service}:${BUILD_NUMBER} \
                        -o spdx-json > sbom-${service}.json
                        """

                        // -------- IMAGE SIGNING --------
                        sh """
                        echo "Signing Image"

                        cosign sign --yes \
                        --key env://COSIGN_PRIVATE_KEY \
                        ${ECR_REGISTRY}/boutique-${service}:${BUILD_NUMBER}
                        """

                        sh """
                        docker push ${ECR_REGISTRY}/boutique-${service}:${BUILD_NUMBER}
                        """
                    }
                }
            }
        }

        // ---------------- DEPLOY DEV ----------------
        stage('Deploy Dev') {
            steps {

                sh '''
                sed -i "s|tag:.*|tag: ${BUILD_NUMBER}|" env-values/dev/*.yaml

                git config user.name "GitOps Bot"

                git add .

                git commit -m "deploy(dev): version ${BUILD_NUMBER}"

                git push
                '''
            }
        }

        // ---------------- APPROVAL ----------------
        stage('Approval') {
            steps {
                input message: "Approve Production Deployment?"
            }
        }

        // ---------------- DEPLOY PROD ----------------
        stage('Deploy Production') {
            steps {

                sh '''
                sed -i "s|tag:.*|tag: ${BUILD_NUMBER}|" env-values/prod/*.yaml

                git add .

                git commit -m "deploy(prod): version ${BUILD_NUMBER}"

                git push
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
        }

        failure {
            echo "Pipeline failed"
        }
    }
}