# **Démonstration RBAC Kubernetes - 15 minutes**

## **📋 Plan de la Démo (15 minutes exactes)**

| Temps | Section | Objectif |
|-------|---------|----------|
| 0-2 min | Introduction | Présenter RBAC et les concepts |
| 2-5 min | Setup | Préparer l'environnement |
| 5-8 min | Problème | Montrer un accès refusé |
| 8-12 min | Solution | Créer RBAC et résoudre |
| 12-14 min | Test | Vérifier les permissions |
| 14-15 min | Conclusion | Résumé et best practices |

---

## **🎯 Objectifs de la Démo**

- Comprendre **ServiceAccount**, **Role**, **RoleBinding**
- Voir un **accès refusé** réel
- Créer des **permissions spécifiques**
- Tester l'accès **avant/après** RBAC

---

## **🚀 DÉMARRAGE DE LA DÉMO**

### **⏱️ 0-2 min : INTRODUCTION**

```bash
# Montrer le cluster actuel
kubectl get nodes
kubectl get pods --all-namespaces

# Expliquer RBAC rapidement
echo "RBAC = Contrôle d'accès basé sur les rôles"
echo "3 composants : ServiceAccount + Role + RoleBinding"
```

**Explication :**
- **ServiceAccount** : Identité (comme un utilisateur)
- **Role** : Permissions (ce qu'on peut faire)
- **RoleBinding** : Lie le Role au ServiceAccount

---

### **⏱️ 2-5 min : SETUP**

```bash
# 1. Créer un namespace de test
kubectl create namespace demo-rbac

# 2. Créer une application de test
kubectl create deployment nginx --image=nginx -n demo-rbac
kubectl scale deployment nginx --replicas=3 -n demo-rbac

# 3. Créer un ServiceAccount sans permissions
kubectl create serviceaccount read-only-user -n demo-rbac

# 4. Vérifier ce qu'on a créé
kubectl get sa,deploy,pods -n demo-rbac
```

**Résultat attendu :**
```
NAME                    SECRETS   AGE
serviceaccount/read-only-user   1         30s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   3/3     3            3           1m

NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-7cdbd8cdc9-abcde   1/1     Running   0          1m
pod/nginx-7cdbd8cdc9-fghij   1/1     Running   0          1m  
pod/nginx-7cdbd8cdc9-klmno   1/1     Running   0          1m
```

---

### **⏱️ 5-8 min : PROBLÈME - ACCÈS REFUSÉ**

```bash
# 1. Tester l'accès AVEC RBAC (ça va échouer)
kubectl auth can-i get pods --as=system:serviceaccount:demo-rbac:read-only-user -n demo-rbac
# ➤ no

# 2. Simuler une connexion avec ce ServiceAccount
vous pouvez lancer la création du pod soit par la méthode 1 ou la méthode 2 :
## méthode 1:
kubectl run test-access --image=bitnami/kubectl --restart=Never -n demo-rbac \
  --overrides='
{
  "spec": {
    "serviceAccountName": "read-only-user",
    "containers": [{
      "name": "test",
      "image": "bitnami/kubectl",
      "command": ["sleep", "3600"]
    }]
  }
}'

## Méthode 2:
## **📝 Fichier YAML complet pour le pod de test**

```yaml
# test-access-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-access
  namespace: demo-rbac
spec:
  serviceAccountName: read-only-user
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]
  restartPolicy: Never
```
kubectl apply -f test-access-pod.yaml


# 3. Tester les commandes depuis le pod
kubectl exec -it test-access -n demo-rbac -- /bin/sh

# Dans le container, tester :
kubectl get pods -n demo-rbac
# ➤ Error: forbidden

kubectl get deployments -n demo-rbac  
# ➤ Error: forbidden

kubectl get pods -n kube-system
# ➤ Error: forbidden

exit
```

**💡 Point à montrer :** Le ServiceAccount ne peut **RIEN** faire sans RBAC !

