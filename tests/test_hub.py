"""tests/test_hub.py — Hub-level structural validation tests.

Validates that all expected files and directories exist and contain
the right content markers. No GPU or network access required.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).parent.parent


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


# ---------------------------------------------------------------------------
# Scripts
# ---------------------------------------------------------------------------

class TestScripts:
    def test_clone_all_exists(self) -> None:
        assert (ROOT / "scripts" / "clone-all.sh").exists()

    def test_clone_all_executable_shebang(self) -> None:
        content = read("scripts/clone-all.sh")
        assert content.startswith("#!/usr/bin/env bash")

    def test_run_e2e_pipeline_exists(self) -> None:
        assert (ROOT / "scripts" / "run-e2e-pipeline.sh").exists()

    def test_run_e2e_pipeline_has_distributed_flag(self) -> None:
        content = read("scripts/run-e2e-pipeline.sh")
        assert "--distributed" in content

    def test_run_e2e_pipeline_has_skip_flags(self) -> None:
        content = read("scripts/run-e2e-pipeline.sh")
        for flag in ("--skip-preprocess", "--skip-train", "--skip-viz", "--skip-benchmark", "--skip-compare"):
            assert flag in content, f"Missing flag: {flag}"

    def test_run_e2e_pipeline_has_dry_run(self) -> None:
        content = read("scripts/run-e2e-pipeline.sh")
        assert "--dry-run" in content

    def test_sync_repos_exists(self) -> None:
        assert (ROOT / "scripts" / "sync_repos.sh").exists()

    def test_sync_repos_has_all_sister_repos(self) -> None:
        content = read("scripts/sync_repos.sh")
        for repo in (
            "ai-wiki-dataset-preprocessor",
            "ai-dist-training-scaler",
            "ai-fault-tolerance-design",
            "ai-attention-throughput-optimizer",
            "ai-transformer-efficiency-comparison",
            "ai-attention-token-viz",
        ):
            assert repo in content, f"Missing repo in sync_repos.sh: {repo}"


# ---------------------------------------------------------------------------
# Notebooks
# ---------------------------------------------------------------------------

EXPECTED_NOTEBOOKS = [
    "notebooks/01_wiki_preprocessing.ipynb",
    "notebooks/02_flashattn3_benchmark.ipynb",
    "notebooks/03_gpt2_rwkv_pareto.ipynb",
    "notebooks/04_attention_viz_streamlit.ipynb",
    "notebooks/05_deepspeed_zero3_training.ipynb",
    "notebooks/06_chaos_fault_injection.ipynb",
]


class TestNotebooks:
    def test_all_notebooks_exist(self) -> None:
        for nb in EXPECTED_NOTEBOOKS:
            assert (ROOT / nb).exists(), f"Missing notebook: {nb}"

    def test_notebooks_valid_json(self) -> None:
        for nb in EXPECTED_NOTEBOOKS:
            data = json.loads((ROOT / nb).read_text(encoding="utf-8"))
            assert data.get("nbformat") == 4, f"Unexpected nbformat in {nb}"

    def test_notebooks_have_wandb_escape_hatch(self) -> None:
        for nb in EXPECTED_NOTEBOOKS:
            content = (ROOT / nb).read_text(encoding="utf-8")
            assert "WANDB_DISABLED" in content, f"Missing WANDB_DISABLED escape hatch in {nb}"

    def test_notebooks_have_arxiv_citations(self) -> None:
        for nb in EXPECTED_NOTEBOOKS[1:]:  # skip wiki (no arXiv needed)
            content = (ROOT / nb).read_text(encoding="utf-8")
            assert "https://arxiv.org/abs/" in content, f"Missing arXiv citation in {nb}"

    def test_notebook_01_has_pipeline_diagram(self) -> None:
        content = read("notebooks/01_wiki_preprocessing.ipynb")
        assert "JSONL" in content

    def test_notebook_02_has_flash_attention(self) -> None:
        content = read("notebooks/02_flashattn3_benchmark.ipynb")
        assert "FlashAttention" in content

    def test_notebook_06_has_simulator_class(self) -> None:
        content = read("notebooks/06_chaos_fault_injection.ipynb")
        assert "DistributedTrainingSimulator" in content


class TestNotebookImplementations:
    """Validate that Phase-3 TODO stubs have been replaced with real implementations."""

    def test_no_todo_stubs_remaining(self) -> None:
        for nb in EXPECTED_NOTEBOOKS:
            content = (ROOT / nb).read_text(encoding="utf-8")
            assert "# TODO (Phase 3)" not in content, f"Unimplemented stub in {nb}"

    def test_notebook_01_has_extract_function(self) -> None:
        content = read("notebooks/01_wiki_preprocessing.ipynb")
        assert "extract_articles" in content

    def test_notebook_01_has_dedup_function(self) -> None:
        content = read("notebooks/01_wiki_preprocessing.ipynb")
        assert "minhash_dedup" in content

    def test_notebook_01_has_shard_writer(self) -> None:
        content = read("notebooks/01_wiki_preprocessing.ipynb")
        assert "write_jsonl_shards" in content

    def test_notebook_02_has_benchmark_function(self) -> None:
        content = read("notebooks/02_flashattn3_benchmark.ipynb")
        assert "benchmark_attention" in content

    def test_notebook_02_has_sdp_backends(self) -> None:
        content = read("notebooks/02_flashattn3_benchmark.ipynb")
        assert "scaled_dot_product_attention" in content

    def test_notebook_03_has_perplexity_function(self) -> None:
        content = read("notebooks/03_gpt2_rwkv_pareto.ipynb")
        assert "compute_perplexity" in content

    def test_notebook_03_has_pareto_function(self) -> None:
        content = read("notebooks/03_gpt2_rwkv_pareto.ipynb")
        assert "is_pareto_optimal" in content

    def test_notebook_04_has_attention_extractor(self) -> None:
        content = read("notebooks/04_attention_viz_streamlit.ipynb")
        assert "extract_attention_weights" in content

    def test_notebook_04_generates_streamlit_app(self) -> None:
        content = read("notebooks/04_attention_viz_streamlit.ipynb")
        assert "streamlit_app.py" in content
        assert "streamlit" in content

    def test_notebook_05_has_accelerator_setup(self) -> None:
        content = read("notebooks/05_deepspeed_zero3_training.ipynb")
        assert "build_accelerator" in content

    def test_notebook_05_has_training_loop(self) -> None:
        content = read("notebooks/05_deepspeed_zero3_training.ipynb")
        assert "train_zero3" in content

    def test_notebook_05_has_checkpoint_recovery(self) -> None:
        content = read("notebooks/05_deepspeed_zero3_training.ipynb")
        assert "resume_from_checkpoint" in content

    def test_notebook_06_simulator_has_all_scenarios(self) -> None:
        content = read("notebooks/06_chaos_fault_injection.ipynb")
        for scenario in ("node_failure", "gradient_corruption", "slow_node"):
            assert scenario in content, f"Missing scenario: {scenario}"

    def test_notebook_06_has_monte_carlo(self) -> None:
        content = read("notebooks/06_chaos_fault_injection.ipynb")
        assert "monte_carlo_survival" in content

    def test_notebook_06_has_reliability_curve(self) -> None:
        content = read("notebooks/06_chaos_fault_injection.ipynb")
        assert "reliability" in content.lower() or "fleet_size" in content


# ---------------------------------------------------------------------------
# Templates
# ---------------------------------------------------------------------------

class TestTemplates:
    def test_copilot_instructions_exists(self) -> None:
        assert (ROOT / "templates" / "copilot-instructions.md").exists()

    def test_copilot_instructions_has_pytorch_version(self) -> None:
        content = read("templates/copilot-instructions.md")
        assert "PyTorch" in content
        assert "2.3" in content

    def test_copilot_instructions_has_wandb(self) -> None:
        content = read("templates/copilot-instructions.md")
        assert "wandb" in content

    def test_repo_ci_yml_exists(self) -> None:
        assert (ROOT / "templates" / "repo-ci.yml").exists()

    def test_repo_ci_yml_has_required_checks(self) -> None:
        content = read("templates/repo-ci.yml")
        for check in ("ruff", "black", "pytest"):
            assert check in content, f"Missing CI check: {check}"

    def test_youtube_demo_outline_exists(self) -> None:
        assert (ROOT / "templates" / "youtube-demo-outline.md").exists()

    def test_youtube_demo_outline_has_all_episodes(self) -> None:
        content = read("templates/youtube-demo-outline.md")
        assert "Episode 1" in content
        assert "Episode 7" in content


# ---------------------------------------------------------------------------
# Configs
# ---------------------------------------------------------------------------

class TestConfigs:
    def test_deepspeed_zero3_exists(self) -> None:
        assert (ROOT / "configs" / "deepspeed_zero3.json").exists()

    def test_deepspeed_zero3_valid_json(self) -> None:
        data = json.loads(read("configs/deepspeed_zero3.json"))
        assert data["zero_optimization"]["stage"] == 3

    def test_deepspeed_zero3_has_offload(self) -> None:
        data = json.loads(read("configs/deepspeed_zero3.json"))
        assert "offload_optimizer" in data["zero_optimization"]
        assert "offload_param" in data["zero_optimization"]


# ---------------------------------------------------------------------------
# Streamlit
# ---------------------------------------------------------------------------

class TestStreamlit:
    def test_streamlit_config_exists(self) -> None:
        assert (ROOT / ".streamlit" / "config.toml").exists()

    def test_streamlit_config_has_theme(self) -> None:
        content = read(".streamlit/config.toml")
        assert "[theme]" in content

    def test_streamlit_secrets_example_exists(self) -> None:
        assert (ROOT / ".streamlit" / "secrets.toml.example").exists()

    def test_streamlit_secrets_example_has_hf_and_wandb(self) -> None:
        content = read(".streamlit/secrets.toml.example")
        assert "huggingface" in content
        assert "wandb" in content


# ---------------------------------------------------------------------------
# Deployment
# ---------------------------------------------------------------------------

class TestDeployment:
    def test_dockerfile_exists(self) -> None:
        assert (ROOT / "Dockerfile").exists()

    def test_dockerfile_has_pytorch_base(self) -> None:
        content = read("Dockerfile")
        assert "nvcr.io/nvidia/pytorch" in content

    def test_docker_compose_exists(self) -> None:
        assert (ROOT / "docker-compose.yml").exists()

    def test_docker_compose_has_streamlit_service(self) -> None:
        content = read("docker-compose.yml")
        assert "streamlit:" in content


# ---------------------------------------------------------------------------
# VS Code workspace
# ---------------------------------------------------------------------------

class TestWorkspace:
    def test_workspace_exists(self) -> None:
        assert (ROOT / "transformer-research-hub.code-workspace").exists()

    def test_workspace_valid_json(self) -> None:
        data = json.loads(read("transformer-research-hub.code-workspace"))
        assert "folders" in data

    def test_workspace_has_all_repos(self) -> None:
        data = json.loads(read("transformer-research-hub.code-workspace"))
        paths = {f.get("path", "") for f in data["folders"]}
        for repo in (
            "ai-wiki-dataset-preprocessor",
            "ai-dist-training-scaler",
            "ai-fault-tolerance-design",
            "ai-attention-throughput-optimizer",
            "ai-transformer-efficiency-comparison",
            "ai-attention-token-viz",
        ):
            assert any(repo in p for p in paths), f"Missing repo in workspace: {repo}"


# ---------------------------------------------------------------------------
# References
# ---------------------------------------------------------------------------

class TestReferences:
    def test_references_exists(self) -> None:
        assert (ROOT / "REFERENCES.md").exists()

    def test_references_has_flashattention(self) -> None:
        content = read("REFERENCES.md")
        assert "FlashAttention" in content

    def test_references_has_zero(self) -> None:
        content = read("REFERENCES.md")
        assert "ZeRO" in content

    def test_references_has_llama(self) -> None:
        content = read("REFERENCES.md")
        assert "LLaMA" in content or "Llama" in content


# ---------------------------------------------------------------------------
# Core docs
# ---------------------------------------------------------------------------

class TestDocs:
    def test_readme_exists(self) -> None:
        assert (ROOT / "README.md").exists()

    def test_readme_has_architecture_section(self) -> None:
        content = read("README.md")
        assert "Architecture" in content

    def test_readme_has_all_sister_repos(self) -> None:
        content = read("README.md")
        for repo in (
            "ai-attention-throughput-optimizer",
            "ai-transformer-efficiency-comparison",
            "ai-wiki-dataset-preprocessor",
            "ai-dist-training-scaler",
            "ai-fault-tolerance-design",
            "ai-attention-token-viz",
        ):
            assert repo in content, f"Missing repo in README: {repo}"

    def test_roadmap_exists(self) -> None:
        assert (ROOT / "docs" / "roadmap.md").exists()

    def test_roadmap_has_phase5(self) -> None:
        content = read("docs/roadmap.md")
        assert "Phase 5" in content

    def test_architecture_doc_exists(self) -> None:
        assert (ROOT / "docs" / "architecture.md").exists()
