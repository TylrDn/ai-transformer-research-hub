# Review: ai-wiki-dataset-preprocessor

**Repository:** [TylrDn/ai-wiki-dataset-preprocessor](https://github.com/TylrDn/ai-wiki-dataset-preprocessor)  
**Layer:** Data  
**Purpose:** Process raw Wikipedia XML dumps into clean, model-ready JSONL or plain-text format.

## Current State

- Handles tokenization, filtering, deduplication, and sharding of Wikipedia dumps
- Outputs `*.jsonl` shards, vocabulary files, and dataset statistics
- Entry point for the entire hub data pipeline — feeds `ai-dist-training-scaler`

## Strengths

- Self-contained pipeline with clear input/output contract
- Sharded JSONL output is compatible with HuggingFace Datasets and Apache Arrow
- Deduplication prevents training on duplicate passages

## Gaps & Issues

- No fixed evaluation split produced for cross-project benchmarking (needed by Phase 2)
- Pipeline is single-threaded in places; large dumps take significant wall-clock time
- No versioning / provenance metadata attached to output shards
- Missing Docker image for reproducible preprocessing environments

## Dependencies

| Upstream | Downstream |
|----------|-----------|
| Wikipedia XML dump (`.xml.bz2`) | `ai-dist-training-scaler` (JSONL shards) |
| — | Shared benchmark dataset (planned) |
