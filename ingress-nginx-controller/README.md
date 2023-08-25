# Ingress Nginx Controller
Helm을 사용한 Ingress Nginx Controller 설치, <br>
*주의: k8s 버전 업그레이드에 맞춰 Ingress Nginx 컨트롤러의 버전도 호환성을 체크하여 업그레이드 해주어야 한다.

## 설치 순서

1. Create Namespace

    ```
    k create ns ingress-nginx
    ```

2. Setup Helm repo

    ```
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    ```

3. Customize Values

    ```
    helm show values ingress-nginx/ingress-nginx > values.yaml

    cp values.yaml user-values.yaml

    # vi user-values.yaml
    controller:
      service:
        annotations: 
          service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz

    ```
4. Install Chart (To be Release)

    ```
    helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx -f user-values.yaml
    ```

5. Check installation

    ```
    # Check Installed chart (release)
    helm ls -n ingress-nginx

    # Check value (user values)
    helm get values ingress-nginx -n ingress-nginx
    ```

## 특정 버전 설치 or 업그레이드
### 특정 버전 설치 가이드

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


### 차트 버전 업그레이드
1. 위 1,2번과 같은 방식으로 k8s 버전과 호환성 확인
2. 차트 업그레이드

    ```
    helm upgrade -n ingress-nginx ingress-nginx ingress-nginx/ingress-nginx --version <CHART_VERSION>
    ```
> user value 값은 업그레이드 하더라도 변하지 않음

### 참고 문서
- Ingress Nginx Official Repo
  
  https://github.com/kubernetes/ingress-nginx

- AKS Docs
  
  https://learn.microsoft.com/ko-kr/azure/aks/ingress-basic?tabs=azure-cli