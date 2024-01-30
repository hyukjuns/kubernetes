# 프로메테우스
# Package (To Install)
- prometheus-community
	- kube-prometheus-stack
		- 프로메테우스의 기타 구성요소가 포함된 스택 - (prometheus-server, alertmanager, kube-state-metrics, node-exporter, pushgateway, promethues-rules, grafana)
		- prometheus-operator/kube-prometheus 깃헙리포를 기반으로 설치됨 -> https://github.com/prometheus-operator/kube-prometheus
		- Artifact Hub link: https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
	- prometheus
		- 프로메테우스 기본 스택만 설치 - (prometheus-server, alertmanager, kube-state-metrics, node-exporter, pushgateway)
		- prometheus/prometheus 깃헙 리포를 기반으로 설치됨 -> https://github.com/prometheus/prometheus
		- Artifact Hub link: https://artifacthub.io/packages/helm/prometheus-community/prometheus
- prometheus-community Chart Repo
	- Github link: https://github.com/prometheus-community/helm-charts