#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# 4_push_product.sh — 推送 image 7z + chart 7z 到产品仓
# =============================================================================
set -euo pipefail
SCRIPT_NAME="4_push_product"
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(cd "$THIS_DIR/.." && pwd)"
# 跨阶段唯一公共函数库（Mooncake-build/lib/common.sh, 含 init_build_image_params）
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/common.sh"

init_build_image_params

: "${B_VERSION:=1.0.00000001}"
: "${PKG_VERSION:=27.0.RC1}"
SIGNATURE_FILE=${SIGNATURE_FILE:-"${WORKSPACE}/signature"}
cloud_build_proxy=${cloud_build_proxy:-"10.90.178.81:12051"}
# sign_versionid=${sign_versionid:-"267878760"}
# SIGNATURE_ARGS=${SIGNATURE_ARGS:-"--proxylist ${cloud_build_proxy} --versionid ${sign_versionid}"}

ARCHIVE_PATH="${DIST_DIR}/Archive"
image_package_name="DSP_${PKG_VERSION}_Images_${OS_TYPE}-${ARCH_STR}_Docker-MooncakeStoreServer-Any.7z"
chart_package_name="DSP_${PKG_VERSION}_Chart_Any_Docker-MooncakeStoreServer-Any.7z"

require_env WORKSPACE SIGNATURE_FILE

# 全量源码构建目录
# [ ! -d ${WORKSPACE}/GLOBLE_OUTPUT/${CMC_DIR} ] && mkdir -p ${WORKSPACE}/GLOBLE_OUTPUT/${CMC_DIR}

# 7z包存放目录
[ ! -d "${ARCHIVE_PATH}" ] && mkdir -p "${ARCHIVE_PATH}"

# signature image package
cd "${DIST_DIR}/images/"
python "${SIGNATURE_FILE}"/cms_signature.py --file "${DIST_DIR}/images/package.mf"
ls -al "${DIST_DIR}/images/"
log_info "7zip ${DIST_DIR}/images/* -> ${ARCHIVE_PATH}/${image_package_name}"
7za a -m0=flzma2 -mx=9 -mfb273 -md=32m -mmt -r "${ARCHIVE_PATH}/${image_package_name}" ./

# signature chart package
cd "${DIST_DIR}/charts/"
# 解压
chart_tar_name="mooncake_store_server-${B_VERSION}.tgz"
tar -zxvf ./"${chart_tar_name}"
# 内签第1层
cd "${DIST_DIR}/charts/mooncake_store_server/"
python "${SIGNATURE_FILE}"/cms_signature.py --file "${DIST_DIR}/charts/mooncake_store_server/package.mf"
ls -al "${DIST_DIR}/charts/mooncake_store_server/"
cd "${DIST_DIR}/charts/"
rm -rf ./"${chart_tar_name}"
log_info "tar ${DIST_DIR}/charts/${chart_tar_name}"
tar zcvf "${chart_tar_name}" "mooncake_store_server/"
rm -rf "./mooncake_store_server"

# 内签第2层
cd "${DIST_DIR}/charts/"
python "${SIGNATURE_FILE}"/cms_signature.py --file "${DIST_DIR}/charts/package.mf"
log_info "7zip ${DIST_DIR}/charts/* -> ${ARCHIVE_PATH}/${chart_package_name}"
7za a -m0=flzma2 -mx=9 -mfb273 -md=32k -mmt -r "${ARCHIVE_PATH}/${chart_package_name}" ./

# check
IMAGE_7Z_PKG="${ARCHIVE_PATH}/${image_package_name}"
CHART_7Z_PKG="${ARCHIVE_PATH}/${chart_package_name}"
[[ -f "${IMAGE_7Z_PKG}" ]] || die "image 7z 不存在：${IMAGE_7Z_PKG}"
[[ -f "${CHART_7Z_PKG}" ]] || die "chart 7z 不存在：${CHART_7Z_PKG}"

# 将7z包，复制到全量源码构建时的上传路径
# 这 GLOBLE 单词拼错了吧，构建工具不改吗
# cp "${ARCHIVE_PATH}"/*.7z "${WORKSPACE}/GLOBLE_OUTPUT/${CMC_DIR}"

# 分层构建时, cmc的上传目录
require_env UPLOAD_DIR
if [[ x"${UPLOAD_DIR}" != x"" ]]; then
	mkdir -p "${UPLOAD_DIR}"
	mv "${ARCHIVE_PATH}"/*.7z "${UPLOAD_DIR}"
fi

log_info "[DONE] 已完成7z包推送准备"
