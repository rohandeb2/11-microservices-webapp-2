# Microservices E-Commerce Platform on AWS EKS

A production-ready microservices-based e-commerce application deployed on Amazon EKS (Elastic Kubernetes Service) with complete CI/CD automation using Jenkins and ArgoCD.
<div align="center">
  <img src="src/images/2.png" >
</div>
<div align="center">
  <img src="src/images/3.png" >
</div>
<div align="center">
  <img src="src/images/4.png" >
</div>
<div align="center">
  <img src="src/images/5.png" >
</div>

## 🏗️ Architecture Overview
<div align="center">
  <img src="src/images/1.png" >
</div>

This project implements a cloud-native microservices architecture featuring:

- **11 Microservices** for various e-commerce functionalities
- **Amazon EKS** for container orchestration
- **Jenkins** for CI/CD pipeline automation
- **ArgoCD** for GitOps-based continuous deployment
- **Terraform** for infrastructure as code
- **Amazon ECR** for container image registry
- **AWS Route 53** for DNS management
- **Classic Load Balancer** with HTTPS/SSL termination

## 🎯 Key Features

- Automated infrastructure provisioning with Terraform
- Containerized microservices architecture
- GitOps deployment workflow with ArgoCD
- Automated CI/CD pipelines for each microservice
- Secure HTTPS access with AWS Certificate Manager
- Custom domain configuration
- High availability and scalability on Kubernetes

## 🛠️ Technology Stack

| Category | Technologies |
|----------|-------------|
| **Cloud Provider** | AWS (EKS, EC2, ECR, S3, Route 53, ACM) |
| **Container Orchestration** | Kubernetes (EKS) |
| **Infrastructure as Code** | Terraform |
| **CI/CD** | Jenkins, ArgoCD |
| **Version Control** | Git, GitHub |
| **Security Scanning** | Trivy |
| **Build Tools** | Maven, Docker |
| **Package Manager** | Helm |

## 📦 Microservices

The application consists of the following microservices:

1. **emailservice** - Handles email notifications
2. **checkoutservice** - Manages checkout process
3. **recommendationservice** - Provides product recommendations
4. **frontend** - User interface
5. **paymentservice** - Processes payments
6. **productcatalogservice** - Manages product catalog
7. **cartservice** - Shopping cart functionality
8. **loadgenerator** - Simulates user traffic
9. **currencyservice** - Currency conversion
10. **shippingservice** - Shipping calculations
11. **adservice** - Advertisement management

## 🚀 Prerequisites

Before you begin, ensure you have the following installed:

- AWS CLI configured with appropriate credentials
- Git
- VS Code or any preferred IDE
- Active AWS account with necessary permissions
- Registered domain (optional, for custom domain setup)

### Required Tools (Pre-installed on EC2 Jumphost)

- Jenkins
- Terraform
- kubectl
- eksctl
- Helm
- Docker
- Trivy
- Maven
- Java

## 📋 Quick Start Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/rohandeb2/onlineboutique-webapp.git
cd Microservices-E-Commerce-eks-project
```

### Step 2: Configure AWS Credentials

```bash
aws configure
```

Provide:
- Access Key ID
- Secret Access Key
- Region (e.g., `us-west-2`)
- Output format: `json`

### Step 3: Create S3 Backend for Terraform State

```bash
cd s3-buckets/
terraform init
terraform plan
terraform apply -auto-approve
```

### Step 4: Provision Network Infrastructure

```bash
cd ../terraform_main_ec2
terraform init
terraform plan
terraform apply -auto-approve
```

Note the output `jumphost_public_ip` for Jenkins access.

### Step 5: Access EC2 Jumphost and Verify Tools

```bash
# Connect to EC2 via AWS Console
sudo -i

# Verify installations
git --version
java -version
jenkins --version
terraform -version
kubectl version --client --short
docker --version
```

### Step 6: Jenkins Initial Setup

1. Get the initial admin password:
```bash
cat /var/lib/jenkins/secrets/initialAdminPassword
```

2. Access Jenkins at `http://<EC2-Public-IP>:8080`
3. Install suggested plugins
4. Create admin user
5. Install additional plugin: **Pipeline: stage view**

### Step 7: Create Jenkins Pipeline Jobs

#### EKS Cluster Pipeline

1. Create new Pipeline job: `eks-terraform`
2. Configure:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository**: `https://github.com/rohandeb2/onlineboutique-webapp.git`
   - **Branch**: `*/master`
   - **Script Path**: `eks-terraform/eks-jenkinsfile`
3. Build with parameter: `action = apply`

Verify EKS cluster:
```bash
aws eks --region us-west-2 update-kubeconfig --name project-eks
kubectl get nodes
```

