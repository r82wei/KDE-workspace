# CI/CD 腳本產生範例

此文件提供各種專案類型的 `generate-cicd-scripts.md` 範例，供開發者參考。

## 範例 1: Node.js/TypeScript 專案 (kubectl 部署)

```markdown
# CI/CD 腳本產生模板

## 專案基本資訊

### 專案名稱

專案名稱: `kde-mcp-server`

### 專案描述

專案描述: 這是一個 MCP (Model Context Protocol) Server，使用 TypeScript 開發

### 技術棧

- 程式語言: `nodejs`
- 框架/工具: `typescript`, `express`
- 建置工具: `npm`
- 容器化: `是`

### 專案目錄結構
```

kde-mcp-server/
├── src/ # TypeScript 原始碼
├── build/ # 編譯後的 JavaScript
├── package.json
└── tsconfig.json

````

## 建置流程 (CI)

### 建置前置作業 (pre-build.sh)
**是否需要 pre-build.sh**: `是`

**前置作業說明**:
- [x] 設定 npm 快取路徑

```bash
NPM_CONFIG_USERCONFIG=$(dirname $PWD)/.npmrc npm config set cache "$(dirname $PWD)/.npm" && export NPM_CONFIG_USERCONFIG=$(dirname $PWD)/.npmrc
````

### 建置步驟 (build.sh)

**建置命令**:

```bash
cd kde-mcp-server
npm install
npm run build
```

**建置產物位置**:

- 目錄: `build/`
- 檔案: `index.js`

### 建置後置作業 (post-build.sh)

**是否需要 post-build.sh**: `否`

## 部署流程 (CD)

### 部署方式

- [x] `kubectl` - 使用原生 Kubernetes YAML 部署

### 部署前置作業 (pre-deploy.sh)

**是否需要 pre-deploy.sh**: `否`

### 部署步驟 (deploy.sh)

**部署命令**:

```bash
kubectl apply -f k8s/
kubectl rollout status deployment/kde-mcp-server -n kde-mcp-server
```

**Kubernetes manifests 位置**:

- 目錄: `k8s/`

### 部署後置作業 (post-deploy.sh)

**是否需要 post-deploy.sh**: `是`

**後置作業說明**:

- [x] 等待 Pod 就緒

```bash
kubectl wait --for=condition=ready pod -l app=kde-mcp-server -n kde-mcp-server --timeout=300s
```

### 解除部署 (undeploy.sh)

**解除部署方式**:

- [x] 使用 kubectl 刪除資源

**解除部署命令**:

```bash
kubectl delete -f k8s/
```

## 環境變數

### 建置環境變數

**需要的環境變數**:

- `NODE_ENV`: 執行環境 (development/production)

### 部署環境變數

**需要的環境變數**:

- `KUBECONFIG`: Kubernetes 設定檔路徑

## 特殊需求

### 錯誤處理

- [x] 使用 `set -e` 遇到錯誤立即退出

### 日誌輸出

- [x] 輸出詳細的執行日誌

````

## 範例 2: Node.js/Vue 專案 (Helm 部署)

```markdown
# CI/CD 腳本產生模板

## 專案基本資訊

### 專案名稱
專案名稱: `vue-example`

### 專案描述
專案描述: 這是一個 Vue.js 前端應用程式

### 技術棧
- 程式語言: `nodejs`
- 框架/工具: `vue`, `vite`
- 建置工具: `npm`
- 容器化: `是`

### 專案目錄結構
````

vue-example/
├── src/ # Vue 原始碼
├── dist/ # 建置產物
├── package.json
└── vite.config.js

````

## 建置流程 (CI)

### 建置前置作業 (pre-build.sh)
**是否需要 pre-build.sh**: `否`

