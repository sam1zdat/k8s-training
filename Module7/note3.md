## 🔐 **accessModes** - Modes d'accès

Définit **comment** le volume peut être monté par les Pods.

### **Les 3 modes disponibles :**

| Mode | Description | Use Case |
|------|-------------|----------|
| **`ReadWriteOnce`** (RWO) | Montable en **lecture/écriture** par un **seul nœud** à la fois | Applications avec stockage local (base de données single-node) |
| **`ReadOnlyMany`** (ROX) | Montable en **lecture seule** par **plusieurs nœuds** | Données statiques partagées (configs, assets) |
| **`ReadWriteMany`** (RWX) | Montable en **lecture/écriture** par **plusieurs nœuds** | Applications partagées (CMS, systèmes de fichiers partagés) |

**Exemple dans un PV :**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce  # ⬅️ Un seul pod peut écrire
  # - ReadWriteMany # ⬅️ Plusieurs pods peuvent écrire
```

---

## ♻️ **persistentVolumeReclaimPolicy** - Politique de récupération

Définit ce qui arrive au PV **quand le PVC associé est supprimé**.

### **Les 3 politiques disponibles :**

| Politique | Description | Conséquence |
|-----------|-------------|-------------|
| **`Retain`** | **Conserver** les données | Le PV reste en statut `Released`, données **préservées** |
| **`Delete`** | **Supprimer** le stockage sous-jacent | Le PV ET les données sont **détruits** |
| **`Recycle`** | ⚠️ **Déprécié** - Nettoyage basique | Supprime les fichiers mais pas recommandé |

### **Exemple visuel :**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain  # ⬅️ Les données sont sauvegardées
  hostPath:
    path: "/data/important"
```

---

## 🎯 **Recommandations pratiques :**

- **`Retain`** pour les données **critiques** (bases de données)
- **`Delete`** pour les données **éphémères** ou tests (avec StorageClass)
- **`ReadWriteOnce`** pour la plupart des applications stateful simples
- **`ReadWriteMany`** seulement si nécessaire (performance impactée)
