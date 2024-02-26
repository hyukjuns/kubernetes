# kube-prometheus-stack
helm 으로 Prometheus Stack 설치

## 사전 준비
1. Kubernetes Cluster: 1.25.x
2. kubectl: 1.26.x
2. Helm: 3.11.x

## Helm Chart (2024.01.31)
- [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
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

> Namespace 및 StorageClass 생성


  프로메테우스를 배포할 Namespace 및 메트릭 데이터 저장용 PV를 위한 StorageClass 생성

  - Namespace: `k create ns <NAMESPACE>`
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

## Ingress Nginx Controller 모니터링 환경 구성
Service Monitor를 활용한 구성 방법

> 전제조건

- 프로메테우스와 인그레스 컨트롤러는 서로 다른 네임스페이스에 존재
- 같은 네임스페이스인 경우 Ingress Controller의 Pod Annotation으로 모니터링 구성해야하며, 서비스 모니터 방식과 혼용해서는 안됨
- Ingress Object는 Wild Card Host를 사용해서는 안되면 개별 Host를 사용해야함
- Wild Card Host 사용하고자 할 경우 인그레스 컨트롤러는 `--metrics-per-host=false` 플래그를 사용해야함

### 구성 방법
[Prometheus and Grafana installation using Service Monitors](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/monitoring.md#prometheus-and-grafana-installation-using-service-monitors)

> 사전 준비
- 서로 다른 네임스페이스에 Ingress Controller와 Prometheus가 설치 완료된 클러스터 환경
> 구성 절차
1. Ingress-Nginx Controller Value 재구성

    - helm values에서 아래 항목 값 추가
    - controller.metrics.serviceMonitor.additionalLabels.release="prometheus"는 kube-prometheus-stack의 helm 릴리스 이름과 일치해야 함.

        ```yaml
        controller.metrics.enabled=true
        controller.metrics.serviceMonitor.enabled=true
        controller.metrics.serviceMonitor.additionalLabels.release="prometheus"
        ```
        > helm value file
        ```yaml
        controller:
          metrics:
            enabled: true
            serviceMonitor:
              enabled: true
              additionalLabels:
                release: prometheus
        ```

2. 인그레스 컨트롤러 차트 업그레이드

    ```bash
    helm upgrade -n NAMESPACE RELEASE CHART -f VALUEFILE --version VERSION
    ```

3. 프로메테우스 재구성

    - 프로메테우스 서버는 인그레스 컨트롤러와 다른 네임스페이스에 존재하므로, 서비스 모니터를 통해서 서비스 디스커버리가 수행됨. 따라서 아래 Value를 False로 세팅해아함

    - 프로메테우스 서버는 기본적으로 같은 네임스페이스 내 PodMonitor만 검색하므로 아래 Value를 False로 세팅해야함.

        > 원문: Since Prometheus is running in a different namespace and not in the ingress-nginx namespace, it would not be able to discover ServiceMonitors in other namespaces when installed. Reconfigure your kube-prometheus-stack Helm installation to set serviceMonitorSelectorNilUsesHelmValues flag to false. By default, Prometheus only discovers PodMonitors within its own namespace. This should be disabled by setting podMonitorSelectorNilUsesHelmValues to false
        ```yaml
        prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false
        prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
        ```
        > helm value file
        ```yaml
        prometheus:
          prometheusSpec:
            podMonitorSelectorNilUsesHelmValues: false
            serviceMonitorSelectorNilUsesHelmValues: false
        ```

4. 프로메테우스 차트 업그레이드

    ```bash
    helm upgrade -n NAMESPACE RELEASE CHART -f VALUEFILE --version VERSION
    ```

### 참고 자료
- [kube-prometheus-stack ArtifactHub](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)

    - [prometheus-community/helm-charts Github](https://github.com/prometheus-community/helm-charts/)


    - [kube-prometheus-stack Github](https://github.com/prometheus-operator/kube-prometheus)

- [Prometheus Storage Resize](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md)

- [Prometheus and Grafana installation using Service Monitors](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/monitoring.md#prometheus-and-grafana-installation-using-service-monitors)

### k8s 모니터링 컴포넌트
- 프로메테우스가 참조하는 컴포넌트 /metrics 스크랩핑

    [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics/tree/main)