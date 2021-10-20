# Nginx-Ingress-Controller 설치 가이드
### nginx-ingress-controller
- kubernetes maintained 공식 Helm Chart 사용
    - https://kubernetes.github.io/ingress-nginx        
### 사전 준비
- Kubernetes v1.16+
- Helm 3.x
### 설치
0. Namespace 생성
    ```
    kubectl create ns ingress
    ```
1. Repo 추가
    ```
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    ```
2. Chart의 values확인 및 편집
    ```
    helm show values ingress-nginx/ingress-nginx > values.yml
    ```
3. Chart 설치
    ```
    helm install [RELEASE_NAME] ingress-nginx/ingress-nginx -f values.yml -n ingress
    ```
4. TLS 사용 설정
    ```
    ```
---
### 참고 문서
- [kubernetes maintained 인그레스 공식 helm chart repo](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx)
- [kubernetes maintained 인그레스 공식 문서, 홈페이지](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm)
- [Azure Ingress Controller 공식 문서](https://docs.microsoft.com/en-us/azure/aks/ingress-basic)
- [Kubernetes Ingress Controller 공식 문서](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)