"""Tests for hub-level scripts and configuration files."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent


# ---------------------------------------------------------------------------
# Script tests
# ---------------------------------------------------------------------------


class TestCloneAllScript:
    """Tests for scripts/clone-all.sh."""

    def test_script_exists(self) -> None:
        script = REPO_ROOT / "scripts" / "clone-all.sh"
        assert script.exists(), "clone-all.sh must exist"

    def test_script_is_executable(self) -> None:
        script = REPO_ROOT / "scripts" / "clone-all.sh"
        assert script.stat().st_mode & 0o111, "clone-all.sh must be executable"

    def test_script_is_valid_bash(self) -> None:
        script = REPO_ROOT / "scripts" / "clone-all.sh"
        result = subprocess.run(
            ["bash", "-n", str(script)],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, f"clone-all.sh syntax error:\n{result.stderr}"

    def test_script_contains_all_repos(self) -> None:
        script = REPO_ROOT / "scripts" / "clone-all.sh"
        content = script.read_text(encoding="utf-8")
        expected_repos = [
            "ai-attention-throughput-optimizer",
            "ai-transformer-efficiency-comparison",
            "ai-wiki-dataset-preprocessor",
            "ai-dist-training-scaler",
            "ai-fault-tolerance-design",
            "ai-attention-token-viz",
        ]
        for repo in expected_repos:
            assert repo in content, f"clone-all.sh is missing repo: {repo}"


class TestE2EPipelineScript:
    """Tests for scripts/run-e2e-pipeline.sh."""

    def test_script_exists(self) -> None:
        script = REPO_ROOT / "scripts" / "run-e2e-pipeline.sh"
        assert script.exists(), "run-e2e-pipeline.sh must exist"

    def test_script_is_executable(self) -> None:
        script = REPO_ROOT / "scripts" / "run-e2e-pipeline.sh"
        assert script.stat().st_mode & 0o111, "run-e2e-pipeline.sh must be executable"

    def test_script_is_valid_bash(self) -> None:
        script = REPO_ROOT / "scripts" / "run-e2e-pipeline.sh"
        result = subprocess.run(
            ["bash", "-n", str(script)],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, f"run-e2e-pipeline.sh syntax error:\n{result.stderr}"

    def test_help_flag_exits_zero(self) -> None:
        script = REPO_ROOT / "scripts" / "run-e2e-pipeline.sh"
        result = subprocess.run(
            ["bash", str(script), "--help"],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, "--help flag must exit 0"
        assert "Usage" in result.stdout, "--help must print usage"


# ---------------------------------------------------------------------------
# Configuration tests
# ---------------------------------------------------------------------------


class TestDeepSpeedConfig:
    """Tests for configs/deepspeed_zero3.json."""

    def test_config_exists(self) -> None:
        cfg = REPO_ROOT / "configs" / "deepspeed_zero3.json"
        assert cfg.exists(), "configs/deepspeed_zero3.json must exist"

    def test_config_is_valid_json(self) -> None:
        cfg = REPO_ROOT / "configs" / "deepspeed_zero3.json"
        data = json.loads(cfg.read_text(encoding="utf-8"))
        assert isinstance(data, dict), "deepspeed_zero3.json must be a JSON object"

    def test_config_has_zero_stage_3(self) -> None:
        cfg = REPO_ROOT / "configs" / "deepspeed_zero3.json"
        data = json.loads(cfg.read_text(encoding="utf-8"))
        assert data.get("zero_optimization", {}).get("stage") == 3, (
            "deepspeed_zero3.json must specify ZeRO stage 3"
        )

    def test_config_has_bf16_or_fp16(self) -> None:
        cfg = REPO_ROOT / "configs" / "deepspeed_zero3.json"
        data = json.loads(cfg.read_text(encoding="utf-8"))
        assert "bf16" in data or "fp16" in data, (
            "deepspeed_zero3.json must specify bf16 or fp16 precision"
        )


# ---------------------------------------------------------------------------
# VS Code workspace tests
# ---------------------------------------------------------------------------


class TestVSCodeWorkspace:
    """Tests for transformer-research-hub.code-workspace."""

    def test_workspace_exists(self) -> None:
        ws = REPO_ROOT / "transformer-research-hub.code-workspace"
        assert ws.exists(), "transformer-research-hub.code-workspace must exist"

    def test_workspace_is_valid_json(self) -> None:
        ws = REPO_ROOT / "transformer-research-hub.code-workspace"
        data = json.loads(ws.read_text(encoding="utf-8"))
        assert isinstance(data, dict), "workspace file must be a JSON object"

    def test_workspace_has_all_repos(self) -> None:
        ws = REPO_ROOT / "transformer-research-hub.code-workspace"
        data = json.loads(ws.read_text(encoding="utf-8"))
        folders = data.get("folders", [])
        folder_names = {f.get("name", "") for f in folders}
        folder_paths = {f.get("path", "") for f in folders}
        expected_repos = [
            "ai-wiki-dataset-preprocessor",
            "ai-attention-throughput-optimizer",
            "ai-transformer-efficiency-comparison",
            "ai-attention-token-viz",
            "ai-dist-training-scaler",
            "ai-fault-tolerance-design",
        ]
        combined = " ".join(folder_names) + " ".join(folder_paths)
        for repo in expected_repos:
            assert repo in combined, f"Workspace must include folder for {repo}"


# ---------------------------------------------------------------------------
# Notebook tests
# ---------------------------------------------------------------------------


class TestNotebooks:
    """Tests for notebooks/ directory."""

    def test_all_six_notebooks_exist(self) -> None:
        notebooks_dir = REPO_ROOT / "notebooks"
        expected = [
            "01_wiki_preprocessing.ipynb",
            "02_flashattn3_benchmark.ipynb",
            "03_gpt2_rwkv_pareto.ipynb",
            "04_attention_viz_streamlit.ipynb",
            "05_deepspeed_zero3_training.ipynb",
            "06_chaos_fault_injection.ipynb",
        ]
        for nb in expected:
            path = notebooks_dir / nb
            assert path.exists(), f"Notebook {nb} must exist in notebooks/"

    def test_notebooks_are_valid_json(self) -> None:
        for nb_path in sorted((REPO_ROOT / "notebooks").glob("*.ipynb")):
            data = json.loads(nb_path.read_text(encoding="utf-8"))
            assert "cells" in data, f"{nb_path.name} must have a 'cells' key"
            assert data.get("nbformat") == 4, f"{nb_path.name} must be nbformat 4"

    def test_notebooks_cite_arxiv(self) -> None:
        """Each notebook must contain at least one arXiv citation (arxiv.org/abs/ URL)."""
        arxiv_pattern = "arxiv.org/abs/"
        for nb_path in sorted((REPO_ROOT / "notebooks").glob("*.ipynb")):
            content = nb_path.read_text(encoding="utf-8")
            assert arxiv_pattern in content, (
                f"{nb_path.name} must contain at least one arXiv citation (arxiv.org/abs/...)"
            )

    def test_notebooks_mention_wandb(self) -> None:
        """Each notebook must reference wandb for experiment tracking."""
        for nb_path in sorted((REPO_ROOT / "notebooks").glob("*.ipynb")):
            content = nb_path.read_text(encoding="utf-8")
            assert "wandb" in content.lower(), (
                f"{nb_path.name} must reference W&B for experiment tracking"
            )


# ---------------------------------------------------------------------------
# Template tests
# ---------------------------------------------------------------------------


class TestTemplates:
    """Tests for templates/ directory."""

    def test_copilot_instructions_template_exists(self) -> None:
        tmpl = REPO_ROOT / "templates" / "copilot-instructions.md"
        assert tmpl.exists()

    def test_repo_ci_template_exists(self) -> None:
        tmpl = REPO_ROOT / "templates" / "repo-ci.yml"
        assert tmpl.exists()

    def test_youtube_demo_outline_exists(self) -> None:
        tmpl = REPO_ROOT / "templates" / "youtube-demo-outline.md"
        assert tmpl.exists()

    def test_copilot_instructions_mentions_key_requirements(self) -> None:
        tmpl = REPO_ROOT / "templates" / "copilot-instructions.md"
        content = tmpl.read_text(encoding="utf-8")
        requirements = [
            "PyTorch",
            "WatsonX",
            "wandb",
            "arXiv",
            "GPU",
            "pytest",
        ]
        for req in requirements:
            assert req in content, (
                f"copilot-instructions.md template must mention '{req}'"
            )

    def test_repo_ci_template_has_ruff_and_pytest(self) -> None:
        tmpl = REPO_ROOT / "templates" / "repo-ci.yml"
        content = tmpl.read_text(encoding="utf-8")
        assert "ruff" in content, "CI template must include ruff"
        assert "pytest" in content, "CI template must include pytest"
        assert "black" in content, "CI template must include black"


# ---------------------------------------------------------------------------
# REFERENCES.md tests
# ---------------------------------------------------------------------------


class TestReferences:
    """Tests for REFERENCES.md."""

    def test_references_md_exists(self) -> None:
        refs = REPO_ROOT / "REFERENCES.md"
        assert refs.exists(), "REFERENCES.md must exist at the repo root"

    def test_references_contains_key_papers(self) -> None:
        refs = REPO_ROOT / "REFERENCES.md"
        content = refs.read_text(encoding="utf-8")
        key_papers = [
            "FlashAttention",
            "ZeRO",
            "RWKV",
            "wandb",
        ]
        for paper in key_papers:
            assert paper in content, f"REFERENCES.md must mention '{paper}'"

    def test_references_contains_arxiv_links(self) -> None:
        refs = REPO_ROOT / "REFERENCES.md"
        content = refs.read_text(encoding="utf-8")
        assert "arxiv.org/abs/" in content, "REFERENCES.md must contain arXiv abstract links"
