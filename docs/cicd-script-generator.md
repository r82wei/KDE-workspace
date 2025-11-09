# CI/CD 腳本自動產生工具使用說明

## 概述

此工具允許開發者在專案目錄下建立 `generate-cicd-scripts.md` 文件，描述專案的 CI/CD 需求。AI Agent（透過 Cursor）會讀取此文件，並自動產生符合 KDE CLI 規範的 CI/CD 腳本。

## 快速開始

### 步驟 1: 建立 generate-cicd-scripts.md

在你的專案目錄下（`environments/[k8s-name]/namespaces/[project-name]/`）建立 `generate-cicd-scripts.md` 文件：

```bash
cd environments/mcp/namespaces/my-project
cp ../../../../docs/generate-cicd-scripts.template.md generate-cicd-scripts.md
```

### 步驟 2: 填寫專案資訊

根據你的專案需求，填寫 `generate-cicd-scripts.md` 中的各個區塊：

1. **專案基本資訊** - 描述專案名稱、技術棧等
2. **建置流程** - 說明如何編譯和打包專案
3. **部署流程** - 說明如何部署到 K8S
4. **環境變數** - 列出需要的環境變數
5. **特殊需求** - 描述任何特殊需求

### 步驟 3: 使用 AI Agent 產生腳本

在 Cursor 中，你可以：

1. **直接詢問 AI Agent**：
   ```
   請根據 generate-cicd-scripts.md 的內容，為這個專案產生 CI/CD 腳本
   ```

2. **或者提供文件內容**：
   ```
   請讀取 generate-cicd-scripts.md 並產生對應的 pre-build.sh, build.sh, post-build.sh, 
   pre-deploy.sh, deploy.sh, post-deploy.sh, undeploy.sh 腳本
   ```

AI Agent 會根據文件內容自動產生所有必要的腳本。

## 文件結構說明

### 專案基本資訊

描述專案的基本資訊，幫助 AI Agent 理解專案類型：

- **專案名稱**: 通常與 namespace 相同
- **專案描述**: 簡短描述專案功能
- **技術棧**: 列出使用的技術（Node.js、Python、Go 等）
- **專案目錄結構**: 描述專案的主要目錄結構

### 建置流程 (CI)

描述如何編譯和打包專案：

#### pre-build.sh
在執行建置前需要做的事情，例如：
- 設定 npm 快取路徑
- 安裝全域依賴
- 設定環境變數

#### build.sh
主要的建置步驟，例如：
- 安裝依賴（`npm install`、`pip install` 等）
- 執行建置（`npm run build`、`go build` 等）
- 產生建置產物

#### post-build.sh
在執行建置後需要做的事情，例如：
- 執行單元測試
- 執行整合測試
- 產生測試報告
- 上傳建置產物

### 部署流程 (CD)

描述如何部署到 K8S：

#### 部署方式
選擇部署方式：
- `kubectl` - 使用原生 Kubernetes YAML 部署
- `helm` - 使用 Helm Chart 部署
- `argocd` - 使用 ArgoCD 部署
- `docker` - 僅建置 Docker Image

#### pre-deploy.sh
在執行部署前需要做的事情，例如：
- 產生 Kubernetes YAML 檔案
- 驗證 Helm Chart
- 設定 ArgoCD Repository

#### deploy.sh
主要的部署步驟，根據部署方式不同：

**kubectl**:
```bash
kubectl apply -f k8s/
kubectl rollout status deployment/my-app -n my-namespace
```

**Helm**:
```bash
helm upgrade --install my-app . -f values.yaml -n my-namespace --create-namespace
```

**ArgoCD**:
```bash
argocd login ${ARGOCD_SERVER} --username ${ARGOCD_USERNAME} --password ${ARGOCD_PASSWORD}
argocd app sync ${ARGOCD_APP_NAME}
```

#### post-deploy.sh
在執行部署後需要做的事情，例如：
- 等待 Pod 就緒
- 執行健康檢查
- 執行冒煙測試
- 發送通知

#### undeploy.sh
如何解除部署，例如：
- 使用 kubectl 刪除資源
- 使用 Helm 解除安裝
- 使用 ArgoCD 刪除應用程式

### 環境變數

列出建置和部署時需要的環境變數。這些變數應該在 `project.env` 中設定，執行時會自動注入到容器中。

### 特殊需求

描述任何特殊需求，例如：
- 錯誤處理方式
- 日誌輸出格式
- 並行執行
- 重試機制

## 範例

參考 `docs/generate-cicd-scripts.examples.md` 查看各種專案類型的完整範例：

