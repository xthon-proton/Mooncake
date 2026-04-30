#!/usr/bin/env bash
# =============================================================================
# 10_build_image.sh — docker build + 7z 打包
# =============================================================================
set -euo pipefail
SCRIPT_NAME="10_build_image"
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(cd "$THIS_DIR/.." && pwd)"
source "$(cd "$STAGE_DIR/../pre-mooncake/scripts/lib" && pwd)/common.sh"

require_env WORKSPACE IMAGE_NAME IMAGE_TAG BASE_IMAGE BUILD_PROFILE

CTX_DIR="${WORKSPACE}/build-context"
[[ -d "$CTX_DIR" ]] || die "build context 缺失：$CTX_DIR（请先执行 00_pull_artifact.sh）"

GIT_SHA="$(git -C "$(dirname "$STAGE_DIR")/.." rev-parse --short=8 HEAD 2>/dev/null || echo unknown)"
FULL_TAG="${IMAGE_NAME}:${IMAGE_TAG}"
SHA_TAG="${IMAGE_NAME}:${IMAGE_TAG}-${GIT_SHA}"
LATEST_TAG="${IMAGE_NAME}:latest"

log_info "docker build (BUILD_PROFILE=${BUILD_PROFILE}) → $FULL_TAG / $SHA_TAG / $LATEST_TAG"

# 必须 cd 到 build context 目录再 docker build —— 这正是 [5] 你的疑问：
# COPY 指令的源路径是相对 build context 的，所以构建前必须切换工作目录。
cd "$CTX_DIR"
docker build \
    --progress=plain \
    --build-arg BASE_IMAGE="${BASE_IMAGE}" \
    --build-arg BUILD_PROFILE="${BUILD_PROFILE}" \
    -t "$FULL_TAG" \
    -t "$SHA_TAG" \
    -t "$LATEST_TAG" \
    .

# ---- 导出镜像为 tar，再用 7z 打包 -----------------------------------------
mkdir -p "${DIST_DIR}"
IMAGE_TAR="${DIST_DIR}/${IMAGE_NAME}_${IMAGE_TAG}_${GIT_SHA}.tar"
log_info "docker save → $IMAGE_TAR"
docker save -o "$IMAGE_TAR" "$FULL_TAG" "$SHA_TAG"

PKG_NAME="V0.1_Images_EulerOS-Aarch64_Docker-MooncakeStoreServer-Any.7z"
PKG_PATH="${DIST_DIR}/${PKG_NAME}"
rm -f "$PKG_PATH"

command -v 7z >/dev/null 2>&1 || die "7z 未安装（yum install -y p7zip）"
( cd "$DIST_DIR" && 7z a -mx=5 "$PKG_NAME" "$(basename "$IMAGE_TAR")" )
log_info "镜像 7z 已生成：$PKG_PATH"
ls -lh "$PKG_PATH"

# 中间 tar 可保留（便于人工 docker load 验证）；如需精简可解开下面注释：
# rm -f "$IMAGE_TAR"
