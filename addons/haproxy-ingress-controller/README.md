# HAProxy Ingress Controller
- Official Repo: https://github.com/haproxytech/kubernetes-ingress
- Official Chart Repo: https://github.com/haproxytech/helm-charts?tab=readme-ov-file
- Official Docs: https://www.haproxy.com/documentation/kubernetes-ingress/overview/

# Helm Chart Mirroring
```bash
# 차트 & 이미지 미러링
helm pull haproxytech/kubernetes-ingress --version 1.49.0
tar -xzf kubernetes-ingress-1.49.0.tgz

# 템플릿 렌더링 → 이미지 후보 추출
helm template tmp ./kubernetes-ingress > kubernetes-ingress-rendered.yaml
grep -R "image:" -n kubernetes-ingress-rendered.yaml | head
grep -R "repository:" -n kubernetes-ingress-rendered.yaml | head

# 컨테이너 이미지 미러링 to ACR
az acr import -n ACR_NAME --source docker.io/haproxytech/kubernetes-ingress:3.2.6 --image "mirror-haproxytech/kubernetes-ingress:3.2.6"

# Helm Chart 미러링 to ACR
helm registry login ACR_NAME.azurecr.io
helm package ./kubernetes-ingress

helm push kubernetes-ingress-1.49.0.tgz oci://ACR_NAME.azurecr.io/mirror-haproxytech-helmchart
```

# Deploy 1.49.0
```bash
helm install ingress-haproxy-hyukjun oci://ACR_NAME.azurecr.io/mirror-haproxytech-helmchart/kubernetes-ingress \
  --version "1.49.0" \
  --namespace haproxy-controller \
  -f user-values-1-49-0.yaml
```

# Update Helm Chart and Mirror (1.49.0 -> 1.49.1) - for readOnlyRootFilesystem
```bash
helm pull haproxytech/kubernetes-ingress --version 1.49.0
tar -xzf kubernetes-ingress-1.49.0.tgz

# 차트 수정
- templates/controller-deployment.yaml 수정
  - containers.securityContext.readOnlyRootFilesystem: {{ .Values.controller.readOnlyRootFilesystem | default false }} 추가
- Chart.yaml -> 버전 업데이트 (ex: 1.49.1)

# Helm Chart to ACR
helm registry login ACR_NAME.azurecr.io
helm package ./kubernetes-ingress # output: kubernetes-ingress-1.49.1.tgz
helm push kubernetes-ingress-1.49.1.tgz oci://ACR_NAME.azurecr.io/mirror-haproxytech-helmchart

```

# Upgrade to 1.49.1
```bash
cat <<EOF > extra-user-values.yaml
controller:
  readOnlyRootFilesystem: true
  extraVolumeMounts:
    - name: etc-haproxy
      mountPath: /etc/haproxy
    - name: var-state-haproxy
      mountPath: /var/state/haproxy
  extraVolumes:
    - name: etc-haproxy
      emptyDir: {}
    - name: var-state-haproxy
      emptyDir: {}
EOF

helm upgrade ingress-haproxy-hyukjun oci://ACR_NAME.azurecr.io/mirror-haproxytech-helmchart/kubernetes-ingress \
  --version "1.49.1" \
  -n haproxy-controller \
  -f extra-user-values.yaml \
  --reuse-values
```

# Install 1.49.1
```bash
helm install ingress-haproxy-hyukjun oci://ACR_NAME.azurecr.io/mirror-haproxytech-helmchart/kubernetes-ingress \
  --version "1.49.1" \
  --namespace haproxy-controller \
  -f user-values-1-49-1.yaml
```

