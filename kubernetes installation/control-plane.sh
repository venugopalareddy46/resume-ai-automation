#!/bin/bash

# ==============================================================
# Kubernetes Control Plane Installer
# Ubuntu EC2 + containerd + kubeadm + Calico
#
# Kubernetes : v1.36.4
# Calico     : v3.32.2
# Runtime    : containerd
# Pod CIDR   : 192.168.0.0/16
#
# Run as a normal Ubuntu user with sudo privileges.
# ==============================================================

set -Eeuo pipefail

# ==============================================================
# CONFIGURATION
# ==============================================================

K8S_VERSION="1.36.4"
K8S_MINOR_VERSION="v1.36"
CALICO_VERSION="v3.32.2"

POD_NETWORK_CIDR="192.168.0.0/16"
CONTROL_PLANE_HOSTNAME="control-plane"

CONTAINERD_SOCKET="unix:///run/containerd/containerd.sock"

# ==============================================================
# COLORS
# ==============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==============================================================
# FUNCTIONS
# ==============================================================

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

section() {
    echo ""
    echo "=============================================================="
    echo -e "${BLUE}$1${NC}"
    echo "=============================================================="
    echo ""
}

# ==============================================================
# ERROR HANDLER
# ==============================================================

trap 'error "Installation failed at line $LINENO."; error "Check the command above for the cause."' ERR

# ==============================================================
# ROOT CHECK
# ==============================================================

if [[ "${EUID}" -eq 0 ]]; then
    error "Do not run this script directly as root."
    echo "Run it as the Ubuntu user:"
    echo ""
    echo "bash install-k8s-control-plane.sh"
    exit 1
fi



# ==============================================================
# OS CHECK
# ==============================================================

section "Checking Operating System"

if [[ ! -f /etc/os-release ]]; then
    error "Cannot detect operating system."
    exit 1
fi

source /etc/os-release

echo "OS           : ${PRETTY_NAME}"
echo "Architecture : $(dpkg --print-architecture)"

if [[ "${ID}" != "ubuntu" ]]; then
    warn "This script is designed for Ubuntu."
fi

# ==============================================================
# ARCHITECTURE CHECK
# ==============================================================

ARCH="$(dpkg --print-architecture)"

if [[ "${ARCH}" != "amd64" && "${ARCH}" != "arm64" ]]; then
    error "Unsupported architecture: ${ARCH}"
    exit 1
fi

# ==============================================================
# HOSTNAME
# ==============================================================

section "Configuring Hostname"

sudo hostnamectl set-hostname "${CONTROL_PLANE_HOSTNAME}"

log "Hostname: $(hostname)"

# ==============================================================
# CONTROL PLANE PRIVATE IP
# ==============================================================

section "Control Plane Private IP"

echo "Available IPv4 addresses:"
echo ""

ip -4 addr show | grep -w inet || true

echo ""
echo "Enter the PRIVATE IPv4 address of this EC2 instance."
echo "Example: 10.0.1.10"
echo ""
echo "Do NOT enter the public EC2 IP."
echo ""

read -rp "Control Plane Private IP: " CONTROL_PLANE_IP

# ==============================================================
# IP FORMAT VALIDATION
# ==============================================================

if [[ -z "${CONTROL_PLANE_IP}" ]]; then
    error "Control Plane IP cannot be empty."
    exit 1
fi

