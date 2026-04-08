# AKS OIDC Federation Credential - Workload Identity
- Official Docs: https://learn.microsoft.com/ko-kr/azure/aks/workload-identity-overview?tabs=dotnet

### 구성 절차

1. AKS 리소스 에서  OIDC Issuer 및 Workload ID 활성화
    
    ```bash
    # Update
    az aks update --resource-group "${RESOURCE_GROUP}" --name "${CLUSTER_NAME}" --enable-oidc-issuer --enable-workload-identity
    
    # Issuer URL 확인
    export AKS_OIDC_ISSUER="$(az aks show --name "${CLUSTER_NAME}" --resource-group "${RESOURCE_GROUP}" --query "oidcIssuerProfile.issuerUrl" --output tsv)"
    ```
    
2. User Managed Identity 생성
    
    ```bash
    export SUBSCRIPTION="$(az account show --query id --output tsv)"
    export USER_ASSIGNED_IDENTITY_NAME="myIdentity$RANDOM_ID"

    az identity create --name "${USER_ASSIGNED_IDENTITY_NAME}" --resource-group "${RESOURCE_GROUP}" --location "${LOCATION}" --subscription "${SUBSCRIPTION}"
    ```
    
3. Service Account 생성 - azure.workload.identity/client-id: 주석 사용 (annotations)
    
    ```yaml
    export SERVICE_ACCOUNT_NAME="workload-identity-sa$RANDOM_ID"
    export SERVICE_ACCOUNT_NAMESPACE="default"
    
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      annotations:
        azure.workload.identity/client-id: "${USER_ASSIGNED_CLIENT_ID}"
      name: "${SERVICE_ACCOUNT_NAME}"
      namespace: "${SERVICE_ACCOUNT_NAMESPACE}"
    ```
    
4. 생성된 UMI를 사용하여 Federation Credential 생성 (AKS OIDC Issuer URL 및 Service Account 정보 사용)
    
    ```bash
    export FEDERATED_IDENTITY_CREDENTIAL_NAME="myFedIdentity$RANDOM_ID"

    az identity federated-credential create --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} \
    --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --issuer "${AKS_OIDC_ISSUER}" \
    --subject system:serviceaccount:"${SERVICE_ACCOUNT_NAMESPACE}":"${SERVICE_ACCOUNT_NAME}" \
    --audience api://AzureADTokenExchange
    ```
    
5. 접근이 필요한 리소스 대상으로 UMI에 권한 할당 (KV, Storage 등)
6. 워크로드 파드 생성시 Service Account 주입 및 Label 로 Workload Identity 사용 선언
    
    ```yaml
    # Example
    apiVersion: v1
    kind: Pod
    metadata:
        name: sample-workload-identity-key-vault
        namespace: ${SERVICE_ACCOUNT_NAMESPACE}
        labels:
            azure.workload.identity/use: "true"
    spec:
        serviceAccountName: ${SERVICE_ACCOUNT_NAME}
        containers:
          - image: ghcr.io/azure/azure-workload-identity/msal-go
            name: oidc
            env:
              - name: KEYVAULT_URL
                value: ${KEYVAULT_URL}
              - name: SECRET_NAME
                value: ${KEYVAULT_SECRET_NAME}
        nodeSelector:
            kubernetes.io/os: linux
    ```
    

### 인증과정

1. Service Account는 자신의 토큰으로 Azure EntraID에 인증 요청 
    1. 토큰은 Federation Credential 정보로 생성됨
2. EntraID는 토큰의 Federation Credential 정보를 바탕으로 승인/거절
    1. AKS 가 발행한 토큰 이므로 EntraID는 해당 토큰을 신뢰 (AKS의 Issuer URL 기반 토큰)
    2. Federation Credential에는 Issuer항목에 AKS OIDC Issuer URL 정보, Subject 항목에 SA 정보가 등록됨
    3. 아래 정보를 바탕으로 신뢰 여부를 결정함
        - **Issuer (`iss`)**: AKS OIDC Issuer URL
        - **Subject (`sub`)**: `system:serviceaccount:<namespace>:<sa-name>`
        - **Audience (`aud`)**: `api://<AAD_APP_CLIENT_ID>`
3. EntraID는 Azure에 접근할 수 있는 Azure Access 토큰을 Service Account에게 제공
4. Service Account는 EntraID로 부터 발급받은 Azure Access 토큰을 사용해서 Azure 리소스에 접근

### 토큰 정보 확인

1. SA를 주입한 Pod 생성
2. 명령실행
    
    ```yaml
    # READ Token in pod
    TOKEN=$(k exec sa-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    
    # Header
    echo $TOKEN | cut -d "." -f1 | base64 -d 2>/dev/null | jq .
    
    # Payload
    echo $TOKEN | cut -d "." -f2 | base64 -d 2>/dev/null | jq .
    ```