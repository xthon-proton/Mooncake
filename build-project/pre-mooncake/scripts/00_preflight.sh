#!/usr/bin/env bash
# =============================================================================
# 00_preflight.sh — 环境校验
#   1. 必需 yum 包（osc 上常态化提供，这里 best-effort 安装）
#   2. GCC 12 工具链可用且为 default
#   3. go 版本 >= GO_MIN_VERSION（1.23.7）；若 < 1.26.1 给 WARN（与安装目标对齐）
#   4. WORKSPACE / SRC_DIR 存在
# =============================================================================
set -euo pipefail
SCRIPT_NAME="00_preflight"
source "$(dirname "$0")/lib/common.sh"

require_env WORKSPACE GO_MIN_VERSION GO_INSTALL_VERSION GCC_TOOLCHAIN_PREFIX

log_info "WORKSPACE=$WORKSPACE"
log_info "SRC_DIR=$SRC_DIR (manifest 拉取根目录)"
[[ -d "$SRC_DIR" ]] || die "$SRC_DIR 不存在；工程任务应已按 manifest 把源码放置到此处"

# ---- yum 依赖（best-effort，已存在则跳过）---------------------------------
YUM_PKGS=(make cmake3 patch git tar gzip xz which file pkgconfig
          openssl-devel zlib-devel libcurl-devel libuuid-devel
          boost-devel protobuf-devel protobuf-compiler grpc-devel grpc-plugins
          numactl-devel libibverbs-devel
          # etcd-cpp-apiv3 / cpprestsdk 不再源码编译，依赖 EulerOS 基础源 -devel 包
          cpprest-devel etcd-cpp-apiv3-devel)
if command -v yum >/dev/null 2>&1; then
    log_info "尝试安装 yum 依赖（已装则跳过）"
    yum install -y "${YUM_PKGS[@]}" || log_warn "yum 安装出现错误，请人工核对"
else
    log_warn "yum 不可用，跳过依赖安装（请确保 ${YUM_PKGS[*]} 已就绪）"
fi

# ---- GCC 12 ----------------------------------------------------------------
[[ -x "${GCC_TOOLCHAIN_PREFIX}/bin/gcc" ]] \
    || die "GCC 12 工具链不存在：${GCC_TOOLCHAIN_PREFIX}/bin/gcc"
export PATH="${GCC_TOOLCHAIN_PREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${GCC_TOOLCHAIN_PREFIX}/lib64:${LD_LIBRARY_PATH:-}"
export CC="${GCC_TOOLCHAIN_PREFIX}/bin/gcc"
export CXX="${GCC_TOOLCHAIN_PREFIX}/bin/g++"
gcc_ver="$("$CC" -dumpversion)"
[[ "${gcc_ver%%.*}" == "12" ]] || die "期望 gcc 12.x，实际 $gcc_ver"
log_info "GCC 工具链就绪：$($CC --version | head -n1)"

# ---- go ---------------------------------------------------------------------
# 实际安装目标 1.26.1（按 #3 澄清），但只强制校验 >= 1.23.7。
check_go_version
current_go="$(go env GOVERSION)"; current_go="${current_go#go}"
if [[ "$current_go" != "$GO_INSTALL_VERSION" ]]; then
    log_warn "当前 go=$current_go 与安装目标 $GO_INSTALL_VERSION 不一致（已满足下限，继续）"
fi

log_info "preflight OK"