if ! [[ "${CONTROL_PLANE_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    error "Invalid IPv4 address: ${CONTROL_PLANE_IP}"
    exit 1
fi

IFS='.' read -r -a IP_PARTS <<< "${CONTROL_PLANE_IP}"

for PART in "${IP_PARTS[@]}"; do
    if (( PART < 0 || PART > 255 )); then
        error "Invalid IPv4 address: ${CONTROL_PLANE_IP}"
        exit 1
    fi
done

# ==============================================================
# IP EXISTENCE CHECK
# ==============================================================

if ! ip -4 addr show | grep -qw "${CONTROL_PLANE_IP}"; then
    error "${CONTROL_PLANE_IP} is not assigned to this machine."
    echo ""
    echo "Available addresses:"
    ip -4 addr show
    exit 1
fi

log "Private IP verified: ${CONTROL_PLANE_IP}"

# ==============================================================
# DISPLAY CONFIGURATION
# ==============================================================

section "Installation Configuration"

echo "Hostname              : ${CONTROL_PLANE_HOSTNAME}"
echo "Private IP            : ${CONTROL_PLANE_IP}"
echo "Kubernetes            : v${K8S_VERSION}"
echo "Kubernetes Repository : ${K8S_MINOR_VERSION}"
echo "Container Runtime     : containerd"
echo "Calico                : v${CALICO_VERSION}"
echo "Pod Network CIDR      : ${POD_NETWORK_CIDR}"
echo ""

read -rp "Continue installation? (y/n): " CONFIRM

if [[ "${CONFIRM}" != "y" && "${CONFIRM}" != "Y" ]]; then
    echo ""
    echo "Installation cancelled."
    exit 0
fi

# ==============================================================
# UPDATE UBUNTU
# ==============================================================

section "1. Updating Ubuntu"

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# ==============================================================
# INSTALL BASIC PACKAGES
# ==============================================================

section "2. Installing Required Packages"

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gpg \
    gnupg \
    jq \
    conntrack \
    socat \
    ebtables \
    ethtool \
    iproute2 \
    iputils-ping \
    net-tools \
    bash-completion \
    runc \
    containerd

log "Required packages installed."

# ==============================================================
# DISABLE SWAP
# ==============================================================

section "3. Disabling Swap"

sudo swapoff -a

sudo sed -ri '/[[:space:]]swap[[:space:]]/ s/^/#/' /etc/fstab

if [[ "$(swapon --show | wc -l)" -eq 0 ]]; then
    log "Swap disabled."
else
    warn "Swap is still enabled."
fi

free -h

# ==============================================================
# KERNEL MODULES
# ==============================================================

section "4. Loading Kubernetes Kernel Modules"

sudo tee /etc/modules-load.d/k8s.conf > /dev/null <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

log "Kernel modules loaded."

# ==============================================================
# SYSCTL NETWORKING
# ==============================================================

section "5. Configuring Kubernetes Networking"

sudo tee /etc/sysctl.d/k8s.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

echo ""
echo "IP forwarding:"
sysctl net.ipv4.ip_forward

# ==============================================================
# CONTAINERD CONFIGURATION
# ==============================================================

section "6. Configuring containerd"

sudo mkdir -p /etc/containerd

containerd config default | \
    sudo tee /etc/containerd/config.toml > /dev/null

# Use systemd cgroup driver.
sudo sed -i \
    's/SystemdCgroup = false/SystemdCgroup = true/g' \
    /etc/containerd/config.toml

# Ensure CRI is not disabled.
if grep -qE 'disabled_plugins.*cri' /etc/containerd/config.toml; then
    sudo sed -i \
        '/disabled_plugins.*cri/d' \
        /etc/containerd/config.toml
fi

sudo systemctl daemon-reload
sudo systemctl enable containerd
sudo systemctl restart containerd

sleep 3

if ! sudo systemctl is-active --quiet containerd; then
    error "containerd is not running."
    sudo systemctl status containerd --no-pager
    exit 1
fi

log "containerd is running."

echo ""
containerd --version

echo ""
echo "SystemdCgroup configuration:"
sudo grep -n "SystemdCgroup" /etc/containerd/config.toml

# ==============================================================
# KUBERNETES REPOSITORY
# ==============================================================

section "7. Configuring Kubernetes Repository"

sudo mkdir -p -m 755 /etc/apt/keyrings

# Remove old repository configuration.
sudo rm -f /etc/apt/sources.list.d/kubernetes.list

# Download Kubernetes repository key.
curl -fsSL \
    "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/deb/Release.key" \
    | sudo gpg --dearmor --yes \
    -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add v1.36 repository.
echo \
"deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

log "Kubernetes repository configured."

# ==============================================================
# INSTALL KUBERNETES
# ==============================================================

section "8. Installing Kubernetes"

sudo apt-get update

sudo apt-get install -y \
    kubelet \
    kubeadm \
    kubectl

sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable kubelet

# ==============================================================
# VERIFY KUBERNETES VERSION
# ==============================================================

section "9. Verifying Kubernetes"

echo "kubeadm:"
kubeadm version

echo ""
echo "kubectl:"
kubectl version --client

echo ""
echo "kubelet:"
kubelet --version

# ==============================================================
# VERIFY EXPECTED VERSION
# ==============================================================

INSTALLED_KUBEADM_VERSION="$(kubeadm version -o short 2>/dev/null || true)"

if [[ "${INSTALLED_KUBEADM_VERSION}" != "v${K8S_VERSION}" ]]; then
    warn "Installed kubeadm version is ${INSTALLED_KUBEADM_VERSION}"
    warn "Expected v${K8S_VERSION}"
fi

# ==============================================================
# KUBEADM INIT
# ==============================================================

section "10. Initializing Kubernetes Control Plane"

echo "Kubernetes version : v${K8S_VERSION}"
echo "Control Plane IP   : ${CONTROL_PLANE_IP}"
echo "Pod Network CIDR   : ${POD_NETWORK_CIDR}"
echo "CRI socket         : ${CONTAINERD_SOCKET}"
echo ""

# IMPORTANT:
# Do NOT run:
# kubeadm init phase preflight --apiserver-advertise-address
#
# kubeadm init performs preflight checks automatically.

sudo kubeadm init \
    --kubernetes-version="v${K8S_VERSION}" \
    --apiserver-advertise-address="${CONTROL_PLANE_IP}" \
    --pod-network-cidr="${POD_NETWORK_CIDR}" \
    --cri-socket="${CONTAINERD_SOCKET}"

# ==============================================================
# KUBECTL CONFIGURATION
# ==============================================================

section "11. Configuring kubectl"

mkdir -p "${HOME}/.kube"

sudo cp -f \
    /etc/kubernetes/admin.conf \
    "${HOME}/.kube/config"

sudo chown \
    "$(id -u):$(id -g)" \
    "${HOME}/.kube/config"

chmod 600 "${HOME}/.kube/config"

log "kubectl configuration completed."

# ==============================================================
# VERIFY API SERVER
# ==============================================================

section "12. Verifying Kubernetes API Server"

kubectl cluster-info

echo ""

kubectl get nodes -o wide

# ==============================================================
# CALICO CRDS
# ==============================================================

section "13. Installing Calico CRDs"

CALICO_BASE_URL="https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests"

kubectl create -f \
    "${CALICO_BASE_URL}/v1_crd_projectcalico_org.yaml"

# ==============================================================
# TIGERA OPERATOR
# ==============================================================

section "14. Installing Tigera Operator"

kubectl create -f \
    "${CALICO_BASE_URL}/tigera-operator.yaml"

# ==============================================================
# WAIT FOR TIGERA OPERATOR
# ==============================================================

section "15. Waiting for Tigera Operator"

kubectl wait \
    --for=condition=Available \
    deployment/tigera-operator \
    -n tigera-operator \
    --timeout=300s

log "Tigera Operator is available."

# ==============================================================
# CALICO CUSTOM RESOURCES
# ==============================================================

section "16. Installing Calico"

CALICO_FILE="/tmp/calico-custom-resources.yaml"

curl -fsSL \
    "${CALICO_BASE_URL}/custom-resources.yaml" \
    -o "${CALICO_FILE}"

# Verify the default Calico IP pool.
echo ""
echo "Calico IP pool configuration:"
grep -n "cidr:" "${CALICO_FILE}" || true
echo ""

# The default Calico v3.32.2 manifest uses 192.168.0.0/16,
# which matches our kubeadm pod network CIDR.
#
# If the downloaded manifest uses another CIDR, replace it.

sed -i \
    -E "s#cidr: [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+#cidr: ${POD_NETWORK_CIDR}#g" \
    "${CALICO_FILE}"

kubectl create -f "${CALICO_FILE}"

rm -f "${CALICO_FILE}"

log "Calico resources created."

# ==============================================================
# WAIT FOR CALICO
# ==============================================================

section "17. Waiting for Calico"

log "Waiting for Calico components..."

sleep 30

echo ""
echo "Calico pods:"
kubectl get pods -n calico-system || true

echo ""
echo "Tigera status:"
kubectl get tigerastatus || true

# ==============================================================
# WAIT FOR NODE READY
# ==============================================================

section "18. Waiting for Control Plane"

log "Waiting for the control-plane node to become Ready..."

NODE_READY="false"

for i in {1..30}; do

    NODE_STATUS="$(kubectl get node "${CONTROL_PLANE_HOSTNAME}" \
        -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' \
        2>/dev/null || true)"

    if [[ "${NODE_STATUS}" == "True" ]]; then
        NODE_READY="true"
        break
    fi

    echo "Waiting... ${i}/30"
    sleep 10

done

# ==============================================================
# FINAL NODE STATUS
# ==============================================================

section "19. Kubernetes Nodes"

kubectl get nodes -o wide

if [[ "${NODE_READY}" != "true" ]]; then
    warn "Control plane is not Ready yet."
    warn "Check:"
    echo "kubectl get pods -A"
    echo "kubectl get tigerastatus"
else
    log "Control plane is Ready."
fi

# ==============================================================
# ALL PODS
# ==============================================================

section "20. Kubernetes Pods"

kubectl get pods -A

# ==============================================================
# CALICO STATUS
# ==============================================================

section "21. Calico Status"

kubectl get pods -n calico-system || true

echo ""

kubectl get tigerastatus || true

# ==============================================================
# GENERATE WORKER JOIN COMMAND
# ==============================================================

section "22. Worker Node Join Command"

JOIN_COMMAND="$(sudo kubeadm token create --print-join-command)"

echo ""
echo "Run the following command on EVERY worker node:"
echo ""
echo "sudo ${JOIN_COMMAND} --cri-socket=${CONTAINERD_SOCKET}"
echo ""

# Save join command.
JOIN_FILE="${HOME}/kubeadm-join-command.txt"

echo "sudo ${JOIN_COMMAND} --cri-socket=${CONTAINERD_SOCKET}" \
    > "${JOIN_FILE}"

chmod 600 "${JOIN_FILE}"

log "Join command saved to:"
echo "${JOIN_FILE}"

# ==============================================================
# FINAL INFORMATION
# ==============================================================

section "KUBERNETES CONTROL PLANE INSTALLATION COMPLETE"

echo "Hostname           : ${CONTROL_PLANE_HOSTNAME}"
echo "Private IP         : ${CONTROL_PLANE_IP}"
echo "Kubernetes         : v${K8S_VERSION}"
echo "Container Runtime  : containerd"
echo "Calico             : v${CALICO_VERSION}"
echo "Pod Network        : ${POD_NETWORK_CIDR}"
echo ""

echo "Useful commands:"
echo ""
echo "kubectl get nodes -o wide"
echo "kubectl get pods -A"
echo "kubectl get pods -n calico-system"
echo "kubectl get tigerastatus"
echo "kubectl get svc -A"
echo "kubectl cluster-info"
echo ""

echo "Worker join command:"
echo ""
cat "${JOIN_FILE}"

echo ""
echo "=============================================================="
echo " DONE"
echo "=============================================================="