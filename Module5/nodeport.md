# 🧪 Démonstration - Création d'un Service NodePort
⏱️ **Durée estimée : 20 minutes**

## 🎯 Objectifs
- Comprendre le fonctionnement des Services de type NodePort
- Exposer une application sur un port spécifique de chaque nœud du cluster
- Accéder à une application via un Service NodePort
- Comprendre comment les Services NodePort routent le trafic vers les pods

## Introduction
Les Services de type NodePort dans Kubernetes permettent d'exposer une application sur un port spécifique de chaque nœud du cluster. Cette démonstration couvre la création, la gestion et l'accès à des applications utilisant des Services NodePort.

---

## 🔧 Prérequis
- Un cluster Kubernetes fonctionnel avec plusieurs nœuds
- kubectl configuré pour accéder au cluster

---

## 1️⃣ Création d'un Service NodePort

### a) Créer un deployment avec une réplica
```bash
kubectl create deployment hello-world-nodeport --image=psk8s.azurecr.io/hello-app:1.0
```
👉 Crée un deployment avec une seule réplica.

### b) Exposer le deployment avec un Service NodePort
```bash
kubectl expose deployment hello-world-nodeport --port=80 --target-port=8080 --type NodePort
```
👉 Expose le deployment avec un Service de type NodePort.

### c) Afficher les détails du service
```bash
kubectl get service
```
👉 Affiche la liste des services avec leur type, CLUSTER-IP, Port et NodePort.

### d) Récupérer les informations du service
```bash
CLUSTERIP=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.clusterIP }')
PORT=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.ports[].port }')
NODEPORT=$(kubectl get service hello-world-nodeport -o jsonpath='{ .spec.ports[].nodePort }')
```
👉 Récupère et stocke les informations du service pour une utilisation ultérieure.

### e) Accéder au service via le NodePort
```bash
kubectl get pods -o wide
curl http://c1-cp1:$NODEPORT
curl http://c1-node1:$NODEPORT
curl http://c1-node2:$NODEPORT
curl http://c1-node3:$NODEPORT
```
👉 Accède au service via le NodePort sur chaque nœud du cluster.

### f) Accéder au service via la ClusterIP
```bash
echo $CLUSTERIP:$PORT
curl http://$CLUSTERIP:$PORT
```
👉 Accède au service via la ClusterIP.

---

## 2️⃣ Nettoyage et exemple déclaratif

### a) Nettoyer les ressources
```bash
kubectl delete service hello-world-nodeport
kubectl delete deployment hello-world-nodeport
```
👉 Supprime le service et le deployment.

### b) Exemple déclaratif
```bash
kubectl apply -f service-hello-world-nodeport-incorrect.yaml
kubectl apply -f service-hello-world-nodeport.yaml
kubectl get service
```
👉 Applique des fichiers de configuration déclarative pour créer le service et affiche la liste des services.

### c) Nettoyer les ressources déclaratives
```bash
kubectl delete -f service-hello-world-nodeport.yaml
```
👉 Supprime le service créé via le fichier de configuration.

---

## ✅ Résultats attendus
À la fin de cette démonstration, vous serez capable de :
1. Créer un Service de type NodePort pour exposer une application sur un port spécifique de chaque nœud
2. Accéder à une application via un Service NodePort
3. Comprendre comment les Services NodePort routent le trafic vers les pods

## 💡 Bonnes pratiques
- Utilisez des Services de type NodePort pour exposer des applications sur un port spécifique de chaque nœud
- Testez toujours les configurations dans un environnement de staging
- Surveillez les ports utilisés pour éviter les conflits
- Utilisez des fichiers de configuration déclarative pour une gestion plus facile des ressources

## 📚 Pour aller plus loin
- Consultez la documentation officielle sur les Services NodePort
- Explorez les autres types de Services (ClusterIP, LoadBalancer, etc.)
- Découvrez comment utiliser des Ingress pour gérer l'accès externe aux services