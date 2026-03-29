<div align="center">

# 🤖 Transformer Research Hub

**Central showcase and navigation for Transformer research experiments**

*Attention mechanisms · Scaling · Datasets · Visualization · Fault Tolerance*

[![GitHub followers](https://img.shields.io/github/followers/TylrDn?style=social)](https://github.com/TylrDn)
[![Profile views](https://komarev.com/ghpvc/?username=TylrDn&color=blue&style=flat-square)](https://github.com/TylrDn)

> Tyler Dunlap — IBM Systems Engineer | ML Researcher | Distributed Training & Transformer Architecture

</div>

---

## 🗂️ Project Ecosystem

Six interconnected projects covering the full lifecycle of Transformer research — from data ingestion through training, optimization, visualization, and fault tolerance.

| Project | Description | Language | Status | Links |
|---------|-------------|----------|--------|-------|
| [**ai-attention-throughput-optimizer**](https://github.com/TylrDn/ai-attention-throughput-optimizer) | Profile, benchmark, and optimize throughput of new attention mechanisms | ![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white&style=flat-square) | [![Stars](https://img.shields.io/github/stars/TylrDn/ai-attention-throughput-optimizer?style=flat-square)](https://github.com/TylrDn/ai-attention-throughput-optimizer/stargazers) [![Last commit](https://img.shields.io/github/last-commit/TylrDn/ai-attention-throughput-optimizer?style=flat-square)](https://github.com/TylrDn/ai-attention-throughput-optimizer/commits) | [⭐ Star](https://github.com/TylrDn/ai-attention-throughput-optimizer) · [🍴 Fork](https://github.com/TylrDn/ai-attention-throughput-optimizer/fork) |
| [**ai-transformer-efficiency-comparison**](https://github.com/TylrDn/ai-transformer-efficiency-comparison) | Compare compute efficiency of Transformer variants (FLOPs, latency, memory) | ![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white&style=flat-square) | [![Stars](https://img.shields.io/github/stars/TylrDn/ai-transformer-efficiency-comparison?style=flat-square)](https://github.com/TylrDn/ai-transformer-efficiency-comparison/stargazers) [![Last commit](https://img.shields.io/github/last-commit/TylrDn/ai-transformer-efficiency-comparison?style=flat-square)](https://github.com/TylrDn/ai-transformer-efficiency-comparison/commits) | [⭐ Star](https://github.com/TylrDn/ai-transformer-efficiency-comparison) · [🍴 Fork](https://github.com/TylrDn/ai-transformer-efficiency-comparison/fork) |
| [**ai-wiki-dataset-preprocessor**](https://github.com/TylrDn/ai-wiki-dataset-preprocessor) | Pipeline to process Wikipedia dumps into model-ready JSONL/text format | ![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white&style=flat-square) | [![Stars](https://img.shields.io/github/stars/TylrDn/ai-wiki-dataset-preprocessor?style=flat-square)](https://github.com/TylrDn/ai-wiki-dataset-preprocessor/stargazers) [![Last commit](https://img.shields.io/github/last-commit/TylrDn/ai-wiki-dataset-preprocessor?style=flat-square)](https://github.com/TylrDn/ai-wiki-dataset-preprocessor/commits) | [⭐ Star](https://github.com/TylrDn/ai-wiki-dataset-preprocessor) · [🍴 Fork](https://github.com/TylrDn/ai-wiki-dataset-preprocessor/fork) |
| [**ai-dist-training-scaler**](https://github.com/TylrDn/ai-dist-training-scaler) | Scale Transformer training jobs to thousands of GPUs with Accelerate/DeepSpeed | ![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white&style=flat-square) | [![Stars](https://img.shields.io/github/stars/TylrDn/ai-dist-training-scaler?style=flat-square)](https://github.com/TylrDn/ai-dist-training-scaler/stargazers) [![Last commit](https://img.shields.io/github/last-commit/TylrDn/ai-dist-training-scaler?style=flat-square)](https://github.com/TylrDn/ai-dist-training-scaler/commits) | [⭐ Star](https://github.com/TylrDn/ai-dist-training-scaler) · [🍴 Fork](https://github.com/TylrDn/ai-dist-training-scaler/fork) |
| [**ai-fault-tolerance-design**](https://github.com/TylrDn/ai-fault-tolerance-design) | Design document and simulator for fault tolerance in distributed training systems | ![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white&style=flat-square) | [![Stars](https://img.shields.io/github/stars/TylrDn/ai-fault-tolerance-design?style=flat-square)](https://github.com/TylrDn/ai-fault-tolerance-design/stargazers) [![Last commit](https://img.shields.io/github/last-commit/TylrDn/ai-fault-tolerance-design?style=flat-square)](https://github.com/TylrDn/ai-fault-tolerance-design/commits) | [⭐ Star](https://github.com/TylrDn/ai-fault-tolerance-design) · [🍴 Fork](https://github.com/TylrDn/ai-fault-tolerance-design/fork) |
| [**ai-attention-token-viz**](https://github.com/TylrDn/ai-attention-token-viz) | Interactive visualization tool for token-to-token attention in language models | ![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white&style=flat-square) | [![Stars](https://img.shields.io/github/stars/TylrDn/ai-attention-token-viz?style=flat-square)](https://github.com/TylrDn/ai-attention-token-viz/stargazers) [![Last commit](https://img.shields.io/github/last-commit/TylrDn/ai-attention-token-viz?style=flat-square)](https://github.com/TylrDn/ai-attention-token-viz/commits) | [⭐ Star](https://github.com/TylrDn/ai-attention-token-viz) · [🍴 Fork](https://github.com/TylrDn/ai-attention-token-viz/fork) |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Transformer Research Hub                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
  ┌──────────┐      ┌────────────┐     ┌──────────────┐
  │ Dataset  │      │ Training   │     │ Visualization│
  │ Pipeline │      │ & Scaling  │     │ & Analysis   │
  └────┬─────┘      └─────┬──────┘     └──────┬───────┘
       │                  │                   │
       ▼                  ▼                   ▼
  ai-wiki-dataset    ai-dist-training    ai-attention-
  -preprocessor        -scaler           token-viz
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ai-attention  ai-transformer  ai-fault-
        -throughput-   -efficiency-  tolerance-
         optimizer     comparison     design
```

See [docs/architecture.md](docs/architecture.md) for the full Mermaid diagram.

---

## 🚀 Quick Start

Each project is self-contained. To get started with any of them:

```bash
# 1. Clone the project you want
git clone https://github.com/TylrDn/<project-name>
cd <project-name>

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the main script or check the README for specific instructions
python main.py
```

### Project-Specific Quickstarts

| Project | One-line Run |
|---------|-------------|
| [ai-attention-throughput-optimizer](https://github.com/TylrDn/ai-attention-throughput-optimizer) | `python benchmark.py --model flash-attention` |
| [ai-transformer-efficiency-comparison](https://github.com/TylrDn/ai-transformer-efficiency-comparison) | `python compare.py --variants vanilla,linear,flash` |
| [ai-wiki-dataset-preprocessor](https://github.com/TylrDn/ai-wiki-dataset-preprocessor) | `python preprocess.py --input dump.xml.bz2 --output data/` |
| [ai-dist-training-scaler](https://github.com/TylrDn/ai-dist-training-scaler) | `accelerate launch train.py --config config.yaml` |
| [ai-fault-tolerance-design](https://github.com/TylrDn/ai-fault-tolerance-design) | `python simulate.py --nodes 64 --failure-rate 0.01` |
| [ai-attention-token-viz](https://github.com/TylrDn/ai-attention-token-viz) | `python viz.py --model bert-base-uncased --text "Hello world"` |

---

## 🗺️ Roadmap

### ✅ Phase 1 — Foundation (Complete)
- [x] Core dataset preprocessing pipeline (`ai-wiki-dataset-preprocessor`)
- [x] Attention mechanism benchmarking framework (`ai-attention-throughput-optimizer`)
- [x] Transformer efficiency comparison suite (`ai-transformer-efficiency-comparison`)
- [x] Distributed training infrastructure (`ai-dist-training-scaler`)
- [x] Fault tolerance design & simulation (`ai-fault-tolerance-design`)
- [x] Attention visualization tooling (`ai-attention-token-viz`)

### 🚧 Phase 2 — Integration (In Progress)
- [ ] Cross-project CI/CD pipeline
- [ ] Shared benchmarking baseline dataset
- [ ] Unified metrics dashboard
- [ ] Docker Compose multi-project environment

### 🔮 Phase 3 — Research Extensions (Planned)
- [ ] Flash Attention v3 integration and profiling
- [ ] Multi-modal Transformer support (vision + language)
- [ ] Sparse attention pattern experiments
- [ ] Federated training experiments
- [ ] Integration with HuggingFace Hub for model publishing

---

## 📊 GitHub Stats

<div align="center">

![TylrDn's GitHub Stats](https://github-readme-stats.vercel.app/api?username=TylrDn&show_icons=true&theme=tokyonight&include_all_commits=true&count_private=true)

![Top Languages](https://github-readme-stats.vercel.app/api/top-langs/?username=TylrDn&layout=compact&theme=tokyonight&langs_count=8)

</div>

---

## 🤝 Contributing

Contributions are welcome across all projects in this hub! Please follow the guidelines below.

### How to Contribute

1. **Fork** the specific project repository you want to contribute to
2. **Create** a feature branch: `git checkout -b feature/your-feature-name`
3. **Commit** your changes: `git commit -m 'feat: add some feature'`
4. **Push** to your fork: `git push origin feature/your-feature-name`
5. **Open** a Pull Request against the `main` branch

### Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: new feature
fix: bug fix
docs: documentation change
perf: performance improvement
refactor: code refactor
test: adding/updating tests
chore: maintenance
```

### Code Standards

- Python: follow [PEP 8](https://pep8.org/) and include docstrings
- Tests: add unit tests for new functionality (pytest)
- Documentation: update README and inline comments as needed

---

## 📬 Contact & Links

<div align="center">

| Platform | Link |
|----------|------|
| 🐙 GitHub | [@TylrDn](https://github.com/TylrDn) |
| 💼 LinkedIn | [Tyler Dunlap](https://www.linkedin.com/in/tylerdunlap/) |
| 🏢 IBM | IBM Systems Engineer |

</div>

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

*Built with ❤️ for the ML research community*

[![Hub Stars](https://img.shields.io/github/stars/TylrDn/ai-transformer-research-hub?style=social)](https://github.com/TylrDn/ai-transformer-research-hub/stargazers)

</div>
