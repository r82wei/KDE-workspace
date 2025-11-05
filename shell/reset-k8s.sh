#!/bin/bash

environments=($(kde list))
PS3="請選擇一個專案（輸入編號）："
select environment in "${environments[@]}" "退出"
do
    case $environment in
        "退出")
            echo "退出"
            exit 0
            ;;
        "")
            echo "無效選擇，請重新輸入。"
            ;;
        *)
            echo "你選擇了: $environment"
            break
            ;;
    esac
done

# 重置 k8s 環境
kde reset ${environment}