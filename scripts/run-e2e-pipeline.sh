#!/usr/bin/env bash
# run-e2e-pipeline.sh — End-to-end orchestration script for the Transformer Research Hub
# Usage: bash scripts/run-e2e-pipeline.sh [OPTIONS]
#
# Orchestrates the full research pipeline across all six sister repositories:
#   wiki-dataset-preprocessor → dist-training-scaler → attention-token-viz
#                             → attention-throughput-optimizer → transformer-efficiency-comparison
#
# Each stage is independently skippable via flags to support iterative development.
#
# OPTIONS:
#   --base-dir DIR          Root directory containing all cloned sister repos (default: ..)
#   --skip-preprocess       Skip the dataset preprocessing stage
#   --skip-train            Skip the distributed training stage
#   --skip-viz              Skip the attention visualization stage
#   --skip-benchmark        Skip the attention throughput benchmark stage
#   --skip-compare          Skip the efficiency comparison stage
#   --distributed           Enable distributed (multi-node) execution via Accelerate
#   --num-processes N       Number of processes for distributed training (default: 1)
#   --config FILE           Path to a YAML config file for hyperparameter overrides
#   --dry-run               Print the commands that would be executed without running them
#   --help                  Show this help message and exit
#
# TODO (Phase 4): wire in fault-injection hooks from ai-fault-tolerance-design

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
BASE_DIR="${BASE_DIR:-..}"
SKIP_PREPROCESS=false
SKIP_TRAIN=false
SKIP_VIZ=false
SKIP_BENCHMARK=false
SKIP_COMPARE=false
DISTRIBUTED=false
NUM_PROCESSES=1
CONFIG_FILE=""
DRY_RUN=false

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-dir)        BASE_DIR="$2";        shift 2 ;;
    --skip-preprocess) SKIP_PREPROCESS=true; shift   ;;
    --skip-train)      SKIP_TRAIN=true;      shift   ;;
    --skip-viz)        SKIP_VIZ=true;        shift   ;;
    --skip-benchmark)  SKIP_BENCHMARK=true;  shift   ;;
    --skip-compare)    SKIP_COMPARE=true;    shift   ;;
    --distributed)     DISTRIBUTED=true;     shift   ;;
    --num-processes)   NUM_PROCESSES="$2";   shift 2 ;;
    --config)          CONFIG_FILE="$2";     shift 2 ;;
    --dry-run)         DRY_RUN=true;         shift   ;;
    --help)
      sed -n '3,30p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Run with --help for usage." >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "[$(date '+%H:%M:%S')] $*"; }
step() { echo; echo "══════════════════════════════════════════════════"; log "STEP: $*"; echo "══════════════════════════════════════════════════"; }
run()  {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [DRY-RUN] $*"
  else
    eval "$*"
  fi
}

# ---------------------------------------------------------------------------
# Stage 1 — Dataset Preprocessing
# ai-wiki-dataset-preprocessor: Wikipedia dump → cleaned JSONL shards
# ---------------------------------------------------------------------------
stage_preprocess() {
  step "Stage 1 — Dataset Preprocessing (ai-wiki-dataset-preprocessor)"
  WIKI_DIR="${BASE_DIR}/ai-wiki-dataset-preprocessor"

  if [[ ! -d "$WIKI_DIR" ]]; then
    log "WARNING: ${WIKI_DIR} not found. Run scripts/clone-all.sh first."
    return 0
  fi

  # TODO (Phase 3): add --input and --output flags once notebook pipeline is merged
  run "cd '${WIKI_DIR}' && python preprocess.py --output data/"
  log "Preprocessing complete. JSONL shards written to ${WIKI_DIR}/data/"
}

# ---------------------------------------------------------------------------
# Stage 2 — Distributed Training
# ai-dist-training-scaler: JSONL shards → model checkpoints (ZeRO-3)
# ---------------------------------------------------------------------------
stage_train() {
  step "Stage 2 — Distributed Training (ai-dist-training-scaler)"
  TRAIN_DIR="${BASE_DIR}/ai-dist-training-scaler"
  WIKI_DATA="${BASE_DIR}/ai-wiki-dataset-preprocessor/data"

  if [[ ! -d "$TRAIN_DIR" ]]; then
    log "WARNING: ${TRAIN_DIR} not found. Run scripts/clone-all.sh first."
    return 0
  fi

  CONFIG_ARG=""
  if [[ -n "$CONFIG_FILE" ]]; then
    CONFIG_ARG="--config ${CONFIG_FILE}"
  fi

  if [[ "$DISTRIBUTED" == "true" ]]; then
    # Multi-process / multi-node via HuggingFace Accelerate
    # Reference: HuggingFace Accelerate — https://huggingface.co/docs/accelerate
    run "cd '${TRAIN_DIR}' && accelerate launch --num_processes=${NUM_PROCESSES} train.py ${CONFIG_ARG} --data-dir '${WIKI_DATA}'"
  else
    run "cd '${TRAIN_DIR}' && python train.py ${CONFIG_ARG} --data-dir '${WIKI_DATA}'"
  fi

  log "Training complete. Checkpoints written to ${TRAIN_DIR}/checkpoints/"
}

