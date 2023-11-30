# Task: 

- Create a pod running a single nginx container. Label pod with "web-app" and "front-end"
 
# Topics covered:

- pods, labels

# Commands used:

**Create pod**: `kubectl apply -f nginx.yml`
**Verify pod creation**: `kubectl get pods`
**Delete pod**: `kubectl delete pods nginx-pod`
**View pod info**: `kubectl describe pods nginx-pod`

