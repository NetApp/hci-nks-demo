# MetalLB Setup

NKS is deployed with an nginx ingress controller by default. 

Unfortunately, this ingress controller is deployed as a **LoadBalancer** service, so won't become functional until it gets a cluster-external IP address. 

This is evident by the Ingress service stuck in pending state:

`kubectl get ingress -n ingress-nginx`
```
NAMESPACE         NAME              TYPE           CLUSTER-IP   EXTERNAL-IP
ingress-nginx     ingress-nginx     LoadBalancer   10.3.0.46    <pending>
```

## MetalLB

In the `metallb-system` namespace, NKS deploys a metallb controller by default. All it needs to become functional is a configmap called `config` with a range of IPs that it can hand out to `LoadBalancer` services in the cluster.

Prepare config file:
```
apiVersion: v1
items:
- apiVersion: v1
  data:
    config: |
      address-pools:
      - addresses:
        - <IP START>-<IP END>
        name: default
        protocol: layer2
  kind: ConfigMap
  metadata:
    labels:
      app: metallb
    name: config 
    namespace: metallb-system
kind: List
metadata:
  namespace: metallb-system
```

Apply config:
```
echo 'apiVersion: v1
items:
- apiVersion: v1
  data:
    config: |
      address-pools:
      - addresses:
        - 10.117.169.153-10.117.169.153
        name: default
        protocol: layer2
  kind: ConfigMap
  metadata:
    labels:
      app: metallb
    name: config 
    namespace: metallb-system
kind: List
metadata:
  namespace: metallb-system' | kubectl apply -f -
```

## Verifying things are working

### Via Controller Logs

After applying the config, the `metallb-controller` logs should have a line with the following:

```
{"caller":"main.go:130","event":"stateSynced","msg":"controller synced, can allocate IPs now","ts":"2020-02-18T19:27:04.250082213Z"}
```

If you dont see this, it failed to detect the config. Configmap should be named `config`

### Check ingress-nginx service

The ingress-nginx service should have an IP from the range configured for metallb now:
```
NAMESPACE       NAME               TYPE           CLUSTER-IP   EXTERNAL-IP             
ingress-nginx   ingress-nginx      LoadBalancer   10.3.0.46    10.117.169.153  
```

### Check DNS

The cluster domain should become resolvable now

1. Get Cluster ID
    - This is the random prefix of the node names (e.g. `netp5fki6k`)
```
$ k get nodes
NAME                      STATUS   ROLES    AGE    VERSION
netp5fki6k-master-1       Ready    master   6d2h   v1.15.0
netp5fki6k-pool-1-gqtkl   Ready    <none>   6d2h   v1.15.0
netp5fki6k-pool-1-trjhx   Ready    <none>   6d2h   v1.15.0
```

2. Run nslookup against cluster domain

- This should resolve to the External IP address of the nginx-ingress `LoadBalancer` service
```
$ nslookup test.netp5fki6k.nks.cloud
Server:         10.122.76.132
Address:        10.122.76.132#53

Non-authoritative answer:
test.netp5fki6k.nks.cloud       canonical name = netp5fki6k.nks.cloud.
Name:   netp5fki6k.nks.cloud
Address: 10.117.169.153
```