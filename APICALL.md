# ServiceAccount in Pod → Pod direct Call to APIServer
```markdown
# Namespace: api
1) SA, Role, Rolebinding 생성
k create sa api-sa -n api
k create role api-test-role -n api --verb=list,get --resource=pod
k create rolebinding api-test-role-binding -n api --role=api-test-role --serviceaccount=api:api-sa
# simple rbac test
k auth can-i list pod -n api --as system:serviceaccount:api:api-sa

2) Pod 생성 (SA 연결)
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: api
  name: api
  namespace: api
spec:
  serviceAccountName: api-sa
  containers:
  - image: alpine:3.12
    name: api
    command:
    - sh
    - -c
    - sleep 1d

3) Pod 내에서 수행
# Point to the internal API server hostname
APISERVER=https://kubernetes.default.svc[.cluster.local]

# Path to ServiceAccount token
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount

# Read this Pod's namespace
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)

# Read the ServiceAccount bearer token
TOKEN=$(cat ${SERVICEACCOUNT}/token)

# Reference the internal certificate authority (CA)
CACERT=${SERVICEACCOUNT}/ca.crt

# Curl 설치
apk --update add curl

# Explore the API with TOKEN
curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/api
EX) curl --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET ${APISERVER}/ap
i/v1/namespaces/api/pods
```