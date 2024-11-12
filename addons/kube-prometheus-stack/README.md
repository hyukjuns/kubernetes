# Kube Prometheus Stack
AKS 환경에 [kube-prometheus-stack](https://github.com/prometheus-operator/kube-prometheus) 헬름 차트 설치 및 관리
### TODO
- Install / Configuration / Alerting

### Prometheus Stack Component
- Prometheus Operator
- Prometheus Server
- Alertmanager
- Node-exporter
- State-Metric Server
- Grafana Server

### Installation

```bash
# Create Namespace & SC
k create ns NAMESPACE
k apply -f ./objects/sample-storageclass.yaml

# Add Helm Repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Get Default Chart Value & Make Custom Values
helm show values prometheus-community/kube-prometheus-stack > values.yaml

# Check Chart Version
helm search repo prometheus-community/kube-prometheus-stack --versions | head

# Install Helm Chart
helm install RELEASE prometheus-community/kube-prometheus-stack -f VALUEFILE -n NAMESPACE --version VERSION

# Upgrade or Install Helm Chart
helm upgrade --install RELEASE prometheus-community/kube-prometheus-stack -f VALUEFILE -n NAMESPACE --version VERSION
```

### Configuration

#### Prometheus Configuration

> Prometheus는 Config Reloader 컨테이너를 사이드카로서 사용함, Prometheus Server는 Config Reloader 컨테이너와 EmptyDir 볼륨을 통해 설정파일을 공유하고 있음, EmptyDir 볼륨의 마운트 경로는 /etc/prometheus/config_out

- prometheus.yaml 생성 과정


  1. Defined default configuration by Helm
  2. Create in Secret Object
    
      - Zipped File: prometheus.yaml.gz
  
  3. Mounted and Unzipped in Config Reloader Container
      - Secret Mount Path: /etc/prometheus/config/prometheus.yaml.gz
      - Unzipped Path: /etc/prometheus/config_out/prometheus.env.yaml
  
  4. Shared and used by prometheus server Container
  
      - Empty Dir Mount Path: /etc/prometheus/config_out/prometheus.env.yaml

- prometheus.yaml 샘플
```yaml
# 전역설정
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s

# 별도 Rule 파일 경로
rule_files:
  - 'prometheus.rules.yml'
  - /etc/prometheus/rules/prometheus-prometheus-kube-prometheus-prometheus-rulefiles-0/*.yaml

# Alertmanager 설정
alerting:
  alert_relabel_configs:
  alertmanagers:

# Job 단위로 서비스 디스커버리
scrape_configs:
  # 개별 수집 항목 (job은 레이블, `job=<job_name>`)
  - job_name: 'prometheus'
      # 스크랩 주기
      scrape_interval: 5s
      # 라벨 재정의
      relabel_configs:
      - source_labels: [job]
        separator: ;
        target_label: __tmp_prometheus_job_name
        replacement: $1
        action: replace
      # 쿠버네티스 서비스 디스커버리 설정
      kubernetes_sd_configs:
      - role: endpoints
        kubeconfig_file: ""
        follow_redirects: true
        enable_http2: true
        namespaces:
          own_namespace: false
          names:
          - monitoring
      # 정적 타겟 설정 (label로 그룹화 가능)
      static_configs:
      - targets: ['localhost:8080', 'localhost:8081']
          labels:
            group: 'production'
      - targets: ['localhost:8082']
          labels:
            group: 'canary'
```

#### Prometheus Rules (Record Rule, Alert Rule)

- Prometheus Rule 파일 생성 과정

  1. Defined default configuration by Helm
  2. Create in ConfigMap Object
    
      - Name: <RELEASE>-prometheus-kube-prometheus-prometheus-rulefiles-0
  
  3. Mount in prometheus server container 
    
      - mount path: /etc/prometheus/rules/<RELEASE>-prometheus-kube-prometheus-prometheus-rulefiles-0
  
- PrometheusRules (CRD) 로 Rule 추가 과정

  Prometheus Operator에 의해 Prometheus Server로 설정이 추가 업데이트 됨

  1. Create PrometheusRule CRD Object
  2. Detect by Prometheus Operator
  2. Update in ConfigMap
    
      - Name: <RELEASE>-prometheus-kube-prometheus-prometheus-rulefiles-0
  
  3. Reconciled in Prometheus Server (Rule Files are Mounted by Volume)

- Rule File 샘플
```yaml
# Record Rule
groups:
  - name: example
    rules:
    - record: code:prometheus_http_requests_total:sum
      expr: sum by (code) (prometheus_http_requests_total)

# Alert Rule
groups:
- name: example
  rules:
  - alert: HighRequestLatency
    expr: job:request_latency_seconds:mean5m{job="myjob"} > 0.5
    for: 10m
    # Alertmanager 로 경고가 전달 될 때, Label 도 함께 전달됨
    # 전달된 경고의 Label은 Alertmanager 설정 중 route.routes[].matchers 와 일치하는지 비교되며, 일치되는 route 경로의 Receiver로 알람이 처리됨
    labels:
      severity: page
    annotations:
      summary: High request latency
```

#### Prometheus Service Monitor
> ServiceMonitor <- Watch -> Prometheus Operator -> Update -> Prometheus Server

메트릭 수집 엔드포인트를 정의한 ServiceMonitor를 Prometheus Operator가 식별하여 Prometheus Server의 서비스 디스커버리 설정(job)을 업데이트 시킴

(세팅순서)
1. Helm Value Setting: 프로메테우스 오퍼레이터가 클러스터의 모든 ServiceMonitor를 별도 Label과 Namespace에 관계 없이 식별할 수 있도록 설정 (metadata.labels 설정 불필요 (release: "RELEASE"))

    ```yaml
    prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues = false
    prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues = false
    ```
    
2. Application 메트릭 노출 여부 확인
   
   Application의 메트릭 엔드포인트 존재 여부와 익스포터 필요 여부 확인 (Ex: nginx-prometheus-exporter)


3. Pod, Service, ServiceMonitor 오브젝트 생성
    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: external-workload-svc
    labels:
      app: external-workload # 서비스 모니터에서 Selector 설정에 사용됨
    spec:
      selector:
        app: external-workload
    ports:
    - name: web
      port: 8080
      targetPort: 80
    - name: metrics # 서비스 모니터에서 바라보는 엔드포인트, Endpoints 설정에 사용됨
      port: 9113
      targetPort: 9113
    ---
    apiVersion: monitoring.coreos.com/v1
    kind: ServiceMonitor
    metadata:
    name: external-workload
    labels:
      software: nginx
      release: prometheus # 프로메테우스 헬름 릴리즈 이름 (필요시)
    spec:
      selector:
        matchLabels:
          app: external-workload # Service Object의 Label
        endpoints:
        - port: metrics # Service Object의 Port Name

    ```
#### PromQL
```markdown
- Config Reload: ```kill -s SIGHUP <PID>```
- Shutdown: ```kill -s SIGTERM <PID>```
- Filter: METRIC{LABEL="VALUE"}
- Function: sum(METRIC)
- Time duration: METRIC[1m]
- Group by: avg by (LABEL) (METRIC) (ex: count by (service) (kubelet_node_name))
- 쿼리 실행시간이 길면 새로운 메트릭으로 만들어서 사용 가능
```

#### Alertmanager Configurations

- alertmanager.yaml

    - Resource: Secret -> Volume -> Pod
    - Default Path: /etc/alertmanager/config
    - 실행시 Flag Path: /etc/alertmanager/config_out
    - ShareVolume(EmptyDir) - config-reloader
        - path: /etc/alertmanager/config_out/alertmanager.env.yaml

- AlertmanagerConfig (CRD)

    - Direct Reconciled by Prometheus Operator (into alertmanager.yaml)

```yaml
global: # map, 글로벌 설정
route:
  receiver: # str, 디폴트 라우팅
  group_by: # list, 디폴트 그룹핑
  routes: # list, 개별 라우팅 설정
  - receiver: # str, 라우팅할 리시버 이름
    matchers: # list, 경고 레이블과 일치하는지 검사, matchers 의 모든 레이블이 경고의 레이블과 일치해야 유효
inhibit_rules: list, # 경고 억제 규칙
- source_matchers: # 아래 레이블이 있는 경고가 발생하면
  - severity="critical"
  target_matchers: # 아래 레이블이 있는 경고는 억제됨
  - severity=~"warning|info"
  equal: # 조건은 아래 레이블의 key: value가 같아야 함
  - namespace
  - alertname
receivers: # list, 각 리시버 설정 (슬랙,이메일 등)
templates: # list, 경고 템플릿 파일 위치 
```

#### AlertmanagerConfig (CRD)

- Alertmanager의 Global 설정
    
    글로벌 설정을 위한 AlertmanagerConfig는 Alertmanager와 같은 네임스페이스에 존재해야함, Alertmanager 스펙에서 alertmanagerConfiguration.name에 AlertmanagerConfig 이름 입력

- AlertmanagerConfig의 Namespace가 alertmanager 설정 중 route.routes.matchers에 label로 강제 등록되는것을 방지 (기본값: OnNamespace)

    ```yaml
    alertmanager:
        alertmanagerSpec:
          alertmanagerConfigMatcherStrategy:
            type: None
    ```
- Alertmanager의 alertmanagerConfigNamespaceSelector 항목으로 AlertmanagerConfig 선택 하도록 설정

    - 프로메테우스 오퍼레이터는 Namespace의 Label을 기준으로 AlertmanagerConfig 선택

- Alertmanager Config 경로 (컨테이너 파일시스템)

- /etc/alertmanager/config_out/alertmanager.env.yaml

- Alertmanager 구성파일 secret 내용 확인

    ```
    k get secret alertmanager-RELEASE-kube-prometheus-alertmanager -o jsonpath='{.data.alertmanager\.yaml}' | base64 -d
    ```

#### AlertManager Alert 구성 방법

- [By Prometheus Operator Config - AlertmanagerConfig(CRD)](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/alerting.md)

    - Helm Value 사용 보다 이점: 슬랙 토큰 같은 민감 정보를 Secret 오브젝트로 만들어서 참조하기 편함
    - 알람 기본 설정: AlertManager(CRD) -> AlertmanagerConfig(route/receivers)
    - 경고 조건 설정: Prometheus(CRD) -> PrometheusRule(Alert Condition)

    1. 슬랙 봇 토큰 및 API 정보 담은 Secret 생성 (AlertmanagerConfig과 같은 네임스페이스)
    2. AlertmanagerConfig Object 생성 -> 경고 채널 및 경고 라우팅 설정 (1에서 만든 시크릿 참조)

        - AlertManager.spec.alertmanagerConfigSelector 에 선언된 Label 작성 (모든 Label일 경우 생략)
        - Alertmanager Pod의 설정 파일에 설정됨 (인메모리, tmpfs)

    3. PromehteusRule Object 생성 -> 경고 조건 설정

        - Prometheus.ruleSelector 에 선언된 Label 작성(기본값: 'release: RELEASE', 모든 Label일 경우 생략)
        - Prometheus Rule 파일 경로에 추가됨 (인메모리, tmpfs)

- [By Alertmanager Native Config - Helm Value to Secret(alertmanager.yaml)](https://prometheus.io/docs/alerting/latest/configuration/)
    
    1. Helm Value 파일에 Slack 채널 추가

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

    2. PrometheusRule Object 생성 -> 경고 조건 등록
    


#### Stateful Setting - Retain 된 PV 재사용

    1. Retain 된 PV에 해당하는 Azure Managed Disk 식별
    2. Managed Disk 사용해서 PV 생성, diskName, diskURI 입력

        ```./objects/restore-prometheus-pv.yaml```

    3.  Prometheus Helm Values에서 PV 정보 입력 후 업그레이드/재배포

        ```prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.volumeName```


#### Ingress Nginx Controller 모니터링 환경 구성 (Service Monitor)

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

#### Uninstall Release

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

- [Awesome Prometheus alerts](https://samber.github.io/awesome-prometheus-alerts/)

- [Alertmanager Matcher Type Enforce Disable](https://github.com/prometheus-operator/prometheus-operator/issues/3737)

- [creating-awesome-alertmanager-templates-for-slack](https://hodovi.cc/blog/creating-awesome-alertmanager-templates-for-slack/)

- [Prometheus Operator API](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#monitoring.coreos.com/v1.AlertmanagerConfigMatcherStrategy)

- [Prometheus Operator User Guide](https://github.com/prometheus-operator/prometheus-operator/tree/main/Documentation/user-guides)

- [Prometheus Alert Runbook](https://runbooks.prometheus-operator.dev/)

- [prometheus-docs](https://prometheus.io/docs/introduction/overview/)

- [kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)

- [prometheus-community/helm-charts Github](https://github.com/prometheus-community/helm-charts/)

- [kube-prometheus-stack Github](https://github.com/prometheus-operator/kube-prometheus)

- [Prometheus Operator](https://prometheus-operator.dev/)

- [Grafana Helm Values](https://github.com/grafana/helm-charts/tree/main/charts/grafana)

- [Nginx Ingress Controller Dashabord](https://github.com/kubernetes/ingress-nginx/tree/main/deploy/grafana/dashboards)

- [Monitor Ingress NGINX Controller](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/monitoring.md#prometheus-and-grafana-installation-using-service-monitors)