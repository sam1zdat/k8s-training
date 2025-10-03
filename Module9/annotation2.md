Exercice 1: Utiliser des annotations pour la gestion de configuration avancée
- Description: Dans cet exercice, nous allons configurer un déploiement avec des annotations pour Prometheus et Fluentd.
- Étapes: Créer un fichier YAML pour un déploiement avec des annotations pour configurer des paramètres avancés de monitoring et de logging.

Exercice 2: Utiliser des annotations pour l'intégration avec des outils externes
- Description: Dans cet exercice, nous allons configurer un service avec des annotations pour un load balancer AWS.
- Étapes: Créer un fichier YAML pour un service avec des annotations pour configurer un load balancer externe.

### Exercice 1: Utiliser des annotations pour la gestion de configuration avancée

**Description** :
Dans cet exercice, nous allons configurer un déploiement avec des annotations pour Prometheus et Fluentd. Les annotations pour Prometheus permettront de configurer la collecte de métriques, tandis que celles pour Fluentd configureront le niveau de logging et les tags pour le traitement des logs.

**Étapes** :

1. **Créer un fichier YAML pour un déploiement avec des annotations pour configurer des paramètres avancés de monitoring et de logging** :
   - Créez un fichier YAML pour un déploiement qui inclut des annotations pour configurer des paramètres de monitoring et de logging avancés.

Voici un exemple de fichier YAML pour vous guider :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: advanced-deployment
  annotations:
    # Annotation pour Prometheus pour activer la collecte de métriques
    monitoring.prometheus.io/scrape: "true"
    # Spécifie le port sur lequel Prometheus doit scrap les métriques
    monitoring.prometheus.io/port: "8080"
    # Annotation pour Fluentd pour définir le niveau de logging
    logging.fluentd.io/level: "debug"
    # Tags pour Fluentd pour catégoriser les logs
    logging.fluentd.io/tags: "application,performance"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: advanced-app
  template:
    metadata:
      labels:
        app: advanced-app
    spec:
      containers:
      - name: advanced-container
        image: advanced-app:latest
        ports:
        - containerPort: 8080
```

2. **Déployer le déploiement** :
   - Utilisez la commande `kubectl apply -f <fichier.yaml>` pour déployer le déploiement.
   - Vérifiez que les annotations ont été ajoutées correctement en utilisant la commande `kubectl describe deployment advanced-deployment`.

### Exercice 2: Utiliser des annotations pour l'intégration avec des outils externes

**Description** :
Dans cet exercice, nous allons configurer un service avec des annotations pour un load balancer AWS. Les annotations permettront de configurer le type de load balancer et d'activer l'équilibrage de charge multi-zones.

**Étapes** :

1. **Créer un fichier YAML pour un service avec des annotations pour configurer un load balancer externe** :
   - Créez un fichier YAML pour un service qui inclut des annotations pour configurer un load balancer externe.

Voici un exemple de fichier YAML pour vous guider :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
  annotations:
    # Annotation pour spécifier le type de load balancer AWS (Network Load Balancer)
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    # Annotation pour activer l'équilibrage de charge multi-zones
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
spec:
  selector:
    app: advanced-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

2. **Déployer le service** :
   - Utilisez la commande `kubectl apply -f <fichier.yaml>` pour déployer le service.
   - Vérifiez que les annotations ont été ajoutées correctement en utilisant la commande `kubectl describe service external-service`.