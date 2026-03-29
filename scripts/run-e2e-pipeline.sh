#!/usr/bin/env bash
# run-e2e-pipeline.sh — End-to-end Transformer Research Hub pipeline
#
# Orchestrates the full research pipeline:
#   wiki-preprocessor → dist-training-scaler → attention-token-viz
#   → attention-throughput-optimizer → dist-training-scaler (ZeRO-3)
#
# Usage:
#   bash scripts/run-e2e-pipeline.sh [--skip-preprocess] [--skip-train]
#
# Environment variables (all optional, reasonable defaults provided):
#   WIKI_DUMP_PATH          Path to Wikipedia XML BZ2 dump
#   WIKI_OUTPUT_DIR         Where to write JSONL shards
#   CHECKPOINT_DIR          Directory for training checkpoints
#   WANDB_DISABLED          Set to "true" to skip W&B logging
#   NUM_GPUS                Number of GPUs for distributed training (default: 1)

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; exit 1; }

# ── Defaults ─────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARENT_DIR="$(dirname "${REPO_ROOT}")"

WIKI_DUMP_PATH="${WIKI_DUMP_PATH:-${PARENT_DIR}/data/raw/enwiki-latest-pages-articles.xml.bz2}"
WIKI_OUTPUT_DIR="${WIKI_OUTPUT_DIR:-${PARENT_DIR}/data/processed/wiki_jsonl}"
CHECKPOINT_DIR="${CHECKPOINT_DIR:-${PARENT_DIR}/checkpoints}"
WANDB_DISABLED="${WANDB_DISABLED:-false}"
NUM_GPUS="${NUM_GPUS:-1}"

SKIP_PREPROCESS=false
SKIP_TRAIN=false

# ── Argument parsing ─────────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --skip-preprocess) SKIP_PREPROCESS=true ;;
    --skip-train)      SKIP_TRAIN=true ;;
    --help|-h)
      echo "Usage: $0 [--skip-preprocess] [--skip-train]"
      exit 0
      ;;
    *) warn "Unknown argument: $arg" ;;
  esac
done

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   Transformer Research Hub — E2E Pipeline   ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${RESET}"
echo ""
info "Hub root:         ${REPO_ROOT}"
info "Parent dir:       ${PARENT_DIR}"
info "Wiki dump:        ${WIKI_DUMP_PATH}"
info "Wiki output:      ${WIKI_OUTPUT_DIR}"
info "Checkpoint dir:   ${CHECKPOINT_DIR}"
info "GPUs:             ${NUM_GPUS}"
info "W&B disabled:     ${WANDB_DISABLED}"
echo ""

# ── Helper: check repo exists ─────────────────────────────────────────────────
check_repo() {
  local repo_name="$1"
  local repo_path="${PARENT_DIR}/${repo_name}"
  if [ ! -d "${repo_path}" ]; then
    warn "Repo ${repo_name} not found at ${repo_path}"
    warn "Run: bash ${REPO_ROOT}/scripts/clone-all.sh ${PARENT_DIR}"
    return 1
  fi
  return 0
}

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Wikipedia preprocessing (wiki → JSONL)
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}── Step 1: Wikipedia Preprocessing ──────────────────${RESET}"
if [ "${SKIP_PREPROCESS}" = true ]; then
  warn "Skipping preprocessing (--skip-preprocess)"
elif ! check_repo "ai-wiki-dataset-preprocessor"; then
  warn "Skipping preprocessing — repo not found"
else
  WIKI_REPO="${PARENT_DIR}/ai-wiki-dataset-preprocessor"
  if [ ! -f "${WIKI_DUMP_PATH}" ]; then
    warn "Wiki dump not found at ${WIKI_DUMP_PATH} — skipping preprocessing"
    warn "Download from: https://dumps.wikimedia.org/enwiki/latest/"
  else
    info "Running wiki preprocessor ..."
    mkdir -p "${WIKI_OUTPUT_DIR}"
    WANDB_DISABLED="${WANDB_DISABLED}" python "${WIKI_REPO}/preprocess.py" \
      --input "${WIKI_DUMP_PATH}" \
      --output "${WIKI_OUTPUT_DIR}"
    success "Preprocessing complete → ${WIKI_OUTPUT_DIR}"
  fi
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — Distributed training with ZeRO-3
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}── Step 2: Distributed Training (ZeRO-3) ────────────${RESET}"
if [ "${SKIP_TRAIN}" = true ]; then
  warn "Skipping training (--skip-train)"
