# REFERENCES.md — Centralised arXiv citation registry

Every non-trivial algorithmic choice in this ecosystem cites its originating
paper below. When adding a new citation, append it to the relevant section
and include the inline comment format used throughout the codebase:

```python
# <Short title>: <Authors> (<Year>) https://arxiv.org/abs/<id>
```

## Attention Mechanisms

| Short name | Full title | Authors | Year | arXiv |
|------------|-----------|---------|------|-------|
| Transformer | Attention Is All You Need | Vaswani et al. | 2017 | [1706.03762](https://arxiv.org/abs/1706.03762) |
| FlashAttention | FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness | Dao et al. | 2022 | [2205.14135](https://arxiv.org/abs/2205.14135) |
| FlashAttention-2 | FlashAttention-2: Faster Attention with Better Parallelism and Work Partitioning | Dao | 2023 | [2307.08691](https://arxiv.org/abs/2307.08691) |
| FlashAttention-3 | FlashAttention-3: Fast and Accurate Attention with Asynchrony and Low-precision | Shah et al. | 2024 | [2407.08608](https://arxiv.org/abs/2407.08608) |
| Linear Attention | Transformers are RNNs: Fast Autoregressive Transformers with Linear Attention | Katharopoulos et al. | 2020 | [2006.16236](https://arxiv.org/abs/2006.16236) |
| Sparse Transformer | Generating Long Sequences with Sparse Transformers | Child et al. | 2019 | [1904.10509](https://arxiv.org/abs/1904.10509) |
| RWKV | RWKV: Reinventing RNNs for the Transformer Era | Peng et al. | 2023 | [2305.13048](https://arxiv.org/abs/2305.13048) |

## Scaling Laws

| Short name | Full title | Authors | Year | arXiv |
|------------|-----------|---------|------|-------|
| Scaling Laws | Scaling Laws for Neural Language Models | Kaplan et al. | 2020 | [2001.08361](https://arxiv.org/abs/2001.08361) |
| Chinchilla | Training Compute-Optimal Large Language Models | Hoffmann et al. | 2022 | [2203.15556](https://arxiv.org/abs/2203.15556) |

## Distributed Training

| Short name | Full title | Authors | Year | arXiv |
|------------|-----------|---------|------|-------|
| ZeRO | ZeRO: Memory Optimizations Toward Training Trillion Parameter Models | Rajbhandari et al. | 2020 | [1910.02054](https://arxiv.org/abs/1910.02054) |
| ZeRO-3 Offload | ZeRO-Offload: Democratizing Billion-Scale Model Training | Ren et al. | 2021 | [2101.06840](https://arxiv.org/abs/2101.06840) |
| Megatron-LM | Megatron-LM: Training Multi-Billion Parameter Language Models Using Model Parallelism | Shoeybi et al. | 2019 | [1909.08053](https://arxiv.org/abs/1909.08053) |
| Pipeline Parallelism | GPipe: Efficient Training of Giant Neural Networks using Pipeline Parallelism | Huang et al. | 2019 | [1811.06965](https://arxiv.org/abs/1811.06965) |

## Optimisers

| Short name | Full title | Authors | Year | arXiv |
|------------|-----------|---------|------|-------|
| Adam | Adam: A Method for Stochastic Optimization | Kingma & Ba | 2014 | [1412.6980](https://arxiv.org/abs/1412.6980) |
| AdamW | Decoupled Weight Decay Regularization | Loshchilov & Hutter | 2017 | [1711.05101](https://arxiv.org/abs/1711.05101) |
| Lion | Symbolic Discovery of Optimization Algorithms | Chen et al. | 2023 | [2302.06675](https://arxiv.org/abs/2302.06675) |

## Datasets & Preprocessing

| Short name | Full title | Authors | Year | arXiv / URL |
|------------|-----------|---------|------|-------------|
| C4 | Exploring the Limits of Transfer Learning with a Unified Text-to-Text Transformer | Raffel et al. | 2020 | [1910.10683](https://arxiv.org/abs/1910.10683) |
| The Pile | The Pile: An 800GB Dataset of Diverse Text for Language Modeling | Gao et al. | 2020 | [2101.00027](https://arxiv.org/abs/2101.00027) |
| Wikipedia | HuggingFace Datasets wikipedia | — | — | [datasets.huggingface.co](https://huggingface.co/datasets/wikipedia) |

## Fault Tolerance

| Short name | Full title | Authors | Year | arXiv |
|------------|-----------|---------|------|-------|
| Check-N-Run | Check-N-Run: a Checkpointing System for Training Deep Learning Recommendation Models | Eisenman et al. | 2022 | [2401.06172](https://arxiv.org/abs/2401.06172) |
| Bamboo | Bamboo: Making Preemptible Instances Resilient for Affordable Training of Large DNNs | Yang et al. | 2023 | [2303.02399](https://arxiv.org/abs/2303.02399) |

## Visualisation

| Short name | Full title | Authors | Year | arXiv / URL |
|------------|-----------|---------|------|-------------|
| BertViz | BertViz: Visualize Attention in NLP Models | Vig | 2019 | [1906.05714](https://arxiv.org/abs/1906.05714) |
| Attention Patterns | What Does BERT Look At? An Analysis of BERT's Attention | Clark et al. | 2019 | [1906.04341](https://arxiv.org/abs/1906.04341) |

## Benchmarks

| Short name | Full title | Authors | Year | arXiv / URL |
|------------|-----------|---------|------|-------------|
| LLaMA 3 | The Llama 3 Herd of Models | Meta AI | 2024 | [2407.21783](https://arxiv.org/abs/2407.21783) |
| GPT-4 Technical Report | GPT-4 Technical Report | OpenAI | 2023 | [2303.08774](https://arxiv.org/abs/2303.08774) |
| LongBench | LongBench: A Bilingual, Multitask Benchmark for Long Context Understanding | Bai et al. | 2023 | [2308.14508](https://arxiv.org/abs/2308.14508) |
