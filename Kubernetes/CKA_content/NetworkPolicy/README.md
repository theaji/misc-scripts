# Task: 

- Create a NetworkPolicy to allow pods with label app=frontend to only be able to communicate to pods with label app=backend on port 3306. Also allow all external DNS traffic.
 
# Topics covered:

- network policy

# Commands used:

**Create networkpolicy**: `kubectl apply -f np.yml`
**Verify creation**: `kubectl describe networkpolicy np`
**Delete networkpolicy**: `kubectl delete -f np.yml`

