# Copilot Instructions — ai-attention-throughput-optimizer

Drop this file into `.github/copilot-instructions.md` of the `ai-attention-throughput-optimizer`
repository.

> **Hub template:** [`templates/copilot-instructions.md`](../../../templates/copilot-instructions.md)
> **Review notes:** [`docs/reviews/ai-attention-throughput-optimizer/`](../../reviews/ai-attention-throughput-optimizer/)

## Framework & Runtime

- **Python ≥ 3.10** with full type annotations (`from __future__ import annotations` where needed)
- **PyTorch ≥ 2.3** — use `torch.nn.functional.scaled_dot_product_attention` (SDPA) with all
  three SDP backends: `FLASH_ATTENTION`, `EFFICIENT_ATTENTION`, and `MATH`
- **IBM WatsonX compatibility** — exported benchmark modules must follow the HuggingFace
  `PreTrainedModel` interface so WatsonX can wrap the optimized attention layers
- **GPU-first** — all benchmarks must run on CUDA; wrap in `@torch.inference_mode()` and use
  `torch.cuda.synchronize()` around timing measurements; graceful CPU fallback for CI

## Experiment Tracking

- Log **all** benchmark runs with Weights & Biases (`wandb`):
  - `wandb.init(project="ai-attention-throughput-optimizer", config=cfg)`
  - Log per-config metrics: `wandb.log({"seq_len": L, "backend": b, "tokens_per_sec": t, "mem_gb": m})`
  - Log benchmark tables as `wandb.Table` artefacts for cross-run comparison
- Include a `--no-wandb` / `WANDB_DISABLED=true` escape hatch for offline runs

## Citations

- Every non-trivial algorithmic choice must include an inline comment citing the originating
  paper in arXiv format:

  ```python
  # FlashAttention-2: Dao et al. (2023) https://arxiv.org/abs/2307.08691
  # FlashAttention-3: Shah et al. (2024) https://arxiv.org/abs/2407.08608
  # Triton kernel: Tillet et al. (2019) https://arxiv.org/abs/1912.01153
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
- Provide golden CSV fixtures in `tests/fixtures/` for regression testing against known throughput baselines

## CI/CD

- GitHub Actions workflows must pass on `ubuntu-latest` with Python 3.11
- Required checks: `ruff check .`, `black --check .`, `pytest --cov`
- GPU benchmarks run only on self-hosted runners tagged `gpu`; skip in standard CI with
  `pytest.mark.skipif(not torch.cuda.is_available(), reason="GPU required")`
- Docker images based on `nvcr.io/nvidia/pytorch:24.03-py3` for GPU jobs

## Data Conventions

- Benchmark results are stored as **CSV** (headers: `backend,seq_len,batch,tokens_per_sec,mem_gb,latency_ms`)
- Use `pandas.DataFrame` for in-memory result manipulation; export to both CSV and
  HuggingFace `datasets.Dataset` for Hub upload
- Dataset schema for cross-repo consumption: `{"id": str, "text": str, "meta": {...}}`

## Distributed Training

- Use **HuggingFace Accelerate** as the primary distributed backend
- DeepSpeed **ZeRO-3** config lives in the hub's
  [`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json)
- All training scripts accept `--config <yaml>` for hyperparameter overrides

## Repo-Specific Notes

### Entry Points

| Script | Purpose |
|--------|---------|
| `benchmark.py` | Main benchmark driver — sweeps seq lengths × backends |
| `benchmark_attention.py` | Core timing harness for a single (backend, seq_len, batch) config |
| `plot_results.py` | Generate Plotly heatmaps and throughput-vs-seq-len curves |

### Key Functions

```python
def benchmark_attention(
    seq_len: int,
    batch_size: int,
    d_model: int = 512,
    n_heads: int = 8,
    backends: list[str] | None = None,
    device: str = "cuda",
    warmup: int = 5,
    repeats: int = 20,
) -> dict[str, float]:
    """Benchmark SDPA backends and return tokens/sec for each.
    # FlashAttention-2: Dao et al. (2023) https://arxiv.org/abs/2307.08691
    """
```

### Benchmark Matrix

| Axis | Values |
|------|--------|
| Sequence lengths | 1k, 2k, 4k, 8k, 16k, 32k, 64k tokens |
| Backends | `FLASH_ATTENTION`, `EFFICIENT_ATTENTION`, `MATH` |
| Batch sizes | 1, 4, 8, 16 |
| Precision | fp16, bf16 |

### Cross-Repo Contracts

- **Upstream:** `ai-dist-training-scaler` provides model checkpoints containing attention weight
  tensors; load with `torch.load(checkpoint_path, map_location=device)`
- **Downstream:** `ai-attention-token-viz` consumes optimised attention modules exported as
  `torch.nn.Module` subclasses with a standard `forward(q, k, v)` signature
- **Sync script:** Use [`scripts/sync_repos.sh`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/scripts/sync_repos.sh)
  to pull checkpoints and push benchmark CSVs

### Dependencies

```txt
torch>=2.3.0
flash-attn>=2.5.8
triton>=2.3.0
plotly>=5.22.0
pandas>=2.2.0
wandb>=0.17.0
```
