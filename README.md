# KDE Workspace

由 [kde-cli](https://github.com/r82wei/KDE-cli.git) 產生的 K8S 開發環境，透過 docker 啟動本地 K8S 或連接現有的 K8S 進行專案的開發及測試，並且模擬 CI/CD 腳本執行，減少開發環境與正式環境的差異。

kde-cli 主要功能：

- 建立開發環境 (容器開發環境 / 容器部署環境 / 本地 K8S / 遠端 K8S 連接)
- 模擬部署服務 (CI/CD Pipeline)
- 整合開發工具 (k9s / headlamp / telepresence)
- 對外公開服務 (Ngrok / Cloudflare tunnel)

#### [Workspace 資料夾結構及檔案說明](./docs/folder.structure.md)

#### [KDE 開發架構說明](./docs/development-architecture.md)

## Requirements

- Linux / MacOS / Windows WSL2
  - 如果使用 Windows WSL2，workspace 資料夾不可以放在 /mnt/ 底下，需要放在 VHD 上，例如 /home/your-username/ 底下
- [Docker](https://www.docker.com/) / [Orbstack](https://orbstack.dev/)

## 初始化環境

- 安裝 [kde-cli](https://github.com/r82wei/KDE-cli.git) 並且初始化環境 `(需要 sudo 權限)`
  ```
  ./init.sh
  ```

## 開始使用

### 啟動本地 K8S

- 啟動當前使用的 k8s 環境 (可以從 current.env 或是執行指令 `kde cur` 查詢目前使用的 k8s 環境)
  ```
  kde start
  ```
- 啟動指定 k8s 環境

  ```
  kde start [環境名稱]
  ```

  #### 如果環境不存在時，第一次啟動如果啟動到一半退出或停止，最好執行 `kde stop && kde remove [環境名稱]`，然後重新建立

### 部署專案

- 互動式選單選擇專案

  ```
  kde proj deploy
  ```

- 直接指定專案
  ```
  kde proj deploy [專案名稱]
  ```

### 查看服務狀態 & log

#### [K9S](https://k9scli.io/) (CLI K8S Dashboard)

- 啟動 K9S
  ```
  kde k9s
  ```
- 啟動 K9S 並且指定可以 Port forward 的 Port (使用方式跟 docker run -p 相同)

  ```
  kde k9s -p [port]

  # 範例
  kde k9s -p 8080        將 k9s Port forward 到 8080 的 Port 對應到本機的 8080
  kde k9s -p 8080,8081   Port forward 到本機 8080、8081 兩個 Port
  kde k9s -p 8080-8090   Port forward 到本機 8080 ~ 8090 整段的 Port
  ```

#### [Headlamp](https://headlamp.dev/) (Web UI sK8S Dashboard)

- 啟動
  ```
  kde headlamp
  ```
- 啟動 headlamp 並且指定啟動的 Port

  ```
  kde headlamp -p [port]
  ```

### 將服務 Port forward 到本地

- 互動式選單選擇要 Port forward 的服務

  ```
  kde expose
  ```

- 直接指定服務

  ```
  kde expose [option] [namespace] [pod|service] [(pod|service) name] [target port] [local port]

  option:
    -d: 在背景執行

  # 範例
  kde expose my-app pod mysql 3306 3306           將 namespace my-app 內的 mysql pod 3306 port 對應到本地的 3306 port
  kde expose -d my-app service mysql 3306 3306    將 namespace my-app 內的 mysql service 3306 port 對應到本地的 3306 port，並且在背景執行
  ```

### 重新部署專案

#### ⚠️ 需要解除部署再重新部署時才使用，如果只是修改 yaml，可以直接執行部署就好

- 互動式選單選擇專案

  ```
  kde proj redeploy
  ```

- 直接指定專案
  ```
  kde proj redeploy [專案名稱]
  ```

### 解除部署專案

- 互動式選單選擇專案

  ```
  kde proj undeploy
  ```

- 直接指定專案
  ```
  kde proj undeploy [專案名稱]
  ```

### 查詢當前使用的 K8S

- 使用指令
  ```
  kde cur
  ```
- 查看設定檔 `current.env`
  ```
  CUR_ENV=[當前環境]
  ```

### 切換 K8S

- 切換當前使用的 k8s 環境 (可以從 current.env 或是執行指令 `kde cur` 查詢目前使用的 k8s 環境)
  ```
  kde use
  ```
- 切換指定 k8s 環境
  ```
  kde use [環境名稱]
  ```

### 關閉 K8S

- 關閉當前使用的 k8s 環境 (可以從 current.env 或是執行指令 `kde cur` 查詢目前使用的 k8s 環境)
  ```
  kde start
  ```
- 關閉指定 k8s 環境
  ```
  kde stop [環境名稱]
  ```

## 常見問題

### 如何將本地檔案或資料夾掛載到 Pod 內

建立一個與要掛載的檔案或資料夾同名的 PVC，並且使用 `StorageClass: local-path`，然後掛載到 Pod，local-path 會自動掛載 `專案資料夾` 底下與 PVC 同名的檔案或資料夾。

範例：

以 MySQL 掛載資料夾為例

- 假設目前環境底下有專案 my-app (專案資料夾路徑：./environments/local-k8s/namespaces/my-app)
- 在 K8S 內建立名稱為 mysql-data 的 PVC ，並且設定 `StorageClass: local-path`
- 在 mysql Pod 掛載 PVC mysql-data 到 /var/lib/mysql

結果：Pod 內的 /var/lib/mysql 會掛載到本機路徑：./environments/local-k8s/namespaces/my-app/mysql-data

### 如何將檔案或資料夾掛載到本地開發容器或是 CI/CD 執行環境

依照作用範圍，在下列環境變數檔案加上 `KDE_MOUNT_` 開頭的環境變數，設定對應的路徑

- kde.env
- environments/[name]/k8s.env
- environments/[name]/.env
- environments/[name]/namespaces/[project name]/project.env

範例：

```bash
# 將本地 HOME 底下的 .netrc 掛載到 container 內的 ~/.netrc
KDE_MOUNT_NETRC=~/.netrc:~/.netrc
```

### kde-cli 執行異常，如何啟動除錯模式 (Debug Mode)

在 `kde.env` 設定檔內，加入環境變數 `KDE_DEBUG=true`，即可啟動除錯模式。

## 其他說明

### [專案設定說明](./docs/project-env.setting.md)

### [Shell 腳本使用說明](./docs/shell.usage.md)

### [透過 Telepresence 擷取遠端 K8S Pod 流量到容器開發環境進行開發](./docs/telepresence.usage.md)

### [使用 Ngrok 建立對外網址](./docs/ngrok.usage.md)

### [使用 Cloudflare Tunnel 建立對外網址](./docs/cloudflare-tunnel.usage.md)

### [使用 code-server(VS Code) Web IDE](./docs/code-server.usage.md)
