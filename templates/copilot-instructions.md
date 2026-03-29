# Copilot Instructions — {{REPO_NAME}}

<!-- Copy this file to .github/copilot-instructions.md in each sister repo.
     Replace {{REPO_NAME}} with the actual repository name. -->

These instructions apply to the **TylrDn/{{REPO_NAME}}** repository and
complement the hub-level instructions at
[ai-transformer-research-hub/.github/copilot-instructions.md](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/.github/copilot-instructions.md).

---

## Framework & Runtime

- **Python ≥ 3.10** — use `from __future__ import annotations` for forward references.
- **PyTorch ≥ 2.3** — prefer `torch.compile`, `torch.amp.autocast`, and `F.scaled_dot_product_attention`.
- **IBM WatsonX compatibility** — all models must implement the HuggingFace `PreTrainedModel`
  interface so they can be wrapped and served via `ibm-watsonx-ai`. Export with
  `model.save_pretrained(path)` / `AutoModel.from_pretrained(path)`.
- **GPU-first** — default tensors and parameters to `device="cuda"`. Always accept an explicit
  `device` argument and fall back gracefully to CPU when CUDA is unavailable (important for CI).

## Experiment Tracking

Log **every** training and evaluation run with [Weights & Biases](https://wandb.ai):

```python
import wandb
wandb.init(project="{{REPO_NAME}}", config=cfg)
wandb.log({"loss": loss, "step": step})
wandb.log_artifact(checkpoint_path, type="model")
```

Provide a `--no-wandb` CLI flag **and** honour `WANDB_DISABLED=true` for offline / CI runs.

## Citations

Every non-trivial algorithmic choice **must** include an inline arXiv citation:

```python
# FlashAttention-2: Dao et al. (2023) https://arxiv.org/abs/2307.08691
attn = F.scaled_dot_product_attention(q, k, v)
```

Collect all references in `REFERENCES.md` at the repo root (see the hub's
[REFERENCES.md](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/REFERENCES.md)
for the canonical list).

## Code Style

- **PEP 8** enforced by `ruff` (linter) and `black` (formatter) — line length **100**.
- Use `pathlib.Path` instead of `os.path`.
- Prefer `dataclasses` or `pydantic` models for configuration objects over plain `dict`.
- Use the `logging` module (not `print`) for all runtime messages.
  Set the root logger level in `__main__`.

```python
import logging
logger = logging.getLogger(__name__)
```

## Testing

- **pytest** for all tests; place in `tests/` using `test_*.py` naming.
- Target **≥ 80 % coverage** (`pytest --cov=src --cov-report=term-missing`).
- Mock GPU operations with `pytest-mock` / `unittest.mock` — CI runs without a GPU.
- Fixtures for shared resources go in `tests/conftest.py`.

## CI / CD

- Workflows in `.github/workflows/ci.yml` must pass on `ubuntu-latest` / Python 3.11.
- Required checks (in order):
  1. `ruff check .`
  2. `black --check .`
  3. `pytest --cov`
- GPU jobs use Docker image `nvcr.io/nvidia/pytorch:24.03-py3` with a self-hosted runner.
- Reference the shared CI template at
  [ai-transformer-research-hub/templates/repo-ci.yml](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/templates/repo-ci.yml).

## Data Conventions

- All datasets stored as **JSONL** (one JSON object per line, UTF-8).
- Schema: `{"id": str, "text": str, "meta": {...}}`.
- Use HuggingFace `datasets` for all dataset I/O; push to HF Hub when applicable.
- Processed Wikipedia shards come from `ai-wiki-dataset-preprocessor` — load them with:

  ```python
  from datasets import load_dataset
  ds = load_dataset("json", data_files="data/wiki_shards/*.jsonl", split="train")
  ```

## Distributed Training

- Primary backend: **HuggingFace Accelerate**.
- DeepSpeed ZeRO-3 config: use the hub's
  [`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json).
- All training scripts accept `--config <yaml>` for hyperparameter overrides.
- Checkpoint format: HuggingFace `save_pretrained` / `from_pretrained` for WatsonX compat.
