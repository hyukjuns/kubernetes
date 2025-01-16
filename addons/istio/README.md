# Istio

## Installation
- istioctl
- helm

## SideCar Injection
```yaml
# inject envoy sidecar specific namespace
kubectl label namespace default istio-injection=enabled
```

## Install kiali operator
- manifest
- helm
```
helm install \
    --set cr.create=true \
    --set cr.namespace=istio-system \
    --set cr.spec.auth.strategy="anonymous" \
    --namespace kiali-operator \
    --create-namespace \
    kiali-operator \
    kiali/kiali-operator
```

## Integration with Prometheus Stack (Prometheus Operator)
for Istio
1. Configure ServiceMonitor for istiod
2. Configure PodMonitor for istio Proxy or envoy sidecar

for kiali
1. Edit Configuration Kiali (config.yaml)
    Edit: configmap or manifest file
    ```
    external_services:
      prometheus:
        url: http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090
      grafana: 
        external_url: http://prometheus-grafana.monitoring.svc.cluster.local:80
        internal_url: http://prometheus-grafana.monitoring.svc.cluster.local:80
    ```