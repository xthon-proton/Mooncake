#!/usr/bin/env bash
# =============================================================================
# 阶段二入口（本地穿刺）；工程任务模式下由 ci/build_mooncake_arm.yml
# 按 step 调用各 scripts/*.sh。
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/scripts/1_pull_artifact.sh"
bash "$SCRIPT_DIR/scripts/2_build_image.sh"
bash "$SCRIPT_DIR/scripts/3_build_chart.sh"
bash "$SCRIPT_DIR/scripts/4_push_product.sh"
