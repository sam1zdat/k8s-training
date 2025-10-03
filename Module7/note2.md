

## 1. PersistentVolume (PV) - Définition manuelle du stockage

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-manual-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain # Important en manuel
  storageClassName: "" # Explicitement vide
  hostPath: # Exemple avec stockage local (développement seulement)
    path: "/data/volumes/my-pv"
```

## 2. PersistentVolumeClaim (PVC) - Réclame le PV

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-manual-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: "" # Doit correspondre au PV
  resources:
    requests:
      storage: 10Gi # Doit correspondre ou être inférieur au PV
```

## 3. Pod utilisant le PVC

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
    - name: my-storage
      mountPath: "/data"
  volumes:
  - name: my-storage
    persistentVolumeClaim:
      claimName: my-manual-pvc
```

---

## Autres types de PV manuels (plus réalistes) :

### PV avec NFS :
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  nfs:
    server: 192.168.1.100
    path: "/exports/data"
```

### PV avec iSCSI :
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: iscsi-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: ""
  iscsi:
    targetPortal: 192.168.1.200:3260
    iqn: iqn.2024-01.com.example:storage.target
    lun: 0
    fsType: ext4
```

## Points clés sans StorageClass :

- ✅ **Contrôle total** sur la configuration du stockage
- ❌ **Provisionnement manuel** requis pour chaque PV
- ❌ **Pas d'auto-scaling** 
- ❌ **Gestion plus complexe** en production
- ⚠️ **`persistentVolumeReclaimPolicy: Retain`** recommandé pour éviter la suppression accidentelle des données