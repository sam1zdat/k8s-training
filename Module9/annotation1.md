Les annotations dans Kubernetes sont utilisées pour ajouter des métadonnées arbitraires aux objets Kubernetes. Elles sont souvent utilisées pour ajouter des informations descriptives ou pour fournir des informations supplémentaires aux outils et bibliothèques qui interagissent avec Kubernetes.


Exercice 1: Ajouter des annotations à un pod
- Créer un fichier YAML pour un pod.
- Ajouter des annotations à ce pod pour inclure des informations telles que la description du pod, l'environnement, et la version de l'application.

Exercice 2: Utiliser des annotations pour la gestion de configuration
- Créer un fichier YAML pour un déploiement.
- Ajouter des annotations pour spécifier des configurations supplémentaires, telles que les paramètres de monitoring ou de logging.

### Exercice 1: Ajouter des annotations à un pod

1. **Créer un fichier YAML pour un pod** :
   - Créez un fichier YAML pour un pod simple. Par exemple, un pod qui exécute un conteneur Nginx.

2. **Ajouter des annotations** :
   - Ajoutez des annotations à ce pod pour inclure des informations telles que la description du pod, l'environnement (par exemple, "production" ou "développement"), et la version de l'application.

Voici un exemple de fichier YAML pour vous guider :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  annotations:
    description: "Un pod Nginx pour servir une application web"
    environment: "développement"
    version: "1.0.0"
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

3. **Déployer le pod** :
   - Utilisez la commande `kubectl apply -f <fichier.yaml>` pour déployer le pod.
   - Vérifiez que les annotations ont été ajoutées correctement en utilisant la commande `kubectl describe pod nginx-pod`.

### Exercice 2: Utiliser des annotations pour la gestion de configuration

1. **Créer un fichier YAML pour un déploiement** :
   - Créez un fichier YAML pour un déploiement simple. Par exemple, un déploiement qui gère plusieurs réplicas d'un conteneur Nginx.

2. **Ajouter des annotations** :
   - Ajoutez des annotations pour spécifier des configurations supplémentaires, telles que les paramètres de monitoring ou de logging.

Voici un exemple de fichier YAML pour vous guider :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  annotations:
    monitoring: "true"
    logging: "debug"
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
        image: nginx:latest
        ports:
        - containerPort: 80
```

3. **Déployer le déploiement** :
   - Utilisez la commande `kubectl apply -f <fichier.yaml>` pour déployer le déploiement.
   - Vérifiez que les annotations ont été ajoutées correctement en utilisant la commande `kubectl describe deployment nginx-deployment`.

Ces exercices vous permettront de comprendre comment ajouter et utiliser des annotations dans Kubernetes. 