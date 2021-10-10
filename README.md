# Azure Managed Kubernetes Service & 필수 Application
## AKS에 관한 정보와 Helm을 사용한 k8s 필수 어플리케이션 설치 가이드
- AKS cluster
- Nginx Ingress Controller
- [Prometheus Stack (Prometheus, Grafana, AlertManager)](monitoring)
- ELK Stack (Elastic Search, Log Stash, Kibana)
- Istio Service Mesh
## AKS
### Azure Kubernetes Service
Azure 제공하는 관리되는 쿠버네티스 클러스터 서비스, Azure의 PaaS 제품으로 쿠버네티스 Control Plane(API Server, ETCD, Controller, Scheduler)은 Azure가 관리하며, 사용자는 Workload에 집중할 수 있는 장점이 있다

## 특징
### 가용성 및 스케일링
1. Region 및 Availability Zone
    
    클러스터가 생성될 지역을 선택하고, 가용성 영역을 선택하여 노드의 가용성을 상승시킬 수 있다.

2. Node Size
    
    노드의 스펙은 Standard D2S_v2 (2 vCPU, 7 Gib Memory)

3. Node Pool
    
    System mode, User mode 두가지 모드가 제공되며, System mode 노드에는 시스템 파드를 배치하고, User mode 노드에는 Application등 비지니스 워크로드에 관한 파드를 배치하는것이 권장사항이다. 하지만 시스템 모드 노드에도 애플리케이션 파드를 배치할 수 있다. 
    
4. Cluster Autoscale
    
    노드는 VMSS로 제공되며, 따라서 VMSS에서 제공되는 autoscale 기능을 사용해 클러스터 자동 확장이 가능하다.
    
5. Virtual Nodes
    
    Serverless Azure Container Instance를 사용하여 보다 빠른 노드 확장을 경험할 수 있다. 물리적 노드 확장이 아닌 서버리스 서비스를 사용해 보다 빠른 서비스 스케일링이 가능하다.
    

### 보안
1. Azure Cloud Authentication method
    
    클러스터가 스스로 사용하게되는 Azure Cloud에 대한 자격증명 설정, 클러스터 스스로 클러스와 관련된 Azure 리소스를 생성 및 삭제할때 사용한다.(ex: 로드밸런서 생성)
    
    - Service Principal: 테넌트에 등록된 Application 정보 사용(사용자 관리 o)
    - System-assigned managed Identity: Azure가 관리하는 매니지드 자격증명(사용자 관리 x)

2. Cluster Authentication/Authorization
    
    k8s 클러스터 내의 사용자 RBAC 관리 기능을 제공한다, AAD와 통합 가능하여 AAD의 관리 그룹을 통해 클러스터 유저의 RBAC관리가 가능하지만, AAD와 통합할 경우 이후 통합을 해제하진 못한다.
    
3. Private Cluster
    
    API Server와 Node 모두 프라이빗 네트워크 환경에 놓여지게 되며, 퍼블릭 환경에서 접근할 수 없도록 설정할 수 있다.
    
4. Set Authorize IP Ranges
    
    API Server 접근에 대한 화이트리스트 접근제한 기능을 제공한다. 지정된 IP만이 API Server에 Request를 보낼수 있도록 설정이 가능하다.
    
5. OS Disk Encryption
    
    Azure VM과 마찬가지로 노드의 디스크 암호화는 기본적으로 제공된다.
    

### 네트워크
1. Network Configuration
    - Kubenet
        - 기본값으로 vnet을 생성하여 네트워크를 구성한다.
        - pod는 Node IP를 통한 NAT를 사용해 Azure 리소스 및 외부와 통신하게 된다.
    - Azure CNI
        - 네트워크 대역 및 구성을 사용자가 설정할 수 있다.(Vnet, Subnet대역(pod ip), Service Network 대역, Docker Bridge, DNS IP,Prefix)
        - pod는 vnet의 ip대역에서 바로 ip를 할당받아 기타 Azure 리소스와 통신할 수 있다. 외부와의 통신은 Node IP를 통한 NAT를 사용한다.
2. Traffic Routing
    - Load Balancer는 Standard SKU로 고정이며, 노드는 로드밸런서의 Outbound Rule을 통해 IP Masquerading을 사용해 외부와의 통신이 이루어진다.
    - HTTP application routing은 Azure가 제공하는 Ingress Controller이며, 인그레스 컨트롤러를 별도로 설치하지 않아도 서비스형태로 인그레스 오브젝트를 사용할 수 있다.
3. Network Policy
    
    클러스터내 파드에 대한 Ingress/Egress 트래픽 규칙을 설정할 수 있다.
    
    Calico가 기본적으로 제공되며, Azure CNI 네트워크 구성을 사용할 경우 Azure Native한 Network Policy를 사용할 수 있다.
    
### 통합 기능
1. Azure Container Registry
    
    기타 컨테이너 레지스트리 대신 ACR을 사용하여 손쉽게 프라이빗한 레지스트리를 사용 및 통합할 수 있도록 제공하고 있다.
    
2. Azure Monitor
    
    Log Analytics와 통합하여 Node의 CPU, Memory 등 노드 인프라에 대한 모니터링을 사용할 수 있다.
    
3. Azure Policy
    
    Azure의 쿠버네티스 관련 정책을 활성화 하여 구독 내 AKS에 관한 규정 준수를 확인 할 수 있도록 서비스 통합을 제공하고 있다.