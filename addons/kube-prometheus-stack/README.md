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
1. Create namespace

    ```bash
    k create ns monitoring
    ```
2. Create StorageClass

    프로메테우스의 데이터 저장을 위한 Blob StorageClass

    [storageclass.yaml](storageclass.yaml)

3. Add Helm repo 

    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    # 확인
    helm search repo prometheus-community
    ```
4. Edit user value
    - k8s version, label, grafana timezone, pw, prometheus retention, volume
    ```bash
    # 참조할 value.yaml 생성
    helm show values prometheus-community/kube-prometheus-stack > values.yaml
    ```
    ```bash
    # 새로운 파일로 user value 커스텀
    # vi user-values.yaml
    ## Provide a k8s version to auto dashboard import script example: kubeTargetVersionOverride: 1.16.6
    kubeTargetVersionOverride: "1.26.6"

    ## Labels to apply to all resources
    commonLabels:
      mgmt: monitoring

    ## Timezone for the default dashboards and password
    grafana:
      defaultDashboardsTimezone: kst
      adminPassword: admin

    # prometheus volumes
    prometheus:
      prometheusSpec:
        ## How long to retain metrics
        retention:  14d
        ## Prometheus StorageSpec for persistent data
        storageSpec:
          volumeClaimTemplate:
            spec:
              storageClassName: azuredisk-ssdlrs # 앞에서 만든 StorageClass Name
              accessModes: ["ReadWriteOnce"]
              resources:
                requests:
                  storage: 10Gi
    ```
5. Install Chart
    ```bash
    helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack -f user-values.yaml -n monitoring
    ```
6. Grafana, Prometheus Service Open

    그라파나, 프로메테우스 외부 노출용 서비스

    [service.yaml](service.yaml)

7. 확인

    - 배포 확인

        ```bash
        kubectl get all -n monitoring
        ```
    - 서비스 접속

        - 그라파나
            
            ![grafana](image/nodes.png)        

        - 프로메테우스

            ![prometheus](image/prometheus.png)
### 사용된 소스
- 아티팩트 허브 kube-prometheus-stack

    https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack

    - 사용된 깃헙 리포 Prometheus Community Kubernetes Helm Charts
        
        https://github.com/prometheus-community/helm-charts/


    - 사용된 깃헙 리포 kube-prometheus

        https://github.com/prometheus-operator/kube-prometheus

- 프로메테우스 스토리지 참고

    https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md