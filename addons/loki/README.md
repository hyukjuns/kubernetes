# Loki on AKS

### Environments
- Cluster: AKS Cluster
- Storage: Azure Blob Storage
- Loki Mode: Simple Scalable
- Log Aggregator: oTel collector

### Installation - Loki
1. Create namespace

    ```
    k create ns loki
    ```

2. Add Repo

    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update

    # Check Version to install
    helm search repo grafana/loki --versions | head
    ```

3. Configure Values

    ```bash
    # Get default Values
    helm show values grafana/loki > values.yaml

    # Set up values in values/azure-values.yaml
    loki.storage_config.azure.account_name
    loki.storage_config.azure.account_key
    ```

4. Install chart

    ```
    helm install RELEASE grafana/loki --values ./values/azure-values.yaml -n loki --version VERSION
    ```

### Installation - oTel Collector

### Ref
- [Loki github](https://github.com/grafana/loki)

- [Install Guide Docs](https://grafana.com/docs/loki/latest/installation/helm/install-scalable/)


- [Install Guide Medium (Azure Specified)](https://observability-360.com/docs/ViewDocument?id=grafana-loki-on-azure)
