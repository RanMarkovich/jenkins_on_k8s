# About the project:
An easy-to-set-up jenkins on k8s cluster with build agents as pods using Helm.


# Fork this repo and follow the below steps

## Prerequisites:

* minikube installed
* kubectl installed
* helm installed

## Steps

* start minikube
* `helm repo add jenkins https://charts.jenkins.io`
* `helm repo update`
* make sure chart exists:
  * `helm search repo jenkins`
* from repository root folder: 
  * `kubectl apply -f ./helm --validate=false`
* from helm folder (`cd ./helm`):
  * `helm install jenkins -n jenkins -f jenkins-values.yaml jenkins/jenkins`
* from repository root folder:
  * `get_creds.sh`
* retrieve creds from `admin_creds.txt`

* expose port 8080:
  * `kubectl -n jenkins port-forward <pod_name> 8080:8080`

* navigate to http://localhost:8080 and login with admin creds

### Enabling kube agent

* navigate to http://localhost:8080/configure
  * under `Labels`, add `jenkins-jenkins-agent`
* navigate to http://localhost:8080/manage/configureClouds/
  * under `Pod Templates` -> `Pod Template Details` -> `Containers` -> `Container Template`
    * clear parameters in `Command to run` and `Arguments to pass to the command`