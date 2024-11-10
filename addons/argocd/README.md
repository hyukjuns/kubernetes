# ArgoCD

### GitOps CI/CD Steps
1. CI - Github Actions
    1. Commit Code
    2. Code Test
    3. Build and Push Image to Container Registry
    4. Modify K8s Manifest (Plain YAML or Helm Chart Value)
2. CD - ArgoCD
    1. Detect change in source git repo
    2. Sync Application - Deployment Strategy (Blue/Green, Canary)

### Argo Rollouts
- Blue/Green
- Canary

### ArgoCD CLI
- Add External Cluster (Default: Internally, https://kubernetes.default.svc)
```
argocd cluster add docker-desktop
```
- Patch Service Type
```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
- Login
```
argocd admin initial-password -n argocd
argocd login <ARGOCD_SERVER>
```
- Create Sample App
```
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
```

```bash
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default
```

### Ref
- [ArgoCD Docs](https://argo-cd.readthedocs.io/en/stable/)
- [ArgoCD Docs - Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)