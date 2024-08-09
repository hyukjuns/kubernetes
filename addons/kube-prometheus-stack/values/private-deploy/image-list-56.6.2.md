# kube-prometheus-stack container image version
### import to acr
`az acr import -n ACRNAME --source SOURCEIMAGE`

`devaksacr001.azurecr.io`

### grafana / grafana-sidecar
    - docker.io/grafana/grafana:10.3.1
    - quay.io/kiwigrid/k8s-sidecar:1.24.6


### alertmanager: 
    - quay.io/prometheus/alertmanager:v0.26.0


### prometheus-operator
    - quay.io/prometheus-operator/prometheus-operator:v0.71.2
    - quay.io/prometheus-operator/prometheus-config-reloader:v0.71.2


### prometheus
    - quay.io/prometheus/prometheus:v2.49.1

### nodeExporter
    - quay.io/prometheus/node-exporter:v1.7.0


### kube-state-metric
    - registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.10.1