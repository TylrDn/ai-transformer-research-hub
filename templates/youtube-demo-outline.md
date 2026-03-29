# YouTube Demo Outline — Transformer Research Hub

Seven-episode series showcasing the end-to-end research pipeline.
Each episode maps to one or more sister repositories and a Phase 3/4 notebook.

---

## Series Title

**"Building Production-Grade Transformer Research from Scratch"**
*Taylor Dean — AI Systems Engineer & ML Researcher*

---

## Episode Guide

### Episode 1 — Hub Overview & Ecosystem Walkthrough (10 min)

**Goal:** Orient viewers; establish credibility and project scope.

**Script sections:**
1. Intro: who is this for, what will you build?
2. Walk the README: ecosystem table, architecture diagram, mermaid pipeline
3. Clone all repos with one command (`scripts/clone-all.sh`)
4. Tour the VS Code multi-root workspace
5. Outro: what's coming in the series

**Key visuals:**
- Architecture diagram from `docs/architecture.md`
- Live terminal: `bash scripts/clone-all.sh`
- VS Code workspace with all repos loaded

**Checklist:**
- [ ] Record screen with VS Code open
- [ ] Show badges updating in README
- [ ] Add subscribe/like CTA at 8 min

---

### Episode 2 — Dataset Preprocessing at Scale (15 min)

**Goal:** Show Wikipedia dump → JSONL pipeline with HuggingFace Datasets.

**Notebook:** `notebooks/01_wiki_preprocessing.ipynb`

**Script sections:**
1. Why clean datasets matter for Transformer research
2. Download a Wikipedia dump (or use cached sample)
3. Run the preprocessor: tokenization, dedup, sharding
4. Inspect output JSONL with pandas
5. Push to HuggingFace Hub

**Key visuals:**
- Terminal: preprocessing progress bar
- wandb dashboard: token count, dedup ratio
- JSONL sample in notebook output

**Checklist:**
- [ ] Use small dump (20MB sample) for live demo
- [ ] Show wandb run live
- [ ] Link to `ai-wiki-dataset-preprocessor` in description

---

### Episode 3 — FlashAttention-3 Benchmark (12 min)

**Goal:** Demonstrate measurable performance gains over vanilla attention.

**Notebook:** `notebooks/02_flashattn3_benchmark.ipynb`

**Script sections:**
1. What FlashAttention-3 is and why it matters ([arXiv 2407.08608](https://arxiv.org/abs/2407.08608))
2. Benchmark setup: sequence lengths 1k → 64k
3. Run benchmarks; live throughput/latency plots
4. Memory comparison: vanilla vs flash vs linear
5. Takeaways: when to use each variant

**Key visuals:**
- Latency vs sequence length line chart
- Memory usage bar chart
- Throughput heatmap (sequence length × batch size)

**Checklist:**
- [ ] Record on GPU machine or use pre-recorded results
- [ ] Export charts as PNG for thumbnail
- [ ] Cite paper in description

---

### Episode 4 — GPT-2 vs RWKV Pareto Analysis (12 min)

**Goal:** Show how to systematically compare Transformer architectures.

**Notebook:** `notebooks/03_gpt2_rwkv_pareto.ipynb`

**Script sections:**
1. Intro to Pareto efficiency (performance vs compute)
2. Load GPT-2 and RWKV with same vocab/dataset
3. Evaluate: perplexity, latency, peak memory
4. Plot Pareto frontier
5. Implications for architecture search

**Key visuals:**
- Pareto scatter: perplexity × latency
- Per-layer efficiency breakdown

**Checklist:**
- [ ] Use small GPT-2 (124M) for demo
- [ ] Export Pareto plot as thumbnail
- [ ] Link to [RWKV arXiv](https://arxiv.org/abs/2305.13048)

---

### Episode 5 — Interactive Attention Heatmaps with Streamlit (12 min)

**Goal:** Build and deploy a live attention visualization app.

**Notebook:** `notebooks/04_attention_viz_streamlit.ipynb`

**Script sections:**
1. Why attention visualization matters for interpretability
2. Extract per-head attention weights from any HF model
3. Build Plotly heatmaps in notebook
4. Generate and run `streamlit_app.py` locally
5. Deploy to Streamlit Cloud (live demo)

**Key visuals:**
- Interactive Streamlit app in browser
- Attention heatmap for "Hello, world" token sequence
- Head-level navigation

**Checklist:**
- [ ] Deploy app to Streamlit Cloud before recording
- [ ] Screen-record the live app
- [ ] Add app URL to video description

---

### Episode 6 — Distributed Training with DeepSpeed ZeRO-3 (18 min)

**Goal:** Show multi-GPU training with fault injection and wandb tracking.

**Notebook:** `notebooks/05_deepspeed_zero3_training.ipynb`

**Script sections:**
1. Why ZeRO-3 enables trillion-parameter training ([arXiv 1910.02054](https://arxiv.org/abs/1910.02054))
2. Configure Accelerate + DeepSpeed (`configs/deepspeed_zero3.json`)
3. Launch training on wiki JSONL data
4. Inject a node failure mid-run; observe checkpoint recovery
5. wandb: training curves, GPU utilization, memory

**Key visuals:**
- `accelerate launch` terminal output
- wandb training dashboard (live)
- Fault injection recovery log

**Checklist:**
- [ ] Use 2× T4 minimum; A100 preferred for 4K context
- [ ] Record recovery from checkpoint
- [ ] Show ZeRO-3 memory savings vs baseline

---

### Episode 7 — Full Pipeline + Benchmarking vs LLaMA/GPT-4 (20 min)

**Goal:** End-to-end showcase; position work against SOTA.

**Script sections:**
1. Run `scripts/run-e2e-pipeline.sh` from scratch (or `--skip-preprocess`)
2. Compare trained model metrics against published LLaMA-3 / GPT-4 numbers
3. Discuss gaps and next research directions
4. Open-source the leaderboard integration

**Key visuals:**
- E2E pipeline terminal (timelapse)
- Comparison table: your model vs LLaMA-3-8B vs GPT-2-XL
- GitHub repo stats (stars, forks, contributions)

**Checklist:**
- [ ] Pre-record pipeline run (real-time too slow)
- [ ] Prepare comparison table in LaTeX + Markdown
- [ ] End with call-to-action: "star, fork, contribute"

---

## YouTube Description Template

```
[EPISODE TITLE] | Transformer Research Hub Series

In this video: [1-2 sentence summary]

🔗 GitHub: https://github.com/TylrDn/ai-transformer-research-hub
📓 Notebook: https://github.com/TylrDn/[SISTER_REPO]/blob/main/notebooks/[NOTEBOOK].ipynb
📄 Paper: [arXiv URL]

Timestamps:
00:00 Intro
[add timestamps after recording]

#TransformerResearch #DeepLearning #PyTorch #MachineLearning #MLOps
```

---

## Production Checklist

- [ ] Record in 1920×1080 at 60fps
- [ ] Use OBS with dark VS Code / terminal theme
- [ ] Export thumbnail (1280×720, bold title, benchmark chart)
- [ ] Add chapters via YouTube timestamps
- [ ] Pin the hub README link in first comment
- [ ] Cross-post to LinkedIn with key benchmark visual
