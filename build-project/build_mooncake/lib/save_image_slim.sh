#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2026-2026. All rights reserved.
# ==========================================
# Filename: save_image_slim.sh
# Description: 提取应用镜像相对于基础镜像的增量层级并打包。
# Usage: ./save_image_slim.sh -b <基础镜像> -a <应用镜像> -r <包名> -p <保存路径>
# ==========================================

# 开启严格模式：遇到错误、未绑定变量或管道报错时立即退出
set -euo pipefail

# 初始化变量
base_image=""
app_image=""
pkg_name=""
save_path=""
base_layer_hash_list=""

# 获取脚本当前所在绝对路径
#current_path=$(cd $(dirname "${BASH_SOURCE[0]}") || exit;pwd)
temp_dir=""

# 定义清理函数，确保脚本退出时删除临时目录
function cleanup_temp_dir() {
	if [[ -n "${temp_dir}" && -d "${temp_dir}" ]]; then
		echo "正在清理临时目录: ${temp_dir}"
		rm -rf "${temp_dir}"
	fi
}
# 捕获 EXIT 信号，无论脚本正常退出还是异常退出，都会执行 cleanup
trap cleanup_temp_dir EXIT

# 打印错误信息并退出的辅助函数
function error_exit() {
    echo "[ERROR] 错误: $1" >&2
    exit 1
}

# 解析命令行参数
while getopts ":b:a:r:p:" opt; do
    case ${opt} in
        b) base_image="${OPTARG}" ;;
        a) app_image="${OPTARG}" ;;
        r) pkg_name="${OPTARG}" ;;
        p) save_path="${OPTARG}" ;;
        ?) echo "用法: $0 -b <基础镜像> -a <应用镜像> -r <包名> -p <保存路径>"; exit 0 ;;
    esac
done

# 1. 参数合法性校验
[[ -z "${base_image}" ]] && error_exit "缺少基础镜像参数 (-b)"
[[ -z "${app_image}" ]] && error_exit "缺少应用镜像参数 (-a)"
[[ -z "${pkg_name}" ]] && error_exit "缺少包名参数 (-r)"
[[ -z "${save_path}" ]] && error_exit "缺少保存路径参数 (-p)"

# 检查 docker 命令是否存在
command -v docker >/dev/null 2>&1 || error_exit "未找到 docker 命令，请先安装 Docker"

echo "[START] 参数校验通过，开始处理..."
echo "   基础镜像: ${base_image}"
echo "   应用镜像: ${app_image}"

# 2. 获取基础镜像的所有层级 Hash (无jq版本：使用 grep -oP 正则提取)
# 提取 RootFS 下的 Layers 数组中的 sha256 哈希值
num=$(docker inspect "${base_image}" | grep -c "        \"sha256")
count=$(echo "${num}"| awk '{print int($0)}')
if [[ ${count} -gt 0 ]];then
	base_layer_hash=$(docker inspect "${base_image}" | awk -F "[sha256]" '/     "sha256/{print substr($0,25,64)}')
	echo "base layer hash : ${base_layer_hash}"
	base_layer_hash_list=(${base_layer_hash//,/})
	echo "[INFO] 基础镜像共包含 ${#base_layer_hash_list[@]} 个层级"
else
	error_exit "无法获取基础镜像 '${base_image}' 的层级信息，请检查镜像是否存在。"
fi

# 3. 创建安全的临时工作目录
temp_dir="$(mktemp -d -t build_image_temp_dir_XXXXXX)"
echo "[INFO] 创建临时工作目录: ${temp_dir}"
cd "${temp_dir}"

# 4. 导出并解压应用镜像
echo "[PROCESSING] 正在导出应用镜像 ${app_image} -> app.tar ..."
docker save -o app.tar "${app_image}" || error_exit "导出镜像失败，请检查应用镜像名称是否正确。"

echo "[PROCESSING] 正在解压镜像包 app.tar ..."
tar -xf app.tar
rm -f app.tar

# 5. 遍历并剔除重复的层级文件
tmp_find_result=$(mktemp)
find . -name "layer.tar" -print0 > "${tmp_find_result}"
deleted_count=0
while IFS= read -r -d '' file; do
	echo "file------ ${file}"
	hashcode=$(sha256sum "${file}" | awk '{print $1}')
	echo "hashcode------ ${hashcode}"

	for base_hash in "${base_layer_hash_list[@]}"; do
		if [[ "${hashcode}" == "${base_hash}" ]]; then
			rm -rf "${file}"
			echo "deleted------ ${file}"
			((deleted_count++)) || true
		fi
	done
done < "${tmp_find_result}"

echo "[DONE] 处理完成，共剔除 ${deleted_count} 个重复层级"

# 6. 打包增量文件并移动到目标路径
echo "[PROCESSING] 正在打包增量文件为 ${pkg_name}.tar..."
tar -cf "${pkg_name}.tar" ./*

# 确保目标保存路径存在
mkdir -p "${save_path}" || error_exit "无法创建保存路径: ${save_path}"

mv "${pkg_name}.tar" "${save_path}/" || error_exit "移动文件到 ${save_path} 失败"

echo "[DONE] 成功！瘦身镜像包已保存至: ${save_path}/${pkg_name}.tar"

# 脚本结束后会自动触发 trap 清理 temp_dir
