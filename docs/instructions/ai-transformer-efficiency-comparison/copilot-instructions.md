# Copilot Instructions — ai-transformer-efficiency-comparison

Drop this file into `.github/copilot-instructions.md` of the `ai-transformer-efficiency-comparison`
repository.

> **Hub template:** [`templates/copilot-instructions.md`](../../../templates/copilot-instructions.md)
> **Review notes:** [`docs/reviews/ai-transformer-efficiency-comparison/`](../../reviews/ai-transformer-efficiency-comparison/)

## Framework & Runtime

- **Python ≥ 3.10** with full type annotations (`from __future__ import annotations` where needed)
- **PyTorch ≥ 2.3** — use `torch.compile` for model inference where applicable; load GPT-2 via
  HuggingFace `transformers` and RWKV via the `rwkv` package
- **IBM WatsonX compatibility** — all model wrappers must implement HuggingFace
  `PreTrainedModel` interfaces so WatsonX can call them uniformly
- **GPU-first** — default all tensor operations to CUDA; add explicit `device` arguments and
  graceful CPU fallback for CI environments without GPUs

## Experiment Tracking

- Log **all** experiments with Weights & Biases (`wandb`):
  - `wandb.init(project="ai-transformer-efficiency-comparison", config=cfg)`
  - Log per-step metrics: `wandb.log({"model": name, "perplexity": ppl, "latency_ms": ms, "params_M": p})`
  - Log Pareto plots as `wandb.Image` artefacts
- Include a `--no-wandb` / `WANDB_DISABLED=true` escape hatch for offline runs

## Citations

- Every non-trivial algorithmic choice must include an inline comment citing the originating
  paper in arXiv format:

  ```python
  # GPT-2: Radford et al. (2019) https://openai.com/research/language-unsupervised
  # RWKV: Peng et al. (2023) https://arxiv.org/abs/2305.13048
  # Chinchilla scaling: Hoffmann et al. (2022) https://arxiv.org/abs/2203.15556
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
- Provide a 100-token fixture corpus in `tests/fixtures/mini_corpus.jsonl` for perplexity tests

## CI/CD

- GitHub Actions workflows must pass on `ubuntu-latest` with Python 3.11
- Required checks: `ruff check .`, `black --check .`, `pytest --cov`
- Perplexity and latency benchmarks skip in CI unless `RUN_SLOW_TESTS=1`
- Docker images based on `nvcr.io/nvidia/pytorch:24.03-py3` for GPU jobs

## Data Conventions

- Datasets are stored as **JSONL** (one JSON object per line, UTF-8)
- Dataset schema: `{"id": str, "text": str, "meta": {...}}`
- Use HuggingFace `datasets` library for all dataset I/O; export to HF Hub when applicable
- Comparison results stored as CSV: `model,perplexity,latency_ms,memory_gb,params_M`

## Distributed Training

- Use **HuggingFace Accelerate** as the primary distributed backend
- DeepSpeed **ZeRO-3** config lives in the hub's
  [`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json)
- All training scripts accept `--config <yaml>` for hyperparameter overrides

## Repo-Specific Notes

### Entry Points

| Script | Purpose |
|--------|---------|
| `compare.py` | Main comparison driver — evaluates all configured models |
| `compute_perplexity.py` | Compute cross-entropy perplexity on JSONL corpus |
| `pareto_analysis.py` | Identify Pareto-optimal models on perplexity × latency axes |
| `plot_pareto.py` | Generate Plotly Pareto-frontier scatter plots |

### Key Functions

```python
def compute_perplexity(
    model_name: str,
    corpus_path: Path,
    device: str = "cuda",
    max_length: int = 1024,
) -> float:
    """Compute average token-level perplexity on a JSONL corpus.
    # PPL definition: Jelinek et al. (1977)
    """

def is_pareto_optimal(costs: np.ndarray) -> np.ndarray:
    """Return boolean mask of Pareto-optimal points in a cost matrix.
    # Multi-objective optimisation: Deb (2001)
    """
```

### Comparison Matrix

| Model | Size | Source |
|-------|------|--------|
| GPT-2 small | 117M | HuggingFace Hub |
| GPT-2 medium | 345M | HuggingFace Hub |
| GPT-2 large | 774M | HuggingFace Hub |
| RWKV-4-169M | 169M | BlinkDL/RWKV-4-Pile |
| RWKV-4-430M | 430M | BlinkDL/RWKV-4-Pile |

### Cross-Repo Contracts

- **Upstream:** `ai-wiki-dataset-preprocessor` provides JSONL shards for perplexity evaluation
- **Upstream:** `ai-attention-throughput-optimizer` provides benchmark CSVs for latency figures
- **Downstream:** Pareto plots and SOTA comparison tables are referenced in hub notebooks
  `notebooks/03_gpt2_rwkv_pareto.ipynb`
- **Sync script:** Use [`scripts/sync_repos.sh`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/scripts/sync_repos.sh)
  to pull JSONL shards and benchmark CSVs

### Dependencies

```txt
torch>=2.3.0
transformers>=4.40.0
rwkv>=0.8.22
numpy>=1.26.0
pandas>=2.2.0
plotly>=5.22.0
wandb>=0.17.0
```
