# kube-prometheus-stack
kube-prometheus-stack 설치 및 관리

## Docs and Repos

- [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)

- [prometheus-community/helm-charts Github](https://github.com/prometheus-community/helm-charts/)

- [kube-prometheus-stack Github](https://github.com/prometheus-operator/kube-prometheus)

- [Prometheus Operator](https://prometheus-operator.dev/)

## Stack Component
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

    # Check Chart Version
    helm search repo prometheus-community/kube-prometheus-stack --versions | head
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
    # helm install <RELEASE_NAME> <CHART_NAME> --version <CHART_VERSION> -f <VALUE_FILE> -n <NAMESPACE>
    helm install nhj-kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 61.9.0 -f ./values/user-values.yaml -n monitoring
    ```


5. Verify

    ```bash
    kubectl get all -n monitoring
    ```

## Ingress Nginx Controller 모니터링 환경 구성 (Service Monitor)

### 구성 방법
[Prometheus and Grafana installation using Service Monitors](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/monitoring.md#prometheus-and-grafana-installation-using-service-monitors)

### 1. Ingress Nginx Controller Side
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
### 2. kuber-prometheus-stack Side
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