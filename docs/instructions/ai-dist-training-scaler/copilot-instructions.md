# Copilot Instructions — ai-dist-training-scaler

Drop this file into `.github/copilot-instructions.md` of the `ai-dist-training-scaler` repository.

> **Hub template:** [`templates/copilot-instructions.md`](../../../templates/copilot-instructions.md)
> **Review notes:** [`docs/reviews/ai-dist-training-scaler/`](../../reviews/ai-dist-training-scaler/)

## Framework & Runtime

- **Python ≥ 3.10** with full type annotations (`from __future__ import annotations` where needed)
- **PyTorch ≥ 2.3** — use `torch.compile`, `torch.amp` (bf16 preferred), and `torch.distributed`
  for all multi-GPU work; never use raw `DataParallel`
- **IBM WatsonX compatibility** — trained models must be exportable as HuggingFace
  `PreTrainedModel` subclasses so WatsonX can load them via the `ibm-watsonx-ai` SDK
- **GPU-first** — default all tensor operations and model parameters to CUDA; add explicit
  `device` arguments and graceful CPU fallback for CI environments without GPUs

## Experiment Tracking

- Log **all** experiments with Weights & Biases (`wandb`):
  - `wandb.init(project="ai-dist-training-scaler", config=cfg)`
  - Log per-step metrics: `wandb.log({"step": s, "loss": l, "lr": lr, "throughput": t})`
  - Log checkpoints: `wandb.log_artifact(checkpoint_dir, type="model")`
- Include a `--no-wandb` / `WANDB_DISABLED=true` escape hatch for offline runs

## Citations

- Every non-trivial algorithmic choice must include an inline comment citing the originating
  paper in arXiv format:

  ```python
  # ZeRO: Rajbhandari et al. (2020) https://arxiv.org/abs/1910.02054
  # Gradient checkpointing: Chen et al. (2016) https://arxiv.org/abs/1604.06174
  # Mixed precision: Micikevicius et al. (2018) https://arxiv.org/abs/1710.03740
  ```

- Collect all references in `REFERENCES.md` at the root of the repo (or link to the hub's
  centralised [REFERENCES.md](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/REFERENCES.md))

## Code Style

- Follow **PEP 8** strictly; use `ruff` (linter) and `black` (formatter) — line length 100
- Use `pathlib.Path` over `os.path`
- Prefer dataclasses or `pydantic` models over plain dicts for configuration
- Use `logging` (not `print`) for runtime messages; set the root logger in `__main__`

## Testing

- **pytest** for all tests; place tests in `tests/` with `test_*.py` naming
- Minimum coverage target: 80% (enforced in CI via `pytest --cov`)
- Mock GPU operations and `accelerate.Accelerator` in unit tests with `unittest.mock`
- Integration tests require `INTEGRATION_TEST=1` env variable and at least one CUDA device

## CI/CD

- GitHub Actions workflows must pass on `ubuntu-latest` with Python 3.11
- Required checks: `ruff check .`, `black --check .`, `pytest --cov`
- Multi-GPU integration tests run only on self-hosted runners tagged `multi-gpu`
- Docker images based on `nvcr.io/nvidia/pytorch:24.03-py3` for GPU jobs

## Data Conventions

- Datasets are stored as **JSONL** (one JSON object per line, UTF-8)
- Dataset schema: `{"id": str, "text": str, "meta": {...}}`
- Use HuggingFace `datasets` library for all dataset I/O; export to HF Hub when applicable
- Checkpoint directory structure: `<run_name>/checkpoint-<step>/` (HuggingFace `save_pretrained` format)

## Distributed Training

- Use **HuggingFace Accelerate** as the primary distributed backend
- DeepSpeed **ZeRO-3** config lives in the hub's
  [`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json)
- All training scripts accept `--config <yaml>` for hyperparameter overrides
- Launch command: `accelerate launch --config_file configs/accelerate.yaml train.py --config configs/train.yaml`

## Repo-Specific Notes

### Entry Points

| Script | Purpose |
|--------|---------|
| `train.py` | Main training script — ZeRO-3 loop with fault injection hooks |
| `build_accelerator.py` | Construct and configure `accelerate.Accelerator` with ZeRO-3 |
| `train_zero3.py` | Core training loop with gradient accumulation and mixed precision |
| `resume_from_checkpoint.py` | Checkpoint recovery — resume training after node failure |

### Key Functions

```python
def build_accelerator(cfg: TrainConfig) -> Accelerator:
    """Build an Accelerate Accelerator with DeepSpeed ZeRO-3 plugin.
    # ZeRO: Rajbhandari et al. (2020) https://arxiv.org/abs/1910.02054
    """

def train_zero3(
    accelerator: Accelerator,
    model: PreTrainedModel,
    dataloader: DataLoader,
    optimizer: torch.optim.Optimizer,
    cfg: TrainConfig,
) -> dict[str, float]:
    """Run the ZeRO-3 training loop; return final metrics dict."""

def resume_from_checkpoint(
    checkpoint_dir: Path,
    accelerator: Accelerator,
    model: PreTrainedModel,
) -> int:
    """Load checkpoint state into model and accelerator; return resumed step number."""
```

### ZeRO-3 Configuration

The canonical config is kept in the hub's
[`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json).
Key knobs:

| Parameter | Default | Notes |
|-----------|---------|-------|
| `zero_optimization.stage` | 3 | Shard params + grads + optimizer states |
| `offload_optimizer.device` | `"cpu"` | CPU offload when VRAM < 40 GB |
| `offload_param.device` | `"cpu"` | Param offload for very large models |
| `fp16.enabled` / `bf16.enabled` | bf16 preferred | Use bf16 on Ampere+ GPUs |

### Cross-Repo Contracts

- **Upstream:** `ai-wiki-dataset-preprocessor` provides JSONL shards via the sync script
- **Upstream:** `ai-fault-tolerance-design` provides the `FaultTolerantTrainer` wrapper that
  should be composed around this repo's training loop
- **Downstream:** `ai-attention-throughput-optimizer` consumes model checkpoints
- **Downstream:** `ai-transformer-efficiency-comparison` consumes training metrics CSV
- **Sync script:** Use [`scripts/sync_repos.sh`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/scripts/sync_repos.sh)
  to pull JSONL shards and push checkpoints

### Dependencies

```txt
torch>=2.3.0
accelerate>=0.31.0
deepspeed>=0.14.0
transformers>=4.40.0
datasets>=2.19.0
wandb>=0.17.0
```
