### Source: 
https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3

prerequisites:
* minikube installed
* kubectl installed
* helm installed

steps:
* `helm repo add jenkins https://charts.jenkins.io`
* `helm repo update`
* make sure chart exists:
  * `helm search repo jenkins`
* create jenkins namespace:
  * create a jenkins-namespace.yaml file:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins
```
* create jenkins volume
  * create a jenkins-volume.yaml file:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv
  namespace: jenkins
spec:
  storageClassName: jenkins-pv
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 50Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/jenkins-volume/
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - minikube
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: jenkins-pv
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```
* create a jenkins-sa.yaml file
```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: jenkins
rules:
- apiGroups:
  - '*'
  resources:
  - statefulsets
  - services
  - replicationcontrollers
  - replicasets
  - podtemplates
  - podsecuritypolicies
  - pods
  - pods/log
  - pods/exec
  - podpreset
  - poddisruptionbudget
  - persistentvolumes
  - persistentvolumeclaims
  - jobs
  - endpoints
  - deployments
  - deployments/scale
  - daemonsets
  - cronjobs
  - configmaps
  - namespaces
  - events
  - secrets
  verbs:
  - create
  - get
  - watch
  - delete
  - list
  - patch
  - update
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - get
  - list
  - watch
  - update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:jenkins
```
* configure jenkins-values.yaml for installation
  * create a jenkins-values.yaml file containing the code from here: https://raw.githubusercontent.com/jenkinsci/helm-charts/main/charts/jenkins/values.yaml
  * modify the below parameters:
    * set `serviceType` property to `nodePort`
    * set `storageClass` property to `jenkins-pv`
    * set `serviceAccount` to the below values:
```yaml
serviceAccount:
  create: false
# Service account name is autogenerated by default
name: jenkins
annotations: {}
```

* install jenkins
  * `helm install jenkins -n jenkins -f jenkins-values.yaml jenkins/jenkins`
* retrieve creds: 
<br>`$ jsonpath="{.data.jenkins-admin-password}"`
<br>`$ secret=$(kubectl get secret -n jenkins jenkins -o jsonpath=$jsonpath)`
<br>`$ echo $(echo $secret | base64 --decode)`
* retrieve jenkins url:
<br>`$ jsonpath="{.spec.ports[0].nodePort}"`
<br>`$ NODE_PORT=$(kubectl get -n jenkins -o jsonpath=$jsonpath services jenkins)`
<br>`$ jsonpath="{.items[0].status.addresses[0].address}"`
<br>`$ NODE_IP=$(kubectl get nodes -n jenkins -o jsonpath=$jsonpath)`
<br>`$ echo http://$NODE_IP:$NODE_PORT/login`

* expose port 8080:
  * `kubectl -n jenkins port-forward <pod_name> 8080:8080`

* navigate to http://localhost:8080