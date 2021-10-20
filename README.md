# Azure Managed Kubernetes Service & 필수 Application
## AKS에 관한 정보와 Helm을 사용한 k8s 필수 어플리케이션 설치 가이드
### 클러스터 정보 및 필수 Add-on 어플리케이션 목록
#### k8s Cluster
- AKS Cluster (Manged Controll Plane, Default 3 Worker nodes)
- 2021.10월 기준 k8s Version: 1.21.x
#### 필수 어플리케이션 설치 가이드는 링크를 참고
- Routing: Nginx Ingress Controller
- Monitoring: [Prometheus Stack (Prometheus, Grafana, AlertManager)](monitoring)
- Logging: ELK Stack (Elastic Search, Log Stash, Kibana)
- Service Mesh: Istio Service Mesh
## AKS 란?
### Azure Kubernetes Service
Azure 제공하는 관리되는 쿠버네티스 클러스터 서비스, Azure의 PaaS 제품으로 쿠버네티스 Control Plane(API Server, ETCD, Controller, Scheduler)은 Azure가 관리하며, 사용자는 Workload에 집중할 수 있는 장점이 있다.

## 특징
### 가용성 및 스케일링
1. Region 및 Availability Zone
    
    클러스터가 생성될 지역을 선택하고, 가용성 영역을 선택하여 노드의 가용성을 상승시킬 수 있다.

2. Node Size
    
    노드의 스펙은 Standard D2S_v2 (2 vCPU, 7 Gib Memory)가 기본값이며, 여타 가상머신을 선택할때와 마찬가지로 스펙 설정이 가능하다.

3. Node Pool
    
    System mode, User mode의 두 가지 모드가 제공되며, System mode 노드에는 시스템 파드 및 클러스터 관리에 적합한 파드를 배치하고, User mode 노드에는 Application, Database 등 비지니스 워크로드에 적합한 파드를 배치하는것이 권장사항이다. 하지만 System mode 노드에도 애플리케이션 파드를 배치할 수 있으며, 워크로드에 따라 필요에 맞게 사용하면 된다. 

    즉, 노드 라벨링과 비슷한 개념으로 생각할 수 있다.
    
4. Cluster Autoscale
    
    노드는 VMSS로 제공되며, 따라서 VMSS의 내장 기능인 Autoscale 기능을 사용하여 Cluster Autoscaling이 가능한 장점이 있다.
    
5. Virtual Nodes
    
    Serverless Azure Container Instance(ACI)를 사용하여 보다 빠른 노드 확장을 경험할 수 있다. 파드를 배치할 노드가 부족할 경우 서버리스 서비스를 사용하여 빠르게 파드를 띄워줄 수 있기 때문에 일반적인 노드 확장보다 빠른 노드 확장 경험을 할 수 있다.
    

### 보안
1. Azure Cloud Authentication method
    
    클러스터가 스스로 사용하게 되는 Azure Cloud에 대한 자격증명 설정이다, 클러스터 스스로 클러스터와 관련된 Azure 리소스를 생성 및 삭제할때 사용한다.(ex: 로드밸런서 생성)
    
    - Service Principal: 테넌트에 등록된 Application 정보 사용(사용자 관리 o)
    - System-assigned managed Identity: Azure가 관리하는 매니지드 자격증명(사용자 관리 x)

2. Cluster Authentication / Authorization
    
    k8s 클러스터 사용자의 RBAC 관리 기능을 제공한다, AAD와 통합 가능하기 때문에 AAD의 관리 그룹을 통해 클러스터 사용자의 RBAC 관리가 가능하지만, AAD와 통합할 경우 다시 통합을 해제하진 못한다.
    
3. Private Cluster
    
    API Server와 Node 모두 프라이빗 네트워크 환경에 놓여지게 되며, 퍼블릭 환경에서 접근할 수 없도록 설정할 수 있다.
    
4. Set Authorize IP Ranges
    
    API Server 접근에 대한 White List 기반 접근제한 기능을 제공한다. 지정된 IP만이 API Server에 Request를 보낼수 있도록 설정이 가능하다.
    
