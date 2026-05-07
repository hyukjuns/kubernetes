# Gateway API - AKS Approuting Addon Gateway API

## Install Step - AKS Approuting Addon Gateway API
https://learn.microsoft.com/en-us/azure/aks/app-routing-gateway-api

## Samples

1 Gateway & N HTTPRoute (Different Namespace)

- Multi Domain
- Multi Path
- TLS Termination With Key Vault CSI Driver
- AppGW - Gateway E2E TLS

## Concept
### 종속 개념
```markdown
GatewayClass <- Gateway <- HttpRoute -> Backend (Service, Pods)
```

### 트래픽 흐름
```markdown
Client/AppGW -> LB(or ILB) Frontend IP ->  Gateway & HttpRoute 경로 검사 -> Backend (Service, Pods)
                                            ^
                                            TLS Termination
```
### Gateway, HTTPRoute
- Gateway를 1개 두고 각 HTTPRoute 가 공유해도 되고 1:1, N:M 모두 가능함
- Gateway 리스너는 유일해야함, 따라서 동일한 port/protocol을 사용한다면 hostname 필드는 필수 (ex: 80/http, 443/https)
- Gateway는 TLS 핸드쉐이크 시 ClientHello의 SNI 값을 리스너의 hostname과 비교하여 리스너를 선택
- Gateway와 HTTPRoute 모두 hostname을 명시하는 것이 권장사항
    - Gateway는 TLS 핸드쉐이크 시 SNI 로 리스너를 선택하고, HTTP 요청의 Host 헤더를 기준으로 해당 리스너에 붙은 HTTPRoute를 순회하며 라우팅 대상을 결정함
    - 만약 Gateway에 hostname이 없는 경우 모든 SNI를 수락하며, Gateway에 *.foo.com 처럼 와일드카드가 설정된 경우 여러 도메인이 같은 리스너로 유입됨, 따라서 이러한 경우 HTTPRoute에 hostname 명시는 필수적
    - Gateway hostname: 인프라 경계 (어떤 도메인을 수락할지)
    - HTTPRoute hostname: 라우팅 경계 (어느 서비스로 보낼지)

## Ref
- https://gateway-api.sigs.k8s.io/