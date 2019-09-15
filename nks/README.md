# Getting Started

### Requirements
* Google Cloud Account - (https://cloud.google.com)
* NKS Account - (https://nks.netapp.io)
* Docker

## Work Environment Prerequisites

1. Create NKS API Key - [Instructions](https://docs.netapp.com/us-en/kubernetes-service/api-basics.html#authorization-requirements)

2. Create GCE Credentials - [Instructions](https://docs.netapp.com/us-en/kubernetes-service/create-auth-credentials-on-gce.html#create-a-new-set-of-gce-credentials)


## Exercise 1 - Create a GCE-backed Kubernetes Cluster using NKS

1. Run `./nks-shell.sh`

* This will prompt for your NKS API Key, and then build/run a deployment container with docker. This container functions as a "cloud shell" with necessary binaries/libs preloaded.

2. Navigate to http://localhost:3000

* This will launch the NKS Shell. After some initial configuration, you will be placed in the shell:

```
                   _   _ _  ______       ____  _          _ _
                  | \ | | |/ / ___|     / ___|| |__   ___| | |
                  |  \| | ' /\___ \ ____\___ \| '_ \ / _ \ | |
                  | |\  | . \ ___) |_____|__) | | | |  __/ | |
                  |_| \_|_|\_\____/     |____/|_| |_|\___|_|_|

*************************
Welcome to the NKS Shell!
*************************

Configuring NKS CLI....
Setting default org..
Default SSH keys not set. Configuring...
NKS CLI Version - v0.0.1 (alpha)

Run 'nks -h for a list of commands.'
bash-4.4$
```

3. Type `nks cluster list`. We currently have no clusters:

```
bash-4.4$ nks cluster list
NAME     ID     PROVIDER     NODES     K8s_VERSION     STATE
bash-4.4$ 
```

4. Let's create a cluster. Enter `nks cluster create --name <name of cluster>`:

This will start a new cluster build on gce:
```
bash-4.4$ nks cluster create --name MyDemoCluster
NAME              ID        PROVIDER     NODES     K8s_VERSION     STATE
MyDemoCluster     24680     gce          3         v1.13.2         draft
bash-4.4$
```

5. Enter `nks clusters list` to view progress:
```
bash-4.4$ nks cluster list
NAME              ID        PROVIDER     NODES     K8s_VERSION     STATE
MyDemoCluster     24680     gce          3         v1.13.2         building (default)
bash-4.4$
```

*Note - The Cluster deployment will take a few minutes. During this time you may want to navigate to the NKS/GCE GUI and show the cluster building*

```
bash-4.4$ nks cluster list
NAME              ID        PROVIDER     NODES     K8s_VERSION     STATE
MyDemoCluster     24680     gce          3         v1.13.2         provisioned (default)
bash-4.4$
```



6. Once the cluster is fully deployed, it will show in the 'Running' state:

```
bash-4.4$ nks cluster list
NAME              ID        PROVIDER     NODES     K8s_VERSION     STATE
MyDemoCluster     24680     gce          3         v1.13.2         running (default)
bash-4.4$
```
7. Run `nks config set cluster --id <cluster id>` to configure kubectl against your new cluster.

* `kubectl` and `helm` should be available and configured to the new cluster:

```
bash-4.4$ nks config set cluster --id=24680
bash-4.4$ kubectl get nodes
NAME                  STATUS   ROLES    AGE     VERSION
netutuuxj8-master-1   Ready    master   2m47s   v1.13.2
netutuuxj8-worker-1   Ready    <none>   99s     v1.13.2
netutuuxj8-worker-2   Ready    <none>   99s     v1.13.2
bash-4.4$
```


### To Delete your demo cluster:

* From inside the cloud shell: `/src/docker-entrypoint.sh --destroy` 
* From outside the cloud shell: `./nks.sh -a destroy-cluster`

## Exercise 2 - Deploy Jenkins onto your NKS Cluster from NKS Curated Charts

Before proceeding here, run `kubectl get pods -n kube-system -l app=helm` and the tiller pod is running in your cluster (this is automatically installed but takes a few extra minutes after cluster creation):

```
NAME                             READY   STATUS    RESTARTS   AGE
tiller-deploy-6f8d4f6c9c-4gvvs   1/1     Running   0          8m57s
```

1. Enter `nks solutions list`:

```
bash-4.4$ nks solutions list
(cluster id: 24680)

NAME            ID        SOLUTION        STATE
Helm Tiller     47671     helm_tiller     installed
bash-4.4$
```
We can see that only Tiller is currently installed. Tiller is included by default with all NKS clusters.

2. Lets deploy jenkins onto our cluster. Enter `nks solutions deploy`:

```
bash-4.4$ nks solutions deploy
creating solution jenkins...
NAME        ID        SOLUTION           STATE     
jenkins     47673     jenkins-repo-1     draft
```

Check progress with `nks solutions list`:

```
bash-4.4$ nks solutions list
(cluster id: 24680)

NAME            ID        SOLUTION           STATE
Helm Tiller     47671     helm_tiller        installed
jenkins         47673     jenkins-repo-1     installing
```

When the solution state shows **installled**, we're ready to use Jenkins:

```
bash-4.4$ nks solutions list
(cluster id: 24680)

NAME            ID        SOLUTION           STATE
Helm Tiller     47671     helm_tiller        installed
jenkins         47672     jenkins-repo-1     installed
bash-4.4$ 
```


Since `helm` is also available in the cloud shell, we can use it to verify the deployment:

```
bash-4.4# helm ls
NAME                    REVISION        UPDATED                         STATUS          CHART           APP VERSION     NAMESPACE
jenkins-dry-recipe      1               Thu Sep  5 18:00:54 2019        DEPLOYED        jenkins-0.19.1  2.121.3         jenkins 
```

To delete jenkins from your cluster, enter `nks solutions delete -s <solution id>`:
```
bash-4.4$ nks solutions delete -s 47672
deleting solution 47672...
NAME            ID        SOLUTION           STATE
Helm Tiller     47671     helm_tiller        installed
jenkins         47672     jenkins-repo-1     deleting
bash-4.4$
```


# Exercise 3 - Configure Jenkins Pipeline against a custom repository/image

1. Login to jenkins


* Enter `kubectl get svc -n jenkins` to get the IP of the Jenkins endpoint:

```
bash-4.4$ kubectl get svc -n jenkins
NAME                       TYPE           CLUSTER-IP   EXTERNAL-IP     PORT(S)          AGE
jenkins-dry-recipe         LoadBalancer   10.3.0.226   35.227.171.13   8080:30230/TCP   3m58s
jenkins-dry-recipe-agent   ClusterIP      10.3.0.251   <none>          50000/TCP        3m58s
```

Get the Jenkins admin password:

```
bash-4.4$ kubectl get secret jenkins-dry-recipe -n jenkins -o json | jq '.data."jenkins-admin-password"' | base64 -d; echo ''
<PASSWORD>
bash-4.4$
```

2. Add Credentials for Docker Hub

* Credentials > Jenkins > Global Credentials > (Add credentials on left)
* Give the credentials an ID of 'Docker' 

3. Configure agent containers

* Manage Jenkins > Configure System 
* In the **cloud** section, scroll down to ***kubernetes pod template**
* Below, in the *raw yaml for the pod* field, paste the following:

```
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins/kube-default: true
    app: jenkins
    component: agent
spec:
  containers:
    - name: jnlp
      image: jenkins/jnlp-slave:3.10-1
      imagePullPolicy: Always
      env:
      - name: POD_IP
        valueFrom:
          fieldRef:
            fieldPath: status.podIP
      - name: DOCKER_HOST
        value: tcp://localhost:2375
    - name: dind
      image: docker:18.05-dind
      securityContext:
        privileged: true
      volumeMounts:
        - name: dind-storage
          mountPath: /var/lib/docker
  volumes:
    - name: dind-storage
      emptyDir: {}
```

*note: This will enable docker-in-docker builds for our cluster*

4. Create a pipeline

* Home > New item 
* Select 'Pipeline'. Enter a name.
* Under **build triggers**, select 'Poll SCM'
* Under ***Pipeline**, select 'Pipeline script from SCM'
* Set SCM to 'Git'
* Set Repository URL to https://github.com/NetApp/hci-nks-demo


Trigger the pipeline. The pipeline will checkout the repository, build and push a docker image.



# Exercise 4 - Deploy a Custom Helm Chart

1. In the NKS Shell, add a custom repository:

```
bash-4.4$ nks repositories create --name demo --url https://github.com/NetApp/hci-nks-demo/tree/master/k8s/hci-nks-demo
NAME     ID      SOURCE     URL                                # CHARTS
demo     614                github.com/NetApp/hci-nks-demo     0
bash-4.4$
```

* View our added repo with `nks repositories list`:

```
bash-4.4$ nks repositories list
NAME     ID      SOURCE     URL                                # CHARTS
demo     614                github.com/NetApp/hci-nks-demo     1
bash-4.4$
```

* Deploy our custom chart:

```
bash-4.4$ nks solutions deploy --name demo
creating solution demo...
NAME             ID        SOLUTION                  STATE     
hci-nks-demo     47679     hci-nks-demo-repo-614     draft
bash-4.4$
```