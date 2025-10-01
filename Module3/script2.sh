#!/bin/bash
set -e

# Définir l'adresse IP de votre Master (à adapter si nécessaire)
MASTER_IP=$(hostname -I | awk '{print $1}')

echo "=== Initialisation du Control Plane sur $MASTER_IP ==="

# 1. Initialisation du cluster Kubernetes
# Utilisation du CIDR 10.244.0.0/16 car Flannel est le CNI utilisé.
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$MASTER_IP

# 2. Configuration de l'environnement kubectl
# Permet à l'utilisateur courant d'utiliser kubectl sans 'sudo'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 3. Installation du CNI Flannel
echo "Installation du CNI Flannel..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "Le Control Plane est initialisé. Attendez 2 minutes."
echo "Surveillez les Pods critiques : kubectl get pods -n kube-system"

echo "=== Commande de jointure pour le Worker ==="
# 4. Afficher la commande de jointure (à exécuter sur la VM Worker)
JOIN_COMMAND=$(sudo kubeadm token create --print-join-command)
echo "Exécutez cette commande sur la VM Worker :"
echo "----------------------------------------------------------------------"
echo $JOIN_COMMAND
echo "----------------------------------------------------------------------"