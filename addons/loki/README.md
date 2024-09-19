# Install Loki on k8s cluster

### Installation
- Cloud: Azure (AKS)
- Storage: Azure Blob Storage
- Loki (Simple Scalable)
- Promtail

### 참고
```markdown
# 테스트 설치 시
Install 커맨드에 --set loki.useTestSchem 설정

# Installed components:
* gateway
* read
* write
* backend
``` 

### Install Step
1. Create namespace

    ```
    k create ns loki
    ```

2. Add Repo

    ```
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update

    # 설치할 버전 확인
    helm search repo grafana/loki --versions | head
    ```

3. Configure Values

    ```
    helm show values grafana/loki > values.yaml

    ```

4. Install

    ```
    helm install <RELEASE_NAME> grafana/loki --values ./values/user-values.yaml -n monitoring --version <VERSION>
    ```
5. Install - Promtail

    ```
    helm install dev-promtail grafana/promtail -n monitoring
    ```
### Ref
- Loki github

    https://github.com/grafana/loki

- Install Guide

    https://grafana.com/docs/loki/latest/installation/helm/install-scalable/

- Install Guide on Azure

    https://observability-360.com/docs/ViewDocument?id=grafana-loki-on-azure