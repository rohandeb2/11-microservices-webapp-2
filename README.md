# Online Boutique — Production-Grade Microservices Platform on AWS EKS

> A fully automated, AI-integrated DevSecOps platform deploying Google's Online Boutique (11 microservices) on AWS EKS Fargate, with GitOps, full observability, and intelligent automation.

![Platform Status](https://img.shields.io/badge/status-production--ready-brightgreen)
![Kubernetes](https://img.shields.io/badge/kubernetes-1.29-blue)
![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.5.0-purple)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Deployment Guide](#deployment-guide)
  - [1. Infrastructure — Terraform](#1-infrastructure--terraform)
  - [2. Cluster Bootstrap — Ansible](#2-cluster-bootstrap--ansible)
  - [3. CI/CD — Jenkins](#3-cicd--jenkins)
  - [4. GitOps — ArgoCD](#4-gitops--argocd)
- [Observability](#observability)
- [AI Tools](#ai-tools)
- [Security Model](#security-model)
- [Key Architectural Decisions](#key-architectural-decisions)
- [Cost Estimate](#cost-estimate)
- [Teardown](#teardown)
- [Author](#author)

---

## Architecture Overview

```
Developer Push
      │
      ▼
┌─────────────────────────────────────────────────────────┐
│                    Jenkins CI Pipeline                   │
│  YAML Lint → Secrets Scan → SAST → SCA → Docker Build  │
│  → Trivy Scan → SBOM (Syft) → Cosign Sign → ECR Push   │
│  → Update env-values/ → Git Push                        │
└─────────────────────────────────────────────────────────┘
      │
      ▼  (Git state change detected)
┌─────────────────────────────────────────────────────────┐
│                  ArgoCD (GitOps)                         │
│  root-app (App-of-Apps) → 11 child Helm applications    │
│  Automated sync · Self-heal · Prune · Retry             │
└─────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────┐
│              AWS EKS Fargate Cluster                     │
│  Namespace: boutique-app                                 │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  11 Services │  │  Prometheus  │  │  ELK Stack   │  │
│  │  frontend    │  │  + Grafana   │  │  Filebeat    │  │
│  │  checkout    │  │  AlertMgr    │  │  Logstash    │  │
│  │  payment...  │  │              │  │  Kibana      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  External    │  │  AWS LBC     │  │  HPA (CPU+   │  │
│  │  Secrets Op  │  │  (ALB Ingress│  │  Memory)     │  │
│  │  → Secrets   │  │  Controller) │  │              │  │
│  │    Manager   │  │              │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────────────────────┐
│              AWS Infrastructure (Terraform)              │
│  VPC (3-tier) · EKS · ECR · ALB · ACM · Route53        │
│  ElastiCache Redis · Secrets Manager · KMS              │
│  CloudFront · WAF · SNS · SQS · DynamoDB · S3           │
│  CloudWatch · X-Ray                                      │
└─────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Cloud | AWS (ap-south-1) |
| Infrastructure as Code | Terraform >= 1.5.0 |
| Container Orchestration | Amazon EKS 1.29 (Fargate) |
| CI Pipeline | Jenkins |
| GitOps | ArgoCD 2.9 (App-of-Apps pattern) |
| Package Manager | Helm 3 |
| Cluster Automation | Ansible |
| Container Registry | Amazon ECR (immutable tags, KMS encrypted) |
| Metrics | Prometheus + Grafana (kube-prometheus-stack) |
| Logging | ELK Stack (Elasticsearch 8.11, Logstash, Filebeat, Kibana) |
| Secrets Management | AWS Secrets Manager + External Secrets Operator |
| Image Security | Trivy (scan) + Cosign (sign) + Syft (SBOM) |
| SAST | SonarQube |
| SCA | OWASP Dependency Check |
| Networking | AWS Load Balancer Controller (ALB Ingress) |
| DNS & TLS | Route53 + ACM |
| CDN & WAF | CloudFront + WAFv2 |
| Caching | Amazon ElastiCache Redis 7 |
| Messaging | SNS + SQS + EventBridge |
| AI Integration | OpenAI GPT-3.5/4 (4 custom tools) |
| Encryption | AWS KMS (CMK) |

---

## Project Structure

```
.
├── terraform-aws-boutique/        # All AWS infrastructure
│   ├── environments/
│   │   ├── dev/                   # Dev environment entry point
│   │   └── prod/                  # Prod environment entry point
│   ├── modules/
│   │   ├── networking/            # VPC, subnets, NAT, CloudFront, Route53
│   │   ├── compute/               # EKS, ECR, ALB, Fargate
│   │   ├── security/              # IAM, KMS, WAF, ACM, Secrets Manager
│   │   ├── data/                  # ElastiCache, DynamoDB, S3, Athena
│   │   ├── messaging/             # SNS, SQS, EventBridge
│   │   └── observability/         # CloudWatch, X-Ray
│   └── global/
│       └── iam-users/             # Human access IAM users and groups
│
├── k8s-boutique-chart/            # Shared Helm chart for all 11 services
│   ├── templates/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml
│   │   └── configmap.yaml
│   └── env-values/                # Per-service value overrides
│
├── argocd/
│   ├── apps/                      # ArgoCD Application manifests (11 services)
│   ├── bootstrap/                 # Root App-of-Apps manifest
│   └── projects/                  # AppProject for RBAC governance
│
├── ansible/
│   ├── playbooks/
│   │   └── bootstrap-cluster.yml  # 7-phase cluster bootstrap
│   └── roles/
│       ├── eks-bootstrap/         # kubeconfig, namespaces, Helm repos
│       ├── argocd/                # ArgoCD install + root app
│       ├── elk/                   # ELK stack deployment
│       └── monitoring/            # Prometheus + Grafana
│
├── elk/                           # ELK manifests (ES, Logstash, Filebeat, Kibana)
├── k8s-cluster-bootstrap/         # RBAC, NetworkPolicy, Quota, LimitRange, SA
├── src/                           # Microservice Dockerfiles (11 services)
├── tools/                         # AI automation tools
│   ├── ai-alert-summarizer/       # Alertmanager webhook → GPT → Slack
│   ├── ai-analyzer/               # ELK error log → GPT root cause analysis
│   ├── ai-deployment-analyzer/    # Git diff → deployment risk score
│   └── ai-predictive-scaler/      # Prometheus RPS → GPT → K8s scale
├── Jenkinsfile                    # CI pipeline definition
├── docker-compose.yml             # Local development environment
└── deploy-k8s.sh                  # Manual deployment script (dev use)
```

---

## Prerequisites

### Local tools required

| Tool | Version | Install |
|---|---|---|
| AWS CLI | >= 2.x | [docs.aws.amazon.com](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| Terraform | >= 1.5.0 | [terraform.io](https://developer.hashicorp.com/terraform/install) |
| kubectl | >= 1.29 | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) |
| Helm | >= 3.x | [helm.sh](https://helm.sh/docs/intro/install/) |
| eksctl | >= 0.170 | [eksctl.io](https://eksctl.io/installation/) |
| Ansible | >= 2.14 | `pip install ansible` |
| Docker | >= 24.x | [docker.com](https://docs.docker.com/get-docker/) |

### Python packages for Ansible

```bash
pip install kubernetes openshift boto3
ansible-galaxy collection install kubernetes.core amazon.aws
```

### AWS permissions required

Your AWS credentials must have permissions for: EKS, ECR, VPC, IAM, ACM, Route53, ElastiCache, Secrets Manager, KMS, S3, DynamoDB, CloudFront, WAF, SNS, SQS, CloudWatch.

### Domain name

You need a registered domain. This project uses `rohandevops.co.in` — replace with your own in all configuration files before deploying.

---

## Deployment Guide

### 1. Infrastructure — Terraform

**Step 1: Create Terraform backend resources manually (one-time)**

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket rohan-terraform-state-dev \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket rohan-terraform-state-dev \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-lock-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

**Step 2: Initialize and apply**

```bash
cd terraform-aws-boutique/environments/dev

terraform init -backend-config=backend.conf

terraform plan -out=tfplan

terraform apply tfplan
```

**Step 3: Note the outputs**

```bash
terraform output certificate_arn    # needed for Helm values
terraform output cluster_name       # needed for kubeconfig
terraform output ecr_repository_urls
```

> Expected time: 20-30 minutes. EKS cluster creation takes the longest.

---

### 2. Cluster Bootstrap — Ansible

**Step 1: Update inventory with Terraform outputs**

Edit `ansible/inventory/hosts.yml`:

```yaml
vars:
  eks_cluster_name: "boutique-app-dev-cluster"   # from terraform output
  aws_region: "ap-south-1"
  aws_account_id: "YOUR_ACCOUNT_ID"
  domain_name: "yourdomain.com"
```

**Step 2: Run the bootstrap playbook**

```bash
cd ansible

# Full bootstrap (all 7 phases)
ansible-playbook playbooks/bootstrap-cluster.yml

# Or run specific phases with tags
ansible-playbook playbooks/bootstrap-cluster.yml --tags argocd
ansible-playbook playbooks/bootstrap-cluster.yml --tags monitoring
ansible-playbook playbooks/bootstrap-cluster.yml --tags elk
```

**What the bootstrap does (7 phases):**

| Phase | What it does |
|---|---|
| 1 | Verifies tools, configures kubeconfig, checks Fargate profile |
| 2 | Creates all namespaces, adds Helm repositories |
| 3 | Installs AWS Load Balancer Controller |
| 4 | Installs External Secrets Operator, applies SecretStore |
| 5 | Installs ArgoCD, bootstraps root App-of-Apps |
| 6 | Applies RBAC, NetworkPolicies, ResourceQuota, LimitRange |
| 7 | Prints platform summary with all URLs |

**Step 3: Retrieve ArgoCD credentials**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

Access ArgoCD at: `https://argocd.yourdomain.com`

---

### 3. CI/CD — Jenkins

**Step 1: Configure Jenkins credentials**

Add these credentials in Jenkins (Manage Jenkins → Credentials):

| Credential ID | Type | Value |
|---|---|---|
| `ecr-registry` | Secret text | `YOUR_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com` |
| `sonar-token` | Secret text | SonarQube project token |
| `sonar-host-url` | Secret text | SonarQube server URL |
| `cosign-private-key` | Secret file | Cosign private key file |
| `cosign-password` | Secret text | Cosign key password |

**Step 2: Create pipeline job**

- New Item → Pipeline
- Pipeline script from SCM → Git → your repository URL
- Branch: `main`
- Script path: `Jenkinsfile`

**Step 3: Pipeline stages**

```
Checkout → Lint → Secrets Scan → IaC Scan → SonarQube
→ OWASP Check → Build Images → Trivy Scan → SBOM
→ Sign Images → Push ECR → Deploy Dev → Approval → Deploy Prod
```

---

### 4. GitOps — ArgoCD

After bootstrap, ArgoCD automatically syncs all applications from the repository. No manual steps required.

**Verify sync status:**

```bash
# Check all apps
kubectl get applications -n argocd

# Watch sync in real time
watch kubectl get applications -n argocd
```

**Expected state — all apps should show:**

```
NAME                    SYNC STATUS   HEALTH STATUS
adservice               Synced        Healthy
cartservice             Synced        Healthy
checkoutservice         Synced        Healthy
currencyservice         Synced        Healthy
emailservice            Synced        Healthy
frontend                Synced        Healthy
paymentservice          Synced        Healthy
productcatalogservice   Synced        Healthy
recommendationservice   Synced        Healthy
shippingservice         Synced        Healthy
```

**Access the application:**

```bash
kubectl get ingress -n boutique-app
```

Visit: `https://boutique.yourdomain.com`

---

## Observability

### Grafana

**URL:** `https://grafana.yourdomain.com`
**Username:** `admin`
**Password:** Retrieved from `grafana-admin-credentials` secret in `monitoring` namespace

```bash
kubectl get secret grafana-admin-credentials -n monitoring \
  -o jsonpath="{.data.admin-password}" | base64 -d
```

Pre-loaded dashboards:
- Kubernetes Cluster Overview
- Pod-level CPU and memory metrics
- Per-service request rates and error rates
- HPA scaling events

### Kibana

**URL:** `https://kibana.yourdomain.com`
**Username:** `elastic`
**Password:** Retrieved from `elasticsearch-credentials` secret in `logging` namespace

Log pipeline: `Microservice pods → Filebeat (DaemonSet) → Logstash (parse + enrich) → Elasticsearch → Kibana`

Logs are indexed as `boutique-{service-name}-{date}`, e.g. `boutique-frontend-2024.01.15`

### Prometheus (internal)

```bash
# Port-forward to access locally
kubectl port-forward svc/kube-prometheus-stack-prometheus \
  9090:9090 -n monitoring
```

Visit: `http://localhost:9090`

### Alertmanager

Alerts are routed to Slack channel `#alerts-boutique`. Configure your Slack webhook in AWS Secrets Manager under the key `alertmanager-slack-webhook`.

---

## AI Tools

Four custom Python tools are deployed to enhance platform intelligence.

### 1. AI Log Analyzer (`tools/ai-analyzer/`)

**What it does:** Runs as a Kubernetes CronJob every 15 minutes. Queries Elasticsearch for ERROR-level logs from the past 15 minutes, sends each error to GPT-4 with service context, and prints a root cause analysis with suggested fix.

**Deployment:** Managed by ArgoCD via `argocd/apps/ai-analyzer.yaml`

**Logs:**

```bash
kubectl logs -l job-name=ai-log-analyzer -n logging --tail=50
```

### 2. AI Alert Summarizer (`tools/ai-alert-summarizer/`)

**What it does:** Runs as a Flask webhook receiver. Alertmanager sends firing alerts to this service. GPT-3.5 rewrites the raw alert into a human-readable summary with root cause guess and next step, then posts to Slack.

**Endpoint:** `http://ai-log-analyzer.logging.svc.cluster.local:5000/webhook`

### 3. AI Deployment Risk Analyzer (`tools/ai-deployment-analyzer/`)

**What it does:** Integrated into the Jenkins pipeline. Captures the `git diff` of each pull request and asks GPT-3.5 to score the deployment risk as Low, Medium, or High with reasoning.

**Usage in pipeline:**

```bash
git diff HEAD~1 HEAD > changes.diff
python risk_app.py changes.diff
```

### 4. AI Predictive Scaler (`tools/ai-predictive-scaler/`)

**What it does:** Runs as a Deployment, polling Prometheus every 60 seconds for current requests-per-second. Asks GPT-3.5 to predict required replicas for 20% traffic growth, then patches the frontend Deployment scale via the Kubernetes API.

**Required secret:** `AI_LOG_ANALYZER_KEY` in AWS Secrets Manager at path `ai/boutique-app/dev/log-analyzer`

---

## Security Model

### Identity and access

- Every microservice pod uses the `boutique-admin-sa` ServiceAccount
- That ServiceAccount is annotated with an IAM Role ARN (IRSA)
- The IAM Role has least-privilege access to Secrets Manager and KMS only
- No hardcoded credentials anywhere — all secrets come from AWS Secrets Manager via External Secrets Operator

### Network security

- Default-deny NetworkPolicy blocks all traffic in `boutique-app` namespace
- Explicit allow rules for: DNS (port 53), frontend ingress (port 8080), internal pod-to-pod
- ALB is the only ingress point — no NodePort services exposed

### Image security

Every image goes through this pipeline before reaching the cluster:

```
Build → Trivy scan (HIGH/CRITICAL = pipeline fail) 
     → Syft SBOM generation 
     → Cosign signing 
     → ECR push (immutable tags, KMS encrypted)
```

### Secrets rotation

External Secrets Operator syncs from AWS Secrets Manager every hour. To force immediate sync:

```bash
kubectl annotate externalsecret boutique-db-secrets \
  force-sync=$(date +%s) -n boutique-app
```

Note: After sync, trigger a rollout restart for pods to pick up new values:

```bash
kubectl rollout restart deployment -n boutique-app
```

### Kubernetes hardening

| Control | Implementation |
|---|---|
| Non-root containers | `runAsNonRoot: true`, `runAsUser: 1000` on all pods |
| Resource limits | LimitRange enforces defaults; ResourceQuota caps namespace total |
| RBAC | Microservices have read-only access to ConfigMaps and Services only |
| Cluster-wide read | Separate ClusterRole for monitoring/observability only |
| WAF | CloudFront → WAFv2 with AWS Managed Rules (CommonRuleSet + KnownBadInputs) |

---

## Key Architectural Decisions

**1. EKS Fargate over managed node groups**

Fargate eliminates node management, OS patching, and capacity planning. The tradeoff is no DaemonSets (solved by using Fargate-compatible Filebeat configuration), no privileged containers, and slightly higher per-pod cost. For a team without a dedicated infrastructure engineer, the operational savings outweigh the cost difference.

**2. App-of-Apps ArgoCD pattern over individual Application manifests**

A single root Application in `argocd/bootstrap/` manages all 11 child Applications in `argocd/apps/`. Adding a new microservice requires only dropping a new YAML file — ArgoCD discovers and syncs it automatically. The alternative (applying each manifest manually) doesn't scale and breaks GitOps purity.

**3. External Secrets Operator over Kubernetes Secrets in Git**

Storing Kubernetes Secrets in Git, even encrypted with Sealed Secrets or SOPS, creates a long-lived encrypted blob that must be rotated manually. ESO pulls from AWS Secrets Manager at runtime, meaning secret rotation requires no Git changes and takes effect within the refresh interval. The tradeoff is an additional operator to maintain.

**4. Single shared Helm chart over per-service charts**

All 11 services use one chart in `k8s-boutique-chart/` with per-service value overrides in `env-values/`. This enforces consistency — every service gets the same Deployment structure, HPA, NetworkPolicy, and security context. The tradeoff is reduced flexibility for services with unusual requirements (e.g. Elasticsearch, which is managed separately).

**5. ALB group annotation over one ALB per service**

All services share one ALB via `alb.ingress.kubernetes.io/group.name: boutique-group`. This reduces cost from ~$0.025/hour × 11 ALBs to $0.025/hour × 1 ALB. The tradeoff is that a misconfigured Ingress annotation on one service can affect routing for all services — mitigated by ArgoCD's self-heal and the review process in the Jenkins pipeline.

---

## Cost Estimate

Monthly AWS cost for the dev environment (ap-south-1, approximate):

| Resource | Cost/month |
|---|---|
| EKS cluster control plane | ~$72 |
| Fargate pods (11 services, min replicas) | ~$45 |
| ALB | ~$18 |
| ElastiCache Redis (cache.t3.medium × 2) | ~$65 |
| NAT Gateways (3 AZs) | ~$100 |
| ECR storage | ~$5 |
| Secrets Manager | ~$4 |
| CloudWatch + X-Ray | ~$10 |
| Route53 | ~$1 |
| **Total** | **~$320/month** |

> To minimize cost during development, tear down NAT Gateways and ElastiCache when not in use. The EKS control plane is the unavoidable fixed cost.

---

## Teardown

```bash
# Remove all Helm releases and Kubernetes resources
bash delete-eks.sh

# Destroy all AWS infrastructure
cd terraform-aws-boutique/environments/dev
terraform destroy
```

> The S3 state bucket and DynamoDB lock table are not destroyed by Terraform — delete them manually via the AWS console if needed.

---

## Author

**Rohan Deb**
B.Tech CSE — Final Year

- GitHub: [github.com/rohandeb2](https://github.com/rohandeb2)
- LinkedIn: [linkedin.com/in/rohandeb](https://linkedin.com/in/rohandeb)
- Domain: [rohandevops.co.in](https://rohandevops.co.in)

---

*Built as a capstone project demonstrating production-grade DevSecOps practices on AWS.*
