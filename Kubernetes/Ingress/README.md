# Task: 

- Create 2 deployments and corresponding services. Create Ingress resource for domain name "my.company.info". The ingress resource should have 2 routes pointing to the 2 services. 
 
# Topics covered:

- deployments, services, ingress controller, ingress

# Commands used:

**Create workloads**: `kubectl apply -f workloads.yml`
**Verify ingress resource creation**: `kubectl get ingress`
**Delete resources**: `kubectl delete -f workloads.yml`

