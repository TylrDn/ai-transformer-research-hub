# Copilot Instructions — ai-wiki-dataset-preprocessor

Drop this file into `.github/copilot-instructions.md` of the `ai-wiki-dataset-preprocessor` repository.

> **Hub template:** [`templates/copilot-instructions.md`](../../../templates/copilot-instructions.md)
> **Review notes:** [`docs/reviews/ai-wiki-dataset-preprocessor/`](../../reviews/ai-wiki-dataset-preprocessor/)

## Framework & Runtime

- **Python ≥ 3.10** with full type annotations (`from __future__ import annotations` where needed)
- **PyTorch ≥ 2.3** — tokenization helpers may use `torch` for tensor-based batching
- **IBM WatsonX compatibility** — exported datasets must be loadable via the WatsonX AI SDK
  (`ibm-watsonx-ai`); use HuggingFace `datasets.Dataset` as the interchange format
- **GPU-first optional** — preprocessing is CPU-bound; add `device` arguments for any
  embedding-based filtering steps and provide graceful CPU fallback

## Experiment Tracking

- Log **all** pipeline runs with Weights & Biases (`wandb`):
  - `wandb.init(project="ai-wiki-dataset-preprocessor", config=cfg)`
  - Log per-shard stats: `wandb.log({"shard": i, "articles": n, "tokens": t})`
  - Log final artefacts: `wandb.log_artifact` for each `*.jsonl` shard
- Include a `--no-wandb` / `WANDB_DISABLED=true` escape hatch for offline runs

## Citations

- Every non-trivial algorithmic choice must include an inline comment citing the originating
  paper in arXiv format:

  ```python
  # MinHash LSH: Broder (1997) — locality-sensitive hashing for near-duplicate detection
  # DataComp dedup: Gadre et al. (2023) https://arxiv.org/abs/2304.14108
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
- Mock file I/O in unit tests — do not rely on real Wikipedia dumps
- Provide a small synthetic fixture dump (`tests/fixtures/mini_dump.xml.bz2`) for integration tests

## CI/CD

- GitHub Actions workflows must pass on `ubuntu-latest` with Python 3.11
- Required checks: `ruff check .`, `black --check .`, `pytest --cov`
- Docker images based on `nvcr.io/nvidia/pytorch:24.03-py3` for GPU jobs

## Data Conventions

- Datasets are stored as **JSONL** (one JSON object per line, UTF-8)
- Dataset schema: `{"id": str, "text": str, "meta": {"title": str, "url": str, "length": int}}`
- Use HuggingFace `datasets` library for all dataset I/O; export to HF Hub when applicable
- Shard naming: `wiki-<lang>-<split>-<shard_index:05d>.jsonl` (e.g., `wiki-en-train-00000.jsonl`)

## Repo-Specific Notes

### Entry Points

| Script | Purpose |
|--------|---------|
| `pipeline.py` | Main orchestration script — dump → extract → dedup → shard |
| `extract_articles.py` | Parse `.xml.bz2` dump; yield `(id, title, text)` tuples |
| `minhash_dedup.py` | MinHash LSH deduplication; configurable Jaccard threshold |
| `write_jsonl_shards.py` | Write deduplicated articles to sized JSONL shards |

### Key Functions

```python
def extract_articles(dump_path: Path, lang: str = "en") -> Iterator[dict]:
    """Yield {"id": str, "text": str, "meta": {...}} from a Wikipedia XML dump."""

def minhash_dedup(articles: Iterable[dict], threshold: float = 0.8) -> list[dict]:
    """Remove near-duplicates using MinHash LSH (datasketch).
    # MinHash LSH: Broder (1997) / datasketch: https://github.com/ekzhu/datasketch
    """

def write_jsonl_shards(
    articles: Iterable[dict], output_dir: Path, shard_size: int = 10_000
) -> list[Path]:
    """Write articles to numbered JSONL shards; return list of created paths."""
```

### Data Flow

```
Wikipedia .xml.bz2 dump
        ↓  extract_articles()
  Raw article dicts
        ↓  minhash_dedup()
  Deduplicated articles
        ↓  write_jsonl_shards()
  wiki-en-train-*.jsonl  →  ai-dist-training-scaler
                          →  HuggingFace Hub
```

### Cross-Repo Contracts

- **Downstream:** `ai-dist-training-scaler` expects JSONL with schema
  `{"id": str, "text": str, "meta": {...}}`; shard files must be `≤ 500 MB` each
- **Shared config:** DeepSpeed ZeRO-3 JSON lives in the hub's
  [`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json)
- **Sync script:** Use [`scripts/sync_repos.sh`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/scripts/sync_repos.sh)
  from the hub to pull produced shards into sibling repos

### Dependencies

```txt
wikiextractor>=3.0.6
datasketch>=1.6.5
datasets>=2.19.0
tqdm>=4.66.0
wandb>=0.17.0
```
