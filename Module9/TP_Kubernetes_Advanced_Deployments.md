TP Kubernetes - Fonctionnalités de Déploiement
3 exer cices pratiques - 20 minutes chacun
🎯 Objectifs du TP (60 minutes total)
Exer cice 1 (20min)  : Rollback de déploiements
Exer cice 2 (20min)  : Autoscaling horizontal (HP A)
Exer cice 3 (20min)  : Jobs et CronJobs
Prérequis
Cluster Kubernetes fonctionnel
kubectl configuré
Metrics Server installé
⚠ Vérification rapide :
kubectl cluster-info && kubectl get nodes
Exer cice 1 - Rollback de Déploiements (20 minutes)
⏱ Durée estimée : 20 minutes
Objectif
Apprendre à gérer l'historique des déploiements et ef fectuer des rollbacks en cas de problème.
1. Déployer une application (5 min)
Créez webapp.yaml  :
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
        command: ["/bin/sh", "-c"]
        args: ["echo '<h1>Version 1.0</h1>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-svc
spec:
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
Déployez :
kubectl apply -f webapp.yaml --record
kubectl rollout status deployment/webapp
kubectl get pods -l app=webapp
2. Mettre à jour avec une version défaillante (5 min)
Mettez à jour vers une image qui n'existe pas :
kubectl set image deployment/webapp nginx=nginx:version-inexistante --record
kubectl rollout status deployment/webapp --timeout=60s
Vérifiez l'état :
kubectl get pods -l app=webapp
kubectl describe deployment webapp
3. Effectuer un rollback (5 min)
Consultez l'historique :
kubectl rollout history deployment/webapp
Effectuez le rollback :

kubectl rollout undo deployment/webapp
kubectl rollout status deployment/webapp
Vérifiez le succès :
kubectl get pods -l app=webapp
kubectl exec deployment/webapp -- curl -s localhost | grep Version
4. Test avancé - Rollback vers une révision spécifique (5 min)
Créez une nouvelle version :
kubectl patch deployment webapp -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","command":["/bin/sh","-c"],"args":["ec
kubectl rollout status deployment/webapp
Rollback vers une révision spécifique :
kubectl rollout history deployment/webapp
kubectl rollout undo deployment/webapp --to-revision=1
kubectl rollout status deployment/webapp
✅ Validation :  L'application doit af ficher "V ersion 1.0" après le rollback.
Exer cice 2 - Autoscaling Horizontal (HP A) (20 minutes)
⏱ Durée estimée : 20 minutes
Objectif
Configurer l'autoscaling horizontal basé sur l'utilisation CPU et tester son fonctionnement.
1. Déployer une application de test (5 min)
Créez php-apache.yaml  :
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
Déployez :
kubectl apply -f php-apache.yaml
kubectl get deployment php-apache
2. Créer l'HPA (5 min)
Créez l'autoscaler :
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
Vérifiez l'état :
kubectl get hpa
kubectl describe hpa php-apache
⚠ Note :  L'HP A peut af ficher "unknown" au début. Attendez quelques minutes pour que les métriques se stabilisent.
3. Générer de la charge (7 min)
Dans un terminal, surveillez l'HP A :
kubectl get hpa php-apache --watch
Dans un autre terminal, créez une char ge :
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# Dans le pod load-generator, exécutez :
while true; do wget -q -O- http://php-apache; done
Observez l'évolution :
kubectl get pods -l run=php-apache
kubectl top pods -l run=php-apache
4. Arrêter la charge et observer le scale-down (3 min)
Arrêtez le pod load-generator (Ctrl+C puis exit).
Surveillez la réduction automatique :
kubectl get hpa php-apache --watch
kubectl get pods -l run=php-apache --watch
✅ Validation :
L'HP A doit scaler jusqu'à plusieurs pods sous char ge
Le scale-down doit se faire automatiquement après arrêt de la char ge (5-10 min)
Vérifiez avec kubectl describe hpa php-apache  les événements de scaling
Exer cice 3 - Jobs et Cr onJobs (20 minutes)
⏱ Durée estimée : 20 minutes
Objectif
Créer et gérer des tâches ponctuelles (Jobs) et planifiées (CronJobs) avec gestion des échecs.
1. Job simple (5 min)
Créez simple-job.yaml  :
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-calculation
spec:
  # Politique en cas d'échec
  backoffLimit: 3
  # Délai max d'exécution
  activeDeadlineSeconds: 300
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
      restartPolicy: Never
Déployez et surveillez :
kubectl apply -f simple-job.yaml
kubectl get jobs
kubectl logs job/pi-calculation
kubectl describe job pi-calculation
2. Job parallèle avec gestion d'échecs (7 min)
Créez parallel-job.yaml  :
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processing
spec:
  parallelism: 3        # 3 pods en parallèle
  completions: 6        # 6 tâches à compléter au total
  backoffLimit: 2       # Max 2 tentatives en cas d'échec
  activeDeadlineSeconds: 180
  template:
    spec:
      containers:
      - name: worker
        image: busybox:1.35
        command: 
        - /bin/sh
        - -c
        - |
          echo "Worker $(hostname) démarré à $(date)"
          # Simuler un traitement avec 20% de chance d'échec
          if [ $((RANDOM % 5)) -eq 0 ]; then
            echo "Erreur simulée dans $(hostname)"
            exit 1
          fi
          # Simuler du travail
          sleep $((10 + RANDOM % 20))
          echo "Worker $(hostname) terminé avec succès à $(date)"
        resources:
          requests:
            memory: "32Mi"
            cpu: "50m"
      restartPolicy: Never

Testez le job parallèle :
kubectl apply -f parallel-job.yaml
kubectl get jobs
kubectl get pods -l job-name=data-processing --watch
Analysez les résultats :
kubectl describe job data-processing
kubectl logs -l job-name=data-processing
3. CronJob avec nettoyage automatique (8 min)
Créez backup-cronjob.yaml  :
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
spec:
  schedule: "*/2 * * * *"  # Toutes les 2 minutes pour le test
  jobTemplate:
    spec:
      backoffLimit: 1
      activeDeadlineSeconds: 120
      template:
        spec:
          containers:
          - name: backup
            image: busybox:1.35
            command:
            - /bin/sh
            - -c
            - |
              echo "=== Backup démarré à $(date) ==="
              echo "Hostname: $(hostname)"
            
              # Simuler une sauvegarde
              echo "Connexion à la base de données..."
              sleep 5
              echo "Export des données..."
              sleep 10
              echo "Compression des fichiers..."
              sleep 5
            
              # Simuler parfois un échec (10% de chance)
              if [ $((RANDOM % 10)) -eq 0 ]; then
                echo "ERREUR: Échec de la sauvegarde !"
                exit 1
              fi
            
              echo "=== Backup terminé avec succès à $(date) ==="
            resources:
              requests:
                memory: "32Mi"
                cpu: "50m"
          restartPolicy: OnFailure
  # Conserver seulement les 3 derniers jobs réussis
  successfulJobsHistoryLimit: 3
  # Conserver seulement le dernier job échoué
  failedJobsHistoryLimit: 1
  # Politique de concurrence
  concurrencyPolicy: Forbid  # Empêcher les exécutions simultanées
Déployez le CronJob :
kubectl apply -f backup-cronjob.yaml
kubectl get cronjobs
kubectl describe cronjob database-backup
Surveillez les exécutions :
# Attendez quelques minutes et vérifiez
kubectl get jobs
kubectl get pods -l job-name
kubectl logs -l job-name --tail=20
Testez l'exécution manuelle :
# Créer un job manuellement depuis le CronJob
kubectl create job manual-backup --from=cronjob/database-backup
kubectl get jobs
kubectl logs job/manual-backup
✅ Validation finale :
Le Job simple doit calculer PI et se terminer avec succès
Le Job parallèle doit exécuter 6 tâches avec 3 pods en parallèle
Le CronJob doit s'exécuter automatiquement toutes les 2 minutes
Vérifiez avec kubectl get jobs,cronjobs
🎯 Récapitulatif du TP
Ce que vous avez appris :
Rollback  : Gérer l'historique et revenir à une version stable
Autoscaling  : Adapter automatiquement le nombre de pods selon la char ge
Jobs/Cr onJobs  : Exécuter des tâches ponctuelles et planifiées
🧹 Nettoyage

kubectl delete deployments --all
kubectl delete services --all
kubectl delete hpa --all
kubectl delete jobs --all
kubectl delete cronjobs --all

