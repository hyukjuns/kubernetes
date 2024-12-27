# Argo CD & Argo Rollouts

## ArgoCD Helm Chart
- [chart Site](https://argoproj.github.io/argo-helm)
- [chart Github Repo](https://github.com/argoproj/argo-helm/tree/main)
## Argo CD / Argo Rollout Repo
- [ArgoCD](https://github.com/argoproj/argo-cd)
- [ArgoRollouts](https://github.com/argoproj/argo-rollouts/tree/master)

## Installation
```bash
# Add Repo
helm repo add argo https://argoproj.github.io/argo-helm

# Argo CD
helm install REALEASE argo/argo-cd -f user-values.yaml -n NAMESPACE

# Argo Rollouts
helm install REALEASE argo/argo-rollouts -f user-values.yaml -n NAMESPACE
```
## Installation - plugin
```
# Rollouts kubectl plugin
brew install argoproj/tap/kubectl-argo-rollouts
```
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