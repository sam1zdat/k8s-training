# 🧪 TP Kubernetes - ResourceQuota en 20 minutes

## 🎯 Objectifs
- Comprendre le fonctionnement des ResourceQuotas dans Kubernetes
- Limiter l'utilisation des ressources CPU et mémoire par namespace
- Configurer des quotas pour les objets Kubernetes (pods, services, etc.)

## 📋 Prérequis
- Un cluster Kubernetes fonctionnel
- kubectl configuré pour accéder au cluster
- Droits d'administration sur le cluster

## 1️⃣ Créer un namespace de test (2 min)

```bash
# Créer un namespace dédié pour le TP
kubectl create namespace quota-demo

# Vérifier la création
kubectl get namespaces
```

## 2️⃣ Créer un ResourceQuota de base (5 min)

```yaml
# quota-cpu-memory.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: cpu-memory-quota
  namespace: quota-demo
spec:
  hard:
    requests.cpu: "2"      # 2 CPU maximum
    requests.memory: 2Gi   # 2 GiB de mémoire maximum
    limits.cpu: "4"        # 4 CPU maximum
    limits.memory: 4Gi     # 4 GiB de mémoire maximum
    pods: "5"              # 5 pods maximum
    services: "3"          # 3 services maximum
```
## 🔍 Explications détaillées

### **Namespace concerné**
- S'applique au namespace `quota-demo`
- Doit être créé au préalable : `kubectl create namespace quota-demo`

### **Limites de ressources CPU/Mémoire**

| Ressource | Type | Valeur | Explication |
|-----------|------|--------|-------------|
| **CPU** | requests | "2" | Total des CPU demandés par tous les pods |
| **CPU** | limits | "4" | Total des CPU maximum utilisables |
| **Mémoire** | requests | 2Gi | Total mémoire réservée |
| **Mémoire** | limits | 4Gi | Total mémoire maximum utilisable |

### **Limites d'objets Kubernetes**
- `pods: "5"` → Maximum 5 pods dans le namespace
- `services: "3"` → Maximum 3 services
## ⚠️ Points importants à retenir

1. **Les requests** : ressources réservées/garanties
2. **Les limits** : ressources maximum utilisables
3. **Format CPU** : 
   - "1" = 1 CPU core
   - "500m" = 0.5 CPU
   - "250m" = 0.25 CPU
4. **Format Mémoire** :
   - 1Gi = 1024 MiB
   - 1G = 1000 MB (décimal)
     
```bash
# Appliquer le quota
kubectl apply -f quota-cpu-memory.yaml

# Vérifier le quota
kubectl describe quota cpu-memory-quota -n quota-demo
```

👉 **Explication** : Ce quota limite :
- Les demandes de CPU à 2 unités
- Les limites de CPU à 4 unités
- Les demandes de mémoire à 2 GiB
- Les limites de mémoire à 4 GiB
- Le nombre de pods à 5
- Le nombre de services à 3

## 3️⃣ Tester le quota avec un deployment (5 min)

```yaml
# deployment-quota-test.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-quota-test
  namespace: quota-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: "500m"    # 0.5 CPU
            memory: "512Mi"
          limits:
            cpu: "1"
            memory: "1Gi"
```

```bash
# Appliquer le deployment
kubectl apply -f deployment-quota-test.yaml

# Vérifier les pods
kubectl get pods -n quota-demo

# Vérifier l'utilisation des ressources
kubectl describe quota cpu-memory-quota -n quota-demo
```

👉 **Résultat attendu** : Le deployment est créé avec succès car il respecte le quota.

## 4️⃣ Tester le dépassement de quota (5 min)

```yaml
# deployment-quota-exceed.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-quota-exceed
  namespace: quota-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-exceed
  template:
    metadata:
      labels:
        app: nginx-exceed
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: "1"       # 1 CPU par pod
            memory: "1Gi"  # 1 GiB par pod
          limits:
            cpu: "2"       # 2 CPU par pod
            memory: "2Gi"  # 2 GiB par pod
```

```bash
# Appliquer le deployment qui dépasse le quota
kubectl apply -f deployment-quota-exceed.yaml

# Vérifier l'erreur
kubectl get pods -n quota-demo

# Voir les details du quota
kubectl describe quota cpu-memory-quota -n quota-demo
```

👉 **Résultat attendu** : Le deployment échoue car il dépasse le quota (3 pods × 2 CPU = 6 CPU > 4 CPU max).

## 5️⃣ Vérifier l'utilisation des ressources (3 min)

```bash
# Voir l'utilisation actuelle des ressources dans le namespace
kubectl describe quota -n quota-demo

# Voir les événements liés au quota
kubectl get events -n quota-demo --sort-by='.lastTimestamp'
```

## 6️⃣ Créer un quota plus complexe (5 min)

```yaml
# quota-advanced.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: advanced-quota
  namespace: quota-demo
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "5"
    services: "3"
    configmaps: "10"
    persistentvolumeclaims: "2"
    requests.storage: "10Gi"
    services.loadbalancers: "1"
    services.nodeports: "0"
```

```bash
# Appliquer le quota avancé
kubectl apply -f quota-advanced.yaml

# Vérifier le quota
kubectl describe quota advanced-quota -n quota-demo
```

👉 **Explication** : Ce quota ajoute des limitations pour :
- Les ConfigMaps
- Les PersistentVolumeClaims
- Le stockage total demandé
- Le nombre de services de type LoadBalancer
- Interdit les services de type NodePort

## 7️⃣ Nettoyage (1 min)

```bash
# Supprimer le namespace (et toutes ses ressources)
kubectl delete namespace quota-demo
```

## ✅ Points de vérification
- [ ] Le namespace est créé avec succès
- [ ] Le quota CPU/mémoire est appliqué et vérifiable
- [ ] Un deployment respectant le quota est créé avec succès
- [ ] Un deployment dépassant le quota est rejeté

- [ ] Le quota avancé est appliqué avec succès