### 建置步驟 (build.sh)
**建置命令**:
```bash
cd vue-example
npm install
npm run build
````

**建置產物位置**:

- 目錄: `dist/`

### 建置後置作業 (post-build.sh)

**是否需要 post-build.sh**: `否`

## 部署流程 (CD)

### 部署方式

- [x] `helm` - 使用 Helm Chart 部署

### 部署前置作業 (pre-deploy.sh)

**是否需要 pre-deploy.sh**: `是`

**前置作業說明**:

- [x] 產生 Kubernetes YAML 檔案（可選）

```bash
helm template vue-example . -f values.yaml > manifests.yaml
```

### 部署步驟 (deploy.sh)

**Helm Chart 位置**:

- 目錄: `./`

**Helm values 檔案**:

- 檔案: `values.yaml`

**Helm 部署參數**:

```bash
helm upgrade --install vue-example . \
  -f values.yaml \
  -n vue-example \
  --create-namespace \
  --wait \
  --timeout 5m
```

### 部署後置作業 (post-deploy.sh)

**是否需要 post-deploy.sh**: `是`

**後置作業說明**:

- [x] 等待 Pod 就緒

```bash
kubectl wait --for=condition=ready pod -l app=vue-example -n vue-example --timeout=300s
```

### 解除部署 (undeploy.sh)

**解除部署方式**:

- [x] 使用 Helm 解除安裝

**解除部署命令**:

```bash
helm uninstall vue-example -n vue-example
```

## 環境變數

### 建置環境變數

**需要的環境變數**:

- `VITE_API_URL`: API 伺服器位址

### 部署環境變數

**需要的環境變數**:

- `HELM_NAMESPACE`: Helm 部署的 namespace

````

## 範例 3: Python 專案 (ArgoCD 部署)

```markdown
# CI/CD 腳本產生模板

## 專案基本資訊

### 專案名稱
專案名稱: `python-api`

### 專案描述
專案描述: 這是一個 Python FastAPI 後端 API 服務

### 技術棧
- 程式語言: `python`
- 框架/工具: `fastapi`, `uvicorn`
- 建置工具: `pip`
- 容器化: `是`

### 專案目錄結構
````

python-api/
├── app/ # Python 原始碼
├── requirements.txt
└── Dockerfile

````

## 建置流程 (CI)

### 建置前置作業 (pre-build.sh)
**是否需要 pre-build.sh**: `否`

### 建置步驟 (build.sh)
**建置命令**:
```bash
cd python-api
pip install -r requirements.txt
# Python 專案通常不需要編譯步驟
````

**建置產物位置**:

- 目錄: `./` (Python 專案通常不需要編譯)

### 建置後置作業 (post-build.sh)

**是否需要 post-build.sh**: `是`

**後置作業說明**:

- [x] 執行單元測試

```bash
cd python-api
pytest tests/
```

## 部署流程 (CD)

### 部署方式

- [x] `argocd` - 使用 ArgoCD 部署

### 部署前置作業 (pre-deploy.sh)

**是否需要 pre-deploy.sh**: `是`

**前置作業說明**:

- [x] 設定 ArgoCD Repository（如果需要）

```bash
argocd login ${ARGOCD_SERVER} \
  --username ${ARGOCD_USERNAME} \
  --password ${ARGOCD_PASSWORD} \
  --insecure=${ARGOCD_INSECURE:-false}

# 檢查並新增 Repository（如果需要）
if ! argocd repo get ${ARGOCD_REPO_URL} > /dev/null 2>&1; then
  argocd repo add ${ARGOCD_REPO_URL} \
    --username ${GIT_USERNAME} \
    --password ${GIT_PASSWORD}
fi
```

### 部署步驟 (deploy.sh)

**ArgoCD 部署方式**:

- [x] 使用 ArgoCD CLI 同步應用程式

**部署命令**:

```bash
set -e

echo "=== 開始 ArgoCD 部署 ==="

# 登入 ArgoCD
argocd login ${ARGOCD_SERVER} \
  --username ${ARGOCD_USERNAME} \
  --password ${ARGOCD_PASSWORD} \
  --insecure=${ARGOCD_INSECURE:-false}

# 檢查應用程式是否存在
if argocd app get ${ARGOCD_APP_NAME} > /dev/null 2>&1; then
  echo "應用程式 ${ARGOCD_APP_NAME} 已存在，進行同步..."
  argocd app sync ${ARGOCD_APP_NAME} \
    --prune \
    --self-heal \
    --replace
  argocd app wait ${ARGOCD_APP_NAME} --timeout 300
