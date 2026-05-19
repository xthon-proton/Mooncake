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
# 跨阶段唯一公共函数库（Mooncake-build/lib/common.sh）
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/common.sh"

# 设置参数默认值
: "${MOONCAKE_VERSION:=v0.3.10}"

# ENV_PIPELINE_TASKNAME: 构建任务job名, 如 mooncake_package_arm
# ENV_SERVICE_NAME: 构建服务名, 如 mooncake
require_env WORKSPACE MOONCAKE_VERSION

CTX_DIR="${WORKSPACE}/build-context"
rm -rf "$CTX_DIR" && mkdir -p "$CTX_DIR"

# ---- 解析待下载的制品文件名 -----------------------------------------------
# 优先使用工程任务注入的 ARTIFACT_FILE；否则从制品仓的 LATEST 文件读取。
# source xxx
# 执行下载 （conan gz包）
# 解压到 TMP_EXTRACT="${WORKSPACE}/tmp/extract"


# ---- 下载制品文件 ---------------------------------------------------------
TARGET_ARTIFACT_DOWNLOAD_PATH="${TMP_DIR}/artifact/"
[[ ! -d "${TARGET_ARTIFACT_DOWNLOAD_PATH}" ]] && mkdir -p "${TARGET_ARTIFACT_DOWNLOAD_PATH}"
log_info "[PROCESSING] 下载 → ${TARGET_ARTIFACT_DOWNLOAD_PATH}"
# 分层构建时, ENV_PIPELINE_TASKNAME, ENV_SERVICE_NAME 变量会带
bash "${WORKSPACE}/${ENV_PIPELINE_TASKNAME}/${ENV_SERVICE_NAME}/pre_mooncake/conan/config_conan.sh"
conan install "${WORKSPACE}/${ENV_PIPELINE_TASKNAME}/${ENV_SERVICE_NAME}/pre_mooncake/conan/conanfile.txt" -g deploy -if "${TARGET_ARTIFACT_DOWNLOAD_PATH}"
# 制品会包含/mooncake目录, 一起下载至目标路径, 如：/usr1/tmp/artifact/mooncake/mooncake-store-server_v0.3.10_EulerOS_Aarch64_fed27e52.tar.gz
LOCAL_TGZ="$(ls "${TARGET_ARTIFACT_DOWNLOAD_PATH}"/mooncake/*.gz | head -n1)"
cd "${TARGET_ARTIFACT_DOWNLOAD_PATH}"
ls -al

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