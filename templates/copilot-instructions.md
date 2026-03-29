# Copilot Instructions — Transformer Research Hub Sister Repos

Drop this file into `.github/copilot-instructions.md` of any sister repository.
Adjust the repo-specific sections marked with `[REPO_NAME]` as appropriate.

## Framework & Runtime

- **Python ≥ 3.10** with full type annotations (`from __future__ import annotations` where needed)
- **PyTorch ≥ 2.3** — use `torch.compile`, `torch.amp`, and the latest attention APIs
- **IBM WatsonX compatibility** — models and pipelines must be exportable / callable via the
  WatsonX AI SDK (`ibm-watsonx-ai`); use standard HuggingFace `PreTrainedModel` interfaces
  so WatsonX can wrap them
- **GPU-first** — default all tensor operations and model parameters to CUDA; add explicit
  `device` arguments and graceful CPU fallback for CI environments without GPUs

## Experiment Tracking

- Log **all** experiments with Weights & Biases (`wandb`):
  - `wandb.init(project="[REPO_NAME]", config=cfg)`
  - Log metrics every step with `wandb.log({...})`
  - Log final artefacts (checkpoints, plots) with `wandb.log_artifact`
- Include a `--no-wandb` / `WANDB_DISABLED=true` escape hatch for offline runs

## Citations

- Every non-trivial algorithmic choice must include an inline comment citing the originating
  paper in arXiv format:

  ```python
  # FlashAttention-2: Dao et al. (2023) https://arxiv.org/abs/2307.08691
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
- Mock GPU operations in unit tests with `pytest-mock` / `unittest.mock`

## CI/CD

- GitHub Actions workflows must pass on `ubuntu-latest` with Python 3.11
- Required checks: `ruff check .`, `black --check .`, `pytest --cov`
- Docker images based on `nvcr.io/nvidia/pytorch:24.03-py3` for GPU jobs

## Data Conventions

- Datasets are stored as **JSONL** (one JSON object per line, UTF-8)
- Dataset schema: `{"id": str, "text": str, "meta": {...}}`
- Use HuggingFace `datasets` library for all dataset I/O; export to HF Hub when applicable

## Distributed Training

- Use **HuggingFace Accelerate** as the primary distributed backend
- DeepSpeed **ZeRO-3** config lives in the hub's
  [`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json)
- All training scripts accept `--config <yaml>` for hyperparameter overrides

## Repo-Specific Notes

<!-- [REPO_NAME]: Add any repo-specific constraints, entry points, or module boundaries here -->
