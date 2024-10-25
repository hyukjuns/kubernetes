### NGINX Application의 메트릭 수집 (프로메테우스)

### Step
1. nginx config에서 stub_status 활성화 
    
    설정 파일을 컨피그맵으로 생성 후 볼륨으로 컨테이너에 파일 마운트

    ```k create cm nginx-metrics-conf --from-file nginx-metrics.conf```

2. nginx 컨테이너와 nginx-metric-exporter 컨테이너 실행

    ```k apply -f application-nginx.yaml```

3. Service Monitor 설정 및 배포

    ```k apply -f servicemonitor-nginx.yaml ```

### stub_status / nginx-metric-exporter / Service Monitor
- stub_status: NGINX 기본 설정 중 하나로 NGINX의 기본 메트릭 노출을 활성화 시킴
- nginx-metric-exporter: nginx의 stub_status로 노출된 메트릭을 프로메테우스 데이터 양식에 맞게 수정한 후 프로메테우스가 수집할 수 있도록 노출 (Expose) 하는 역할 
- Service Monitor: 메트릭을 수집할 수 있도록 타겟 서비스 레이블과 서비스의 포트(엔드포인트)를 설정해줌

### Ref
- [stub_status](https://nginx.org/en/docs/http/ngx_http_stub_status_module.html#stub_status)
- [nginx-prometheus-exporter](https://github.com/nginxinc/nginx-prometheus-exporter?tab=readme-ov-file#prerequisites)
