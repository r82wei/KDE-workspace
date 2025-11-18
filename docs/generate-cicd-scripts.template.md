# CI/CD 腳本產生模板

此文件用於描述專案的 CI/CD 需求，AI Agent 會讀取此文件並自動產生對應的 `.sh` 腳本。

## 專案基本資訊

### 專案名稱

<!-- 專案名稱，通常與 namespace 相同 -->

專案名稱: `your-project-name`

### 專案描述

<!-- 簡短描述專案的功能和用途 -->

專案描述: 這是一個 [描述專案功能]

### 技術棧

<!-- 列出專案使用的主要技術 -->

- 程式語言: `nodejs` | `python` | `go` | `java` | `rust` | `其他`
- 框架/工具: `express` | `django` | `react` | `vue` | `其他`
- 建置工具: `npm` | `yarn` | `pnpm` | `pip` | `maven` | `gradle` | `cargo` | `其他`
- 容器化: `是` | `否` (是否有 Dockerfile)

### 專案目錄結構

<!-- 描述專案的主要目錄結構，特別是原始碼和建置產物的位置 -->

```
專案根目錄/
├── src/              # 原始碼目錄
├── build/            # 建置產物目錄
├── package.json      # Node.js 專案
└── Dockerfile        # Docker 檔案（如果有）
```

## 建置流程 (CI)

### 建置前置作業 (pre-build.sh)

<!-- 描述在執行建置前需要做的事情，例如：安裝全域工具、設定環境變數等 -->

```bash
# 範例：設定 npm 快取
# NPM_CONFIG_USERCONFIG=$(dirname $PWD)/.npmrc npm config set cache "$(dirname $PWD)/.npm"
```

**是否需要 pre-build.sh**: `是` | `否`

**前置作業說明**:

<!-- 描述需要執行的前置作業，如果不需要則留空 -->

- [ ] 設定 npm 快取路徑
- [ ] 安裝全域依賴
- [ ] 設定環境變數
- [ ] 其他: **\*\***\_\_\_**\*\***

### 建置步驟 (build.sh)

<!-- 描述如何編譯和打包專案 -->

```bash
# 範例：Node.js 專案
# cd project-directory
# npm install
# npm run build
```

**建置命令**:

```bash
# 請列出完整的建置命令序列
# 1. 切換到專案目錄（如果需要）
# 2. 安裝依賴
# 3. 執行建置
# 4. 其他建置步驟
```

**建置產物位置**:

<!-- 建置完成後的產物存放位置 -->

- 目錄: `build/` | `dist/` | `target/` | `其他: _______`
- 檔案: `index.js` | `app.jar` | `其他: _______`

### 建置後置作業 (post-build.sh)

<!-- 描述在執行建置後需要做的事情，例如：執行測試、產生報告等 -->

```bash
# 範例：執行測試
# npm test
```

**是否需要 post-build.sh**: `是` | `否`

**後置作業說明**:

<!-- 描述需要執行的後置作業，如果不需要則留空 -->

- [ ] 執行單元測試
- [ ] 執行整合測試
- [ ] 產生測試報告
- [ ] 上傳建置產物
- [ ] 其他: **\*\***\_\_\_**\*\***

## 部署流程 (CD)

### 部署方式

<!-- 選擇部署方式 -->

- [ ] `kubectl` - 使用原生 Kubernetes YAML 部署
- [ ] `helm` - 使用 Helm Chart 部署
- [ ] `argocd` - 使用 ArgoCD 部署
- [ ] `docker` - 僅建置 Docker Image
- [ ] `其他` - 自訂部署方式

### 部署前置作業 (pre-deploy.sh)

<!-- 描述在執行部署前需要做的事情，例如：產生 YAML、驗證配置等 -->

```bash
# 範例：使用 Helm 產生 YAML
# helm template my-app . -f values.yaml > manifests.yaml
```

**是否需要 pre-deploy.sh**: `是` | `否`

**前置作業說明**:

<!-- 描述需要執行的前置作業，如果不需要則留空 -->

- [ ] 產生 Kubernetes YAML 檔案
- [ ] 驗證 Helm Chart
- [ ] 設定 ArgoCD Repository
- [ ] 其他: **\*\***\_\_\_**\*\***

### 部署步驟 (deploy.sh)

#### 如果使用 kubectl

```bash
# 範例：使用 kubectl 部署
# kubectl apply -f k8s/
# kubectl rollout status deployment/my-app -n my-namespace
```

**部署命令**:

```bash
# 請列出完整的部署命令序列
# 1. 套用 Kubernetes manifests
# 2. 等待部署完成
# 3. 驗證部署狀態
```

**Kubernetes manifests 位置**:

- 目錄: `k8s/` | `manifests/` | `其他: _______`