else
  echo "應用程式 ${ARGOCD_APP_NAME} 不存在，請先建立 Application"
  exit 1
fi

echo "=== ArgoCD 部署完成 ==="
```

### 部署後置作業 (post-deploy.sh)

**是否需要 post-deploy.sh**: `是`

**後置作業說明**:

- [x] 執行健康檢查

```bash
# 檢查應用程式健康狀態
HEALTH_STATUS=$(argocd app get ${ARGOCD_APP_NAME} -o json | jq -r '.status.health.status')
SYNC_STATUS=$(argocd app get ${ARGOCD_APP_NAME} -o json | jq -r '.status.sync.status')

if [ "${HEALTH_STATUS}" != "Healthy" ] || [ "${SYNC_STATUS}" != "Synced" ]; then
  echo "警告: 應用程式狀態異常"
  exit 1
fi
```

### 解除部署 (undeploy.sh)

**解除部署方式**:

- [x] 使用 ArgoCD 刪除應用程式

**解除部署命令**:

```bash
argocd app delete ${ARGOCD_APP_NAME} --yes
```

## 環境變數

### 建置環境變數

**需要的環境變數**:

- `PYTHON_VERSION`: Python 版本

### 部署環境變數

**需要的環境變數**:

- `ARGOCD_SERVER`: ArgoCD Server 位址
- `ARGOCD_USERNAME`: ArgoCD 使用者名稱
- `ARGOCD_PASSWORD`: ArgoCD 密碼
- `ARGOCD_APP_NAME`: ArgoCD 應用程式名稱
- `ARGOCD_NAMESPACE`: 目標 namespace
- `ARGOCD_PROJECT`: ArgoCD Project 名稱

````

## 範例 4: Go 專案 (kubectl 部署)

```markdown
# CI/CD 腳本產生模板

## 專案基本資訊

### 專案名稱
專案名稱: `go-service`

### 專案描述
專案描述: 這是一個 Go 語言開發的微服務

### 技術棧
- 程式語言: `go`
- 框架/工具: `gin`
- 建置工具: `go build`
- 容器化: `是`

### 專案目錄結構
````

go-service/
├── cmd/ # 主程式入口
├── internal/ # 內部套件
├── pkg/ # 公開套件
├── go.mod
└── Dockerfile

````

## 建置流程 (CI)

### 建置前置作業 (pre-build.sh)
**是否需要 pre-build.sh**: `否`

### 建置步驟 (build.sh)
**建置命令**:
```bash
cd go-service
go mod download
go build -o bin/service ./cmd/main.go
````

**建置產物位置**:

- 目錄: `bin/`
- 檔案: `service`

### 建置後置作業 (post-build.sh)

**是否需要 post-build.sh**: `是`

**後置作業說明**:

- [x] 執行單元測試

```bash
cd go-service
go test ./...
```

## 部署流程 (CD)

### 部署方式

- [x] `kubectl` - 使用原生 Kubernetes YAML 部署

### 部署前置作業 (pre-deploy.sh)

**是否需要 pre-deploy.sh**: `否`

### 部署步驟 (deploy.sh)

**部署命令**:

```bash
set -e

echo "=== 開始部署 ==="
kubectl apply -f k8s/
kubectl rollout status deployment/go-service -n go-service --timeout=5m
echo "=== 部署完成 ==="
```

**Kubernetes manifests 位置**:

- 目錄: `k8s/`

### 部署後置作業 (post-deploy.sh)

**是否需要 post-deploy.sh**: `是`

**後置作業說明**:

- [x] 等待 Pod 就緒
- [x] 執行健康檢查

```bash
kubectl wait --for=condition=ready pod -l app=go-service -n go-service --timeout=300s

