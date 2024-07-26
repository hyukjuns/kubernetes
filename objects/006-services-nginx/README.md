- document root
```
/usr/share/nginx/html/index.html
```
- config
```
/etc/nginx/nginx.conf
/etc/nginx/conf.d/default.conf
```
- log
```
/var/log/nginx/access.log
/var/log/nginx/error.log
```

# Tip for Test
```bash
# Busybox running
k run --rm -it tester --image=busybox
k run tester --image=busybox sleep 10m

# Curl to Wget, -q: 로깅 x, -O-: 다운로드 파일을 stdout으로 리다이렉팅하여 출력
wget -q -O- [URL]
# 외부에서 커맨드 전달 시 예시
k exec tester -- wget -q -O- [URL] 
```

# TLS Setting
```
# [option] Self Example Cert
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=example.com/O=example.com"

# Create TLS Secret
kubectl create secret tls NAME --cert=tls.crt --key=tls.key

# Set ingress manifest
spec:
  tls:
    - hosts:
      - DOMAIN
      secretName: SECRETNAME
```

# 노드 연결
```
kubectl debug node/NODENAME -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0
```