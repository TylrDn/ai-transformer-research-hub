# Planned Updates: ai-fault-tolerance-design

## Priority: High

### Straggler & Network Partition Simulation
- Extend the Monte Carlo simulator to model straggler nodes (slow workers degrading overall throughput)
- Add network partition scenarios: split-brain detection and recovery strategies
- Produce survival probability curves for each failure mode independently and in combination

### Checkpoint/Resume Integration Tests
- Add a pytest suite that launches a minimal 2-process distributed job, injects a failure mid-training, and verifies automatic resume from the last checkpoint
- Run these tests in CI on CPU-only mode to avoid GPU requirements

## Priority: Medium

### Adaptive Checkpointing
- Implement a checkpointing scheduler that increases checkpoint frequency when estimated failure probability rises (e.g., during long jobs on large clusters)
- Expose as a configurable policy: `fixed`, `adaptive`, `risk-based`

### Unified Metrics Dashboard Integration
- Export checkpoint events, resume events, and estimated job survival probability to the dashboard JSON schema
- Enables correlation between infrastructure reliability and model quality metrics

## Priority: Low

### Chaos Engineering Toolkit
- Provide scripts to inject controlled node failures into a live Slurm or Kubernetes job
- Use alongside the simulator to validate that theoretical survival numbers match observed behavior

### Publication / Design Doc Update
- Update the design document to cover all new failure modes
- Add a comparison table against existing fault tolerance approaches (CKPT-Restart, DML, etc.)
