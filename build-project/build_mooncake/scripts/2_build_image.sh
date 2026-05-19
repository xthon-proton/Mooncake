#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# 2_build_image.sh — docker build + 7z 打包
# =============================================================================
set -euo pipefail
SCRIPT_NAME="2_build_image"
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(cd "$THIS_DIR/.." && pwd)"
# 跨阶段唯一公共函数库（Mooncake-build/lib/common.sh, 含 init_build_image_params）
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/common.sh"

# 初始化 OS_ARCH, IMAGE_LABEL
init_build_image_params

# 变量声明
: "${B_VERSION:=1.0.00000001}"

: "${BASE_IMAGE:=libforlayer:1.0.0}"
: "${IMAGE_NAME:=mooncake-store-server}"
: "${IMAGE_TAG:=${B_VERSION}}"

# 变量检测
require_env WORKSPACE BASE_IMAGE SUB_VERSION IMAGE_NAME OS_ARCH IMAGE_LABEL

CTX_DIR="${WORKSPACE}/build-context"
[[ -d "$CTX_DIR" ]] || die "build context 缺失：$CTX_DIR（请先执行 1_pull_artifact.sh）"

FULL_TAG="${IMAGE_NAME}:${IMAGE_TAG}"

log_info "docker build $FULL_TAG"

# --- BUILD image ---
# 必须 cd 到 build context 目录再 docker build —— 这正是 [5] 你的疑问：
# COPY 指令的源路径是相对 build context 的，所以构建前必须切换工作目录。
# 传递参数, 替换 基础镜像, label from
cd "$CTX_DIR"
docker version
docker build \
    --progress=plain \
    --build-arg BASE_IMAGE="${BASE_IMAGE}" \
    --build-arg BASE_IMAGE_LABEL="${IMAGE_LABEL}" \
    -t "$FULL_TAG" \
    .

# --- 镜像瘦身，并导出 tar 包 ---
# 需要基础镜像名，目标镜像名，tar包名，保存路径'
# tar包名结构：mooncake-store-server-{B_VERSION}-{OS_ARCH}
IMAGE_TAR_NAME="${IMAGE_NAME}-${IMAGE_TAG}-${OS_ARCH}"
TAR_SAVE_PATH="${DIST_DIR}/images"

# 执行完毕后, tar文件位于: ${DIST_DIR}/images/${IMAGE_TAR_NAME}
sh "${STAGE_DIR}"/lib/save_image_slim.sh -b "${BASE_IMAGE}" -a "${FULL_TAG}" -r "${IMAGE_TAR_NAME}" -p "${TAR_SAVE_PATH}"

# 输出 meta-info.yaml
cat <<EOF > "${DIST_DIR}"/images/meta-info.yaml
images:
  - pkg: ${IMAGE_TAR_NAME}
    tag: ${FULL_TAG}
    dependency: ${DEPENDENCY_IMAGE_NAME}:${B_VERSION}
EOF
ls -al "${DIST_DIR}"/images/meta-info.yaml
log_info "Success to save mooncake-store-server image -> ${DIST_DIR}/images/${IMAGE_TAR_NAME}"
