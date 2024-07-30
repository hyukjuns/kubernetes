# Headless Service
## Background
### Pod의 DNS 조회 매커니즘

Pod 생성시 kubelet은 Pod의 /etc/resolv.conf 파일내 search 항목에 클러스터 관련 도메인을 기입함

Pod는 DNS 조회시 search 항목에 기입된 도메인들을 활용해서 조회할 도메인에 접미사(suffix)로 붙힐 수 있음

ex) resolv.conf에 아래 내용이 기입되어 있음

> search <NAMESPACE>.svc.cluster-domain.local svc.cluster-domain.local ...

따라서 같은 네임스페이스인 경우 Pod, Service에 Namespace를 생략하는게 가능해지며,
다른 네임스페인 경우 항상 타겟 서비스 혹은 파드의 네임스페이스를 명시해주어야 함

## Headless Service 구현
### 구현 방법
서비스 스펙을 다음과 같이 세팅 `.spec.clusterIP: None`

### 주 사용 목적
로드밸런싱이 필요하지 않거나, 특정한 Pod로 연결을 맺어야 할 경우 

### 동작 원리
- 다른 기본 서비스들과 다르게 서비스 디스커버리 매커니즘이 다름 
	즉, kube-proxy를 타지 않으며, 요청을 로드밸런싱 하지 않음
- headless 서비스는 Selector로 잡힌 Pod를 DNS record로 등록하고, 
	클라이언트가 요청을 보내면 DNS로 등록된 Pod 들의 IP 주소들을 모두 Return 함
- Client는 Return 된 Pod IP 목록 중 최상단 IP를 사용함
- 특정 Pod(statefulSet) 로 연결을 맺어야 할 경우 `POD_HOSTNAME.SERVICE_NAME` 으로 특정 Pod의 주소를 알아낼 수 있음
- StatefulSet의 Pod기 때문에 Pod의 이름(hostname)과 Suffix를 예상할 수 있음
- Pod 이름 == STS이름+번호 == hostname

### 사용 방법
기본 할당되는 서비스의 DNS 도메인으로 주소 확인
> my-svc.[my-namespace.svc.cluster-domain.example]

도메인 조회시 해당 서비스의 Endpoint로 등록된 Pod의 IP 들을 모두 리턴함, 클라이언트는 리턴된 ip들 중 가장 상단의 IP를 사용하게 됨

### 특정 Pod로 연결이 필요할 경우
StatefulSet과 함께 사용시 Pod의 hostname이 들어간 FQDN 으로 주소 확인
1. StatefulSet spec에 serviceName 기입
`.spec.serviceName: <SERVICENAME>`
	
2. hostname이 들어간 fqdn 사용	
`hostname.my-svc.[my-namespace.svc.cluster-domain.example]`
도메인 조회시 hostname에 해당하는 파드 IP 1개만을 리턴함

### k8s Manifest
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
  namespace: test
spec:
  clusterIP: None
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
---
# volume 생략
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  serviceName: nginx-headless
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 100m
            memory: 128Mi
```

### 테스트
```bash
# network tool 이미지 실행
k run network-tool -it --rm --image=hyukjun/network-tool-ubuntu:1.0 /bin/bash

# nslookup sts-pod-#.service-name.[namespace]
nslookup nginx-0.nginx-headless.test
```