
# 🧪 Démonstration - Exposition et accès aux applications avec des Services sur notre cluster local
⏱️ **Durée estimée : 20 minutes**

## 🎯 Objectifs
- Comprendre le fonctionnement des Services de type ClusterIP
- Exposer une application interne dans un cluster Kubernetes
- Accéder à une application via un Service ClusterIP
- Comprendre comment les endpoints sont gérés par les Services

## Introduction
Les Services dans Kubernetes permettent d'exposer des applications s'exécutant sur des pods en tant que service réseau. Cette démonstration couvre la création, la gestion et l'accès à des applications utilisant des Services de type ClusterIP.

---

## 🔧 Prérequis
- Un cluster Kubernetes fonctionnel
- kubectl configuré pour accéder au cluster

---

## 1️⃣ Création d'un Service ClusterIP

### a) Créer un deployment avec une réplique
```bash
kubectl create deployment hello-world-clusterip --image=psk8s.azurecr.io/hello-app:1.0
```
👉 Crée un deployment avec une seule réplique.

### b) Exposer le deployment avec un Service ClusterIP
```bash
kubectl expose deployment hello-world-clusterip --port=80 --target-port=8080 --type ClusterIP
```
👉 Expose le deployment avec un Service de type ClusterIP.

### c) Lister les services et examiner les détails
```bash
kubectl get service
```
👉 Affiche la liste des services avec leur type, CLUSTER-IP et port.

### d) Récupérer l'adresse IP du Service
```bash
SERVICEIP=$(kubectl get service hello-world-clusterip -o jsonpath='{ .spec.clusterIP }')
echo $SERVICEIP
```
👉 Récupère et affiche l'adresse IP du Service.

### e) Accéder au service à l'intérieur du cluster
```bash
kubectl run busybox --image=busybox --restart=Never --command -- sleep 3600
kubectl exec -it busybox -- sh

wget http://$SERVICEIP
```
<img width="1252" height="497" alt="image" src="https://github.com/user-attachments/assets/7f128570-06f2-4f95-a953-89229f736bae" />

👉 Accède à l'application via l'adresse IP du Service.

### f) Lister les endpoints pour le service
```bash
kubectl get endpoints hello-world-clusterip
kubectl get pods -o wide
```
👉 Affiche les endpoints pour le service et les détails des pods.

### g) Accéder directement à l'application du pod
```bash
kubectl get endpoints hello-world-clusterip
PODIP=$(kubectl get endpoints hello-world-clusterip -o jsonpath='{ .subsets[].addresses[].ip }')
echo $PODIP
curl http://$PODIP:8080
```
👉 Accède directement à l'application du pod via son adresse IP et le port cible.

---

## 2️⃣ Mise à l'échelle et gestion des endpoints

### a) Mettre à l'échelle le deployment
```bash
kubectl scale deployment hello-world-clusterip --replicas=6
kubectl get endpoints hello-world-clusterip
```
👉 Met à l'échelle le deployment à 6 répliques et affiche les endpoints mis à jour.

### b) Accéder au service avec load balancing
```bash
curl http://$SERVICEIP
```
👉 Accède au service, les requêtes sont load balancées entre les pods.

### c) Examiner les détails du service et les labels des pods
```bash
kubectl describe service hello-world-clusterip
kubectl get pods --show-labels
```
👉 Affiche les détails du service et les labels des pods.

---

## 3️⃣ Nettoyage et exemple déclaratif

### a) Nettoyer les ressources
```bash
kubectl delete deployments hello-world-clusterip
kubectl delete service hello-world-clusterip
```
👉 Supprime le deployment et le service.

### b) Exemple déclaratif
```bash
kubectl apply -f service-hello-world-clusterip.yaml
kubectl get service
```
👉 Applique un fichier de configuration déclarative pour créer le service et affiche la liste des services.

### c) Nettoyer les ressources déclaratives
```bash
kubectl delete -f service-hello-world-clusterip.yaml
```
👉 Supprime le service créé via le fichier de configuration.

---

## ✅ Résultats attendus
À la fin de cette démonstration, vous serez capable de :
1. Créer un Service de type ClusterIP pour exposer une application interne
2. Accéder à une application via un Service ClusterIP
3. Comprendre comment les endpoints sont gérés par les Services
4. Mettre à l'échelle un deployment et observer le load balancing

## 💡 Bonnes pratiques
- Utilisez des Services de type ClusterIP pour les applications internes
- Testez toujours les configurations dans un environnement de staging
- Surveillez les endpoints pour vérifier la disponibilité des pods
- Utilisez des fichiers de configuration déclarative pour une gestion plus facile des ressources



