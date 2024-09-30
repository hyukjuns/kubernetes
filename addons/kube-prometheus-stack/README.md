# kube-prometheus-stack
kube-prometheus-stack 설치 및 관리

## Custom Point
- Prometheus의 PV 회수정책 변경 (StorageClass 커스텀)
- Grafana를 StatefulSet으로 배포하도록 세팅 (대시보드 저장)
- 각 컴포넌트의 Resource Request/Limit 지정 (OOM 방지)
- NGINX Ingress Controller에 대한 모니터링 설정 (ServiceMonitor)

## Prom Stack Component
- Prometheus Operator
- Prometheus Server
- Alertmanager
- Node-exporter
- State-Metric Server
- Grafana Server

## Installation

1. Create Namespace & Storage Class
    
    ```bash
    k create ns monitoring
    k apply -f ./objects/storageclass.yaml
    ```

2. Add Helm Repo

    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    ```

3. Setting Helm Value

    ```bash
    # Get Default Value
    helm show values prometheus-community/kube-prometheus-stack > values.yaml

    # Create User Value File
    vi ./values/user-values.yaml
    ...
    ```

4. Install Helm Chart

    ```bash
    # Check Chart Version
    helm search repo prometheus-community/kube-prometheus-stack --versions | head

    # Install Helm Chart
    helm install RELEASE prometheus-community/kube-prometheus-stack --version VERSION -f ./values/user-values.yaml -n monitoring
    ```

5. Verify

    ```bash
    kubectl get all -n monitoring
    ```
## Operation
- Retain 된 PV 재사용

    1. Retain 된 PV에 해당하는 Azure Managed Disk 식별
    2. Managed Disk 사용해서 PV 생성, diskName, diskURI 입력

        ```./objects/restore-prometheus-pv.yaml```

    3.  Prometheus Helm Values에서 PV 정보 입력 후 업그레이드/재배포

        ```prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.volumeName```


## Ingress Nginx Controller 모니터링 환경 구성 (Service Monitor)

### 1. kuber-prometheus-stack Side
1. kuber-prometheus-stack Helm Value 구성

    ```yaml
    prometheus:
      prometheusSpec:
        podMonitorSelectorNilUsesHelmValues: false
        serviceMonitorSelectorNilUsesHelmValues: false
    ```

2. 프로메테우스 차트 업그레이드

    ```bash
    helm upgrade -n NAMESPACE RELEASE CHART -f VALUEFILE --version VERSION
    ```

### 2. Ingress Nginx Controller Side
1. Ingress-Nginx Controller Helm Values 구성
    ```yaml
    controller:
        metrics:
        enabled: true
        serviceMonitor:
            enabled: true
            additionalLabels:
            release: prometheus # kuber-prometheus-stack's Release Name
    ```

2. 인그레스 컨트롤러 차트 업그레이드

    ```bash
    helm upgrade -n NAMESPACE RELEASE CHART -f VALUEFILE --version VERSION
    ```

### Nginx Ingress Controller Grafana Official Dashabord
- NGINX Ingress controller: 9614
- Ingress Nginx / Request Handling Performance: 20510
- Request Handling Performance: 12680

---
## Docs and Official Repos

- [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)

- [prometheus-community/helm-charts Github](https://github.com/prometheus-community/helm-charts/)

- [kube-prometheus-stack Github](https://github.com/prometheus-operator/kube-prometheus)

- [Prometheus Operator](https://prometheus-operator.dev/)

- [Grafana Helm Values](https://github.com/grafana/helm-charts/tree/main/charts/grafana)

- [Nginx Ingress Controller Dashabord](https://github.com/kubernetes/ingress-nginx/tree/main/deploy/grafana/dashboards)

- [Prometheus and Grafana installation using Service Monitors](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/monitoring.md#prometheus-and-grafana-installation-using-service-monitors)