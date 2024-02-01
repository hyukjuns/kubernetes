### 사전 준비
aks managed identity는 노드의 리소스그룹과 노드의 vnet, nsg에 기여자 역할이 있어야 함

### 사용 방법
클러스터에 blob csi 설치 후 SC 및 PVC 생성하여 사용
    ```
    az aks update -n myAKSCluster -g myResourceGroup --enable-blob-driver
    ```
#### default storage class 사용
- reclaimPolicy: Delete
- pvc 삭제시 pv도 함께 삭제됨, 즉 azure blob container도 삭제됨

#### custom storage class 사용
- reclaimPolicy: Retain
- pvc 삭제해도 pv는 남아잇음, 즉, azure blob container는 남아있음(재사용 불가)

### Reclaim Policy
PVC가 삭제될 경우 남아있는 PV의 생명 주기를 결정함
1. Recycle: 기존 pv의 데이터를 모두 제거 한 후 Available 상태로 pv를 되돌려 놓음, 즉 초기화 후 사용 가능하도록 재구성함
2. Retain: pvc가 삭제되더라도, 기존 pv 데이터는 유지되지만, pvc로 다시 사용하지 못하는 Released 상태가 됨, 
    - 또한, 클라우드 프로바이더에 리소스로 존재하는 스토리지도 유지됨, pv object를 클러스터에서 삭제하더라도 클라우드 리소스는 유지됨
    - 다시 사용하기 위해서는 새로운 pv를 만들고 기존 데이터를 마이그레이션 해야 함
3. Delete: pvc가 삭제되면, pv object도 삭제되며, 이는 곧, 클라우드 프로바이더의 리소스로 존재하는 스토리지도 함께 삭제됨

### memo
- 스토리지 클래스 당 Azure Storage Account 하나씩 맵핑됨
- 생성된 스토리지 어카운트는 네트워킹 설정도 자동으로 구성됨 -> 노드의 vnet에서만 통신 가능하도록 선택된 네트워크 방화벽 기능 사용함
- retain으로 데이터 영구 보존 한 뒤에, azure sac의 life cycle mgmt로 데이터 보존기간을 클라우드로 옮기는 방법이 좋을것 같음
    - life cycle mgmt에서 blob을 필터링 하는 방법을 구체화 해야함, 어떤 log 파일을 선택해서 archive하고 delete 할지.. 등
    - 필터링을 위해서 blob은 이름 혹은 Index(metadata)를 활용하는 방법이 존재함
    - life cycle mgmt는 컨테이너 자체가 아니라 컨테이너 안에 있는 blob object를 관리함
- pv 가 release 되는 시점은 pvc가 삭제되었을 경우, pod가 삭제되는것과는 별개임, 즉 pod만 삭제 하고 다시 생성될 경우 pvc만 살아있다면 다시 사용할 수 있음
    - 즉, pod와 pv,pvc간의 라이프사이클은 별개임




