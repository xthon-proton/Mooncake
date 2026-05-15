#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.

function init_build_image_params() {
	: "${PKG_VERSION:=27.0.RC1}"
	: "${SUB_VERSION:=27.0.0}"
	labelVersion=${LABEL_VERSION:-${SUB_VERSION}}

	if [[ "X${cmc_type}" == "XARM" ]]; then
		echo "Current Machine: ARM"
		OS_TYPE="EulerOS"
		ARCH_STR="Aarch64"
		OS_ARCH="euler_aarch64"
		DEPENDENCY_IMAGE_NAME="eulerarmlib"
		IMAGE_LABEL="euler_aarch64/eulerarmlib:${labelVersion}"
	elif [[ "X${cmc_type}" == "XX86" ]]; then
		echo "Current Machine: x86-64"
		OS_TYPE="EulerOS"
		ARCH_STR="X86"
		OS_ARCH="euler_x86"
		DEPENDENCY_IMAGE_NAME="eulerx86lib"
		IMAGE_LABEL="euler_x86/eulerx86lib:${labelVersion}"
	elif [[ "X${cmc_type}" == "XSUSE" ]]; then
		echo "Current Machine: SUSE"
		OS_TYPE="Suse"
		ARCH_STR="X86"
		OS_ARCH="suse_x86"
		DEPENDENCY_IMAGE_NAME="sles12sp5lib"
		IMAGE_LABEL="suse_x86/sles12sp5lib:${labelVersion}"
	fi

	echo "=== 初始化镜像构建变量 ==="
	echo "OS_TYPE:               ${OS_TYPE:-<未设置>}"
	echo "ARCH_STR:              ${ARCH_STR:-<未设置>}"
	echo "OS_ARCH:               ${OS_ARCH:-<未设置>}"
	echo "IMAGE_LABEL:           ${IMAGE_LABEL:-<未设置>}"
	echo "DEPENDENCY_IMAGE_NAME: ${DEPENDENCY_IMAGE_NAME:-<未设置>}"
	echo "======================="
}

# 处理入参
# 暂未用到，还没捋清几个`version`变量的关联关系、在流程中出现的位置、必要性
function set_params() {
    echo "function set_params begin-------------------"

    # 包的种类，目前仅有Any，无OP、OC
    [[ X"$1" != X"" ]] && package_type=$1 || package_type="Any"
    # 服务化包的版本号
    package_version=${PKG_VERSION:-"27.0.RC1"}
    # DockersubVersion
    service_version=${SUB_VERSION:-"27.0.0"}
    middlewarelib_version=${MIDDLEWARE_VERSION:-${service_version}}
    # 基础镜像名称
    image_tag="libforlayer:1.0.0"

    if [[ -z "${LAYER_IMAGES_PATH}" ]] || [[ ! -d ${LAYER_IMAGES_PATH} ]];then
        echo "Cannot find dir of LAYER_IMAGES_PATH ${LAYER_IMAGES_PATH}."; exit 1;
    fi

    bVersion=${B_VERSION:-${service_version}}

    echo "function set_params end-------------------"

}