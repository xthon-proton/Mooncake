#!/usr/bin/env bash
# =============================================================================
# 3_build_chart.sh — helm package + 7z 打包
#
# 输出结构（解开 7z 后）：
#   V0.1_Chart_Any_Docker-MooncakeStoreServer-Any.7z
#   └── mooncake_store_server-v0.1.tgz                ← helm package 标准产物
#       └── mooncake_store_server/
#           ├── Chart.yaml
#           ├── values.yaml
#           └── templates/...
# =============================================================================
set -euo pipefail
SCRIPT_NAME="3_build_chart"
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(cd "$THIS_DIR/.." && pwd)"
source "$(cd "$THIS_DIR/../../lib" && pwd)/common.sh"

require_env WORKSPACE CHART_VERSION

CHART_SRC="${STAGE_DIR}/chart/mooncake_store_server"
[[ -d "$CHART_SRC" ]] || die "chart 源不存在：$CHART_SRC"

command -v helm >/dev/null 2>&1 || die "helm 未安装（构建机请预装 helm v3）"

CHART_OUT="${WORKSPACE}/chart-out"
rm -rf "$CHART_OUT" && mkdir -p "$CHART_OUT"

log_info "helm lint"
helm lint "$CHART_SRC"

log_info "helm package → $CHART_OUT"
helm package "$CHART_SRC" --version "${CHART_VERSION}" --app-version "${CHART_VERSION}" -d "$CHART_OUT"

TGZ_FILE="$(ls "$CHART_OUT"/*.tgz | head -n1)"
[[ -f "$TGZ_FILE" ]] || die "helm package 未产出 tgz"
log_info "chart tgz: $TGZ_FILE"

# 7z 包名固定（按 #10 + [4] 约定）
PKG_NAME="V0.1_Chart_Any_Docker-MooncakeStoreServer-Any.7z"
PKG_PATH="${DIST_DIR}/${PKG_NAME}"
rm -f "$PKG_PATH"
mkdir -p "$DIST_DIR"

command -v 7z >/dev/null 2>&1 || die "7z 未安装（yum install -y p7zip）"
( cd "$CHART_OUT" && 7z a -mx=5 "$PKG_PATH" "$(basename "$TGZ_FILE")" )
log_info "chart 7z 已生成：$PKG_PATH"
ls -lh "$PKG_PATH"
