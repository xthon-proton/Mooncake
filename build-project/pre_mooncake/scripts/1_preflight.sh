#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# =============================================================================
# 00_preflight.sh — 环境校验
#   1. 必需 yum 包（best-effort 安装）
#   2. GCC 12 工具链可用且为 default
#   3. go 版本 >= GO_MIN_VERSION（1.23.7）；若 < 1.26.1 给 WARN（与安装目标对齐）
#   4. WORKSPACE / SRC_DIR 存在
#
#   参数：
#   1. WORKSPACE：CI工具会声明
#   2. GO_MIN_VERSION：编译依赖的最小go版本，默认1.23.7
#   3. GCC_HOME_12_3：编译依赖的gcc12的安装路径，构建镜像中默认已声明
# =============================================================================

set -euo pipefail
SCRIPT_NAME="1_preflight"
source "$(dirname "$0")/lib/common.sh"

# 设置部分参数默认值
: "${GO_MIN_VERSION:=1.23.7}"
: "${GCC_HOME_12_3:=/usr/local/bin}"

require_env WORKSPACE GO_MIN_VERSION GCC_HOME_12_3

log_info "=== env 变量 ==="
log_info "WORKSPACE:      ${WORKSPACE}"
log_info "GO_MIN_VERSION: ${GO_MIN_VERSION:-<未设置>}"
log_info "GCC_HOME_12_3:  ${GCC_HOME_12_3:-<未设置>}"
log_info "================"

log_info "SRC_DIR=$SRC_DIR (根据 manifest xml 配置文件，拉取根目录)"
[[ -d "$SRC_DIR" ]] || die "$SRC_DIR 不存在；工程任务应已按 manifest xml 配置文件，把源码拉取放置到此处"

# ---- yum 源管理函数 ---------------------------------------------------------
SUDO="sudo"
$SUDO -v || die "需要 root 权限操作 yum 源，请检查 sudo 配置"

# 添加临时 yum 源（备份原源 → 添加新源 → 刷新缓存）
add_yum_repo() {
    $SUDO mkdir -p /repo_bak \
    && $SUDO cp -r /etc/yum.repos.d/ /repo_bak/

    # 根据 build_image_arm 变量选择不同的 yum 源配置
    if [[ "${build_image_arm}" == "kweecr04.his.huawei.com:80/ecr-build-arm-gzkunpeng/gde_27.0_kylinos_sp3_arm:22.0" ]]; then
        $SUDO tee /etc/yum.repos.d/base.repo >/dev/null <<'REPO_EOF'
[base]
name=centos- - Base
baseurl=http://ncedevtools.rnd.huawei.com/kylin_10_sp3_2403_4GB_yum_arm/
gpgcheck=0
enabled=1
REPO_EOF
    else
        $SUDO tee /etc/yum.repos.d/base.repo >/dev/null <<'REPO_EOF'
[base]
name=local_base
baseurl=http://buildtools.szv.dragon.tools.huawei.com/repo/EulerOS/V200R012C00SPC100B150/
gpgcheck=0
enabled=1

[updates0]
name=local_base
baseurl=http://buildtools.szv.dragon.tools.huawei.com/repo/devel_tools/EulerOS/V200R012C00SPC100B150/devel_tools/
gpgcheck=0
enabled=1
REPO_EOF
    fi
    $SUDO yum clean all && $SUDO yum makecache
}

# 清理临时 yum 源（恢复原源 → 删除备份）
cleanup_yum_repo() {
    $SUDO rm -rf /etc/yum.repos.d/* && $SUDO bash -c 'mv /repo_bak/* /etc/yum.repos.d/'
    $SUDO rm -rf /repo_bak/
}

# ---- yum 依赖（best-effort，已存在则跳过）---------------------------------
# 不检查 make, cmake 等基础工具包
YUM_PKGS=(numactl-devel openssl-devel libcurl-devel
          zstd-devel rdma-core-devel boost-devel
          python3-devel)
if command -v yum >/dev/null 2>&1; then
    add_yum_repo
    log_info "尝试安装 yum 依赖（已装则跳过）"
    $SUDO yum install -y "${YUM_PKGS[@]}" || log_warn "yum 安装出现错误，请人工核对"
    cleanup_yum_repo
else
    log_warn "yum 不可用，跳过依赖安装（请确保 ${YUM_PKGS[*]} 已就绪）"
fi

# ---- GCC 12 ----------------------------------------------------------------
[[ -x "${GCC_HOME_12_3}/bin/gcc" ]] || die "GCC 12 工具链不存在：${GCC_HOME_12_3}/bin/gcc"
# 切换至 GCC 12
export PATH="${GCC_HOME_12_3}/bin:$PATH"
export LD_LIBRARY_PATH="${GCC_HOME_12_3}/lib64:${LD_LIBRARY_PATH:-}"
export CC="${GCC_HOME_12_3}/bin/gcc"
export CXX="${GCC_HOME_12_3}/bin/g++"
gcc_ver="$("$CC" -dumpversion)"
[[ "${gcc_ver%%.*}" == "12" ]] || die "期望 gcc 12.x，实际 $gcc_ver"
log_info "GCC 工具链就绪：$($CC --version | head -n1)"

# ---- go ---------------------------------------------------------------------
# 实际安装目标 1.26.1，但只强制校验 >= 1.23.7。
check_go_version

log_info "preflight OK"