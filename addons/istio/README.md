# Istio

```yaml
# Install Istiod
# inject envoy sidecar specific namespace
kubectl label namespace default istio-injection=enabled

```

# kiali operator
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