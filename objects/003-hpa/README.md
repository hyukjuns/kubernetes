# HPA 테스트

### Usage
1. 워크로드 배포 (Deployment, HPA, Service)
2. 부하 발생 시키기
    1. curl 사용
    2. 파드에 직접 들어가서 stress 툴 사용
        ```
        apt-get update -y & apt-get install stress
        stress -c 4 -t 300
        ```
3. HPA 동작 확인

### ArgoCD 사용할 경우 주의사항
- Deployment의 spec.replicas 주석 처리 필요 (HPA 동작과 ArgoCD 동작이 겹치지 않도록)

- 참고문서
    - [Leaving Room For Imperativeness (Argo CD)](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/#leaving-room-for-imperativeness)
    - [HorizontalPodAutoscaler 연습 (K8s docs)](https://kubernetes.io/ko/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
