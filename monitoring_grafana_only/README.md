# Grafana Helm Chart
Installs the web dashboarding system Grafana
# Get Repo Info
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
See helm repo for command documentation.

# Installing the Chart
To install the chart with the release name my-release:
```
helm install my-release grafana/grafana
```
# Uninstalling the Chart
To uninstall/delete the my-release deployment:
```
helm delete my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release.