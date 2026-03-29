# Planned Updates: ai-attention-token-viz

## Priority: High

### Multi-Modal Attention Visualization
- Add cross-attention view for vision-language models (e.g., CLIP, LLaVA): display image patch grid on one axis and text tokens on the other
- Align with Phase 3 multi-modal Transformer support planned across the hub

### SVG / Vector Export
- Add `--export-svg` flag to the CLI and an SVG download button in the Streamlit UI
- Vector exports scale losslessly for journal figures and conference posters

## Priority: Medium

### Batch Visualization Mode
- Add a `batch_viz.py` script that generates HTML/PNG exports for every sample in an evaluation dataset
- Useful for auditing attention patterns across hundreds of inputs without manual interaction

### BertViz Integration Clarification & Consolidation
- Decide whether to wrap BertViz or replace it with the custom Plotly implementation
- Document the distinction clearly in the README; remove unused dependency if BertViz is not actively used

### GitHub Pages Demo
- Deploy the Streamlit app as a static demo via GitHub Pages (using `stlite` or a pre-rendered export)
- Lower the barrier for collaborators to explore the tool without a local Python environment

## Priority: Low

### HuggingFace Hub Publishing
- Add a "Share" button that uploads the current visualization to HuggingFace Spaces as a public demo
- Enables one-click sharing of attention analysis results with collaborators

### Sparse Attention Pattern Visualization
- Visualize non-dense (blocked, strided, or random) attention masks alongside the actual attention weights
- Coordinate with Phase 3 sparse attention experiments in `ai-attention-throughput-optimizer`
