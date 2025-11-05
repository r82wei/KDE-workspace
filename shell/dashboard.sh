#!/bin/bash

read -p "請輸入要啟動的 Web Dashboard Port (Default: 4466): " PORT

# 啟動 Web UI Dashboard
kde headlamp -p ${PORT:-4466}