#### ECR Registry Pipeline

1. Create new Pipeline job: `ecr-terraform`
2. Configure with same repository
3. **Script Path**: `ecr-terraform/ecr-jenkinfile`
4. Build with parameter: `action = apply`

Verify ECR repositories:
```bash
aws ecr describe-repositories --region us-west-2
```

#### Microservices Build Pipelines

Create individual pipeline jobs for each microservice:

- `emailservice` → Script Path: `jenkinsfiles/emailservice`
- `checkoutservice` → Script Path: `jenkinsfiles/checkoutservice`
- `recommendationservice` → Script Path: `jenkinsfiles/recommendationservice`
- `frontend` → Script Path: `jenkinsfiles/frontend`
- `paymentservice` → Script Path: `jenkinsfiles/paymentservice`
- `productcatalogservice` → Script Path: `jenkinsfiles/productcatalogservice`
- `cartservice` → Script Path: `jenkinsfiles/cartservice`
- `loadgenerator` → Script Path: `jenkinsfiles/loadgenerator`
- `currencyservice` → Script Path: `jenkinsfiles/currencyservice`
- `shippingservice` → Script Path: `jenkinsfiles/shippingservice`
- `adservice` → Script Path: `jenkinsfiles/adservice`

**Note**: Add GitHub PAT token as Jenkins credential (ID: `my-git-pattoken`) before building.

### Step 8: Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Verify installation
kubectl get pods -n argocd

# Expose ArgoCD server
kubectl edit svc argocd-server -n argocd
# Change type from ClusterIP to LoadBalancer

# Get ArgoCD URL
kubectl get svc argocd-server -n argocd

# Get admin password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

Access ArgoCD at `https://<EXTERNAL-IP>.amazonaws.com` with username `admin`.

### Step 9: Deploy Application with ArgoCD

1. Create namespace:
```bash
kubectl create namespace dev
```

2. In ArgoCD UI, create new application:
   - **Application Name**: `project`
   - **Project**: `default`
   - **Sync Policy**: `Automatic`
   - **Repository URL**: `https://github.com/rohandeb2/onlineboutique-webapp.git`
   - **Path**: `kubernetes-files`
   - **Cluster URL**: `https://kubernetes.default.svc`
   - **Namespace**: `dev`

### Step 10: Configure Custom Domain (Optional)

#### Setup Route 53

1. Create hosted zone for your domain
2. Update domain registrar with Route 53 nameservers

#### Request SSL Certificate

1. Go to AWS Certificate Manager
2. Request public certificate for your domain
3. Use DNS validation
4. Create CNAME records in Route 53

#### Configure Load Balancer

1. Add HTTPS listener (port 443) to Classic Load Balancer
2. Attach SSL certificate
3. Configure security group to allow port 443
4. Create Route 53 A record pointing to load balancer

#### Test HTTPS Access

```bash
curl -v https://your-domain.com
```

## 🔒 Security Best Practices

- AWS credentials stored securely using AWS Secrets Manager
- GitHub PAT token stored in Jenkins credentials
- SSL/TLS encryption for all external traffic
- Container vulnerability scanning with Trivy
- Network isolation with VPC and security groups
- RBAC configured for Kubernetes access

## 📊 Monitoring and Observability

The platform includes monitoring capabilities through:
- Kubernetes native metrics
- Load balancer health checks
- ArgoCD deployment status
- Jenkins build history

## 🔄 CI/CD Workflow

1. **Code Commit** → Developer pushes code to GitHub
2. **Build Trigger** → Jenkins detects changes and triggers pipeline
3. **Build & Test** → Application is built and tested
4. **Security Scan** → Trivy scans for vulnerabilities
5. **Image Push** → Docker image pushed to ECR
6. **Manifest Update** → Kubernetes manifests updated with new image tag
7. **Sync** → ArgoCD detects changes and syncs to EKS cluster
8. **Deploy** → Application deployed to Kubernetes

## 🛡️ Infrastructure Components

### AWS Resources Created

- VPC with public/private subnets
- EKS cluster with worker nodes
- EC2 jumphost for management
- ECR repositories for container images
- S3 buckets for Terraform state
- Classic Load Balancer
- Route 53 hosted zone
- ACM SSL certificate
- Security groups and IAM roles

## 📝 Project Structure

```
.
├── s3-buckets/              # Terraform for S3 backend
├── terraform_main_ec2/      # Terraform for EC2 and networking
├── eks-terraform/           # Terraform for EKS cluster
├── ecr-terraform/           # Terraform for ECR repositories
├── jenkinsfiles/            # Jenkins pipeline definitions
├── kubernetes-files/        # Kubernetes manifests
└── src/                     # Microservices source code
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request