- Node.js/TypeScript 專案 (kubectl 部署)
- Node.js/Vue 專案 (Helm 部署)
- Python 專案 (ArgoCD 部署)
- Go 專案 (kubectl 部署)
- Helm Chart 專案 (Loki Stack)

## 腳本執行順序

根據 KDE CLI 的規範，腳本會依以下順序執行：

1. `pre-build.sh` (如果存在)
2. `build.sh` (如果存在)
3. `post-build.sh` (如果存在)
4. `pre-deploy.sh` (如果存在)
5. `deploy.sh` (如果存在)
6. `post-deploy.sh` (如果存在)

執行 `kde proj undeploy` 時會執行：
- `undeploy.sh` (如果存在，否則預設刪除 namespace)

## 腳本執行環境

腳本會在對應的 Docker 容器中執行：

- **CI 腳本** (pre-build.sh, build.sh, post-build.sh):
  - 預設使用 `DEVELOP_IMAGE`（在 project.env 中設定）
  - 可以透過 `PRE_BUILD_IMAGE`、`BUILD_IMAGE`、`POST_BUILD_IMAGE` 自訂

- **CD 腳本** (pre-deploy.sh, deploy.sh, post-deploy.sh, undeploy.sh):
  - 預設使用 `DEPLOY_IMAGE`（在 project.env 中設定）
  - 可以透過 `PRE_DEPLOY_IMAGE`、`POST_DEPLOY_IMAGE`、`UNDEPLOY_IMAGE` 自訂

## 環境變數注入

所有在 `project.env` 中設定的環境變數都會自動注入到執行腳本的容器中。例如：

```bash
# project.env
GIT_REPO_URL=my-repo
DEVELOP_IMAGE=node:22
DEPLOY_IMAGE=r82wei/deploy-env:1.0.0
NODE_ENV=production
```

在腳本中可以直接使用這些環境變數：

```bash
# build.sh
echo "Building ${GIT_REPO_URL} with NODE_ENV=${NODE_ENV}"
```

## 最佳實踐

### 1. 錯誤處理

建議在所有腳本開頭加入：

```bash
#!/bin/bash
set -e  # 遇到錯誤立即退出
set -o pipefail  # 處理管道錯誤
```

### 2. 日誌輸出

建議在關鍵步驟輸出日誌：

```bash
echo "=== 開始建置 ==="
npm install
npm run build
echo "=== 建置完成 ==="
```

### 3. 等待部署完成

部署後建議等待資源就緒：

```bash
kubectl rollout status deployment/my-app -n my-namespace --timeout=5m
```

### 4. 健康檢查

部署後執行健康檢查：

```bash
kubectl wait --for=condition=ready pod -l app=my-app -n my-namespace --timeout=300s
```

## 常見問題

### Q: 如果我不需要某個腳本怎麼辦？

A: 在 `generate-cicd-scripts.md` 中將對應的「是否需要」選項設為 `否`，或者直接不產生該腳本。KDE CLI 會自動跳過不存在的腳本。

### Q: 如何自訂執行環境的 Docker Image？

A: 在 `project.env` 中設定對應的環境變數：
- `PRE_BUILD_IMAGE` - pre-build.sh 的執行環境
- `BUILD_IMAGE` - build.sh 的執行環境
- `POST_BUILD_IMAGE` - post-build.sh 的執行環境
- `PRE_DEPLOY_IMAGE` - pre-deploy.sh 的執行環境
- `POST_DEPLOY_IMAGE` - post-deploy.sh 的執行環境
- `UNDEPLOY_IMAGE` - undeploy.sh 的執行環境

### Q: 如何掛載檔案到容器中？

A: 在 `project.env` 中使用 `KDE_MOUNT_` 開頭的環境變數：

```bash
# 將本地 ~/.netrc 掛載到容器內的 ~/.netrc
KDE_MOUNT_NETRC=~/.netrc:~/.netrc
```

### Q: 如何測試產生的腳本？

A: 可以使用 KDE CLI 的指令測試：

```bash
# 只執行 CI（建置）
kde proj build my-project

# 執行完整的 CI/CD（建置 + 部署）
kde proj deploy my-project

# 只執行 CD（部署）
kde proj deploy-only my-project

# 解除部署
kde proj undeploy my-project
```

## 相關文件

- [KDE 開發架構說明](./development-architecture.md)
- [Workspace 資料夾結構及檔案說明](./folder.structure.md)
- [ArgoCD 部署指南](./argocd-deployment.md)
- [專案設定說明](./project-env.setting.md)

## 支援

如有問題或建議，請參考專案的相關文件或聯繫專案維護者。