#### 如果使用 Helm

```bash
# 範例：使用 Helm 部署
# helm upgrade --install my-app . -f values.yaml -n my-namespace --create-namespace
```

**Helm Chart 位置**:

- 目錄: `./` | `helm/` | `chart/` | `其他: _______`

**Helm values 檔案**:

- 檔案: `values.yaml` | `values-dev.yaml` | `其他: _______`

**Helm 部署參數**:

```bash
# 請列出 Helm 部署時需要的參數
# --namespace: my-namespace
# --create-namespace: true
# --set: key=value
# -f: values.yaml
```

#### 如果使用 ArgoCD

```bash
# 範例：使用 ArgoCD 部署
# argocd login ${ARGOCD_SERVER} --username ${ARGOCD_USERNAME} --password ${ARGOCD_PASSWORD}
# argocd app sync ${ARGOCD_APP_NAME}
```

**ArgoCD 設定** (這些變數應該在 project.env 中設定):

- `ARGOCD_SERVER`: ArgoCD Server 位址
- `ARGOCD_USERNAME`: ArgoCD 使用者名稱
- `ARGOCD_PASSWORD`: ArgoCD 密碼
- `ARGOCD_APP_NAME`: ArgoCD 應用程式名稱
- `ARGOCD_NAMESPACE`: 目標 namespace
- `ARGOCD_PROJECT`: ArgoCD Project 名稱

**ArgoCD 部署方式**:

- [ ] 使用 ArgoCD CLI 同步應用程式
- [ ] 使用 ArgoCD Application Manifest (YAML)
- [ ] 使用 GitOps 流程（提交 manifests 到 Git）

#### 如果使用 Docker

```bash
# 範例：建置和推送 Docker Image
# docker build -t my-image:tag .
# docker push my-image:tag
```

**Docker Image 資訊**:

- Image 名稱: `my-image`
- Tag 策略: `latest` | `git-commit` | `git-tag` | `其他: _______`
- Registry: `docker.io` | `ghcr.io` | `其他: _______`

### 部署後置作業 (post-deploy.sh)

<!-- 描述在執行部署後需要做的事情，例如：健康檢查、通知等 -->

```bash
# 範例：健康檢查
# kubectl wait --for=condition=available --timeout=300s deployment/my-app -n my-namespace
```

**是否需要 post-deploy.sh**: `是` | `否`

**後置作業說明**:

<!-- 描述需要執行的後置作業，如果不需要則留空 -->

- [ ] 等待 Pod 就緒
- [ ] 執行健康檢查
- [ ] 執行冒煙測試
- [ ] 發送通知（Slack、Email 等）
- [ ] 其他: **\*\***\_\_\_**\*\***

### 解除部署 (undeploy.sh)

<!-- 描述如何解除部署 -->

```bash
# 範例：使用 kubectl 刪除
# kubectl delete -f k8s/
```

**解除部署方式**:

- [ ] 使用 kubectl 刪除資源
- [ ] 使用 Helm 解除安裝
- [ ] 使用 ArgoCD 刪除應用程式
- [ ] 刪除 namespace（預設行為）
- [ ] 其他: **\*\***\_\_\_**\*\***

**解除部署命令**:

```bash
# 請列出解除部署的命令序列
```

## 環境變數

### 建置環境變數

<!-- 建置時需要的環境變數，這些會從 project.env 注入到容器中 -->

```bash
# 範例
# NODE_ENV=production
# BUILD_VERSION=1.0.0
```

**需要的環境變數**:

- `變數名稱`: 說明
- `變數名稱`: 說明

### 部署環境變數

<!-- 部署時需要的環境變數 -->

```bash
# 範例
# KUBECONFIG=/path/to/kubeconfig
# HELM_NAMESPACE=my-namespace
```

**需要的環境變數**:

- `變數名稱`: 說明
- `變數名稱`: 說明

## 特殊需求

### 錯誤處理

<!-- 描述錯誤處理的需求 -->

- [ ] 使用 `set -e` 遇到錯誤立即退出
- [ ] 使用 `set -o pipefail` 處理管道錯誤
- [ ] 自訂錯誤處理邏輯

### 日誌輸出

<!-- 描述日誌輸出的需求 -->

- [ ] 輸出詳細的執行日誌
- [ ] 使用顏色標記不同階段
- [ ] 記錄執行時間

### 其他特殊需求

<!-- 描述其他特殊需求，例如：並行執行、重試機制等 -->

```
請在此描述其他特殊需求
```

## 注意事項

<!-- 任何需要注意的事項，例如：依賴順序、特殊配置等 -->

- 注意事項 1
- 注意事項 2

## 參考資料

<!-- 相關的文件或連結 -->

- [相關文件連結]
- [相關文件連結]

