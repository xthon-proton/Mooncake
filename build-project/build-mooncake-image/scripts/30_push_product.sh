#!/usr/bin/env bash
# =============================================================================
# 30_push_product.sh — 推送 image 7z + chart 7z 到产品仓
# 当前为 mock 实现：仅打印将要执行的上传命令。
# =============================================================================
set -euo pipefail
SCRIPT_NAME="30_push_product"
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(cd "$THIS_DIR/.." && pwd)"
source "$(cd "$STAGE_DIR/../pre-mooncake/scripts/lib" && pwd)/common.sh"

require_env WORKSPACE PRODUCT_REPO_BASE CHART_VERSION

IMAGE_PKG="${DIST_DIR}/V0.1_Images_EulerOS-Aarch64_Docker-MooncakeStoreServer-Any.7z"
CHART_PKG="${DIST_DIR}/V0.1_Chart_Any_Docker-MooncakeStoreServer-Any.7z"
[[ -f "$IMAGE_PKG" ]] || die "image 7z 不存在：$IMAGE_PKG"
[[ -f "$CHART_PKG" ]] || die "chart 7z 不存在：$CHART_PKG"

IMG_URL="${PRODUCT_REPO_BASE}/${CHART_VERSION}/images/$(basename "$IMAGE_PKG")"
CHT_URL="${PRODUCT_REPO_BASE}/${CHART_VERSION}/charts/$(basename "$CHART_PKG")"

log_info "[MOCK] upload image  : $IMAGE_PKG → $IMG_URL"
log_info "[MOCK] upload chart  : $CHART_PKG → $CHT_URL"
log_warn "实际请替换为公司内部产品仓客户端命令，例如："
cat <<EOF
# curl -fSL -u "\${REPO_USER}:\${REPO_TOKEN}" -T "${IMAGE_PKG}" "${IMG_URL}"
# curl -fSL -u "\${REPO_USER}:\${REPO_TOKEN}" -T "${CHART_PKG}" "${CHT_URL}"
EOF
log_info "[MOCK] 推送完成（伪）"
