```markdown
# 🧪 Exercice - Découverte de l'API Kubernetes et utilisation de `kubectl`
⏱️ **Durée estimée : 30 minutes**

## 🎯 Objectifs
- Comprendre comment explorer l'API Kubernetes
- Apprendre à utiliser les commandes `kubectl explain`, `dry-run` et `diff`
- Générer et appliquer des manifests YAML

## Introduction
Ce TP vous guidera à travers les outils essentiels de kubectl pour interagir avec l'API Kubernetes. Vous apprendrez à explorer la structure des ressources, valider vos configurations avant application et comparer différentes versions de manifests.

---

## 1️⃣ Découverte de l'API et du cluster

### a) Vérifier le contexte actuel
```bash
kubectl config get-contexts
```
👉 Affiche tous les contextes Kubernetes configurés et indique celui actuellement actif (marqué par un astérisque).
*Conseil* : Utilisez cette commande pour vérifier que vous travaillez sur le bon cluster avant toute opération.

### b) Changer de contexte si nécessaire
```bash
kubectl config use-context kubernetes-admin@kubernetes
```
👉 Bascule vers le contexte spécifié. Utile lorsque vous travaillez avec plusieurs clusters.

### c) Obtenir des informations sur le cluster
```bash
kubectl cluster-info
```
👉 Affiche :
- L'URL de l'API Server
- L'état de contrôleurs essentiels (core-dns, etc.)
- La version de Kubernetes
*À noter* : Vérifiez que le serveur est accessible avant de continuer.

### d) Lister les ressources disponibles
```bash
kubectl api-resources | more
```
👉 Liste complète des types de ressources disponibles avec :
- Le nom court (pour les commandes)
- Le nom complet de l'API
- Si la ressource est namespaced ou non
*Exemple* : `pods (po)`, `deployments (deploy)`, etc.

---

## 2️⃣ Explorer les ressources avec `kubectl explain`

### a) Structure d'un Pod
```bash
kubectl explain pods | more
```
👉 Affiche la documentation complète de l'objet Pod avec :
- Les champs obligatoires
- Les champs optionnels
- Les types de données attendus

### b) Zoom sur la spécification (`spec`)
```bash
kubectl explain pod.spec | more
kubectl explain pod.spec.containers | more
```
👉 Permet d'explorer :
1. La structure globale d'un Pod
2. Les détails des conteneurs (image, ports, resources, etc.)
*Astuce* : Utilisez cette commande pour comprendre la structure attendue avant de créer un manifest.

---

## 3️⃣ Créer et supprimer un Pod via YAML

### a) Déploiement d'un Pod
```bash
kubectl apply -f pod.yaml
```
👉 Applique le manifest YAML pour créer le Pod défini dans le fichier.

### b) Vérifier les Pods en cours
```bash
kubectl get pods
```
👉 Liste tous les pods avec :
- Leur statut (Running, Pending, etc.)
- Le nombre de redémarrages
- Leur âge

### c) Supprimer le Pod
```bash
kubectl delete pod hello-world
```
👉 Supprime le Pod nommé "hello-world".

---

## 4️⃣ Utiliser `kubectl dry-run`

### a) Validation côté serveur
```bash
kubectl apply -f deployment.yaml --dry-run=server
```
👉 Vérification complète qui :
1. Envoie le manifest à l'API Server
2. Valide la syntaxe et la sémantique
3. Ne crée pas la ressource
*Cas d'usage* : Validation finale avant application en production.

### b) Validation côté client
```bash
kubectl apply -f deployment.yaml --dry-run=client
```
👉 Vérification locale qui :
1. Valide la syntaxe YAML
2. Ne nécessite pas de connexion au cluster
*Différence* : Plus rapide mais moins complète que la validation serveur.

### c) Détection d'erreurs dans le manifest
```bash
kubectl apply -f deployment-error.yaml --dry-run=client
```
👉 Détecte les erreurs comme :
- Fautes de frappe (ex. `replica` au lieu de `replicas`)
- Champs manquants
- Types de données incorrects

---

## 5️⃣ Générer des manifests YAML avec `dry-run`

### a) Générer un Deployment en YAML
```bash
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml | more
```
👉 Génère un template de Deployment avec :
- 1 replica par défaut
- La stratégie de mise à jour
- Les sélecteurs appropriés

### b) Générer un Pod en YAML
```bash
kubectl run nginx-pod --image=nginx --dry-run=client -o yaml | more
```
👉 Crée un manifest Pod avec :
- Le conteneur spécifié
- La politique de redémarrage par défaut
- Aucun volume monté

### c) Sauvegarder un manifest généré
```bash
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment-generated.yaml
more deployment-generated.yaml
```
👉 Permet de :
1. Créer un fichier manifest
2. Le modifier avant application
3. Le versionner dans votre système de contrôle de version

### d) Appliquer le manifest généré
```bash
kubectl apply -f deployment-generated.yaml
```
👉 Déploie la ressource à partir du fichier généré.

### e) Nettoyer
```bash
kubectl delete -f deployment-generated.yaml
```
👉 Supprime proprement la ressource.

---

## 6️⃣ Utiliser `kubectl diff`

### a) Créer un Deployment initial
```bash
kubectl apply -f deployment.yaml
```
👉 Applique la première version de votre application.

### b) Comparer avec une nouvelle version
```bash
kubectl diff -f deployment-new.yaml | more
```
👉 Affiche les différences avec :
- Les champs modifiés (images, replicas, etc.)
- Les ajouts/suppressions
- Le format unifié des diffs
*Exemple* : Passage de 4 à 5 replicas ou changement d'image.

### c) Nettoyer
```bash
kubectl delete -f deployment.yaml
```
👉 Supprime la ressource après vérification.

---

## ✅ Résultats attendus
À la fin de ce TP, vous serez capable de :
1. Explorer l'API Kubernetes avec `kubectl explain`
2. Distinguer et utiliser `dry-run=server` et `dry-run=client`
3. Générer des manifests YAML avec `kubectl create --dry-run -o yaml`
4. Comparer différentes versions de manifests avec `kubectl diff`

## 💡 Bonnes pratiques
- Toujours utiliser `--dry-run` avant d'appliquer en production
- Vérifier le contexte actuel avec `kubectl config get-contexts`
- Utiliser `kubectl explain` pour comprendre les structures de ressources
- Sauvegarder les manifests générés pour réutilisation future
- Comparer les changements avec `kubectl diff` avant application

## 📚 Pour aller plus loin
- Consultez la documentation officielle : `kubectl explain --recursive`
- Explorez les options de formatage : `-o json`, `-o wide`
- Découvrez d'autres commandes utiles : `kubectl get events --watch`
```