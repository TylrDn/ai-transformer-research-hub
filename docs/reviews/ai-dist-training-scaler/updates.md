# Planned Updates: ai-dist-training-scaler

## Priority: High

### Cross-Project CI/CD Pipeline
- Define a GitHub Actions workflow that runs an end-to-end smoke test: preprocess a small Wikipedia sample → train for 100 steps → run attention benchmark
- Use workflow_call to compose individual repo workflows into a hub-level pipeline

### Unified Metrics Dashboard Integration
- Stream TensorBoard scalar data to a lightweight JSON log format on each checkpoint
- Feed the JSON logs into the Phase 2 unified metrics dashboard for cross-run comparison

## Priority: Medium

### Docker Compose Multi-Project Environment
- Add a `docker-compose.yml` that brings up preprocessor, trainer, and profiler in a single command
- Use named volumes for dataset shards and checkpoint directories shared between services

### Slurm Job Templates
- Provide ready-to-use Slurm batch scripts for common HPC cluster configurations
- Cover single-node multi-GPU, multi-node Infiniband, and cloud (AWS/GCP) configurations

## Priority: Low

### Federated Training Experiments
- Prototype a federated Transformer training setup using Flower or OpenFL
- Compare convergence and communication overhead against centralized training baseline

### ZeRO-Infinity / Offloading
- Evaluate ZeRO-Infinity (NVMe offloading) for models too large to fit on GPU+CPU RAM
- Document memory vs. throughput trade-offs
