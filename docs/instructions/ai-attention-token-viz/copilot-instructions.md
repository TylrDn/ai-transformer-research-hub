# Copilot Instructions — ai-attention-token-viz

Drop this file into `.github/copilot-instructions.md` of the `ai-attention-token-viz` repository.

> **Hub template:** [`templates/copilot-instructions.md`](../../../templates/copilot-instructions.md)
> **Review notes:** [`docs/reviews/ai-attention-token-viz/`](../../reviews/ai-attention-token-viz/)

## Framework & Runtime

- **Python ≥ 3.10** with full type annotations (`from __future__ import annotations` where needed)
- **PyTorch ≥ 2.3** — extract attention weights via `output_attentions=True` on HuggingFace models;
  use `torch.no_grad()` for all inference passes
- **IBM WatsonX compatibility** — the Streamlit app and extraction pipeline must be callable via
  the WatsonX AI SDK; use standard HuggingFace `PreTrainedModel` interfaces as the model contract
- **GPU-first** — default all inference to CUDA; add explicit `device` arguments and graceful CPU
  fallback so the Streamlit app runs on CPU in cloud deployments (HF Spaces, Streamlit Cloud)

## Experiment Tracking

- Log **all** visualization runs with Weights & Biases (`wandb`):
  - `wandb.init(project="ai-attention-token-viz", config=cfg)`
  - Log attention entropy statistics: `wandb.log({"layer": i, "head": h, "entropy": e})`
  - Log heatmap images: `wandb.log({"attention_map": wandb.Image(fig)})`
- Include a `--no-wandb` / `WANDB_DISABLED=true` escape hatch for offline runs

## Citations

- Every non-trivial algorithmic choice must include an inline comment citing the originating
  paper in arXiv format:

  ```python
  # BERT attention: Devlin et al. (2019) https://arxiv.org/abs/1810.04805
  # BertViz: Vig (2019) https://arxiv.org/abs/1904.02679
  # Attention is All You Need: Vaswani et al. (2017) https://arxiv.org/abs/1706.03762
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
- Mock GPU operations and `transformers` model forward passes in unit tests
- Test Streamlit app by mocking `streamlit` module — do not require a live Streamlit server

## CI/CD

- GitHub Actions workflows must pass on `ubuntu-latest` with Python 3.11
- Required checks: `ruff check .`, `black --check .`, `pytest --cov`
- Docker images based on `nvcr.io/nvidia/pytorch:24.03-py3` for GPU jobs
- Streamlit Cloud deployment: set `STREAMLIT_SERVER_PORT=8501` and mount `.streamlit/config.toml`
  from the hub's [`.streamlit/`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/.streamlit/)

## Data Conventions

- Datasets are stored as **JSONL** (one JSON object per line, UTF-8)
- Dataset schema: `{"id": str, "text": str, "meta": {...}}`
- Attention weight tensors serialised as `numpy` `.npy` files:
  `attn-<model>-<layer>-<head>.npy` (shape: `[seq_len, seq_len]`)
- Heatmap images exported as PNG at 150 DPI minimum

## Distributed Training

- Use **HuggingFace Accelerate** as the primary distributed backend when running batch inference
- DeepSpeed **ZeRO-3** config lives in the hub's
  [`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json)
- All batch inference scripts accept `--config <yaml>` for hyperparameter overrides

## Repo-Specific Notes

### Entry Points

| Script | Purpose |
|--------|---------|
| `streamlit_app.py` | Interactive Streamlit attention heatmap app |
| `extract_attention_weights.py` | Extract per-layer, per-head attention from a HuggingFace model |
| `plot_attention.py` | Generate static Plotly / Matplotlib heatmaps |
| `export_hf_spaces.py` | Package the app for HuggingFace Spaces deployment |

### Key Functions

```python
def extract_attention_weights(
    text: str,
    model_name: str = "bert-base-uncased",
    device: str = "cuda",
) -> dict[str, torch.Tensor]:
    """Return dict of {f'layer_{i}_head_{j}': attention_tensor} for all layers and heads.
    # BERT attention: Devlin et al. (2019) https://arxiv.org/abs/1810.04805
    """

def plot_attention_layer(
    attention: torch.Tensor,
    tokens: list[str],
    layer: int,
    head: int,
) -> go.Figure:
    """Return a Plotly heatmap Figure for a single attention head."""
```

### Streamlit App Structure

```
streamlit_app.py
├── Sidebar: model selector, layer/head sliders, text input
├── Main: attention heatmap (Plotly)
└── Expander: raw attention tensor statistics (entropy, max, sparsity)
```

### Cross-Repo Contracts

- **Upstream:** `ai-attention-throughput-optimizer` supplies optimised attention modules;
  load with `torch.load(module_path, map_location=device)` and call `module(q, k, v)`
- **Upstream:** `ai-dist-training-scaler` supplies fine-tuned checkpoints for extracting
  task-specific attention patterns
- **Sync script:** Use [`scripts/sync_repos.sh`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/scripts/sync_repos.sh)
  to pull checkpoints and optimised modules into the workspace

### Streamlit Configuration

Copy hub's `.streamlit/config.toml` into this repo's `.streamlit/` directory:

```toml
[theme]
primaryColor = "#6C63FF"
backgroundColor = "#0E1117"
secondaryBackgroundColor = "#1E2130"
textColor = "#FAFAFA"
font = "monospace"

[server]
port = 8501
enableCORS = false
```

### Dependencies

```txt
torch>=2.3.0
transformers>=4.40.0
streamlit>=1.35.0
plotly>=5.22.0
numpy>=1.26.0
wandb>=0.17.0
```
