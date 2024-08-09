# Azure Application Gateway Ingress Controller

## Installation
[Install Docs](https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/setup/install.md)

## Tips

```markdown
# Readiness Probe
- AGW Health Probe == readinessProbe
    - Interval (seconds) == periodSeconds
    - Timeout (seconds) == timeoutSeconds

```