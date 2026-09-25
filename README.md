# 🚀 Resume AI — Self-Healing DevOps Application

<p align="center">
  <img src="https://img.shields.io/badge/Resume%20AI-Self--Healing%20DevOps-0A66C2?style=for-the-badge&logo=github&logoColor=white" alt="Resume AI">
  <img src="https://img.shields.io/badge/Docker-Containerized-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Kubernetes-Orchestrated-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" alt="Kubernetes">
  <img src="https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions">
</p>

<p align="center">
  <b>End-to-End DevOps • CI/CD • Kubernetes • Monitoring • Self-Healing</b>
</p>

<p align="center">
  A production-style DevOps implementation of a Resume AI application,
  demonstrating automated deployment, containerization, Kubernetes orchestration,
  health monitoring, troubleshooting, and self-healing.
</p>

---

## 📌 Project Overview

The **Resume AI – Self-Healing DevOps Application** demonstrates a complete application delivery workflow from source code to a running application.

```text
                    👨‍💻 Developer
                         │
                         ▼
                      GitHub
                         │
                         ▼
                 GitHub Actions
                         │
                 ┌───────┴───────┐
                 ▼               ▼
               Test          Docker Build
                                 │
                                 ▼
                            Docker Hub
                                 │
                                 ▼
                            Kubernetes
                                 │
                                 ▼
                              Ingress
                                 │
                    ┌────────────┴────────────┐
                    ▼                         ▼
                 Frontend                  Backend
                 Service                   Service
                    │                         │
                ┌───┴───┐                 ┌───┴───┐
                ▼       ▼                 ▼       ▼
              Pod 1   Pod 2             Pod 1   Pod 2
                                              │
                                              ▼
                                           /health
                                              │
                                              ▼
                                      Python Monitoring
                                              │
                                     ┌────────┴────────┐
                                     ▼                 ▼
                                    UP                DOWN
                                     │                 │
                                     ▼                 ▼
                                  Healthy        Troubleshooting
                                                       │
                                                       ▼
                                                  Self-Healing
```

---

## ✨ Key Features

* 🚀 Resume AI web application
* 📦 Docker containerization
* 🐳 Docker Hub image publishing
* ☸️ Kubernetes deployment
* 🔄 Two application replicas
* 🌐 Nginx Ingress Controller
* 🔐 Kubernetes Secrets
* ⚙️ Kubernetes ConfigMaps
* 🔁 GitHub Actions CI/CD
* 🐍 Python health monitoring
* ❤️ `/health` endpoint
* 🔥 Failure simulation
* 🛠️ Kubernetes troubleshooting
* ♻️ Kubernetes self-healing
* 📊 Application health verification

---

## 🛠️ Technologies Used

| Technology     | Purpose                     |
| -------------- | --------------------------- |
| Node.js        | Application runtime         |
| npm            | Dependency management       |
| Git            | Version control             |
| GitHub         | Source code repository      |
| GitHub Actions | CI/CD automation            |
| Docker         | Containerization            |
| Docker Hub     | Container registry          |
| Kubernetes     | Container orchestration     |
| Nginx Ingress  | External application access |
| ConfigMap      | Application configuration   |
| Secret         | Sensitive configuration     |
| Python 3       | Health monitoring           |
| Requests       | HTTP health checks          |
| Ubuntu/Linux   | Deployment environment      |

---

# 📁 Project Structure

```text
resume-ai/
│
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── application files
│
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── application files
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   └── secret.yaml
│
├── monitoring/
│   ├── health_monitor.py
│   ├── requirements.txt
│   └── health_monitor.log
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
├── docker-compose.yml
└── README.md
```

---

# 🚀 1. Clone the Repository

```bash
git clone <YOUR-GITHUB-REPOSITORY>
```

```bash
cd resume-ai
```

---

# 💻 2. Run Application Locally

Check Node.js:

```bash
node --version
```

Check npm:

```bash
npm --version
```

Install dependencies:

```bash
npm install
```

Start the application:

```bash
npm start
```

Open:

```text
http://localhost:3000
```

Test the health endpoint:

```bash
curl http://localhost:3000/health
```

---

# 🐳 3. Run Using Docker

