# 使用 Cloudflare Tunnel 建立對外網址

### ⚠️  網域名稱必須由 Cloudflare 託管 DNS 服務

### 下列說明以「gosu.world」網域名稱為例，第一次執行會產生 cloudflare 登入網址，需要透過瀏覽器登入取得憑證 (會將憑證存在 .cloudflared 資料夾內，後續就不用再登入)

## 使用說明

### 將自訂網址對應到指定的 URL

- ⚠️  因為是在 container 內執行，如果要對應到本地的 8080 port，不可以直接使用 http://127.0.0.1:8080，而是需要輸入本地的 IP，例如： http://192.168.0.20:8080

```bash
kde cloudflare-tunnel [domain] [url]

# 此範例將會自動設定 DNS test.gosu.world 並且 proxy 到 192.168.0.20 的 8080 port
kde cloudflare-tunnel test.gosu.world http://192.168.0.20:8080
```

### 將自訂網址對應到當前環境的 ingress

```bash
kde cloudflare-tunnel [domain] ingress

# 此範例將會自動設定 DNS test.gosu.world 並且 proxy 到當前環境的 ingress controller
kde cloudflare-tunnel test.gosu.world ingress
```

### 將自訂網址對應到當前環境的 service

```bash
kde cloudflare-tunnel [domain] service

# 此範例將會自動設定 DNS test.gosu.world 並且 proxy 到後續使用者選擇的 namespace 內的 service port
kde cloudflare-tunnel test.gosu.world service
```

### 將自訂網址對應到當前環境的 pod

```bash
kde cloudflare-tunnel [domain] pod

# 此範例將會自動設定 DNS test.gosu.world 並且 proxy 到後續使用者選擇的 namespace 內的 pod port
kde cloudflare-tunnel test.gosu.world http://localhost:8080
```
