# Kubernetes Practice

### Cluster
- AKS

### Addons
- Prometheus
- Loki
- Nginx Ingress Controller

## Helm
```markdown
# Update Release
helm upgrade [RELEASE] [CHART] [flags]
ex) helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack  -f ./values/user-values.yaml -n prometheus
ex) helm upgrade -n ingress-nginx ingress-nginx ingress-nginx/ingress-nginx --version <CHART_VERSION>
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
