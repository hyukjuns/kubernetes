# Kubernetes & Azure Kubernetes Service

## Workspace Setting
```bash
# shell setting
source <(kubectl completion zsh)
alias k=kubectl
compdef __start_kubectl k

# vim setting
vi ~/.vimrc
set et
set ts=2
set sw=2
set nu
```

## Addon
- [ingress-nginx-controller](./addons/ingress-nginx-controller/)

- [kube-prometheus-stack](./addons/kube-prometheus-stack/)

- [loki](./addons/loki/)

- [API Call by Pod](./document/APICALL.md)

##  Useful Tools
- [df-pv](https://github.com/yashbhutwala/kubectl-df-pv)

## Cheatsheet
```markdown
# ctr, crictl
# ctr = containerd와 통신
# crictl = ctr과 유사하게 컨테이너를 조회할 수 있지만 containerd 만을 위한 통신은 아니며, k8s 오브젝트인 pod를 조회하거나 생성할 수도 있다
ctr ns list # ctr로 구성되어 있는 네임스페이스 조회
ctr -n k8s.io container list # 컨테이너 목록 조회
crictl pods # 노드에서 실행중인 파드 조회
crictl ps # 노드에서 실행중인 컨테이너 조회
crictl inspect <CONTAINERID> # 컨테이너 스펙 조회

# Busybox running
k run --rm -it tester --image=busybox
# Curl to Wget, -q: 로깅 x, -O-: 다운로드 파일을 stdout으로 리다이렉팅하여 출력
wget -q -O- [URL]
# 외부에서 커맨드 전달 시 예시
k exec tester -- wget -q -O- [URL] 

# AKS Nodepool Taints
az aks nodepool update \
-g RGNAME \
--cluster-name CLUSTERNAME \
-n NODEPOOLNAME \
--node-taints "CriticalAddonsOnly=true:NoSchedule"

# QoS에 따른 Node Request Sum 반영 여부
- BestEffort -> 반영 X
- Burstable -> 반영 O
- Guaranteed -> 반영 O

# Headless Service - Call Specific Pod
POD-HOSTNAME.HEADLESS-SVCNAME
POD-HOSTNAME.HEADLESS-SVCNAME.NAMESPACE
ex) mysql-sts-0.mysql-headless-svc.db

# Pod Schedule 시 노드 선정 기준 (기본동작)
스케쥴러는 Node의 Requests Sum을 기준으로 Pod가 할당 가능한지 확인, 
가능하지 않다면, Pod를 배치할 노드가 없기 때문에 Pending 상태가 지속됨, 
따라서 클러스터내 노드들의 Requests Sum을 미리 파악해서 신규 배포시 스케쥴 가능한지 미리 파악 필요

# topologySpreadConstraints 조건 위반되더라도 Schedule 보장 효과
whenUnsatisfiable: ScheduleAnyway

# Use Blob PV (Enable BLOB CSI)
az aks update -n CLUSTER -g RG --enable-blob-driver
k create storageclass
[LINL->](./objects/001-aks-pv-blob)

# ServiceAccount in Pod → Pod direct Call to APIServer
[LINK->](./APICALL.md)

# Docker Image Build for AKS Node
docker build --platform linux/amd64 -t IMAGE:TAG

# Ingegration Azure Entra ID, Using k8s RBAC
# Install
brew install Azure/kubelogin/kubelogin

# Login to use kubectl by kubeconfig
az account set --subscription SUBID
az aks get-credentials -g RG -n CLUSTER
kubelogin convert-kubeconfig -l azurecli

# AKS Node Scale-In (by Manual)
1. AKS AutoScaleMode: Auto -> Manual
2. Cordon Node (All Target Node)
3. Drain Node
4. Delete Node
5. Azure > RG > MC_xxx > VMSS (AKS's NodePool) > Delete Instance (Drained Node)

# Helm Cheat Sheet
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