# Planned Updates: ai-attention-throughput-optimizer

## Priority: High

### Flash Attention v3 Integration
- Add `flash_attn_v3` backend to the benchmark runner
- Compare v2 vs v3 throughput and memory on common sequence lengths (512, 1024, 2048, 4096)
- Update benchmark CSVs and profiling reports accordingly

### Regression Baseline
- Capture a set of golden benchmark numbers on a reference GPU (e.g., A100 40 GB)
- Add a CI check that fails if throughput regresses by more than 5%

## Priority: Medium

### Sparse Attention Experiments
- Integrate Longformer-style local + global sparse attention
- Add BigBird random + sliding window sparse patterns
- Benchmark against dense baselines at long sequence lengths (8192+)

### Shared Benchmark Dataset
- Coordinate with `ai-wiki-dataset-preprocessor` to produce a fixed 10 K-sample evaluation split
- Use this split consistently across `ai-attention-throughput-optimizer` and `ai-transformer-efficiency-comparison`

## Priority: Low

### Docker Image
- Publish a versioned Docker image with all profiling dependencies pre-installed
- Add `docker-compose` entry to the hub's Phase 2 multi-project environment

### HuggingFace Hub Publishing
- Export optimized attention modules as HF-compatible model components
- Tag releases on the HuggingFace Hub for community reuse