# 健康檢查
kubectl exec -n go-service deployment/go-service -- curl -f http://localhost:8080/health || exit 1
```

### 解除部署 (undeploy.sh)

**解除部署方式**:

- [x] 使用 kubectl 刪除資源

**解除部署命令**:

```bash
kubectl delete -f k8s/
```

## 環境變數

### 建置環境變數

**需要的環境變數**:

- `GO_VERSION`: Go 版本
- `CGO_ENABLED`: 是否啟用 CGO

### 部署環境變數

**需要的環境變數**:

- `KUBECONFIG`: Kubernetes 設定檔路徑

````

## 範例 5: Helm Chart 專案 (Loki Stack)

```markdown
# CI/CD 腳本產生模板

## 專案基本資訊

### 專案名稱
專案名稱: `loki-stack`

### 專案描述
專案描述: 這是一個使用 Helm Chart 部署的 Loki Stack 日誌系統

### 技術棧
- 程式語言: `其他` (Helm Chart)
- 框架/工具: `helm`
- 建置工具: `helm`
- 容器化: `否` (使用現有的 Helm Chart)

### 專案目錄結構
````

loki-stack/
├── loki-stack.values.yaml # Helm values 檔案
└── loki.yaml # 產生的 YAML（可選）

````

## 建置流程 (CI)

### 建置前置作業 (pre-build.sh)
**是否需要 pre-build.sh**: `否`

### 建置步驟 (build.sh)
**建置命令**:
```bash
# Helm Chart 專案通常不需要建置步驟
# 或者可以產生 YAML 檔案作為建置產物
helm template loki grafana/loki-stack \
  --debug \
  -f loki-stack.values.yaml \
  > loki.yaml
````

**建置產物位置**:

- 檔案: `loki.yaml` (可選)

### 建置後置作業 (post-build.sh)

**是否需要 post-build.sh**: `否`

## 部署流程 (CD)

### 部署方式

- [x] `helm` - 使用 Helm Chart 部署

### 部署前置作業 (pre-deploy.sh)

**是否需要 pre-deploy.sh**: `否`

### 部署步驟 (deploy.sh)

**Helm Chart 位置**:

- Chart: `grafana/loki-stack` (來自 Helm Repository)

**Helm values 檔案**:

- 檔案: `loki-stack.values.yaml`

**Helm 部署參數**:

```bash
set -e

echo "請選擇要執行的操作:"
echo "1. 產生 yaml 檔案"
echo "2. 部署 Loki Stack"
read -p "請選擇(輸入編號): " deployment_mode

case $deployment_mode in
  1)
    helm template loki grafana/loki-stack \
      --debug \
      -f loki-stack.values.yaml \
      > loki.yaml
    ;;
  2)
    helm upgrade loki grafana/loki-stack \
      --install \
      --namespace loki \
      --create-namespace \
      --debug \
      -f loki-stack.values.yaml
    ;;
  *)
    echo "無效的選擇"
    exit 1
    ;;
esac
```

### 部署後置作業 (post-deploy.sh)

**是否需要 post-deploy.sh**: `否`

### 解除部署 (undeploy.sh)

**解除部署方式**:

- [x] 使用 Helm 解除安裝

**解除部署命令**:

```bash
helm uninstall loki -n loki
```

## 環境變數

### 建置環境變數

**需要的環境變數**:
無

### 部署環境變數

**需要的環境變數**:

- `HELM_NAMESPACE`: Helm 部署的 namespace

```

## 使用說明

1. 複製 `docs/generate-cicd-scripts.template.md` 到你的專案目錄
2. 重新命名為 `generate-cicd-scripts.md`
3. 根據你的專案需求填寫各個區塊
4. 在 Cursor 中，AI Agent 會自動讀取此文件並產生對應的 CI/CD 腳本

## 注意事項

- 所有腳本都會在對應的 Docker 容器中執行（根據 project.env 中的 DEVELOP_IMAGE 或 DEPLOY_IMAGE）
- 環境變數會從 project.env 自動注入到容器中
- 腳本執行順序遵循 KDE CLI 的規範：pre-build.sh → build.sh → post-build.sh → pre-deploy.sh → deploy.sh → post-deploy.sh

```
