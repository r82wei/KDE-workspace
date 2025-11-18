# ArgoCD 部署指南

本指南說明如何在 KDE Workspace 的 CD 流程中使用 ArgoCD 進行部署。

## 前置準備

### 1. 設定 DEPLOY_IMAGE

在 `project.env` 中設定包含 ArgoCD CLI 的 Docker image：

```bash
DEPLOY_IMAGE=r82wei/deploy-env:1.0.0
# 或者使用包含 ArgoCD CLI 的自訂 image
# DEPLOY_IMAGE=your-custom-image:tag
```

### 2. 設定環境變數

在 `project.env` 中加入 ArgoCD 相關環境變數：

```bash
# ArgoCD Server 連線設定
ARGOCD_SERVER=argocd-server.argocd.svc.cluster.local:443
ARGOCD_USERNAME=admin
ARGOCD_PASSWORD=your-password
ARGOCD_INSECURE=true  # 如果使用自簽憑證設為 true

# 專案設定
ARGOCD_APP_NAME=my-app
ARGOCD_PROJECT=default
ARGOCD_NAMESPACE=my-namespace

# Git Repository 設定（如果使用 GitOps）
ARGOCD_REPO_URL=https://github.com/your-org/your-repo.git
ARGOCD_REPO_PATH=manifests
ARGOCD_TARGET_REVISION=main
```

## 部署腳本範例

### 方法一：使用 ArgoCD CLI 同步應用程式

在 `deploy.sh` 中實作：

```bash
#!/bin/bash

set -e  # 遇到錯誤立即退出

echo "=== 開始 ArgoCD 部署 ==="

# 登入 ArgoCD
echo "登入 ArgoCD Server: ${ARGOCD_SERVER}"
argocd login ${ARGOCD_SERVER} \
  --username ${ARGOCD_USERNAME} \
  --password ${ARGOCD_PASSWORD} \
  --insecure=${ARGOCD_INSECURE:-false}

# 檢查應用程式是否存在
if argocd app get ${ARGOCD_APP_NAME} > /dev/null 2>&1; then
  echo "應用程式 ${ARGOCD_APP_NAME} 已存在，進行同步..."
  
  # 同步應用程式
  argocd app sync ${ARGOCD_APP_NAME} \
    --prune \
    --self-heal \
    --replace
  
  # 等待同步完成
  argocd app wait ${ARGOCD_APP_NAME} --timeout 300
else
  echo "應用程式 ${ARGOCD_APP_NAME} 不存在，建立新應用程式..."
  
  # 建立應用程式
  argocd app create ${ARGOCD_APP_NAME} \
    --repo ${ARGOCD_REPO_URL} \
    --path ${ARGOCD_REPO_PATH} \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace ${ARGOCD_NAMESPACE} \
    --project ${ARGOCD_PROJECT} \
    --revision ${ARGOCD_TARGET_REVISION} \
    --sync-policy automated \
    --self-heal \
    --auto-prune
  
  # 同步應用程式
  argocd app sync ${ARGOCD_APP_NAME}
  
  # 等待同步完成
  argocd app wait ${ARGOCD_APP_NAME} --timeout 300
fi

# 顯示應用程式狀態
echo "=== 應用程式狀態 ==="
argocd app get ${ARGOCD_APP_NAME}

echo "=== ArgoCD 部署完成 ==="
```

### 方法二：使用 ArgoCD Application Manifest

在 `deploy.sh` 中實作：

```bash
#!/bin/bash

set -e

echo "=== 開始 ArgoCD 部署 ==="

# 登入 ArgoCD
echo "登入 ArgoCD Server: ${ARGOCD_SERVER}"
argocd login ${ARGOCD_SERVER} \
  --username ${ARGOCD_USERNAME} \
  --password ${ARGOCD_PASSWORD} \
  --insecure=${ARGOCD_INSECURE:-false}

# 應用 Application Manifest
if [ -f "argocd-application.yaml" ]; then
  echo "使用 argocd-application.yaml 部署..."
  kubectl apply -f argocd-application.yaml
  
  # 等待應用程式建立
  sleep 5
  
  # 同步應用程式
  argocd app sync ${ARGOCD_APP_NAME} --prune --self-heal --replace
  
  # 等待同步完成
  argocd app wait ${ARGOCD_APP_NAME} --timeout 300
else
  echo "錯誤: 找不到 argocd-application.yaml"
  exit 1
fi

# 顯示應用程式狀態
echo "=== 應用程式狀態 ==="
argocd app get ${ARGOCD_APP_NAME}

echo "=== ArgoCD 部署完成 ==="
```

### 方法三：使用 ArgoCD CLI 直接部署 YAML

在 `deploy.sh` 中實作：

```bash
#!/bin/bash

set -e

echo "=== 開始 ArgoCD 部署 ==="

# 登入 ArgoCD
argocd login ${ARGOCD_SERVER} \
  --username ${ARGOCD_USERNAME} \
  --password ${ARGOCD_PASSWORD} \
  --insecure=${ARGOCD_INSECURE:-false}

# 使用 kubectl 或 helm 產生 YAML，然後透過 ArgoCD 部署
if [ -d "k8s-manifests/" ]; then
  echo "部署 Kubernetes Manifests..."
  
  # 建立或更新 Application
  cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${ARGOCD_APP_NAME}
  namespace: argocd
spec:
  project: ${ARGOCD_PROJECT}
  source:
    repoURL: ${ARGOCD_REPO_URL}
    targetRevision: ${ARGOCD_TARGET_REVISION}
    path: ${ARGOCD_REPO_PATH}
  destination:
    server: https://kubernetes.default.svc
    namespace: ${ARGOCD_NAMESPACE}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

  # 同步應用程式
  argocd app sync ${ARGOCD_APP_NAME}
  argocd app wait ${ARGOCD_APP_NAME} --timeout 300
fi

echo "=== ArgoCD 部署完成 ==="
```

