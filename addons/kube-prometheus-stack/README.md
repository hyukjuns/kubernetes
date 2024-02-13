# kube-prometheus-stack
helm 으로 Prometheus Stack 설치

## 사전 준비
1. Kubernetes Cluster: 1.25.x
2. kubectl: 1.26.x
2. Helm: 3.11.x

## Helm Chart (2024.01.31)
- [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack){:target="_blank"}
    - Chart version: 56.2.1
    - App Version: v0.71.2

## Stack Component
- The Prometheus Operator
- Highly available Prometheus
- Highly available Alertmanager
- Prometheus node-exporter
- Prometheus Adapter for Kubernetes Metrics APIs
- kube-state-metrics
- Grafana

## 설치 순서

### 사전준비
1. Namespace 및 StorageClass 생성

    프로메테우스를 배포할 Namespace 및 메트릭 데이터 저장용 PV를 위한 StorageClass 생성

    - Namespace: ```k create ns <NAMESPACE>```
    - StorageClass: [utils/storageclass.yaml](utils/storage-class.yaml)

### Helm을 사용한 설치 순서
1. 클러스터에 Helm repo 추가

    ```bash
    # 클러스터에 리포 추가
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    # 차트 버전 확인
    helm search repo prometheus-community/kube-prometheus-stack --versions
    ```

2. 배포에 사용할 User Value 설정

    - User Value File: [values/user-values.yaml](values/user-values.yaml)

    ```bash
    # 기본 value 추출 후 분석
    helm show values prometheus-community/kube-prometheus-stack > values.yaml

    # User Value를 위한 파일 생성
    vi user-values.yaml
    ...
    ```

3. 클러스터에 Chart 설치

    ```bash
    # 클러스터에 Chart 설치
    helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack --version <CHART_VERSION> -f user-values.yaml -n <NAMESPACE>
    ```


4. 배포 확인

    ```bash
    kubectl get all -n <NAMESPACE>
    ```

### 참고 자료
- 아티팩트 허브 kube-prometheus-stack

    https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack

    - 사용된 깃헙 리포 Prometheus Community Kubernetes Helm Charts
        
        https://github.com/prometheus-community/helm-charts/


    - 사용된 깃헙 리포 kube-prometheus

        https://github.com/prometheus-operator/kube-prometheus

- 프로메테우스 스토리지 참고

    https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md