#!/bin/bash


environments=($(kde list))
PS3="請選擇一個 K8S 環境（輸入編號）："
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
            echo "你選擇的 K8S 環境: $environment"
            export TARGET_ENVIRONMENT=$environment
            break
            ;;
    esac
done

kde use ${TARGET_ENVIRONMENT}