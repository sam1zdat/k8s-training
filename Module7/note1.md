
### 1. StorageClass (Optionnel, pour le provisionnement dynamique)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs # Exemple pour AWS
parameters:
  type: gp3
  fsType: ext4
```

### 2. PersistentVolumeClaim (PVC)

L'utilisateur demande du stockage via le PVC.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-app-pvc
spec:
  accessModes:
    - ReadWriteOnce # RWO = Montable en écriture par un seul nœud
  storageClassName: fast-ssd # Fait référence au StorageClass
  resources:
    requests:
      storage: 10Gi # Demande 10 Go de stockage
```

### 3. Pod utilisant le PVC comme Volume

Le Pod utilise le PVC via la section `volumes`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
spec:
  containers:
  - name: app-container
    image: nginx
    volumeMounts:
    - name: storage-volume
      mountPath: "/data" # Le volume est monté dans le container à ce chemin
  volumes:
  - name: storage-volume
    persistentVolumeClaim:
      claimName: my-app-pvc # Référence directe au PVC créé précédemment
```

---

### Flux avec Provisionnement Dynamique :

1.  Vous appliquez le **PVC**.
2.  Kubernetes voit le `storageClassName: fast-ssd`.
3.  Il interroge la **StorageClass** "fast-ssd".
4.  La StorageClass provisionne automatiquement un **PV** (vous n'avez pas à le créer manuellement).
5.  Le **PVC** est lié au **PV** nouvellement créé.
6.  Le **Pod** monte le **PVC** comme un **Volume** dans le container.

**Résultat :** Les données écrites dans `/data` du container seront persistées sur le disque EBS, même si le Pod est recréé.