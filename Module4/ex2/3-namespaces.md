
```markdown
# 🧪 Exercice – Gestion des Namespaces dans Kubernetes
⏱️ **Durée estimée : 35 minutes**

## 🎯 Objectifs
- Explorer les namespaces existants dans le cluster.
- Comprendre la différence entre création **impérative** et **déclarative**.
- Déployer et gérer des workloads dans un namespace spécifique.
- Supprimer un namespace et observer l’impact sur les ressources.

## Introduction
Dans cet exercice, vous allez apprendre à gérer les namespaces dans Kubernetes. Les namespaces permettent de diviser les ressources d'un cluster en plusieurs espaces de travail isolés. Vous allez explorer les namespaces existants, créer de nouveaux namespaces, déployer des applications dans des namespaces spécifiques, et supprimer des namespaces.

---

## 1️⃣ Explorer les namespaces

### a) Lister tous les namespaces
```bash
kubectl get namespaces
```
Cette commande liste tous les namespaces existants dans le cluster.

### b) Vérifier si les ressources sont namespaced ou non
```bash
kubectl api-resources --namespaced=true | head
kubectl api-resources --namespaced=false | head
```
👉 Exemple : les Pods sont dans un namespace, les Nodes non.
Ces commandes listent les ressources qui sont namespaced et celles qui ne le sont pas.

### c) Vérifier l’état des namespaces
```bash
kubectl describe namespaces
```
👉 États possibles : `Active` ou `Terminating`.
Cette commande décrit l'état de tous les namespaces.

### d) Détails d’un namespace spécifique
```bash
kubectl describe namespace kube-system
```
Cette commande affiche les détails du namespace `kube-system`.

---

## 2️⃣ Lister les ressources dans tous les namespaces

### a) Lister tous les pods système
```bash
kubectl get pods --all-namespaces
```
Cette commande liste tous les pods dans tous les namespaces.

### b) Lister toutes les ressources dans tout le cluster
```bash
kubectl get all --all-namespaces
```
Cette commande liste toutes les ressources dans tous les namespaces.

### c) Pods uniquement dans `kube-system`
```bash
kubectl get pods --namespace kube-system
```
Cette commande liste les pods uniquement dans le namespace `kube-system`.

---

## 3️⃣ Créer un namespace

### a) Création impérative
```bash
kubectl create namespace playground1
```
⚠️ Les noms doivent être en **minuscules** avec des tirets uniquement :
```bash
kubectl create namespace Playground1   # ❌ Erreur
```
Cette commande crée un namespace nommé `playground1` de manière impérative.

### b) Création déclarative
```bash
kubectl apply -f namespace.yaml
```
Cette commande crée un namespace en utilisant un fichier de configuration YAML.

---

## 4️⃣ Déployer une application dans un namespace

### a) Déploiement via YAML
```bash
kubectl apply -f deployment.yaml
```
👉 Vérifie dans quel namespace est créé le déploiement (via `metadata.namespace` dans le manifest).
Cette commande déploie une application dans le namespace spécifié dans le fichier YAML.

### b) Création impérative d’un Pod
```bash
kubectl run hello-world-pod \
  --image=psk8s.azurecr.io/hello-app:1.0 \
  --namespace playground1
```
Cette commande crée un pod nommé `hello-world-pod` dans le namespace `playground1`.

### c) Vérifier où sont les Pods
```bash
kubectl get pods           # Namespace par défaut → aucun Pod
kubectl get pods -n playground1
```
👉 Le Pod créé et le Deployment sont visibles uniquement dans `playground1`.
Ces commandes vérifient que le pod a été créé dans le namespace `playground1`.

### d) Lister toutes les ressources du namespace
```bash
kubectl get all -n playground1
```
Cette commande liste toutes les ressources dans le namespace `playground1`.

---

## 5️⃣ Supprimer des ressources dans un namespace

### a) Supprimer uniquement les Pods
```bash
kubectl delete pods --all -n playground1
```
👉 Les Pods gérés par un Deployment/ReplicaSet seront recréés automatiquement.
Cette commande supprime tous les pods dans le namespace `playground1`.

### b) Vérifier les Pods recréés
```bash
kubectl get pods -n playground1
```
Cette commande vérifie que les pods ont été recréés par les contrôleurs.

### c) Supprimer tout le namespace
```bash
kubectl delete namespace playground1
kubectl delete namespace playgroundinyaml
```
👉 Cela supprime toutes les ressources à l’intérieur (Deployments, Pods, Services…).
Ces commandes suppriment les namespaces et toutes les ressources qu'ils contiennent.

---

## 6️⃣ Vérification finale

### a) Vérifier que tout est bien supprimé
```bash
kubectl get all
kubectl get all --all-namespaces
```
👉 Les ressources déployées dans `playground1` n’existent plus.
Ces commandes vérifient que toutes les ressources ont été supprimées.

---

## ✅ Résultats attendus
- Savoir lister et décrire les namespaces.
- Comprendre la portée des ressources namespaced vs non-namespaced.
- Créer des namespaces impérativement et déclarativement.
- Déployer et gérer des Pods/Deployments dans un namespace dédié.
- Supprimer un namespace et constater la suppression de toutes ses ressources.

```