# Kubernetes by Terraform
### Kubernetes Cluster
AKS Cluster

### 필수 Applications
1. Cluster Autoscaler
    1. 노드 자동 확장
2. Nginx Ingress Controller
    1. ingress
3. Metric Server
    1. k top
4. Monitoring
    1. Prometheus,Alert Manager, Grafana
5. Logging
    1. EFK Stack
        1. Elasticsearch,Fluentd Kibana
6. ArgoCD, Jenkins
    1. CI/CD 배포툴
7. Network Plugin/Policy
    1. calico
8. Image Registry
    1. ACR or 3rd party Private Registry
9. etc

### Tool

- k8s(AKS)
- Helm
- Terraform
    - provider
        - azurerm
        - k8s
        - helm