# Reloader

ConfigMap, Secret 변경시 자동 반영 가능(롤링업데이트 시작)

Repo: https://github.com/stakater/Reloader

## Install
https://github.com/stakater/Reloader?tab=readme-ov-file#deploying-to-kubernetes

## Usage
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myenv-app
  annotations:
    reloader.stakater.com/auto: "true"
    # configmap.reloader.stakater.com/reload: "foo-configmap,bar-configmap,baz-configmap"
    # secret.reloader.stakater.com/reload: "foo-secret,bar-secret,baz-secret"
spec:
```