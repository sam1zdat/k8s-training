#!/bin/bash
set -e

echo "=== Configuration des prérequis du système ==="

# 1. Configuration des paramètres du noyau (netfilter et overlay)
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configuration des paramètres réseau nécessaires
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

echo "Paramètres réseau du noyau configurés."

# 2. Installation de Containerd (Runtime de Conteneur)
echo "Installation et configuration de Containerd (pilote systemd)..."

# Ajout des dépendances et dépôts Docker officiels
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y containerd.io

# Configuration du pilote cgroup 'systemd' (Correction de l'erreur CNI/CoreDNS)
echo "Configuration du pilote cgroup sur systemd."

# Créer la configuration par défaut de Containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# Utiliser 'sed' pour changer "SystemdCgroup = false" à "SystemdCgroup = true"
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Redémarrer Containerd
sudo systemctl restart containerd

echo "Containerd installé et configuré."

# 3. Installation des outils Kubernetes (kubelet, kubeadm, kubectl)
echo "Installation de Kubeadm, Kubelet et Kubectl (v1.29)..."

# Ajout du dépôt Kubernetes (corrige les erreurs de dépôt obsolètes)
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Clé GPG
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
# Utilisation d'une version spécifique pour éviter les surprises
KUBE_VERSION="1.29.5-1.1" 
sudo apt-get install -y kubelet="$KUBE_VERSION" kubeadm="$KUBE_VERSION" kubectl="$KUBE_VERSION"

# Empêcher les mises à jour automatiques des outils K8s
sudo apt-mark hold kubelet kubeadm kubectl

# Activer Kubelet
sudo systemctl enable --now kubelet

echo "=== Installation de base terminée. ==="