# Planned Updates: ai-transformer-efficiency-comparison

## Priority: High

### Unified Metrics Dashboard Integration
- Emit structured JSON alongside Markdown reports so the Phase 2 dashboard can ingest results automatically
- Define a schema: `{ model, variant, flops, latency_ms, peak_memory_gb, hardware, timestamp }`

### Hardware Metadata Tagging
- Record GPU model, driver version, CUDA version, and batch size in every output file
- Prevents silent comparison errors when results from different machines are mixed

## Priority: Medium

### Multi-Modal Transformer Variants
- Add ViT (Vision Transformer) and CLIP to the comparison matrix
- Benchmark cross-attention blocks separately from self-attention blocks

### Live Re-benchmarking via GitHub Actions
- Add a weekly scheduled workflow that re-runs comparisons on a self-hosted GPU runner
- Commit updated Markdown reports automatically via a bot commit

## Priority: Low

### Interactive Plotly Dashboard (static HTML)
- Export a self-contained `report.html` with interactive Plotly charts
- Host via GitHub Pages for easy sharing without running a server

### Federated / Sparse Variants
- Add sparse attention efficiency numbers to align with Phase 3 sparse attention experiments in `ai-attention-throughput-optimizer`
