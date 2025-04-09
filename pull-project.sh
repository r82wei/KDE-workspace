#!/bin/bash

PROJECT=$1

if [[ -z "${PROJECT}" ]]; then
    projects=($(kde project list))
    PS3="請選擇一個 Porject（輸入編號）："
    select project in "${projects[@]}" "退出"
    do
        case $project in
            "退出")
                echo "退出"
                exit 0
                ;;
            "")
                echo "無效選擇，請重新輸入。"
                ;;
            *)
                echo "你選擇了 Project: $project"
                export TARGET_PROJECT=$project
                break
                ;;
        esac
    done
else 
    export TARGET_PROJECT=$PROJECT
fi

kde project pull ${TARGET_PROJECT}