# Ingress Nginx Controller In AKS
AKS 환경에서 [Ingress NGINX Controller](https://github.com/kubernetes/ingress-nginx) 설치 및 관리

## Installation

1. Create Namespace

    ```bash
    k create ns ingress-nginx
    ```

2. Add Helm Repo

    ```bash
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    ```

3. Setting Helm Value

    ```bash
    # Get Default Values
    helm show values ingress-nginx/ingress-nginx > values.yaml
    
    ## Azure LB 프로브 세팅 (최소설정)
    service:
        annotations: 
            service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
    ```
    
4. Install Helm Chart

    ```bash
    # Check Chart Version
    helm search repo ingress-nginx/ingress-nginx --versions | head

    # Install Helm Chart
    helm install RELEASE ingress-nginx/ingress-nginx --version VERSION -n NAMESPACE> -f VALUEFILE
    ```

5. Verify

    ```bash
    # Check Installed chart (release)
    helm ls -n ingress-nginx

    # Check value (user values)
    helm get values ingress-nginx -n ingress-nginx
    ```
## Operations
### Traffic Manage
```
# Client Origin IP 보존 (X-Forwarded-For)
# 트래픽을 받은 노드(노드포트)에 존재하는 백앤드 Pod로 트래픽을 전달한다 (다른 노드의 Pod로 전달 하지 않음)
controller.service.externalTrafficPolicy=Local
```
### Version Control
k8s 버전 업그레이드시 Ingress Nginx Contorller Version 호환성 확인

1. [공식 저장소](https://github.com/kubernetes/ingress-nginx#supported-versions-table)에서 업그레이드할 K8s 버전과 현재 Ingress Controller 버전의 호환성 확인

2. 버전 업그레이드

    ```bash
    # Update & Check Chart Version
    helm repo update
    helm search repo ingress-nginx/ingress-nginx --versions | head

    # helm upgrade [RELEASE] [CHART] [flags]
    helm upgrade RELEASE ingress-nginx/ingress-nginx --version VERSION -n NAMESPACE [-f VALUEFILE.yaml | --reuse-values]
    ```

### [NGINX Configuration](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/#nginx-configuration)


- Configmap: 글로벌 설정, Ingress Controller 단위로 적용 (Namespace와 Name은 Controller와 동일하게 배포)
- Annotation: 지역 설정, Ingress Object 생성 시 Annotation에 Nginx Configuration을 기입하여 인그레스 오브젝트 개별로 적용 가능

### [NGINX Prometheus Monitoring](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/monitoring.md#monitoring)

- Service Monitor 방식 (클러스터 단위)

    ```yaml
    controller:
    ## Prometheus Monitoring (Diffrent Namespace)
    metrics:
        enabled: true
        serviceMonitor:
        enabled: true
        additionalLabels:
            release: kube-prometheus-stack-dev # prometheus helm release name
    ```

- Pod Annotation 방식 (네임스페이스 단위)

    ```yaml
    controller:
    ## Prometheus Monitoring (Same Namespace)
    podAnnotations:
        prometheus.io/scrape: true
        prometheus.io/port: 10254
    ```


### [NGINX Logging](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/log-format/)

- NGINX Controller Pod의 STDOUT 확인
- [Log Format 변경 참고](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/log-format/)

### [NGINX TLS Termination Setting](https://kubernetes.github.io/ingress-nginx/user-guide/tls/)

```bash
# [option] Self Example Cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=example.com/O=example.com"

# Create TLS Secret
kubectl create secret tls NAME --cert=tls.crt --key=tls.key

# Set ingress manifest
spec:
  tls:
    - hosts:
      - DOMAIN
      secretName: SECRETNAME
```

### Internal Ingress Controller

1. Helm Value 설정
    ```yaml
    # Internal Ingress Controller in AKS
    controller:
    service:
        annotations: 
        service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
        service.beta.kubernetes.io/azure-load-balancer-internal: true
        loadBalancerIP: 10.224.224.100
    electionID: internal-ingress-controller-leader
    ingressClassResource:
        name: nginx-internal
        enabled: true
        default: false
        controllerValue: "k8s.io/internal-ingress-nginx"
    ingressClass: nginx-internal
    ```
2. 차트 배포

    ```yaml
    # helm install [NAME] [CHART] [flags]
    helm install ingress-nginx-internal ingress-nginx/ingress-nginx --version <CHART_VERSION> -n ingress-nginx -f internal-ingress-values.yaml
    ```

## References

- [Ingress Nginx Official Repo](https://github.com/kubernetes/ingress-nginx)
  
- [AKS Docs](https://learn.microsoft.com/ko-kr/azure/aks/ingress-basic?tabs=azure-cli)