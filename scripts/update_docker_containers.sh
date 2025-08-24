#!/bin/bash
############################
# File Name: update_docker_containers.sh
# Author: alfred
# mail: wdjzsl@gmail.com
# Created Time: Tue 12 Aug 2025 12:13:38 PM CST
############################
DOCKERHUB_PROXY=${DOCKERHUB_PROXY:-docker.1ms.run}
GHCR_PROXY=${GHCR_PROXY:-ghcr.1ms.run}

# 1. 批量拉取镜像
docker ps --format "{{.Image}}" | while read image; do
  echo "处理镜像: $image"

  if echo "$image" | grep -q "ghcr.io"; then
    proxy_image=$(echo "$image" | sed "s|ghcr.io|$GHCR_PROXY|")
    docker pull "$proxy_image"
    # 打标签
    docker tag "$proxy_image" "$image"
    
  else
    docker pull "$DOCKERHUB_PROXY/$image"
    docker tag "$image" "$DOCKERHUB_PROXY/$image"
  fi
done



# 3. 运行 watchtower 更新容器（仅使用本地已拉取的镜像，不重新拉取）
docker run --rm --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e TZ=Asia/Shanghai \
  "$DOCKERHUB_PROXY/containrrr/watchtower" \
  --run-once --no-pull