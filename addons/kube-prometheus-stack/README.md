# Kube Prometheus Stack
AKS 환경에 [kube-prometheus-stack](https://github.com/prometheus-operator/kube-prometheus) 헬름 차트 설치 및 관리

### Alert List
- Cluster Level

- Node Level

- Pod Level

- 컨테이너 재시작
- CPU/Mem 부하
- 스케일링 (노드/파드)
- 네임스페잉스별 알람 체계
- 스케쥴링 실패

### Config
- Config Reload: ```kill -s SIGHUP <PID>```
- Shutdown: ```kill -s SIGTERM <PID>```
- Filter: METRIC{LABEL="VALUE"}
- Function: sum(METRIC)
- Time duration: METRIC[1m]
- Group by: avg by (LABEL) (METRIC) (ex: count by (service) (kubelet_node_name))
- 쿼리 실행시간이 길면 새로운 메트릭으로 만들어서 사용 가능

    >Example

    - prometheus.rules.yml
        ```
        groups:
        - name: cpu-node
        rules:
        - record: job_instance_mode:node_cpu_seconds:avg_rate5m
            expr: avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
        ```
    - prometheus.yml
        ```
        rule_files:
        - 'prometheus.rules.yml'
        ```
### Custom Values
- Prometheus의 PV 회수정책 변경 (StorageClass 커스텀)
- Grafana를 StatefulSet으로 배포하도록 세팅 (대시보드 저장)
- 각 컴포넌트의 Resource Request/Limit 지정 (OOM 방지)
- NGINX Ingress Controller에 대한 모니터링 설정 (ServiceMonitor)
- Grafana / Prometheus에 Ingress 연결

### Prom Stack Component
- Prometheus Operator
- Prometheus Server
- Alertmanager
- Node-exporter
- State-Metric Server
- Grafana Server

### Installation

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

    # Upgrade or Install Helm Chart
    helm upgrade --install -n NAMESPACE RELEASE prometheus-community/kube-prometheus-stack -f VALUEFILE --version VERSION
    ```

5. Verify

    ```bash
    kubectl get all -n monitoring
    ```
### Operation
- Alert Manager로 알람 생성

    - Slack 채널 추가

        ```yaml
        alertmanager:
          config:
            route:
              receiver: 'slack-notification' # receiver 이름
            receivers:
            - name: 'null' # default watchdog 경고 에서 사용
            - name: 'slack-notification' # receiver 이름
              slack_configs:
                - channel: '#alert-test' # 슬랙 채널 이름
                  send_resolved: true
                  api_url: https://slack.com/api/chat.postMessage # 슬랙 API 엔드포인트
                  http_config:
                    authorization:
                      type: Bearer 
                      credentials: 'BOT_TOKEN' # 슬랫 봇 토큰
        ```

- ServiceMonitor

    1. 동작방식

        - ServiceMonitor <- Watch -> Prometheus Operator -> Update -> Prometheus

    1. 프로메테우스가 클러스터 내 모든 Service Monitor를 식별할 수 있도록 설정

        - 아래 설정을 하게 되면 service monitor selector 설정을 하지 않아도 모든 service monitor 식별 가능 (ServiceMonitor의 metadata.labels 설정 불필요 (release: "RELEASE"))

        ```
        prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues = false
        prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues = false
        ```
    
    2. Application, Pod, Service 구성
        
        - Application이 자신의 메트릭을 수집할 수 있도록 엔드포인트를 제공하는지 확인 
            
            - nginx application의 경우 stub_status 설정을 On 하면 메트릭 노출되며, nginx-prometheus-exporter application을 통해 프로메테우스 시계열 데이터로 변환해서 노출시킴
    
        - Pod에서 메트릭 노출 엔드포인트 포트를 설정 하고 Service에서 이를 특정 포트로 메트릭 노출


    3. Service Monitor 세팅 및 배포

        - 수집할 Service를 Label로 선택하고, Service에서 노출한 메트릭 수집 엔드포인트 포트를 설정
    
        ```yaml
        apiVersion: monitoring.coreos.com/v1
        kind: ServiceMonitor
        metadata:
          name: example-app
        labels:
          team: frontend
          release: prometheus # 프로메테우스 헬름 릴리즈 이름
        spec:
          selector:
              matchLabels:
                  app: example-app # Service Object의 Label
          endpoints:
          - port: web # Service Object의 Port Name

        ```


- Retain 된 PV 재사용

    1. Retain 된 PV에 해당하는 Azure Managed Disk 식별
    2. Managed Disk 사용해서 PV 생성, diskName, diskURI 입력

        ```./objects/restore-prometheus-pv.yaml```

    3.  Prometheus Helm Values에서 PV 정보 입력 후 업그레이드/재배포

        ```prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.volumeName```


- Ingress Nginx Controller 모니터링 환경 구성 (Service Monitor)

    1. kuber-prometheus-stack Side

        1. kuber-prometheus-stack Helm Value 설정 편집

            ```yaml
            prometheus:
                prometheusSpec:
                    podMonitorSelectorNilUsesHelmValues: false
                    serviceMonitorSelectorNilUsesHelmValues: false
            ```

        2. 프로메테우스 차트 업그레이드

            ```bash
            helm upgrade -n NAMESPACE RELEASE prometheus-community/kube-prometheus-stack -f VALUEFILE --version VERSION
            ```

    2. Ingress Nginx Controller Side

        1. Ingress-Nginx Controller Helm Values 설정 편집
            ```yaml
            controller:
                metrics:
                    enabled: true
                    serviceMonitor:
                        enabled: true
                        additionalLabels:
                            release: RELEASE # kuber-prometheus-stack's Release Name
            ```

        2. 인그레스 컨트롤러 차트 업그레이드

            ```bash
            helm upgrade -n NAMESPACE RELEASE CHART -f VALUEFILE --version VERSION
            ```

- Nginx Ingress Controller Grafana Official Dashabord

    - NGINX Ingress controller: 9614
    - Ingress Nginx / Request Handling Performance: 20510
    - Request Handling Performance: 12680

4- Configiguration Path

    - Prometheus: File Path (in prometheus server) (created by Custom Resource)

        - configfile: /etc/prometheus/config_out/prometheus.env.yaml
        - rulefile: /etc/prometheus/rules/prometheus-prom-stack-hyukjun-kube-pr-prometheus-rulefiles-0/*.yaml

    - Prometheus: 기본 Config

        ```
        # 전역설정
        global:
            scrape_interval:
        # 별도 Rule 파일 경로
        rule_files:
            - 'prometheus.rules.yml'
        # 개별 수집 설정
        scrape_configs:
            # 개별 수집 항목 (job은 레이블, `job=<job_name>`)
            - job_name: 'prometheus'
              scrape_interval: 5s
              # 타겟 설정 (label로 그룹화 가능)
              static_configs:
              - targets: ['localhost:8080', 'localhost:8081']
                  labels:
                    group: 'production'

              - targets: ['localhost:8082']
                  labels:
                    group: 'canary'
        ```

    - Prometheus: Rule 설정 (특정 쿼리를 메트릭 지표로 만들어서 수집 가능, 성능 향상)
        - prometheus.rules.yml

            ```
            groups:
            - name: cpu-node
              rules:
              - record: job_instance_mode:node_cpu_seconds:avg_rate5m
                expr: avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
            ```
    - Prometheus: Service Monitor
        k8s에서 메트릭 수집을 위한 프로메테우스 Rule 설정을 위한 객체, 즉 CRD로 프로메테우스 룰을 구성하는 용도

- Uninstall

    1. Uninstall Helm Release
    2. Delete crd manually
        ```bash
        kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
        kubectl delete crd alertmanagers.monitoring.coreos.com
        kubectl delete crd podmonitors.monitoring.coreos.com
        kubectl delete crd probes.monitoring.coreos.com
        kubectl delete crd prometheusagents.monitoring.coreos.com
        kubectl delete crd prometheuses.monitoring.coreos.com
        kubectl delete crd prometheusrules.monitoring.coreos.com
        kubectl delete crd scrapeconfigs.monitoring.coreos.com
        kubectl delete crd servicemonitors.monitoring.coreos.com
        kubectl delete crd thanosrulers.monitoring.coreos.com
        ```
    3. Delete Service in kube-system (for kubelet)

### Reference
- [Prometheus Alert Runbook](https://runbooks.prometheus-operator.dev/)

- [prometheus-docs](https://prometheus.io/docs/introduction/overview/)

- [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)

- [prometheus-community/helm-charts Github](https://github.com/prometheus-community/helm-charts/)

- [kube-prometheus-stack Github](https://github.com/prometheus-operator/kube-prometheus)

- [Prometheus Operator](https://prometheus-operator.dev/)

- [Grafana Helm Values](https://github.com/grafana/helm-charts/tree/main/charts/grafana)

- [Nginx Ingress Controller Dashabord](https://github.com/kubernetes/ingress-nginx/tree/main/deploy/grafana/dashboards)

- [Monitor Ingress NGINX Controller](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/monitoring.md#prometheus-and-grafana-installation-using-service-monitors)