# kube-prometheus-stack
helm을 사용한 prometheus, alertmanager, grafana 통합 설치

# 사전 준비
1. Kubernetes 1.16 버전 이상
2. Helm 3 버전 이상
3. [선택] monitoring 네임스페이스 생성
    ```bash
    kubectl create ns monitoring
    ```
# 설치 순서
1. Helm repo 추가
    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    ```
2. value 구성
- values.yml
    - Namespace 셋팅
    - Grafana admin password 셋팅
    - Grafana dashboard timezone 셋팅
    - Prometheus, Alert Manager가 사용할 PVC 셋팅
3. Chart 설치
    ```bash
    helm install [RELEASE_NAME] prometheus-community/kube-prometheus-stack -f values.yml
    ```
4. 확인
    - 배포 확인
    ```bash
    kubectl get all -n monitoring
    ```
    - Grafana 대시보드 확인
    ```bash
    kubectl port-forward <GRAFANA_POD_NAME> 3000
    ```
---
- Grafana admin 정보 조회
    ```bash
    kubectl get secret -n monitoring
    kubectl get secret <GRAFANA_SECRET_NAME> -o yaml -n monitoring
        apiVersion: v1
        data:
        admin-password: ZGthZ2gxLmRrYWdoMS4=
        admin-user: YWRtaW4=
        ...    
    echo "ZGthZ2gxLmRrYWdoMS4=" | base64 --decode
    dkagh1.dkagh1.
    echo "YWRtaW4=" | base64 --decode
    admin
    ```
---
### Trouble shoot
- node exporter crashlooback 이슈 발생 시
    - patch 사용
        ```
        kubectl patch ds <NODE_EXPORTER_DAEMONSET_NAME> --type "json" -p '[{"op": "remove", "path" : "/spec/template/spec/containers/0/volumeMounts/2/mountPropagation"}]'
        ```
    - value.yml 수정
        ```
        nodeExporter:
            hostRootfs: false
        ```
[kube-prometheus-stack](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack#configuration)