# Gateway API - AKS Approuting Addon Gateway API

## Samples
- Multi Domain
- Multi Path
- TLS Termination

## Concept
### Hierachy
```markdown
GatewayClass -> Gateway -> HttpRoute -> Backend (Service, Pods)
```
### Traffic Flow (Azure 기준)
```markdown
Client/AppGW -> LB(or ILB) Frontend IP ->  Gateway (Pods) HttpRoute 경로 검사 -> BAckend (Service, Pods)
                                            ^
                                            TLS Termincation
```
## Install Step - AKS Approuting Addon Gateway API
https://learn.microsoft.com/en-us/azure/aks/app-routing-gateway-api

### Concepts
- 리스너가 여러개이고, 같은 포트와 프로토콜을 사용하는 리스너가 존재할때에는 리스너 구분을 위해 hostname 필드 사용, port로 구분 가능한 경우 hostname은 옵션, 즉 443/https 를 사용하는 리스너가 여러개라면, 리스너 마다 hostname 설정은 필수, hostname은 TLS 핸드쉐이크시 요청자의 SNI 정보를 바탕으로 리스너 선택에 사용됨
- Gateway는 TLS 핸드셰이크 시 ClientHello의 SNI 값을 리스너의 hostname과 비교하여 리스너를 선택함

- 리스너 설정시 hostname 필요성 참고 (어차피 같은 포트/프로토콜이므로 hostname은 필수)
1) 여러개 리스너, 리스너마다 hostname이 없는 경우 SNI는 정상적으로 왔지만, 비교할 hostname이 없으니 모든 리스너가 매칭되어버려서 선택이 불가능한 상황 발생

    ```markdown
    클라이언트 → SNI: "api.foo.com"
                    ↓
    Gateway가 리스너 목록 순회
    - listener-a: hostname 없음 (= *)  ← api.foo.com 매칭됨
    - listener-b: hostname 없음 (= *)  ← api.foo.com 매칭됨
                    ↓
    둘 다 매칭 → 어느 리스너의 인증서를 써야 하지? → 충돌
    ```

2) 여러개 리스너, 리스너마다 hostname이 존재 하는 경우 SNI 값과 비교할 hostname이 있으므로 유일한 리스너를 선택 가능

    ```markdown
    클라이언트 → SNI: "api.foo.com"
                    ↓
    Gateway가 리스너 목록 순회
    - listener-a: hostname: "api.foo.com"  ← 매칭됨 ✅
    - listener-b: hostname: "api.bar.com"  ← 매칭 안됨 ❌
                    ↓
    listener-a 선택 → foo-cert 로드 → TLS 핸드셰이크 완료
    ```
- Gateway와 HTTPRoute 모두 hostname을 명시하는 것이 권장사항
    ```markdown
    1. Gateway는 TLS 핸드셰이크 시 ClientHello의 SNI 값을
    리스너의 hostname과 비교하여 리스너를 선택한다.

    2. 리스너가 선택된 후, TLS Termination이 완료되면
    평문 HTTP 요청의 Host 헤더를 기준으로
    해당 리스너에 붙은 HTTPRoute를 순회하며 라우팅 대상을 결정한다.

    3. 두 단계의 역할이 다르다.
        - Gateway hostname: 인프라 경계 (어떤 도메인을 수락할지)
        - HTTPRoute hostname: 라우팅 경계 (어느 서비스로 보낼지)

    4. 특히 Gateway에 *.foo.com처럼 와일드카드가 설정된 경우,
    api.foo.com / admin.foo.com 등 여러 도메인이 같은 리스너로 유입되므로
    HTTPRoute에 hostname 명시가 필수적이다.

    5. Gateway hostname이 없는 경우(= 모든 SNI 수락),
    HTTPRoute의 Host 헤더 매칭이 유일한 라우팅 수단이 된다.
    ```
- TLS Termination 처리 방식 정리, hostname 위치를 어디에 둘지
- TLS Key Vault 연계 방식 정리

## Sample Scenario
### Basic

### Cross-Namespace routing
https://gateway-api.sigs.k8s.io/guides/multiple-ns/#shared-gateway
```markdown
Gateway(infra ns) -> Site ns -> 
                  -> Store ns
```
## Ref