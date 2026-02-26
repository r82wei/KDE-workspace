# OpenClaw 文件同步

透過 mount --bind 掛載資料夾，讓不同的 container 內可以同步
- 注意：需要在 kind 啟動前執行 mount，否則需要重啟 kind
```
sudo mount --bind [openclaw obsidian vault 資料夾] [本地 k8s pvc obsidian vault 資料夾]
```