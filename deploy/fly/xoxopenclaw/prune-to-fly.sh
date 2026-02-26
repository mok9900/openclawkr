#!/usr/bin/env bash
set -euo pipefail

# Destructive cleanup script.
# Keeps only Fly deployment essentials for xoxopenclaw.

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${ROOT_DIR}"

KEEP_LIST=$'deploy/fly/xoxopenclaw\nfly.toml\nfly.private.toml\nDockerfile\nDockerfile.sandbox\nDockerfile.sandbox-common\nDockerfile.sandbox-browser\n.git\n.gitignore'

declare -A keep_map
while IFS= read -r path; do
  [[ -z "${path}" ]] && continue
  keep_map["${path}"]=1
done <<< "${KEEP_LIST}"

shopt -s dotglob nullglob
for item in * .*; do
  [[ "${item}" == "." || "${item}" == ".." ]] && continue
  [[ -n "${keep_map[${item}]:-}" ]] && continue
  rm -rf -- "${item}"
done

echo "Prune complete in ${ROOT_DIR}"