5. OS Disk Encryption
    
    Azure VM과 마찬가지로 노드의 디스크 암호화는 기본적으로 제공된다.
    

### 네트워크
1. Network Configuration
    - Kubenet
        - 기본값으로 vnet을 생성하여 네트워크를 구성한다.
        - pod는 Node IP를 통한 NAT를 사용해 Azure 리소스 및 외부와 통신하게 된다.
    - Azure CNI
        - pod의 네트워크 대역 및 구성을 사용자가 설정할 수 있다.(Vnet, Subnet(pod's ip), Service Network, Docker Bridge, DNS IP,Prefix)
        - pod는 vnet ip대역에서 바로 ip를 할당받아 기타 Azure 리소스와 통신할 수 있지만, 외부와의 통신은 결국 Node IP를 통한 NAT를 사용한다.
2. Traffic Routing
    - Load Balancer는 Standard SKU로 고정이며, 노드는 로드밸런서의 Outbound Rule을 통한 IP Masquerading을 사용해 외부와 아웃바운드 통신하게 된다.
    - HTTP application routing은 Azure가 제공하는 서비스형 Ingress Controller이며, 인그레스 컨트롤러를 별도로 설치하지 않아도 된다는 장점이 있다. 하지만 아직 Nginx Ingress Controller가 권장이다.
3. Network Policy
    
    클러스터내 파드에 대한 Ingress/Egress 트래픽 규칙을 설정할 수 있다.
    
    Calico가 기본적으로 제공되며, Azure CNI 네트워크 구성을 사용한 경우 Azure Native한 Network Policy를 사용할 수 있다.
    
### 통합 기능
1. Azure Container Registry
    
    기타 컨테이너 레지스트리 대신 ACR을 사용하여 손쉽게 프라이빗한 레지스트리를 사용 할 수 있도록 통합 기능을 제공하고 있다.
    
2. Azure Monitor
    
    Log Analytics와 통합하여 Node의 CPU, Memory 등 노드 인프라에 대한 모니터링을 사용할 수 있다.
    
3. Azure Policy
    
    Azure의 쿠버네티스 관련 정책을 활성화 하여 구독 내 AKS에 관한 규정 준수를 확인 할 수 있도록 서비스 통합을 제공하고 있다.
### 지원하는 k8s Version
<p>
[major].[minor].[patch] <br>
[주 버전].[부 버전].[패치 버전] <br>
ex) 1.17.7 <br>

주 버전 은 호환되지 않는 API 업데이트 또는 이전 버전과의 호환성이 손상될 수 있으면 변경된다.

부 버전 은 다른 부 릴리스의 이전 버전과 호환되는 기능 업데이트가 수행되면 변경된다.

패치 버전 은 이전 버전과 호환되는 버그 수정이 수행되면 변경된다.

AKS는 일반 공급 버전을 모든 SLO 또는 SLA 측정에서 사용하도록 설정되고 모든 지역에서 사용할 수 있는 버전으로 정의합니다. AKS에서 지원하는 Kubernetes의 3개 GA 부 버전은 다음과 같다.
1. AKS에서 릴리스된 최신 GA 부 버전
2. 최신 GA 부 버전의 이전 부 버전 2개
    - 지원되는 각 부 버전은 안정적인 패치 버전을 최대 2개까지 지원한다.

AKS에서 Kubernetes 버전의 지원 기간은 “N-2(N(최신 릴리스) - 2(부 버전))” 이다.

예를 들어 AKS가 현재 1.17.a 를 도입하는 경우 다음 버전에 대한 지원이 제공된다.

새 부 버전:1.17.a
지원되는 버전 목록 :1.17.a	1.17.a, 1.17.b, 1.16.c, 1.16.d, 1.15.e, 1.15.f
</p>

[k8s Release Info](https://en.wikipedia.org/wiki/Kubernetes#History)

### AKS Network Mode
- bridge는 deprecated되었으며, transparent가 디폴드 값으로 적용된다.
- 참고 링크: https://docs.microsoft.com/en-us/azure/aks/faq#what-is-azure-cni-transparent-mode-vs-bridge-mode