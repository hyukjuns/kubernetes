# Loki
AKS 환경에 [Loki](https://github.com/grafana/loki) 헬름 차트 설치 및 관리

### Environments
- Cluster: AKS Cluster
- Storage: Azure Blob Storage
- Loki Mode: Simple Scalable
- Log Aggregator: promtail

### Install Loki on Azure
1. Create blob container
    ```markdown
    # Blob Container Name == bucketNames in Value File
    bucketNames:
      chunks: "chunks-test"
      ruler: "ruler-test"
      admin: "admin-test"
    ```
2. Create Namespace

    ```
    k create ns loki
    ```

3. Add Repo

    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update

    # Check Version to install
    helm search repo grafana/loki --versions | head
    ```

4. Configure Values

    ```bash
    # Get default Values
    helm show values grafana/loki > values.yaml

    # Set up values in values/azure-values.yaml
    loki.storage_config.azure.account_name
    loki.storage_config.azure.account_key
    ```

5. Install chart

    ```
    helm install RELEASE grafana/loki --values ./values/loki-values.yaml -n loki --version VERSION
    ```

### Install Promtail Agent

1. Create Namespace

    ```
    k create ns promtail
    ```

2. Configure Value 

    ```
    config:
      # publish data to loki
      clients:
      - url: http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push
          tenant_id: 1
    ```

### LogQL Sample
```
# Find String
{"LABLE"="VALUE"} |="STRING" 

# STDOUT Format
{"LABLE"="VALUE"} |= `` 

# Log Format
{"LABLE"="VALUE"} |= `` | logfmt

# JSON Format
{"LABLE"="VALUE"} |= `` | json

# JSON Format and filter 
{"LABLE"="VALUE"} |= `` | json |spanid="5b5671aad21a81e3"
```
### Reference
- [Loki github](https://github.com/grafana/loki)

- [Install Guide Docs](https://grafana.com/docs/loki/latest/installation/helm/install-scalable/)

- [Install Guide Medium (Azure Specified)](https://observability-360.com/docs/ViewDocument?id=grafana-loki-on-azure)