Build the backend image:

```bash
docker build -t resume-ai-backend:2.0 ./backend
```

Build the frontend image:

```bash
docker build -t resume-ai-frontend:2.0 ./frontend
```

Check images:

```bash
docker images
```

Run the backend:

```bash
docker run -d \
  --name resume-ai-backend \
  -p 3000:3000 \
  resume-ai-backend:2.0
```

Check:

```bash
docker ps
```

Test:

```bash
curl http://localhost:3000/health
```

---

# 🐳 4. Run Using Docker Compose

For a multi-container setup:

```bash
docker compose up -d
```

Check containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f
```

Stop:

```bash
docker compose down
```

---

# 📦 5. Push Image to Docker Hub

Login:

```bash
docker login
```

Tag:

```bash
docker tag resume-ai-backend:2.0 \
<dockerhub-username>/resume-ai-backend:2.0
```

Push:

```bash
docker push \
<dockerhub-username>/resume-ai-backend:2.0
```

---

# ☸️ 6. Deploy to Kubernetes

Check the cluster:

```bash
kubectl get nodes
```

Apply ConfigMap:

```bash
kubectl apply -f k8s/configmap.yaml
```

Apply Secret:

```bash
kubectl apply -f k8s/secret.yaml
```

Deploy application:

```bash
kubectl apply -f k8s/deployment.yaml
```

Create Service:

```bash
kubectl apply -f k8s/service.yaml
```

Configure Ingress:

```bash
kubectl apply -f k8s/ingress.yaml
```

---

# 🔍 7. Verify Kubernetes

Pods:

```bash
kubectl get pods
```

Deployment:

```bash
kubectl get deployment
```

Services:

```bash
kubectl get service
```

Ingress:

```bash
kubectl get ingress
```

ConfigMap:

```bash
kubectl get configmap
```

Secret:

```bash
kubectl get secret
```

---

# 🌐 8. Application Access

### Frontend

```text
https://venugopalareddy.in
```

### Backend API

```text
https://api.venugopalareddy.in
```

### Health Endpoint

```text
https://api.venugopalareddy.in/health
```

Test:

```bash
curl https://api.venugopalareddy.in/health
```

Expected:

```text
Status: UP
HTTP: 200
```

---

# ⚙️ 9. ConfigMap and Secret

ConfigMap contains:

```text
APP_NAME
APP_ENV
APP_VERSION
```

Check:

```bash
kubectl get configmap
```

Secret contains the test application secret:

```text
TEST_SECRET
```

Check:

```bash
kubectl get secret
```

Verify environment variables:

```bash
kubectl exec -it <pod-name> -- env
```

> ⚠️ Never commit real passwords, API keys, tokens, or production credentials to GitHub.

---

# 🐍 10. Python Health Monitoring

Go to the monitoring directory:

```bash
cd monitoring
```

Install dependencies:

```bash
pip3 install -r requirements.txt
```

Run the monitor:

```bash
python3 health_monitor.py
```

Monitoring flow:

```text
             Python Monitor
                    │
                    ▼
                 /health
                    │
                    ▼
             Application UP?
               ↙       ↘
             YES        NO
              │          │
              ▼          ▼
           Log OK     Log Error
```

Example:

```text
Status=UP | HTTP=200
```

Failure example:

```text
Status=DOWN | HTTP=N/A | Error=Connection Error
```

---

# ❤️ 11. Kubernetes Self-Healing

Check Pods:

```bash
kubectl get pods
```

Delete one Pod:

```bash
kubectl delete pod <pod-name>
```

Watch Kubernetes:

```bash
kubectl get pods -w
```

Kubernetes automatically creates a replacement Pod.

Verify:

```bash
kubectl get deployment
```

Expected:

```text
READY
2/2
```

Test again:

```bash
curl https://api.venugopalareddy.in/health
```

---

# 🔧 12. Troubleshooting

### Check Pods

```bash
kubectl get pods
```

### Pod Details

```bash
kubectl describe pod <pod-name>
```

### Pod Logs

```bash
kubectl logs <pod-name>
```

### Kubernetes Events

```bash
kubectl get events --sort-by=.lastTimestamp
```

### Deployment Details

```bash
kubectl describe deployment resume-ai-backend
```

### Rollout Status

```bash
kubectl rollout status deployment/resume-ai-backend
```

---

# ❌ 13. Failure Simulation

For controlled testing, use an invalid image:

```text
resume-ai-backend:does-not-exist
```

Check:

```bash
kubectl get pods
```

Possible result:

```text
ErrImagePull
```

or:

```text
ImagePullBackOff
```

Troubleshoot:

```bash
kubectl describe pod <pod-name>
```

Check events:

```bash
kubectl get events --sort-by=.lastTimestamp
```

Restore the correct image:

```text
<dockerhub-username>/resume-ai-backend:2.0
```

Apply:

```bash
kubectl apply -f k8s/deployment.yaml
```

Verify:

```bash
kubectl rollout status deployment/resume-ai-backend
```

---

# 🔄 14. GitHub Actions CI/CD

The CI/CD pipeline follows:

```text
Git Push
    │
    ▼
