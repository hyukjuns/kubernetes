# Azure Application Gateway Ingress Controller
AKS 환경에 [Azure Application Gateway](https://learn.microsoft.com/ko-kr/azure/application-gateway/ingress-controller-overview)를 사용한 Ingress Controller 설치 및 관리
### Installation
[Install Docs](https://github.com/Azure/application-gateway-kubernetes-ingress/blob/master/docs/setup/install.md)

### Operation

```markdown
# Readiness Probe
- AGW Health Probe == readinessProbe
    - Interval (seconds) == periodSeconds
    - Timeout (seconds) == timeoutSeconds
```

### Reference

- https://learn.microsoft.com/ko-kr/azure/application-gateway/ingress-controller-overview