## 完整範例：結合 Helm 和 ArgoCD

```bash
#!/bin/bash

set -e

echo "=== 開始 CI/CD 流程 ==="

# 1. 使用 Helm 產生 manifests（如果需要）
if [ -f "Chart.yaml" ]; then
  echo "產生 Helm manifests..."
  helm template ${ARGOCD_APP_NAME} . \
    --namespace ${ARGOCD_NAMESPACE} \
    --values values.yaml \
    > manifests/deployment.yaml
fi

# 2. 提交到 Git Repository（GitOps 流程）
if [ -n "${GIT_REPO_URL}" ] && [ -n "${GIT_COMMIT_MESSAGE}" ]; then
  echo "提交 manifests 到 Git Repository..."
  git config user.name "KDE CI/CD"
  git config user.email "ci-cd@kde.local"
  git add manifests/
  git commit -m "${GIT_COMMIT_MESSAGE}" || echo "沒有變更需要提交"
  git push origin ${ARGOCD_TARGET_REVISION}
fi

# 3. 登入 ArgoCD
echo "登入 ArgoCD Server: ${ARGOCD_SERVER}"
argocd login ${ARGOCD_SERVER} \
  --username ${ARGOCD_USERNAME} \
  --password ${ARGOCD_PASSWORD} \
  --insecure=${ARGOCD_INSECURE:-false}

# 4. 同步 ArgoCD 應用程式
echo "同步 ArgoCD 應用程式: ${ARGOCD_APP_NAME}"
if argocd app get ${ARGOCD_APP_NAME} > /dev/null 2>&1; then
  argocd app sync ${ARGOCD_APP_NAME} --prune --self-heal --replace
else
  echo "應用程式不存在，請先建立 Application"
  exit 1
fi

# 5. 等待部署完成
echo "等待部署完成..."
argocd app wait ${ARGOCD_APP_NAME} --timeout 600 --health

# 6. 顯示狀態
echo "=== 部署狀態 ==="
argocd app get ${ARGOCD_APP_NAME}

echo "=== CI/CD 流程完成 ==="
```

## 使用 pre-deploy.sh 進行前置作業

如果需要在前置作業中設定 ArgoCD Repository 或 Project，可以在 `pre-deploy.sh` 中實作：

```bash
#!/bin/bash

set -e

echo "=== ArgoCD 前置作業 ==="

# 登入 ArgoCD
argocd login ${ARGOCD_SERVER} \
  --username ${ARGOCD_USERNAME} \
  --password ${ARGOCD_PASSWORD} \
  --insecure=${ARGOCD_INSECURE:-false}

# 檢查並建立 Repository（如果需要）
if ! argocd repo get ${ARGOCD_REPO_URL} > /dev/null 2>&1; then
  echo "新增 Git Repository..."
  argocd repo add ${ARGOCD_REPO_URL} \
    --username ${GIT_USERNAME} \
    --password ${GIT_PASSWORD}
fi

# 檢查並建立 Project（如果需要）
if ! argocd proj get ${ARGOCD_PROJECT} > /dev/null 2>&1; then
  echo "建立 ArgoCD Project..."
  argocd proj create ${ARGOCD_PROJECT} \
    --description "Project for ${ARGOCD_APP_NAME}"
fi

echo "=== 前置作業完成 ==="
```

## 使用 post-deploy.sh 進行後置作業

在 `post-deploy.sh` 中可以進行健康檢查或通知：

```bash
#!/bin/bash

set -e

echo "=== ArgoCD 後置作業 ==="

# 登入 ArgoCD
argocd login ${ARGOCD_SERVER} \
  --username ${ARGOCD_USERNAME} \
  --password ${ARGOCD_PASSWORD} \
  --insecure=${ARGOCD_INSECURE:-false}

# 檢查應用程式健康狀態
HEALTH_STATUS=$(argocd app get ${ARGOCD_APP_NAME} -o json | jq -r '.status.health.status')
SYNC_STATUS=$(argocd app get ${ARGOCD_APP_NAME} -o json | jq -r '.status.sync.status')

echo "健康狀態: ${HEALTH_STATUS}"
echo "同步狀態: ${SYNC_STATUS}"

if [ "${HEALTH_STATUS}" != "Healthy" ] || [ "${SYNC_STATUS}" != "Synced" ]; then
  echo "警告: 應用程式狀態異常"
  exit 1
fi

# 可以在此加入通知邏輯（Slack、Email 等）
echo "=== 後置作業完成 ==="
```

## 注意事項

1. **安全性**：建議使用 ArgoCD 的 Service Account Token 或 OIDC 認證，避免在環境變數中直接存放密碼
2. **錯誤處理**：腳本中使用 `set -e` 確保錯誤時立即退出
3. **超時設定**：根據應用程式大小調整 `--timeout` 參數
4. **GitOps 最佳實踐**：建議將 manifests 提交到 Git Repository，讓 ArgoCD 自動同步
5. **多環境部署**：可以透過不同的 `ARGOCD_APP_NAME` 和 `ARGOCD_NAMESPACE` 區分不同環境

## 參考資源

- [ArgoCD CLI 文件](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd/)
- [ArgoCD Application CRD](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications)
- [GitOps 最佳實踐](https://www.gitops.tech/)


