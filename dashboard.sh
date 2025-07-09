#!/bin/bash

read -p "請輸入要啟動的 Web UI Dashboard Port (Default: 9090): " PORT

# 啟動 Web UI Dashboard
kde dashboard -p ${PORT:-9090} --insecure