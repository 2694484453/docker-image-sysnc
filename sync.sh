#!/bin/sh
# 判断目录是否存在
if [ ! -d "~/.docker" ]; then
    mkdir -p ~/.docker
fi

#拷贝认证信息
cp ./config/auth-config.json  ~/.docker/config.json

# 读取JSON文件
CONFIG_FILE="./config/images-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "配置文件 $CONFIG_FILE 不存在"
    exit 1
fi

# 读取JSON配置文件中的镜像信息
jq -c '.[]' "$CONFIG_FILE" | while read -r image; do
    SOURCE_NAME=$(echo $image | jq -r '.name')

    # 获取版本集合
    SOURCE_VERSIONS=$(echo $image | jq -c '.versions[]')

    # 获取sync-list
    SYNC_LIST=$(echo $repo | jq -c '.["sync-list"][]')

    #遍历版本集合
    for SOURCE_VERSION in $SOURCE_VERSIONS; do
      echo "正在获取 $SOURCE_NAME 的 $SOURCE_VERSION 版本... "

      # 拉取镜像
      docker pull "$SOURCE_NAME:$SOURCE_VERSION"
      if [ $? -ne 0 ]; then
            echo "拉取镜像失败: $SOURCE_NAME:$SOURCE_VERSION"
            continue
       fi

      # 遍历sync-list
      for SYNC in $SYNC_LIST; do
          TARGET_HOST=$(echo $SYNC | jq -r '.host')
          TARGET_NAMESPACE=$(echo $SYNC | jq -r '.namespace')
          TARGET_NAME=$(echo $SYNC | jq -r '.name')
          TARGET_IMAGE_NAME="$TARGET_HOST/$TARGET_NAMESPACE/$TARGET_NAME"
          TARGET_VERSION=$SOURCE_VERSION
           # 打标签
           docker tag "$SOURCE_NAME:$SOURCE_VERSION" "$TARGET_IMAGE_NAME:$TARGET_VERSION"
           if [ $? -ne 0 ]; then
              echo "打标签失败: $SOURCE_NAME:$SOURCE_VERSION -> $TARGET_IMAGE_NAME:$TARGET_VERSION"
              continue
           fi
          # 推送镜像
           docker push "$TARGET_IMAGE_NAME:$TARGET_VERSION"
              if [ $? -ne 0 ]; then
                 echo "推送镜像失败: $TARGET_IMAGE_NAME:$TARGET_VERSION"
                 continue
              fi
                echo "版本 $VERSION 处理完成"
      done
    done
done
echo "所有版本处理完毕"