GitHub Actions
    │
    ▼
Install Dependencies
    │
    ▼
Run Tests
    │
    ▼
Docker Build
    │
    ▼
Docker Hub
    │
    ▼
Kubernetes Deployment
    │
    ▼
Rollout Verification
```

Workflow:

```text
.github/
└── workflows/
    └── ci-cd.yml
```

Check pipeline:

```text
GitHub → Repository → Actions
```

---

# 🧪 15. Final Verification

Run:

```bash
kubectl get nodes
```

```bash
kubectl get pods
```

```bash
kubectl get deployment
```

```bash
kubectl get service
```

```bash
kubectl get ingress
```

```bash
kubectl get configmap
```

```bash
kubectl get secret
```

Health check:

```bash
curl https://api.venugopalareddy.in/health
```

Monitoring:

```bash
python3 monitoring/health_monitor.py
```

---

# 📊 Final Status

| Component          | Status |
| ------------------ | :----: |
| GitHub             |    ✅   |
| GitHub Actions     |    ✅   |
| Docker             |    ✅   |
| Docker Hub         |    ✅   |
| Docker Compose     |    ✅   |
| Kubernetes         |    ✅   |
| 2 Replicas         |    ✅   |
| Service            |    ✅   |
| Ingress            |    ✅   |
| ConfigMap          |    ✅   |
| Secret             |    ✅   |
| Health Check       |    ✅   |
| Python Monitoring  |    ✅   |
| Self-Healing       |    ✅   |
| Failure Simulation |    ✅   |
| Troubleshooting    |    ✅   |

---

# 🏆 Final Architecture

```text
                       👨‍💻 Developer
                            │
                            ▼
                         GitHub
                            │
                            ▼
                    GitHub Actions
                            │
                            ▼
                       Docker Build
                            │
                            ▼
                       Docker Hub
                            │
                            ▼
                       Kubernetes
                            │
                            ▼
                         Ingress
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
       venugopalareddy.in       api.venugopalareddy.in
              │                           │
              ▼                           ▼
        Frontend Service            Backend Service
              │                           │
          ┌───┴───┐                   ┌───┴───┐
          ▼       ▼                   ▼       ▼
        Pod 1   Pod 2               Pod 1   Pod 2
                                          │
                                          ▼
                                       /health
                                          │
                                          ▼
                                  Python Monitoring
                                          │
                                   ┌──────┴──────┐
                                   ▼             ▼
                                  UP            DOWN
                                   │             │
                                   ▼             ▼
                               Healthy      Troubleshoot
                                                 │
                                                 ▼
                                            Self-Healing
```

---

# 🎯 Final Result

The **Resume AI Self-Healing DevOps Application** demonstrates a complete end-to-end DevOps workflow:

```text
GitHub
   ↓
GitHub Actions
   ↓
Docker
   ↓
Docker Hub
   ↓
Kubernetes
   ↓
Service
   ↓
Ingress
   ↓
Resume AI
   ↓
Health Check
   ↓
Python Monitoring
   ↓
Failure Detection
   ↓
Kubernetes Self-Healing
```

---

## 👨‍💻 Author

**Venu Gopala Reddy Eppala**

**Project:** Resume AI — Self-Healing DevOps Application
