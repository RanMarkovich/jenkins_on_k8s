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
* from repository root folder: 
  * `kubectl apply -f ./helm`
  * `helm install jenkins -n jenkins -f jenkins-values.yaml jenkins/jenkins`
  * `get_creds.sh`
* retrieve creds from `admin_creds.txt`

* expose port 8080:
  * `kubectl -n jenkins port-forward <pod_name> 32000:32000`

* navigate to http://localhost:8080 and login with admin creds

### Enabling kube agent

* navigate to http://localhost:8080/configure
  * under `Labels`, add `jenkins-jenkins-agent`
* navigate to http://localhost:8080/manage/configureClouds/
  * under `Pod Templates` -> `Pod Template Details` -> `Containers` -> `Container Template`
    * clear parameters in `Command to run` and `Arguments to pass to the command`