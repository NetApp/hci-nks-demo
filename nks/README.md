# Getting Started

### Requirements
* Google Cloud Account - (https://cloud.google.com)
* NKS Account - (https://nks.netapp.io)
* Docker

## Work Environment Prerequisites

1. Create NKS API Key - [Instructions](https://docs.netapp.com/us-en/kubernetes-service/api-basics.html#authorization-requirements)

2. Create GCE Credentials - [Instructions](https://docs.netapp.com/us-en/kubernetes-service/create-auth-credentials-on-gce.html#create-a-new-set-of-gce-credentials)


## Exercise 1 - Create a GCE-backed Kubernetes Cluster using NKS

1. Run `./nks.sh`

* This will prompt for your NKS API Key, and then build/run a deployment container with docker. This container functions as a "cloud shell" with necessary binaries/libs preloaded.

* By default, the cloud shell will build a GCE-backed NKS cluster called `nks-demo-gce` using the NKS API Token provided in the previous step.

*Note - The build container uses the [NKS Terraform Provider](https://github.com/NetApp/terraform-provider-nks) to deploy cluster resources.*

*Note - The Cluster deployment will take ~7 minutes*

Once the cluster is deployed, the user will be dropped into a bash shell within the deployment container. `kubectl` and `helm` should be available and configured to the new cluster:

```
bash-4.4# kubectl get nodes
NAME                  STATUS   ROLES    AGE     VERSION
netdgynvdh-master-1   Ready    master   5m42s   v1.13.2
netdgynvdh-worker-1   Ready    <none>   4m35s   v1.13.2
netdgynvdh-worker-2   Ready    <none>   4m34s   v1.13.2
bash-4.4# 
```


### To Delete your demo cluster:

* From inside the cloud shell: `/src/docker-entrypoint.sh --destroy` 
* From outside the cloud shell: `./nks.sh -a destroy-cluster`

## Exercise 2 - Deploy Jenkins onto your NKS Cluster

Before proceeding here, run `kubectl get pods -n kube-system -l app=helm` and the tiller pod is running in your cluster (this is automatically installed but takes a few extra minutes after cluster creation):

```
NAME                             READY   STATUS    RESTARTS   AGE
tiller-deploy-6f8d4f6c9c-4gvvs   1/1     Running   0          8m57s
```

1. From within the cloud shell, execute `/src/deploy-jenkins.sh`

This will install the pre-packaged jenkins helm chart into the cluster, in the `jenkins` namespace.

Run `helm ls` to verify the deployment

```
bash-4.4# helm ls
NAME                    REVISION        UPDATED                         STATUS          CHART           APP VERSION     NAMESPACE
jenkins-dry-recipe      1               Thu Sep  5 18:00:54 2019        DEPLOYED        jenkins-0.19.1  2.121.3         jenkins 
```

Get the external IP of the Jenkins Endpoint:

`echo $(kubectl get svc jenkins-dry-recipe -n jenkins -o json | jq -r '.status.loadBalancer.ingress[0].ip'):8080`

```
34.83.37.34:8080
```

Get the Jenkins admin password:

`echo $(kubectl get secret jenkins-dry-recipe -n jenkins -o json | jq '.data."jenkins-admin-password"' | base64 -d)`

```
sVjwXh5CKU
```