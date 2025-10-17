# 🔧 Installation de Metrics Server

## 🎯 Méthode la Plus Simple et Efficace

```bash
# 1. Supprimer l'installation existante (si elle échoue)
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml 2>/dev/null || true

# 2. Installer Metrics Server avec les correctifs TLS
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 3. Ajouter les arguments pour contourner les problèmes TLS
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# 4. Redémarrer le déploiement
kubectl rollout restart deployment/metrics-server -n kube-system
```

## ⏳ Attendre le Démarrage

```bash
# Attendre que Metrics Server soit prêt
echo "⏳ Attente du démarrage de Metrics Server..."
kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=k8s-app=metrics-server \
  --timeout=180s
```

## ✅ Vérification

```bash
# Vérifier le statut du pod
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Vérifier les logs (doit montrer "successfully scraped" au lieu d'erreurs TLS)
kubectl logs -n kube-system -l k8s-app=metrics-server --tail=5

# Tester la fonctionnalité
echo "🧪 Test des métriques..."
kubectl top nodes

# Si top nodes fonctionne, tester les pods
kubectl top pods -A
```

## 🐛 Si Ça Ne Fonctionne Toujours Pas - Méthode Alternative

```bash
# Créer un fichier de configuration complet avec tous les correctifs
cat > metrics-server-complete.yaml << 'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - port: 443
    protocol: TCP
    targetPort: 4443
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP
        - --metric-resolution=15s
        image: registry.k8s.io/metrics-server/metrics-server:v0.6.4
        name: metrics-server
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
      serviceAccountName: metrics-server
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
EOF

# Appliquer cette configuration
kubectl apply -f metrics-server-complete.yaml
```

## 🔧 Vérification Finale et Diagnostic

```bash
# Vérifier que tout fonctionne
echo "🔍 Diagnostic complet..."

# 1. Vérifier le pod
kubectl get pods -n kube-system -l k8s-app=metrics-server

# 2. Vérifier les logs
echo "📋 Logs de Metrics Server:"
kubectl logs -n kube-system -l k8s-app=metrics-server --tail=10

# 3. Vérifier les métriques
echo "📊 Test des métriques:"
kubectl top nodes 2>/dev/null && echo "✅ Metrics Server fonctionne!" || echo "❌ Problème avec Metrics Server"

# 4. Vérifier l'API
echo "🌐 Test de l'API metrics:"
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes 2>/dev/null | head -c 100 && echo "... (succès)" || echo "Échec de l'accès à l'API"
```

## 🚀 Test du HPA Une fois Metrics Server Opérationnel

```bash
# Une fois que kubectl top nodes fonctionne, tester le HPA

# 1. Créer l'application de test
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hpa-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hpa-demo
  template:
    metadata:
      labels:
        app: hpa-demo
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: hpa-demo-service
spec:
  selector:
    app: hpa-demo
  ports:
  - port: 80
EOF

# 2. Créer le HPA
kubectl autoscale deployment hpa-demo --cpu-percent=50 --min=2 --max=5

# 3. Vérifier le HPA
kubectl get hpa hpa-demo

# 4. Surveiller
watch "kubectl get hpa hpa-demo && echo --- && kubectl get pods -l app=hpa-demo"
```

## 📝 Résultat Attendu

Si tout fonctionne, vous devriez voir :

```
# Metrics Server
NAME                              READY   STATUS    RESTARTS   AGE
metrics-server-xxxxx-xxxxx        1/1     Running   0          2m

# HPA
NAME       REFERENCE             TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
hpa-demo   Deployment/hpa-demo   0%/50%    2         5         2          30s

# Top nodes
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
controlplane   100m         5%     500Mi           25%
node01         50m          2%     300Mi           15%
```

**La clé est l'argument `--kubelet-insecure-tls` qui résout le problème des certificats !** 🎉