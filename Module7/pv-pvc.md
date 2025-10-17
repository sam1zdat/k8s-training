Voici deux exemples complets de PVC : un avec StorageClass et un sans StorageClass.

## 📝 Fichiers de Configuration

### 1. 🔧 PVC **AVEC** StorageClass (Provisionnement Dynamique)

#### 📄 Fichier : `pvc-with-storageclass.yaml`
```yaml
# StorageClass pour le provisionnement dynamique
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd  # Nom de la StorageClass
provisioner: kubernetes.io/aws-ebs  # Exemple avec AWS EBS
parameters:
  type: gp3
  fsType: ext4
  iops: "3000"
  throughput: "125"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Delete
---
# PVC utilisant la StorageClass
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dynamic-ssd
  namespace: default
spec:
  storageClassName: fast-ssd  # 🔑 Référence à la StorageClass
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi  # Le volume sera créé automatiquement
  selector:
    matchLabels:
      environment: production
---
# Pod utilisant le PVC dynamique
apiVersion: v1
kind: Pod
metadata:
  name: app-with-dynamic-pvc
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    volumeMounts:
    - name: dynamic-storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: dynamic-storage
    persistentVolumeClaim:
      claimName: pvc-dynamic-ssd
```

### 2. 🔧 PVC **SANS** StorageClass (Provisionnement Statique)

#### 📄 Fichier : `pvc-without-storageclass.yaml`
```yaml
# PersistentVolume manuel (sans StorageClass)
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-manual
  labels:
    type: local
    app: myapp
spec:
  storageClassName: ""  # 🔑 StorageClass vide = pas de StorageClass
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/mnt/data/manual-pv"
    type: DirectoryOrCreate
---
# PVC sans StorageClass (binding manuel)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-manual
  namespace: default
spec:
  storageClassName: ""  # 🔑 PVC sans StorageClass
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi  # Doit être <= capacité du PV
  selector:
    matchLabels:
      app: myapp  # Lie le PVC au PV spécifique
---
# Pod utilisant le PVC manuel
apiVersion: v1
kind: Pod
metadata:
  name: app-with-manual-pvc
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    volumeMounts:
    - name: manual-storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: manual-storage
    persistentVolumeClaim:
      claimName: pvc-manual
```

---

## 🚀 Déploiement et Test

### 🔧 Commandes de déploiement :
```bash
# 1. Créer le répertoire pour le PV manuel
sudo mkdir -p /mnt/data/manual-pv
sudo chmod 777 /mnt/data/manual-pv

# 2. Déployer le PVC AVEC StorageClass
kubectl apply -f pvc-with-storageclass.yaml

# 3. Déployer le PVC SANS StorageClass
kubectl apply -f pvc-without-storageclass.yaml

# 4. V