# ---------------------------------------------------------------------------
# Stage 3 — Attention Visualization
# ai-attention-token-viz: checkpoints → interactive attention heatmaps
# ---------------------------------------------------------------------------
stage_viz() {
  step "Stage 3 — Attention Visualization (ai-attention-token-viz)"
  VIZ_DIR="${BASE_DIR}/ai-attention-token-viz"
  CHECKPOINT="${BASE_DIR}/ai-dist-training-scaler/checkpoints/latest"

  if [[ ! -d "$VIZ_DIR" ]]; then
    log "WARNING: ${VIZ_DIR} not found. Run scripts/clone-all.sh first."
    return 0
  fi

  # TODO (Phase 3): replace with Streamlit app launch once notebook pipeline is merged
  run "cd '${VIZ_DIR}' && python viz.py --checkpoint '${CHECKPOINT}'"
  log "Visualization complete."
}

# ---------------------------------------------------------------------------
# Stage 4 — Attention Throughput Benchmark
# ai-attention-throughput-optimizer: checkpoints → benchmark CSVs
# ---------------------------------------------------------------------------
stage_benchmark() {
  step "Stage 4 — Attention Throughput Benchmark (ai-attention-throughput-optimizer)"
  BENCH_DIR="${BASE_DIR}/ai-attention-throughput-optimizer"
  CHECKPOINT="${BASE_DIR}/ai-dist-training-scaler/checkpoints/latest"

  if [[ ! -d "$BENCH_DIR" ]]; then
    log "WARNING: ${BENCH_DIR} not found. Run scripts/clone-all.sh first."
    return 0
  fi

  run "cd '${BENCH_DIR}' && python benchmark.py --checkpoint '${CHECKPOINT}' --model flash-attention"
  log "Benchmark complete. Results written to ${BENCH_DIR}/results/"
}

# ---------------------------------------------------------------------------
# Stage 5 — Efficiency Comparison
# ai-transformer-efficiency-comparison: benchmark results → Pareto plots + reports
# ---------------------------------------------------------------------------
stage_compare() {
  step "Stage 5 — Efficiency Comparison (ai-transformer-efficiency-comparison)"
  COMP_DIR="${BASE_DIR}/ai-transformer-efficiency-comparison"
  BENCH_RESULTS="${BASE_DIR}/ai-attention-throughput-optimizer/results"

  if [[ ! -d "$COMP_DIR" ]]; then
    log "WARNING: ${COMP_DIR} not found. Run scripts/clone-all.sh first."
    return 0
  fi

  run "cd '${COMP_DIR}' && python compare.py --variants vanilla,linear,flash --results-dir '${BENCH_RESULTS}'"
  log "Comparison complete. Reports written to ${COMP_DIR}/reports/"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
log "Transformer Research Hub — End-to-End Pipeline"
log "Base directory : ${BASE_DIR}"
log "Distributed    : ${DISTRIBUTED} (processes: ${NUM_PROCESSES})"
log "Dry run        : ${DRY_RUN}"
[[ -n "$CONFIG_FILE" ]] && log "Config file    : ${CONFIG_FILE}"

[[ "$SKIP_PREPROCESS" == "false" ]] && stage_preprocess || log "Skipping Stage 1 (preprocessing)"
[[ "$SKIP_TRAIN"      == "false" ]] && stage_train      || log "Skipping Stage 2 (training)"
[[ "$SKIP_VIZ"        == "false" ]] && stage_viz        || log "Skipping Stage 3 (visualization)"
[[ "$SKIP_BENCHMARK"  == "false" ]] && stage_benchmark  || log "Skipping Stage 4 (benchmark)"
[[ "$SKIP_COMPARE"    == "false" ]] && stage_compare    || log "Skipping Stage 5 (comparison)"

echo
log "Pipeline complete."