elif ! check_repo "ai-dist-training-scaler"; then
  warn "Skipping training — repo not found"
else
  SCALER_REPO="${PARENT_DIR}/ai-dist-training-scaler"
  ZERO3_CONFIG="${REPO_ROOT}/configs/deepspeed_zero3.json"
  info "Launching distributed training with ${NUM_GPUS} GPU(s) ..."
  mkdir -p "${CHECKPOINT_DIR}"
  WANDB_DISABLED="${WANDB_DISABLED}" accelerate launch \
    --num_processes "${NUM_GPUS}" \
    --deepspeed_config_file "${ZERO3_CONFIG}" \
    "${SCALER_REPO}/train.py" \
    --config "${SCALER_REPO}/config.yaml" \
    --data_path "${WIKI_OUTPUT_DIR}" \
    --output_dir "${CHECKPOINT_DIR}/zero3_wiki"
  success "Training complete → ${CHECKPOINT_DIR}/zero3_wiki"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Attention visualization
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}── Step 3: Attention Visualization ──────────────────${RESET}"
if ! check_repo "ai-attention-token-viz"; then
  warn "Skipping visualization — repo not found"
else
  VIZ_REPO="${PARENT_DIR}/ai-attention-token-viz"
  info "Generating attention maps from latest checkpoint ..."
  CHECKPOINT=$(ls -td "${CHECKPOINT_DIR}/zero3_wiki/"* 2>/dev/null | head -1 || echo "gpt2")
  WANDB_DISABLED="${WANDB_DISABLED}" python "${VIZ_REPO}/viz.py" \
    --model "${CHECKPOINT}" \
    --text "Transformer architectures have revolutionized natural language processing." \
    --output "${PARENT_DIR}/results/attention_maps"
  success "Attention maps written to ${PARENT_DIR}/results/attention_maps"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — Attention throughput benchmarking
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}── Step 4: Attention Throughput Benchmark ───────────${RESET}"
if ! check_repo "ai-attention-throughput-optimizer"; then
  warn "Skipping benchmark — repo not found"
else
  ATTN_REPO="${PARENT_DIR}/ai-attention-throughput-optimizer"
  info "Running FlashAttention benchmark ..."
  WANDB_DISABLED="${WANDB_DISABLED}" python "${ATTN_REPO}/benchmark.py" \
    --model flash-attention \
    --output "${PARENT_DIR}/results/benchmark_results.csv"
  success "Benchmark results → ${PARENT_DIR}/results/benchmark_results.csv"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 — Efficiency comparison
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}── Step 5: Efficiency Comparison ────────────────────${RESET}"
if ! check_repo "ai-transformer-efficiency-comparison"; then
  warn "Skipping comparison — repo not found"
else
  CMP_REPO="${PARENT_DIR}/ai-transformer-efficiency-comparison"
  info "Running GPT-2 vs RWKV comparison ..."
  WANDB_DISABLED="${WANDB_DISABLED}" python "${CMP_REPO}/compare.py" \
    --variants vanilla,linear,flash \
    --data_path "${WIKI_OUTPUT_DIR}" \
    --output "${PARENT_DIR}/results/efficiency_comparison"
  success "Efficiency comparison → ${PARENT_DIR}/results/efficiency_comparison"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo -e "${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║              Pipeline Complete              ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${RESET}"
echo ""
echo "Results directory: ${PARENT_DIR}/results/"
echo "Checkpoints:       ${CHECKPOINT_DIR}/"
echo ""
success "End-to-end pipeline finished successfully!"
