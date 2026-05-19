#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
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
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/common.sh"

# 变量声明
: "${B_VERSION:=27.0.0}"
: "${CHART_VERSION:=${B_VERSION}}"

require_env WORKSPACE B_VERSION CHART_VERSION

CHART_SRC="${STAGE_DIR}/chart/mooncake_store_server"
[[ -d "$CHART_SRC" ]] || die "chart 源不存在：$CHART_SRC"

# 填充 version <- B_VERSION
sed -i "s|{{version}}|${CHART_VERSION}|g" "${CHART_SRC}"/Chart.yaml
sed -i "s|{{version}}|${CHART_VERSION}|g" "${CHART_SRC}"/values.yaml

command -v helm >/dev/null 2>&1 || die "helm 未安装（构建机请预装 helm v3）"

CHART_OUT="${WORKSPACE}/chart-out"
rm -rf "$CHART_OUT" && mkdir -p "$CHART_OUT"

log_info "helm lint"
helm lint "$CHART_SRC"

TGZ_FILE="mooncake_store_server-${CHART_VERSION}.tgz"
log_info "helm package → ${CHART_OUT}/${TGZ_FILE}"
helm package "$CHART_SRC" --version "${CHART_VERSION}" --app-version "${CHART_VERSION}" -d "$CHART_OUT"
# 预期 mooncake_store_server-27.0.0.tgz


[[ -f "${CHART_OUT}/${TGZ_FILE}" ]] || die "helm package 未产出 tgz"
log_info "Success to build mooncake_store_server chart tgz package:  ${CHART_OUT}/${TGZ_FILE}"

[ ! -d "${DIST_DIR}/charts" ] && mkdir -p "${DIST_DIR}/charts"
cp "${CHART_OUT}/${TGZ_FILE}" "${DIST_DIR}/charts/"
log_info "cp ${TGZ_FILE} -> ${DIST_DIR}/charts/${TGZ_FILE}"
ls -lh "${DIST_DIR}/charts/${TGZ_FILE}"
