#!/usr/bin/env bash
# =============================================================================
# 阶段一入口：本地穿刺时使用；工程任务模式下由 ci/pre_mooncake_arm.yml
# 按 step 顺序逐个调用 scripts/*.sh，不会走这个入口。
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export STAGE_DIR="$SCRIPT_DIR"

bash "$SCRIPT_DIR/scripts/00_preflight.sh"
bash "$SCRIPT_DIR/scripts/10_build_deps.sh"
bash "$SCRIPT_DIR/scripts/20_build_mooncake.sh"
bash "$SCRIPT_DIR/scripts/30_collect_artifact.sh"
bash "$SCRIPT_DIR/scripts/40_push_artifact.sh"
