#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# 1_pull_artifact.sh — 从制品仓拉取阶段一的 tar.gz，并解压到 build context
# 完成后 build context 形态：
#   ${WORKSPACE}/build-context/
#     ├── Dockerfile            ← 由本脚本拷入
#     ├── entrypoint.sh         ← 由本脚本拷入
#     ├── .dockerignore         ← 由本脚本拷入
#     ├── bin/mooncake_master
#     └── lib/*.so
#
# 调测：
# 调测时，从 $WORKSPACE/dist/ 直接拉取上一阶段构建的tar制品包
# =============================================================================
set -euo pipefail
SCRIPT_NAME="1_pull_artifact"

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(cd "$THIS_DIR/.." && pwd)"
# 跨阶段唯一公共函数库（build-project/lib/common.sh）
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/common.sh"

# 设置参数默认值
: "${MOONCAKE_VERSION:=v0.3.10}"
: "${ARTIFACT_REPO_BASE:=${DIST_DIR}}"

require_env WORKSPACE MOONCAKE_VERSION ARTIFACT_REPO_BASE DIST_DIR

ARTIFACT_FILE="$(ls "$ARTIFACT_REPO_BASE"/*.gz | head -n1)"

CTX_DIR="${WORKSPACE}/build-context"
rm -rf "$CTX_DIR" && mkdir -p "$CTX_DIR"

# todo
LOCAL_TGZ=${ARTIFACT_FILE}


# ---- 解析待下载的制品文件名 -----------------------------------------------
# 优先使用工程任务注入的 ARTIFACT_FILE；否则从制品仓的 LATEST 文件读取。
# source xxx
# 执行下载 （conan gz包）
# 解压到 TMP_EXTRACT="${WORKSPACE}/tmp/extract"


# ---- 下载（mock） ---------------------------------------------------------
if [[ -f "$LOCAL_TGZ" ]]; then
    log_info "本地已存在 $LOCAL_TGZ，跳过下载"
else
    log_info "[MOCK] 下载：$ARTIFACT_URL → $LOCAL_TGZ"
    log_warn "请将下面这一行替换为公司内部制品仓客户端命令："
    echo "  # curl -fSL -u \"\${REPO_USER}:\${REPO_TOKEN}\" -o \"$LOCAL_TGZ\" \"$ARTIFACT_URL\""
    die "未实现真实下载（mock 状态）。请实现下载或将制品手工放到 $LOCAL_TGZ 后重试。"
fi

# ---- 解压 + 组装 build context --------------------------------------------
TMP_EXTRACT="${WORKSPACE}/tmp/extract"
rm -rf "$TMP_EXTRACT" && mkdir -p "$TMP_EXTRACT"
tar -C "$TMP_EXTRACT" -xzf "$LOCAL_TGZ"
[[ -d "${TMP_EXTRACT}/mooncake/bin" && -d "${TMP_EXTRACT}/mooncake/lib" ]] \
    || die "tar 包结构不符合预期（应为 mooncake/{bin,lib}）"

cp -a "${TMP_EXTRACT}/mooncake/bin" "${CTX_DIR}/"
cp -a "${TMP_EXTRACT}/mooncake/lib" "${CTX_DIR}/"
cp "${STAGE_DIR}/docker/"* "${CTX_DIR}/"

log_info "build context 已就绪："
ls -la "$CTX_DIR"