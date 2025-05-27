Promql 연산조건: 메트릭 레이블의 키/값이 모두 일치
- 레이블 불일치 시 
- on으로 공통 레이블 기준으로 연산 (without은 해당 레이블 제이한 모든 레이블로 그룹화)
```
container_memory_working_set_bytes 
/ on (namespace, pod, container) 
kube_pod_container_resource_limits{resource="memory"}
```
- group_left로 N:1 매핑 활용 (좌측 벡터 > 우측 벡터), group_left(LABEL) 에서 LABEL은 우측 벡터의 값이며, 좌측 레이블로 편입됨, 즉, 연산 이후 결과값에서 사용 가능
```
container_memory_working_set_bytes
/ on (namespace, pod, container) group_left
container_spec_memory_limit_bytes
```
- 집계 함수로 미리 필터링 하고 연산
```
sum by (namespace, pod) (
  container_memory_working_set_bytes{container!=""}
)
/ 
sum by (namespace, pod) (
  container_spec_memory_limit_bytes{container!=""}
)
```
rate: 변화량
increase: 증가량

