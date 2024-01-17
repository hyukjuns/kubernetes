# Kubernetes Practice

### Cluster
- AKS

### Addons
- Prometheus
- Loki
- Nginx Ingress Controller

## Helm
```
# Add Repo
helm repo add <REPO_NAME> <REPO_ADDRESS>
helm repo update

# List repo
helm repo ls

# List charts in repo list
helm search repo <KEYWORD>

# Check Chart Version
helm search repo <CHART_NAME(KEYWORD)> --versions

# Show Chart Value
helm show values <CHART_NAME>

# Install Chart
helm install <RELEASE_NAME> <CHART> -n <NAMESPACE> -f <VALUEFILE>

# Uninstall Chart
helm uninstall <RELEASE_NAME> -n <NAMESPACE>

```
