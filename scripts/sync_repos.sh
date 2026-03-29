#!/usr/bin/env bash
# sync_repos.sh — Pull data and model artefacts from associated sister repositories
# Usage: bash scripts/sync_repos.sh [OPTIONS]
#
# Syncs relevant data, model checkpoints, and benchmark results from all six
# sister repositories into the local workspace, enabling offline development
# and cross-repo experimentation without re-running full pipelines.
#
# OPTIONS:
#   --base-dir DIR     Root directory containing all cloned sister repos (default: ..)
#   --data-only        Sync JSONL datasets only (skip checkpoints and results)
#   --checkpoints-only Sync model checkpoints only
#   --results-only     Sync benchmark results / reports only
#   --repo REPO_NAME   Sync a single repository only (repeatable)
#   --dry-run          Print rsync/copy commands without executing them
#   --help             Show this help and exit
#
# TODO (Phase 4): replace path-based rsync with a proper artefact registry
#                 (e.g., HuggingFace Hub or DVC remote) once each repo is published.

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
BASE_DIR="${BASE_DIR:-..}"
DATA_ONLY=false
CHECKPOINTS_ONLY=false
RESULTS_ONLY=false
DRY_RUN=false
SELECTED_REPOS=()

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-dir)          BASE_DIR="$2"; shift 2 ;;
    --data-only)         DATA_ONLY=true; shift ;;
    --checkpoints-only)  CHECKPOINTS_ONLY=true; shift ;;
    --results-only)      RESULTS_ONLY=true; shift ;;
    --repo)              SELECTED_REPOS+=("$2"); shift 2 ;;
    --dry-run)           DRY_RUN=true; shift ;;
    --help)
      sed -n '3,22p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log() { echo "[$(date '+%H:%M:%S')] $*"; }

rsync_or_copy() {
  local src="$1" dst="$2"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [DRY-RUN] rsync -av --mkpath '${src}' '${dst}'"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if command -v rsync &>/dev/null; then
    rsync -av --exclude='*.pyc' --exclude='__pycache__' "${src}" "${dst}"
  else
    cp -r "${src}" "${dst}"
  fi
}

should_sync() {
  local repo="$1"
  if [[ ${#SELECTED_REPOS[@]} -eq 0 ]]; then
    return 0
  fi
  for r in "${SELECTED_REPOS[@]}"; do
    [[ "$r" == "$repo" ]] && return 0
  done
  return 1
}

# ---------------------------------------------------------------------------
# Sync targets
# ---------------------------------------------------------------------------
# Each entry: repo_name | source_path | local_dest | category
# Categories: data | checkpoint | result
declare -a SYNC_TARGETS=(
  "ai-wiki-dataset-preprocessor|data/|sync/datasets/wiki/|data"
  "ai-dist-training-scaler|checkpoints/|sync/checkpoints/dist-training/|checkpoint"
  "ai-fault-tolerance-design|checkpoints/|sync/checkpoints/fault-tolerance/|checkpoint"
  "ai-attention-throughput-optimizer|results/|sync/results/attention-benchmark/|result"
  "ai-transformer-efficiency-comparison|reports/|sync/results/efficiency-comparison/|result"
  "ai-attention-token-viz|exports/|sync/results/attention-viz/|result"
)

# ---------------------------------------------------------------------------
# Main sync loop
# ---------------------------------------------------------------------------
log "Transformer Research Hub — Cross-Repo Sync"
log "Base directory : ${BASE_DIR}"
log "Dry run        : ${DRY_RUN}"

SYNCED=0
SKIPPED=0
MISSING=0

for entry in "${SYNC_TARGETS[@]}"; do
  IFS='|' read -r repo src_rel dst_rel category <<< "$entry"

  # Filter by --repo flag
  if ! should_sync "$repo"; then
    ((SKIPPED++)) || true
    continue
  fi

  # Filter by category flags
  if [[ "$DATA_ONLY" == "true" ]] && [[ "$category" != "data" ]]; then
    ((SKIPPED++)) || true
    continue
  fi
  if [[ "$CHECKPOINTS_ONLY" == "true" ]] && [[ "$category" != "checkpoint" ]]; then
    ((SKIPPED++)) || true
    continue
  fi
  if [[ "$RESULTS_ONLY" == "true" ]] && [[ "$category" != "result" ]]; then
    ((SKIPPED++)) || true
    continue
  fi

  src="${BASE_DIR}/${repo}/${src_rel}"
  dst="${dst_rel}"   # relative to hub root

  if [[ ! -d "$src" ]]; then
    log "  MISSING : ${src} (run clone-all.sh + build ${repo} first)"
    ((MISSING++)) || true
    continue
  fi

  log "  SYNC    : ${repo}/${src_rel} → ${dst}"
  rsync_or_copy "$src" "$dst"
  ((SYNCED++)) || true
done

echo
log "Summary: ${SYNCED} synced, ${SKIPPED} skipped, ${MISSING} missing."
if [[ $MISSING -gt 0 ]]; then
  log "Run 'bash scripts/clone-all.sh' to clone missing repos, then build them to generate artefacts."
fi
