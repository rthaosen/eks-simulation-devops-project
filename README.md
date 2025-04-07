## 💼 DevOps Portfolio Project - Starter Template (Free & EKS-Focused)

This is a **hands-on DevOps portfolio project** built to demonstrate real-world tools like **Terraform**, **Helm**, **Ansible**, and **GitHub Actions** — without spending a dime on cloud. It simulates an **AWS EKS infrastructure locally** using Kind and adds full observability with Prometheus + Grafana.

---

## 🧰 Tools Used

- **Terraform** – IaC for AWS EKS (mocked)
- **Kind** – Local Kubernetes cluster (EKS simulated)
- **Helm** – App + Monitoring deployments
- **Ansible** – Lightweight local provisioning
- **GitHub Actions** – CI/CD pipeline
- **Prometheus & Grafana** – Monitoring stack

---

## 📁 Folder Structure

```
devops-portfolio/
├── terraform-eks-mock/       # Mocked Terraform code
├── kind-k8s-cluster/         # Kind config + Helm charts
├── ansible/                  # Basic Ansible playbook + inventory
├── scripts/                  # Local setup + cleanup
├── diagrams/                 # Architecture diagrams (EKS + local)
├── .github/workflows/        # GitHub Actions pipeline
├── .gitignore
└── README.md
```

---

## 🚀 Local Setup (EKS Simulated)

### ✅ 1. Create Kind Cluster & Deploy

```bash
bash scripts/run-local.sh
```

- App deployed via Helm  
- Monitoring stack installed (Prometheus & Grafana)

### 📊 Grafana Access

- URL: [http://localhost:3000](http://localhost:3000)  
- Username: `admin`  
- Password: `admin`  
- Preconfigured dashboard: ✅ `K8s Cluster Overview`

### 🧹 Tear Down

```bash
bash scripts/cleanup.sh
```

---

## 🔁 CI/CD Pipeline (GitHub Actions)

On every push to `main`:

1. Terraform: Init → Validate → Plan
2. Provision Kind cluster
3. Deploy app & monitoring stack using Helm

Pipeline: [.github/workflows/ci.yml](.github/workflows/ci.yml)

---

## 📐 Architecture Diagrams

### 🟢 Local Kubernetes Monitoring Workflow (Kind + Helm + Prometheus + Grafana)

graph TD
  A[run-local.sh script] --> B[Kind Cluster]
  
  B --> C[Sample App (hello-release)]
  C -->|Uses| C1[NGINX Docker Image]
  
  B --> D[Prometheus]
  B --> E[Grafana]

  D -->|Scrapes Metrics| F[Kubernetes Nodes/Pods]
  E -->|Uses Datasource| D
  E -->|Loads| G[Cluster Overview Dashboard (JSON)]

  G1[dashboard-configmap.yaml](kind-k8s-cluster/monitoring/dashboard-configmap.yaml) --> G
  G2[grafana-values.yaml](kind-k8s-cluster/monitoring/grafana-values.yaml)
 --> E
  D1[prometheus-values.yaml](kind-k8s-cluster/monitoring/prometheus-values.yaml) --> D

  C -->|Port-Forwarded| H1[localhost:8080]
  E -->|Port-Forwarded| H2[localhost:3000]
  D -->|Port-Forwarded| H3[localhost:9090]



### 🟡 Production Monitoring Architecture with Terraform, Ansible, and Kubernetes

graph TD
  subgraph IaC Setup
    T[Terraform]
    T -->|Provision| C1[Cloud Infrastructure (VMs, Load Balancer, etc.)]
    A[Ansible]
    A -->|Configure| C1
  end

  subgraph Kubernetes Cluster
    K8s[Kubernetes Cluster]
    C1 --> K8s

    K8s --> APP[Production App (e.g., Web App)]
    APP -->|Uses| NGINX[NGINX Container]

    K8s --> PROM[Prometheus]
    K8s --> GRAF[Grafana]

    PROM -->|Scrapes| METRICS[Cluster Metrics]
    GRAF -->|Displays| DASHBOARD[Monitoring Dashboards]
    GRAF -->|Uses| PROM
  end

  subgraph CI/CD (Optional)
    GIT[GitHub Repo]
    GIT -->|Trigger| CI[CI Pipeline]
    CI -->|Deploy| APP
  end

  subgraph Access Points
    GRAF -->|Exposed| GRAF_UI[Grafana UI :3000]
    PROM -->|Exposed| PROM_UI[Prometheus UI :9090]
    APP -->|Exposed| APP_UI[App UI :80/443]
  end

---

## 📂 Key Files

- `terraform-eks-mock/`: Defines EKS cluster (mocked, no real AWS costs)
- `kind-k8s-cluster/helm-chart/`: Sample microservice Helm chart
- `monitoring/`: Prometheus + Grafana config
- `ansible/playbook.yaml`: Basic local provisioner
- `scripts/run-local.sh`: Full environment bootstrap

---

### ✅ Notes

- **Terraform** provisions the infrastructure (e.g., EC2, VPC, EKS, etc.).
- **Ansible** configures the provisioned resources (e.g., installs packages, sets up kubelet, joins the cluster).
- **Kubernetes** hosts the actual workloads and observability stack.
- **Prometheus** scrapes metrics from the cluster.
- **Grafana** visualizes those metrics.
- **NGINX** serves as the web server/proxy for the app.

---

## 🎯 What This Project Demonstrates

- Infrastructure-as-Code (IaC) practices
- Kubernetes deployment workflows
- CI/CD automation pipelines
- Monitoring and dashboard setup
- Cost-effective local simulation of cloud-native setups

---

## 📌 Future Ideas

- Add real EKS provisioning (paid)
- Push Docker image to ECR
- Add Alertmanager + Slack/Email alerts
- Use ArgoCD or Flux for GitOps

---

## 📄 License

MIT
