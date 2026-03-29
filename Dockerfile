# Dockerfile — Transformer Research Hub demo image
#
# Builds a self-contained image for running the Streamlit attention viz app
# and the E2E pipeline.  Based on the official NVIDIA PyTorch image for GPU
# support; falls back gracefully to CPU when no GPU is available.
#
# Build:
#   docker build -t tylrdn/transformer-research-hub:latest .
#
# Run (CPU):
#   docker run -p 8501:8501 tylrdn/transformer-research-hub:latest
#
# Run (GPU):
#   docker run --gpus all -p 8501:8501 tylrdn/transformer-research-hub:latest

# GPU base: nvcr.io/nvidia/pytorch:24.03-py3 includes CUDA 12.3 + PyTorch 2.3
FROM nvcr.io/nvidia/pytorch:24.03-py3

LABEL maintainer="TylrDn <https://github.com/TylrDn>"
LABEL description="Transformer Research Hub — Streamlit demo + E2E pipeline"

# ---------------------------------------------------------------------------
# System dependencies
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Python dependencies
# ---------------------------------------------------------------------------
WORKDIR /workspace

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir \
        streamlit>=1.33 \
        plotly>=5.20 \
        transformers>=4.40 \
        datasets>=2.19 \
        wandb>=0.17 \
        accelerate>=0.30 \
        deepspeed>=0.14

# ---------------------------------------------------------------------------
# Application code
# ---------------------------------------------------------------------------
COPY . /workspace/

# Make scripts executable
RUN chmod +x scripts/*.sh

# ---------------------------------------------------------------------------
# Streamlit configuration
# ---------------------------------------------------------------------------
EXPOSE 8501

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Default: launch the Streamlit app
# Override CMD to run the E2E pipeline: docker run ... bash scripts/run-e2e-pipeline.sh
CMD ["streamlit", "run", "notebooks/04_attention_viz_streamlit.ipynb", \
     "--server.port=8501", "--server.address=0.0.0.0"]
