# Copilot Instructions — ai-fault-tolerance-design

Drop this file into `.github/copilot-instructions.md` of the `ai-fault-tolerance-design`
repository.

> **Hub template:** [`templates/copilot-instructions.md`](../../../templates/copilot-instructions.md)
> **Review notes:** [`docs/reviews/ai-fault-tolerance-design/`](../../reviews/ai-fault-tolerance-design/)

## Framework & Runtime

- **Python ≥ 3.10** with full type annotations (`from __future__ import annotations` where needed)
- **PyTorch ≥ 2.3** — fault injection hooks attach to `torch.distributed` process groups;
  use `torch.distributed.is_available()` guard in all distributed code paths
- **IBM WatsonX compatibility** — the `FaultTolerantTrainer` wrapper must be composable with
  any HuggingFace `PreTrainedModel`-based training loop used in WatsonX AI pipelines
- **GPU-first** — default CUDA device for all tensor operations; add explicit `device`
  arguments and graceful CPU fallback so simulations run in CI without GPUs

## Experiment Tracking

- Log **all** simulation runs with Weights & Biases (`wandb`):
  - `wandb.init(project="ai-fault-tolerance-design", config=cfg)`
  - Log per-scenario results: `wandb.log({"scenario": s, "fleet_size": n, "survival": p})`
  - Log Monte Carlo reliability curves as `wandb.Table` and `wandb.Image` artefacts
- Include a `--no-wandb` / `WANDB_DISABLED=true` escape hatch for offline runs

## Citations

- Every non-trivial algorithmic choice must include an inline comment citing the originating
  paper in arXiv format:

  ```python
  # Chaos engineering: Basiri et al. (2016) — Chaos Monkey at Netflix
  # Check-N-Run: Eisenman et al. (2022) https://arxiv.org/abs/2204.09552
  # Resilience in ML: Gupta et al. (2020) https://arxiv.org/abs/2006.08887
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
- Mock GPU operations and `torch.distributed` calls in unit tests
- Monte Carlo tests must be deterministic: seed `numpy.random` and `random` in fixtures

## CI/CD

- GitHub Actions workflows must pass on `ubuntu-latest` with Python 3.11
- Required checks: `ruff check .`, `black --check .`, `pytest --cov`
- Distributed integration tests require `DISTRIBUTED_TEST=1` and multiple processes
- Docker images based on `nvcr.io/nvidia/pytorch:24.03-py3` for GPU jobs

## Data Conventions

- Datasets are stored as **JSONL** (one JSON object per line, UTF-8)
- Dataset schema: `{"id": str, "text": str, "meta": {...}}`
- Simulation results serialised as JSON: `{"scenario": str, "fleet_size": int, "survival": float, "p50_recovery_s": float}`
- Reliability curves exported as CSV: `fleet_size,scenario,survival_probability`

## Distributed Training

- Use **HuggingFace Accelerate** as the primary distributed backend
- DeepSpeed **ZeRO-3** config lives in the hub's
  [`configs/deepspeed_zero3.json`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/configs/deepspeed_zero3.json)
- All training scripts accept `--config <yaml>` for hyperparameter overrides

## Repo-Specific Notes

### Entry Points

| Script | Purpose |
|--------|---------|
| `simulator.py` | Main simulation driver — runs all fault scenarios |
| `distributed_training_simulator.py` | `DistributedTrainingSimulator` class with injection hooks |
| `monte_carlo_survival.py` | Monte Carlo reliability sweep across fleet sizes |
| `fault_scenarios.py` | Scenario definitions: `node_failure`, `gradient_corruption`, `slow_node` |

### Key Classes & Functions

```python
@dataclass
class ScenarioResult:
    scenario: str
    fleet_size: int
    n_trials: int
    survival_probability: float
    p50_recovery_s: float
    p95_recovery_s: float


class DistributedTrainingSimulator:
    """Simulate fault injection in a virtual distributed training fleet.

    Chaos engineering: Basiri et al. (2016) — Chaos Monkey at Netflix
    """

    def run_scenario(self, scenario: str, fleet_size: int, n_trials: int) -> ScenarioResult: ...
    def node_failure(self, fleet_size: int) -> bool: ...
    def gradient_corruption(self, p_corrupt: float = 0.05) -> bool: ...
    def slow_node(self, slowdown_factor: float = 10.0) -> bool: ...


def monte_carlo_survival(
    simulator: DistributedTrainingSimulator,
    fleet_sizes: list[int],
    scenarios: list[str],
    n_trials: int = 1000,
) -> list[ScenarioResult]:
    """Sweep fleet sizes × scenarios; return list of ScenarioResult."""
```

### Fault Scenarios

| Scenario | Description | Key Parameter |
|----------|-------------|---------------|
| `node_failure` | Random worker process crash | `p_fail` per step |
| `gradient_corruption` | NaN/Inf injection into gradient tensors | `p_corrupt` per batch |
| `slow_node` | Straggler simulation — one node runs at `1/slowdown_factor` speed | `slowdown_factor` |

### Cross-Repo Contracts

- **Upstream (composes with):** `ai-dist-training-scaler` — the `FaultTolerantTrainer`
  wrapper should be applied around `train_zero3()` calls
- **Downstream:** Hub notebook `notebooks/06_chaos_fault_injection.ipynb` imports
  `DistributedTrainingSimulator` and `monte_carlo_survival` directly
- **Sync script:** Use [`scripts/sync_repos.sh`](https://github.com/TylrDn/ai-transformer-research-hub/blob/main/scripts/sync_repos.sh)
  to share simulation result JSONs with the hub

### Dependencies

```txt
torch>=2.3.0
numpy>=1.26.0
scipy>=1.13.0
matplotlib>=3.9.0
plotly>=5.22.0
wandb>=0.17.0
```
