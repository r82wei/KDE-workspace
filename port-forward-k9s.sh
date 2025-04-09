#!/bin/bash

# 啟動 k9s

EXPOSE_PORT=$1

if [[ -z "${EXPOSE_PORT}" ]]; then
    read -p "請輸入要 k9s port-forward 的 port(e.g. 8080 or 30000-30010): " EXPOSE_PORT
fi

kde k9s --port ${EXPOSE_PORT}