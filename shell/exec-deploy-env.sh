#!/bin/bash

projects=($(kde project list))
PS3="請選擇一個專案（輸入編號）："
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
            echo "你選擇了: $project"
            break
            ;;
    esac
done

kde project exec ${project} deploy

