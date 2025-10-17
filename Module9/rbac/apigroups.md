
## 🏗️ Architecture Complète des API Groups Kubernetes

```
API KUBERNETES
│
├── 🔹 CORE GROUP (v1) - "groupe vide"
│   ├── Pods
│   ├── Services
│   ├── Namespaces
│   ├── Nodes
│   ├── ConfigMaps
│   ├── Secrets
│   ├── PersistentVolumes (PV)
│   ├── PersistentVolumeClaims (PVC)
│   ├── ServiceAccounts
│   ├── Endpoints
│   ├── Events
│   ├── LimitRanges
│   ├── ResourceQuotas
│   ├── ReplicationControllers
│   └── ComponentStatuses
│
├── 🔹 APPS GROUP (apps/v1)
│   ├── Deployments
│   ├── StatefulSets
│   ├── ReplicaSets
│   ├── DaemonSets
│   └── ControllerRevisions
│
├── 🔹 BATCH GROUP (batch/v1)
│   ├── Jobs
│   └── CronJobs
│
├── 🔹 NETWORKING GROUP (networking.k8s.io/v1)
│   ├── Ingresses
│   ├── IngressClasses
│   ├── NetworkPolicies
│   └── NetworkAttachmentDefinitions (CRD)
│
├── 🔹 STORAGE GROUP (storage.k8s.io/v1)
│   ├── StorageClasses
│   ├── VolumeAttachments
│   ├── CSINodes
│   ├── CSIDrivers
│   └── CSIStorageCapacities
│
├── 🔹 RBAC GROUP (rbac.authorization.k8s.io/v1)
│   ├── Roles
│   ├── RoleBindings
│   ├── ClusterRoles
│   └── ClusterRoleBindings
│
├── 🔹 AUTHENTICATION GROUP (authentication.k8s.io/v1)
│   ├── TokenReviews
│   └── TokenRequests
│
├── 🔹 AUTHORIZATION GROUP (authorization.k8s.io/v1)
│   ├── SubjectAccessReviews
│   ├── SelfSubjectAccessReviews
│   ├── LocalSubjectAccessReviews
│   └── SelfSubjectRulesReviews
│
├── 🔹 ADMISSION REGISTRATION (admissionregistration.k8s.io/v1)
│   ├── ValidatingWebhookConfigurations
│   ├── MutatingWebhookConfigurations
│   ├── ValidatingAdmissionPolicies
│   └── ValidatingAdmissionPolicyBindings
│
├── 🔹 CERTIFICATES GROUP (certificates.k8s.io/v1)
│   ├── CertificateSigningRequests (CSR)
│   └── CertificateSigningRequestApprovals
│
├── 🔹 POLICY GROUP (policy/v1)
│   ├── PodDisruptionBudgets (PDB)
│   └── PodSecurityPolicies (déprécié)
│
├── 🔹 COORDINATION GROUP (coordination.k8s.io/v1)
│   ├── Leases
│   └── LeaderElections
│
├── 🔹 DISCOVERY GROUP (discovery.k8s.io/v1)
│   ├── EndpointSlices
│   └── EndpointSliceMirrors
│
├── 🔹 FLOW CONTROL GROUP (flowcontrol.apiserver.k8s.io/v1)
│   ├── PriorityLevelConfigurations
│   └── FlowSchemas
│
├── 🔹 NODE GROUP (node.k8s.io/v1)
│   ├── RuntimeClasses
│   └── NodeRuntimeConfigs
│
├── 🔹 METRICS GROUP (metrics.k8s.io/v1)
│   ├── NodeMetricses
│   └── PodMetricses
│
├── 🔹 AUTOSCALING GROUP (autoscaling/v1, v2)
│   ├── HorizontalPodAutoscalers (HPA)
│   ├── VerticalPodAutoscalers (VPA)
│   └── ClusterAutoscalers
│
├── 🔹 EXTENSIONS GROUP (extensions/v1beta1) - DÉPRÉCIÉ
│   ├── Deployments (migré vers apps/v1)
│   ├── DaemonSets (migré vers apps/v1)
│   ├── ReplicaSets (migré vers apps/v1)
│   ├── NetworkPolicies (migré vers networking.k8s.io/v1)
│   └── Ingresses (migré vers networking.k8s.io/v1)
│
├── 🔹 CUSTOM RESOURCE DEFINITIONS (CRDs)
│   ├── CustomResources (divers)
│   ├── Operators
│   ├── ServiceMeshes (Istio, Linkerd)
│   ├── Monitoring (Prometheus, Grafana)
│   ├── Databases (MySQL, PostgreSQL operators)
│   └── Applications spécifiques
│
└── 🔹 API EXTENSIONS GROUP (apiextensions.k8s.io/v1)
    ├── CustomResourceDefinitions (CRD)
    └── CustomResourceValidation
```

---

## 📊 Tableau des API Groups avec Exemples Complets

| API Group | Version | Ressources Clés | Exemple d'Usage |
|-----------|---------|-----------------|-----------------|
| **`(core)`** | `v1` | Pod, Service, ConfigMap | `apiVersion: v1` |
| **`apps`** | `v1` | Deployment, StatefulSet | `apiVersion: apps/v1` |
| **`batch`** | `v1` | Job, CronJob | `apiVersion: batch/v1` |
| **`networking.k8s.io`** | `v1` | Ingress, NetworkPolicy | `apiVersion: networking.k8s.io/v1` |
| **`storage.k8s.io`** | `v1` | StorageClass, CSI | `apiVersion: storage.k8s.io/v1` |
| **`rbac.authorization.k8s.io`** | `v1` | Role, ClusterRole | `apiVersion: rbac.authorization.k8s.io/v1` |
| **`autoscaling`** | `v2` | HPA, VPA | `apiVersion: autoscaling/v2` |
| **`policy`** | `v1` | PodDisruptionBudget | `apiVersion: policy/v1` |
| **`certificates.k8s.io`** | `v1` | CertificateSigningRequest | `apiVersion: certificates.k8s.io/v1` |
| **`admissionregistration.k8s.io`** | `v1` | ValidatingWebhook | `apiVersion: admissionregistration.k8s.io/v1` |
| **`apiextensions.k8s.io`** | `v1` | CustomResourceDefinition | `apiVersion: apiextensions.k8s.io/v1` |

---

