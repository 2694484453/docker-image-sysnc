#!/bin/sh
# 判断目录是否存在
if [ ! -d "~/.docker" ]; then
    mkdir -p ~/.docker
fi

#拷贝认证信息
cp ./auth/auth-config.json  ~/.docker/config.json

# 读取JSON文件
CONFIG_FILE="./config/images-config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "配置文件 $CONFIG_FILE 不存在"
    exit 1
fi

# 使用jq解析JSON文件
REPO_NAME=$(jq -r '.name' "$CONFIG_FILE")
VERSIONS=($(jq -r '.version[]' "$CONFIG_FILE"))
TARGET_HOST=$(jq -r '.["sync-repo-list"][0].host' "$CONFIG_FILE")
TARGET_NAMESPACE=$(jq -r '.["sync-repo-list"][0].namespace' "$CONFIG_FILE")
TARGET_NAME=$(jq -r '.["sync-repo-list"][0].name' "$CONFIG_FILE")

TARGET_REPO="$TARGET_HOST/$TARGET_NAMESPACE/$TARGET_NAME"

# 检查是否安装了jq
if ! command -v jq &> /dev/null; then
    echo "jq 命令未找到，请先安装 jq"
    exit 1
fi

# 循环处理每个版本
for VERSION in "${VERSIONS[@]}"; do
    echo "正在处理版本: $VERSION"

    # 拉取镜像
    docker pull "$REPO_NAME:$VERSION"
    if [ $? -ne 0 ]; then
        echo "拉取镜像失败: $REPO_NAME:$VERSION"
        continue
    fi

    # 打标签
    docker tag "$REPO_NAME:$VERSION" "$TARGET_REPO:$VERSION"
    if [ $? -ne 0 ]; then
        echo "打标签失败: $REPO_NAME:$VERSION -> $TARGET_REPO:$VERSION"
        continue
    fi

    # 推送镜像
    docker push "$TARGET_REPO:$VERSION"
    if [ $? -ne 0 ]; then
        echo "推送镜像失败: $TARGET_REPO:$VERSION"
        continue
    fi

    echo "版本 $VERSION 处理完成"
done

echo "所有版本处理完毕"
