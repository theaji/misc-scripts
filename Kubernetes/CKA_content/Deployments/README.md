# Task: 

- Create a Deployment of nginx with 3 replicas
 
# Topics covered:

- pods, deployments

# Commands used:

**Create deployment**: `kubectl apply -f nginx.yml`
**Verify deployment creation**: `kubectl get deployments`
**Delete deployment**: `kubectl delete -f nginx.yml`
**View deployment info**: `kubectl describe deployment nginx`
**View deployment rollout history**: `kubectl rollout history deployment nginx-deployment`

