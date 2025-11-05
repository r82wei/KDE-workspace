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

source ./current.env
source ./environments/${CUR_ENV}/namespaces/${project}/project.env
REPO_DIR=./environments/${CUR_ENV}/namespaces/${project}/$(basename -s .git ${GIT_REPO_URL})

# 如果 project 的 repo 是空的，則先 clone repo

if [[ ! -d ${REPO_DIR} ]]; then
    echo "Repo 不存在，git clone repo ${GIT_REPO_URL} ..."
    kde project pull ${project}
fi

kde project deploy ${project}
kde k9s

