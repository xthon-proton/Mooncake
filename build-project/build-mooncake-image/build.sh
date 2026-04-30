#!/usr/bin/env bash
# =============================================================================
# 阶段二入口（本地穿刺）；工程任务模式下由 ci/build_mooncake_image_arm.yml
# 按 step 调用各 scripts/*.sh。
# =============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/scripts/00_pull_artifact.sh"
bash "$SCRIPT_DIR/scripts/10_build_image.sh"
bash "$SCRIPT_DIR/scripts/20_build_chart.sh"
bash "$SCRIPT_DIR/scripts/30_push_product.sh"
