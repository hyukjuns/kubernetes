# Kubernetes
API Server와 MySQL을 Kubernetes Object로 배포

### Prerequisite
- [Ingress Nginx Controller (Public)](https://github.com/hyukjuns/kubernetes/tree/main/addons/ingress-nginx-controller)

### 구성 절차
1. 네임스페이스 생성

    ```bash
    k create ns api
    ```

1. 환경변수를 Secret으로 생성

    ```bash
    # For API Server
    k create secret generic api-mysql-context -n api --from-env-file=api-mysql.env

    # For MySQL
    k create secret generic mysql-context -n db --from-env-file=mysql.env

    ```

2. MySQL 생성

    ```bash
    k apply -f api-mysql-sts.yaml
    ```

3. API Server 생성

    ```bash
    k apply -f api-deployment.yaml
    k apply -f api-ingress.yaml
    ```

### API Server
- Object: Deployment, API 서버 자체는 상태 비저장 Application
- ENV File: api-mysql.env, CRUD 통신을 위해 MySQL 연결정보를 주입
- Network: External Ingress, 외부 통신을 위해 서비스 오픈

### MySQL Database
- Object: StatefulSet, MySQL 은 상태 저장 Application
- ENV File: mysql.env, MySQL 데이터베이스 초기 셋업을 위한 환경변수 주입
- Network
    - Headless 서비스 사용하여 특정 Pod로 통신이 가능하도록 구성
    - API 서버는 MySQL Headless 서비스에서 지원하는 FQDN 사용
    - 같은 네임스페이스: `<POD-HOSTNAME>.<SERVICENAME>`
    - 다른 네임스페이스: `<POD-HOSTNAME>.<SERVICENAME>.<NAMESPACE>`
    - StatefulSet은 Pod의 이름을 `자신의 이름+숫자 접미사`를 사용해서 순차적으로 생성하므로, Pod의 hostname은 `스테이풀셋 이름+번호`로 미리 예상할 수 있음
    - 따라서 `<POD-HOSTNAME>.<SERVICENAME>` 은 `mysql-sts-0.mysql-headless-svc` 로 풀이되며, 이를 환경변수 파일에 DB HOST로서 미리 세팅할 수 있게 됨

### 환경변수를 위한 Secret 생성
Database 셋업 및 API 서버에 MySQL 정보 주입
- API Server
    - 통신을 위한 MySQL 정보 주입
    - `k create secret generic api-mysql-context -n api --from-env-file=api-mysql.env`
    - MYSQL_DATABASE_HOST는 StatefulSet과 Headless 서비스의 특징을 사용해서 예측 할 수 있음(`<POD-HOSTNAME>.<SERVICENAME>`)
- MySQL
    - Database 셋업 용도
    - `k create secret generic mysql-context -n api --from-env-file=mysql.env`

### 특이사항
- AKS Node의 Arch인 amd64를 고려해서 docker image는 amd64 플랫폼에 맞춰서 빌드된 이미지를 사용해야함

### 제한사항
- MySQL은 Read-Replica가 구성되지 않았으므로, StatefulSet의 Replica를 1개로 고정함