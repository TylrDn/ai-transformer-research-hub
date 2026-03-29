#!/usr/bin/env bash
# clone-all.sh — Clone all Transformer Research Hub sister repos
# Usage: bash scripts/clone-all.sh [target-directory]
#
# Clones all 6 sister repositories into the specified directory
# (defaults to the current directory).

set -euo pipefail

TARGET_DIR="${1:-.}"

REPOS=(
  "ai-attention-throughput-optimizer"
  "ai-transformer-efficiency-comparison"
  "ai-wiki-dataset-preprocessor"
  "ai-dist-training-scaler"
  "ai-fault-tolerance-design"
  "ai-attention-token-viz"
)

OWNER="TylrDn"
BASE_URL="https://github.com/${OWNER}"

echo "Cloning Transformer Research Hub repos into: ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

for repo in "${REPOS[@]}"; do
  repo_path="${TARGET_DIR}/${repo}"
  if [ -d "${repo_path}/.git" ]; then
    echo "  ↻  ${repo} — already cloned, pulling latest..."
    git -C "${repo_path}" pull --ff-only
  else
    echo "  ↓  Cloning ${repo}..."
    git clone "${BASE_URL}/${repo}.git" "${repo_path}"
  fi
done

echo ""
echo "Done! Repos available in: ${TARGET_DIR}"
echo "  $(printf '%s\n' "${REPOS[@]}" | wc -l | tr -d ' ') repos ready."
