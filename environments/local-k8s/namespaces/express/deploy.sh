#!/bin/bash

# Create namespace
if ! kubectl get namespace "${NAMESPACE}" --no-headers --output=name > /dev/null 2>&1; then
  kubectl create ns ${NAMESPACE}
fi

# deploy the express app
envsubst < ${REPO_DIR}/yaml/express.yaml | kubectl -n ${NAMESPACE} apply -f -

# Create pvc for source code dir
if ! kubectl -n ${NAMESPACE} get pvc ${REPO_DIR} --no-headers --output=name > /dev/null 2>&1; then
  echo "
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    namespace: ${NAMESPACE}
    name: ${REPO_DIR}
  spec:
    accessModes:
      - ReadWriteMany
    resources:
      requests:
        storage: 5Gi
    storageClassName: local-path
  " | kubectl apply -f - 
fi

# 使用 kubectl 變更 deployment，把原本的 deployment，command 改成 npm run build line-point，加上 名稱為 ${REPO_DIR} 的 volumes 並且掛載 pvc 到 /usr/src/app 這個路徑
kubectl -n ${NAMESPACE} patch deployment example-express --patch "
{
  \"spec\": {
    \"template\": {
      \"spec\": {
        \"containers\": [{
          \"name\": \"example-express\",
          \"image\": \"node:24\",
          \"workingDir\": \"/app\",
          \"volumeMounts\": [{
            \"name\": \"${REPO_DIR}\",
            \"mountPath\": \"/app\"
          }]
        }],
        \"volumes\": [{
          \"name\": \"${REPO_DIR}\",
          \"persistentVolumeClaim\": {
            \"claimName\": \"${REPO_DIR}\"
          }
        }]
      }
    }
  }
}"