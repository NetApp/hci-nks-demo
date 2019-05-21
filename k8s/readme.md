# Startup the Python AIOHTTP dynamic microservice

~~~~
kubectl create -f dynamic_deployment.yaml
kubectl create -f dynamic-service.yaml

~~~~

# Startup the nginx static content web server
~~~~
kubectl create -f static_deployment.yaml
kubectl create -f static-service.yaml

~~~~~

# Check if things are up and running

~~~~~
kubectl get all

~~~~~