---

### **⏱️ 8-12 min : SOLUTION - CRÉATION RBAC**

```bash
# 1. Créer un Role avec permissions LECTURE SEULEMENT
cat > role-read-only.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: demo-rbac
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
EOF

# 2. Lier le Role au ServiceAccount
cat > rolebinding-read.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: demo-rbac
subjects:
- kind: ServiceAccount
  name: read-only-user
  namespace: demo-rbac
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
EOF

# 3. Appliquer la configuration RBAC
kubectl apply -f role-read-only.yaml
kubectl apply -f rolebinding-read.yaml

# 4. Vérifier ce qu'on a créé
kubectl get role,rolebinding -n demo-rbac
```

---

### **⏱️ 12-14 min : TEST - VÉRIFICATION DES PERMISSIONS**

```bash
# 1. Tester avec kubectl auth can-i
kubectl auth can-i get pods --as=system:serviceaccount:demo-rbac:read-only-user -n demo-rbac
# ➤ yes

kubectl auth can-i list deployments --as=system:serviceaccount:demo-rbac:read-only-user -n demo-rbac  
# ➤ yes

kubectl auth can-i delete pods --as=system:serviceaccount:demo-rbac:read-only-user -n demo-rbac
# ➤ no

kubectl auth can-i get pods --as=system:serviceaccount:demo-rbac:read-only-user -n kube-system
# ➤ no

# 2. Tester depuis le pod (même pod, pas besoin de recréer)
kubectl exec -it test-access -n demo-rbac -- /bin/sh

# Dans le container :
kubectl get pods -n demo-rbac
# ➤ SUCCÈS ! Liste les pods

kubectl get deployments -n demo-rbac
# ➤ SUCCÈS ! Liste les deployments

kubectl delete pod nginx-7cdbd8cdc9-abcde -n demo-rbac
# ➤ ÉCHEC ! "forbidden"

kubectl get pods -n kube-system
# ➤ ÉCHEC ! "forbidden"

kubectl get pods --all-namespaces
# ➤ ÉCHEC ! "forbidden"

exit
```

**🎉 RÉSULTAT :** L'utilisateur peut MAINTENANT lire mais seulement dans son namespace !

---

### **⏱️ 14-15 min : CONCLUSION & BEST PRACTICES**

```bash
# Nettoyage
kubectl delete namespace demo-rbac

# Résumé des concepts
echo "✅ ServiceAccount = QUI"
echo "✅ Role = QUOI (permissions)"  
echo "✅ RoleBinding = OÙ (namespace)"

# Best practices
echo "🐙 PRINCIPLE OF LEAST PRIVILEGE : Donner le minimum de permissions nécessaires"
echo "🔒 NAMESPACE ISOLATION : Un Role par namespace"
echo "📝 CLUSTERROLE pour les permissions cluster-wide"
```

---

## **📊 Résumé Visuel**

```
AVANT RBAC:
ServiceAccount → ❌ AUCUN ACCÈS

APRÈS RBAC:
ServiceAccount → RoleBinding → Role → ✅ ACCÈS LIMITÉ

Role = {
  "get", "list", "watch" pods,
  "get", "list" deployments
} dans namespace "demo-rbac" seulement
```

---

## **🎓 Points Clés à Retenir**

1. **Sans RBAC = Aucun accès**
2. **RBAC = ServiceAccount + Role + RoleBinding**  
3. **Principle of Least Privilege** - Donner le minimum
4. **Namespace isolation** - Contrôle par namespace
5. **Tester avec `kubectl auth can-i`**

---

## **🚀 Bonus (si temps supplémentaire)**

```bash
# Montrer un ClusterRole (accès cluster-wide)
kubectl get clusterroles view -o yaml | head -20

# Montrer comment debugger RBAC
kubectl auth can-i --list --as=system:serviceaccount:demo-rbac:read-only-user
```

**Démo terminée en 15 minutes précises !** 🎯
