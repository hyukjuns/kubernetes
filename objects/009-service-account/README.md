# RBAC Test

1. Authentication (Without using a proxy)

```
# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc

# Path to ServiceAccount token
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

# Explore the API with TOKEN
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api
```

2. Authorization
```
2.1 Create SA
k create sa test-sa -n test

2.2 Create Role
k create clusterrole test-cluster-role  --verb=list,get --resource=pods

2.3 Binding Role
k create clusterrolebinding test-cluster-role-binding --serviceaccount test:test-sa --clusterrole test-cluster-role 

2.4 Set Pod Spec
spec.serviceAccountName: test-sa
```