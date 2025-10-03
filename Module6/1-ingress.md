
```markdown
# 🧪 TP Ingress NGINX avec NodePort - Version complète

## 0️⃣ Prérequis et installation de Helm

### Installation de Helm (si ce n'est pas déjà fait)

**Sur Linux/macOS :**
```bash
# Télécharge le script d'installation de Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**Vérification de l'installation :**
```bash
# Affiche la version de Helm installée
helm version

# Liste les dépôts Helm configurés (devrait être vide au début)
helm repo list
```
---

## 1️⃣ Installer Ingress NGINX en mode NodePort

```bash
# Crée un namespace dédié pour l'ingress controller
# Cela permet d'isoler les ressources de l'ingress des autres applications
kubectl create ns ingress-nginx

# Ajoute le dépôt Helm officiel pour Ingress NGINX
# Helm est le gestionnaire de packages pour Kubernetes
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Met à jour les informations des dépôts Helm locaux
# Important pour avoir les dernières versions des charts
helm repo update

# Vérifie que le dépôt a bien été ajouté
helm search repo ingress-nginx

# Installe/Met à jour Ingress NGINX avec les paramètres suivants :
# - Dans le namespace "ingress-nginx"
# - Configure le service en type NodePort (expose sur un port de chaque node)
# - Définit la classe d'ingress à "nginx" (pour l'utiliser par défaut)
# - Nomme la ressource IngressClass "nginx" pour identification
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  --set controller.service.type=NodePort \
  --set controller.ingressClassResource.name=nginx \
  --set controller.ingressClass=nginx \
  --set controller.service.nodePorts.http=31577 \
  --set controller.service.nodePorts.https=31578

# Pour voir tous les paramètres disponibles :
helm show values ingress-nginx/ingress-nginx
```

**Vérification de l'installation :**
```bash
# Affiche les services dans le namespace ingress-nginx
kubectl -n ingress-nginx get svc

# Vérifie que les pods sont bien déployés :
kubectl -n ingress-nginx get pods -l app.kubernetes.io/name=ingress-nginx

# Affiche les détails du deployment
kubectl -n ingress-nginx describe deploy ingress-nginx-controller

# Vérifie les logs pour le dépannage
kubectl -n ingress-nginx logs -l app.kubernetes.io/name=ingress-nginx --tail=50
```

---

## 2️⃣ Déployer une application + Service + Ingress

📄 `demo-ingress.yaml`
```yaml
# Définition d'un Deployment pour notre application web
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  labels:
    app: web
spec:
  replicas: 2  # Deux instances pour la haute disponibilité
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: ghcr.io/nginxinc/ingress-demo/nginx-hello:plain
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "10m"
            memory: "32Mi"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10

# Définition d'un Service pour exposer le deployment
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80

# Définition de la ressource Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ing
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: demo.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80
```

**Application des configurations :**
```bash
# Applique le fichier de configuration
kubectl apply -f demo-ingress.yaml

# Vérification que tout est bien créé
kubectl get deploy,svc,ingress

# Vérification détaillée
kubectl describe ingress web-ing
kubectl describe svc web-svc
```

---

## 3️⃣ Configurer le DNS local (optionnel mais recommandé)

**Sur Linux/macOS :**
```bash
# Ajoute l'entrée DNS dans votre fichier hosts
echo "$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}') demo.local" | sudo tee -a /etc/hosts

# Vérifie que l'entrée a été ajoutée
cat /etc/hosts
```

**Sur Windows :**
```powershell
# Ajoute l'entrée DNS (à exécuter en tant qu'administrateur)
$nodeIP = (kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value "`ndemo.local $nodeIP" -Force
```

---

## 4️⃣ Tester l'ingress

**Méthode 1 : Avec curl et l'IP du node**
```bash
# Récupère l'IP du node et le port HTTP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')

# Teste avec curl
curl -v -H "Host: demo.local" http://$NODE_IP:$NODE_PORT/

# Alternative si vous avez configuré le fichier hosts
curl -v http://demo.local:$NODE_PORT/
```

**Méthode 2 : Avec un navigateur**
1. Ouvrez votre navigateur
2. Accédez à : `http://demo.local:31577` (remplacez 31577 par votre port NodePort)

**Méthode 3 : Tester depuis un pod dans le cluster**
```bash
# Crée un pod de test avec curl
kubectl run curl-test --image=curlimages/curl -it --rm

# Depuis le pod, testez (utilisez l'IP du service ingress)
curl -H "Host: demo.local" http://ingress-nginx-controller.ingress-nginx.svc.cluster.local
```

---

## 5️⃣ Dépannage et vérifications avancées

```bash
# Vérifie les événements Kubernetes
kubectl get events -A --sort-by='.lastTimestamp'

# Vérifie les endpoints de l'ingress
kubectl get endpoints -n ingress-nginx

# Affiche les règles de l'ingress controller
kubectl -n ingress-nginx exec deploy/ingress-nginx-controller -- nginx -t

# Voir la configuration générée
kubectl -n ingress-nginx exec deploy/ingress-nginx-controller -- cat /etc/nginx/nginx.conf

# Vérifie les métriques (si le module metrics est activé)
kubectl -n ingress-nginx get svc | grep metrics
```

---

## 6️⃣ Nettoyage

```bash
# Supprime l'application et l'ingress
kubectl delete -f demo-ingress.yaml

# Désinstalle l'ingress controller
helm uninstall ingress-nginx -n ingress-nginx

# Supprime le namespace (optionnel)
kubectl delete ns ingress-nginx

# Supprime le dépôt Helm (optionnel)
helm repo remove ingress-nginx
```

---