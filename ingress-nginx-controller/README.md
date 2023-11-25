# Ingress Nginx Controller
Helm을 사용한 Ingress Nginx Controller 설치 및 튜닝, 

## Caution
운영시에 k8s 버전 업그레이드가 필요할 경우 Ingress Nginx Controller 버전과 호환성을 확인해야한다.

## Type
- External Ingress Controller
- Internal Ingress Controller

## 기본 설치 순서

1. Create Namespace

    ```
    k create ns ingress-nginx
    ```

2. Setup Helm repo

    ```
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    ```

3. Customize Values

    ```
    # Get Default Values
    helm show values ingress-nginx/ingress-nginx > values.yaml

    # Custom Chart Values
    $ vi user-values.yaml
    controller:
      service:
        annotations: 
          service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz

    ```
4. Install Chart (To be Release)

    ```
    # helm install [NAME] [CHART] [flags]
    helm install ingress-nginx ingress-nginx/ingress-nginx --version <CHART_VERSION> -n ingress-nginx -f user-values.yaml
    ```

5. Check installation

    ```
    # Check Installed chart (release)
    helm ls -n ingress-nginx

    # Check value (user values)
    helm get values ingress-nginx -n ingress-nginx
    ```

## 특정 버전 설치

1. 차트 버전 살펴보기

    ```
    helm search repo ingress-nginx --versions
    ```
    ![ingress-nginx-versions](image/ingress-nginx-versions.png)

2. 공식 문서 참고해서 k8s 버전과 호환되는 버전으로 선택

    [supported-versions-table](https://github.com/kubernetes/ingress-nginx#supported-versions-table)
    ![supported-versions-table](image/supported-version-table.png)

2. 버전 지정하여 설치

    ```
    helm install ingress-nginx ingress-nginx/ingress-nginx --version <CHART_VERSION> -n ingress-nginx -f user-values.yaml
    ```


## 차트 버전 업그레이드
1. 위 1,2번과 같은 방식으로 k8s 버전과 호환성 확인
2. 차트 업그레이드

    ```
    helm upgrade -n ingress-nginx ingress-nginx ingress-nginx/ingress-nginx --version <CHART_VERSION>
    ```
> 기존 user value 값이 변하지 않도록 미리 추출해서 파일로 가지고 있던지, 혹은 유지하는 옵션 사용

## NGINX Configuration
Configmap으로 Ingress Nginx 세팅, (Helm Value로 세팅 가능)
- Configmap은 글로벌 설정, Annotation은 개별 설정이며 튜닝 가능한 옵션은 공식 문서 참조하여 구현

    https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/#nginx-configuration

- Configmap 설정

1. 설정내용

    - Configmap의 Namespace와 Name은 Controller와 같아야함
    
    - Helm value에서 Configmap 참조방식을 변경하지 않은 경우 기본값으로 다음과 같이 세팅됨
    - controller pod의 args를 보면 ```--configmap=$(POD_NAMESPACE)/<RELEASE>-controller``` 으로 지정되어 있고 컨트롤러 파드의 네임스페이스와 Helm 릴리즈이름을 참조하도록 세팅되어 있음

    [config/configmap.yaml](confing/config.yaml)

    ```
    apiVersion: v1
    data:
      proxy-connect-timeout: "10"
      proxy-read-timeout: "120"
      proxy-send-timeout: "120"
    kind: ConfigMap
    metadata:
      name: ingress-nginx-controller
      namespace: ingress-nginx
    ```


2. 확인
nginx reload 확인 및 컨테이너 내 설정값 까지 확인

    ```  
    k describe pod <POD_NAME> -n ingress-nginx
    Events:
    ...
    Normal   RELOAD             10m (x2 over 33m)  nginx-ingress-controller  NGINX reload triggered due to a change in configuration

    k exec -it -n ingress-nginx <POD_NAME> -- /bin/bash
    cat nginx.conf
    ...
    proxy_connect_timeout                   10s;
    proxy_send_timeout                      120s;
    proxy_read_timeout                      120s;
    ...
    ```
## NGINX Logging
NGINX Controller Pod의 STDOUT으로 확인 가능

- Log Format

    https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/log-format/

## NGINX TLS Termination
- TLS Termination

    https://kubernetes.github.io/ingress-nginx/user-guide/tls/

### Ref.
- Ingress Nginx Official Repo
  
  https://github.com/kubernetes/ingress-nginx

- AKS Docs
  
  https://learn.microsoft.com/ko-kr/azure/aks/ingress-basic?tabs=azure-cli

# External and Internal Ingress
### Goal

인그레스를 External (Public IP), Internal (Private IP) 용도로 분리하여 구성

### Env

1. AKS (k8s v1.26.6)
2. Ingress Nginx Chart 4.8.3 (nginx v1.9.4)

### Config

1. External Ingress
    
    ```
    # External Ingress Controller in AKS
    controller:
    service:
        annotations: 
        service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
    electionID: external-ingress-controller-leader
    ingressClassResource:
        name: nginx-external
        enabled: true
        default: false
        controllerValue: "k8s.io/external-ingress-nginx"
    ingressClass: nginx-external
    ```
2. Internal Ingress
    ```
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
### Install

    ```
    # helm install [NAME] [CHART] [flags]
    helm install ingress-nginx-[internal | external] ingress-nginx/ingress-nginx --version <CHART_VERSION> -n ingress-nginx -f [internal | external]-ingress-values.yaml
    ```