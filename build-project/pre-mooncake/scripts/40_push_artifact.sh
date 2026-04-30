#!/usr/bin/env bash
# =============================================================================
# 40_push_artifact.sh — 推送 tar.gz 制品到制品仓
#
# 当前为 mock 实现：仅打印将要执行的上传命令；生产环境替换为
# 公司内部使用的客户端（如 osc cli / curl PUT / artifactory cli 等）。
# =============================================================================
set -euo pipefail
SCRIPT_NAME="40_push_artifact"
source "$(dirname "$0")/lib/common.sh"

require_env DIST_DIR MOONCAKE_VERSION ARTIFACT_REPO_BASE

ARTIFACT_FILE="$(cat "${DIST_DIR}/.latest_artifact")"
ARTIFACT_PATH="${DIST_DIR}/${ARTIFACT_FILE}"
[[ -f "$ARTIFACT_PATH" ]] || die "制品文件不存在：$ARTIFACT_PATH"

UPLOAD_URL="${ARTIFACT_REPO_BASE}/${MOONCAKE_VERSION}/aarch64/${ARTIFACT_FILE}"

log_info "[MOCK] 即将上传："
log_info "  source : $ARTIFACT_PATH"
log_info "  target : $UPLOAD_URL"
log_warn "当前为 mock，实际上传请替换为公司内部制品仓客户端，例如："
cat <<EOF
# curl 示例（需鉴权 token）：
#   curl -fSL -u "\${REPO_USER}:\${REPO_TOKEN}" \\
#        -T "${ARTIFACT_PATH}" \\
#        "${UPLOAD_URL}"
EOF

log_info "[MOCK] 上传完成（伪）"
