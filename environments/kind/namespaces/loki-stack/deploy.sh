#!/bin/bash

echo "--------------------------------"
echo "請選擇要執行的操作:"
echo "1. 產生 yaml 檔案"
echo "2. 部署 Loki Stack"
read -p "請選擇(輸入編號): " deployment_mode

case $deployment_mode in
  1)
    # loki yaml
    helm template loki grafana/loki-stack \
    --debug \
    -f loki-stack.values.yaml \
    > loki.yaml
    ;;
  2)
    # 安裝 loki
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



