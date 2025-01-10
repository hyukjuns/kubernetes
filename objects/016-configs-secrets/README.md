# Configmap, Secrets

1. Pod에 필요한 변수를 Configmap, Secret로 생성하여 ENV로 세팅하여 사용한다면, Configmap, Secret의 내용을 바꾸어도 Pod가 재시작 되어야 반영할 수 있음

2. Pod에 ENV가 아닌 Volume을 마운트해서 Configmap, Secret을 사용한다면, 파드의 재시작 없이 Configmap, Secret의 내용을 업데이트 할 수 있음, 하지만 반영까지 약간의 시간이 소요됨

3. reloader addon을 사용하면 ENV, Volume 타입으로 사용중인 Configmap, Secret의 변경사항 발생시 바로 파드를 업데이트 함 (롤링 업그레이드로 파드를 재배포함)

4. configMapRef, configMapKeyRef 차이 (시크릿도 동일)
```
# env.valueFrom.configMapKeyRef 은 ConfigMap의 특정 Key만 참조해서 환경변수로 설정할 수 있게 해줌
env:
  - name: CONSUMERGROUP
    valueFrom:
      configMapKeyRef:
        name: myenv-app-config
        key: consumer-group-name

# envFrom.configMapRef 는 ConfigMap의 모든 키-값 데이터를 한번에 환경변수로 가져올 수 있게 해줌
envFrom:
- configMapRef:
    name: myenv-app-config
```