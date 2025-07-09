#!/bin/bash

if [ -z "$1" ]; then
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
else
    project=$1
fi

source ./current.env
source ./environments/${CUR_ENV}/namespaces/${project}/project.env
REPO_DIR=./environments/${CUR_ENV}/namespaces/${project}/$(basename -s .git ${GIT_REPO_URL})

# 如果 project 的 repo 是空的，則先 clone repo

if [[ ! -d ${REPO_DIR} ]]; then
    echo "Repo 不存在，git clone repo ${GIT_REPO_URL} ..."
    kde project pull ${project}
    # 如果失敗，就 exit 1
    if [[ $? -ne 0 ]]; then
        echo "git clone repo 失敗，請檢查 repo 是否存在或是是否擁有權限"
        exit 1
    fi
fi

kde project deploy ${project}

if [[ ${ENABLE_K9S} != "false" ]]; then
    kde k9s
fi

