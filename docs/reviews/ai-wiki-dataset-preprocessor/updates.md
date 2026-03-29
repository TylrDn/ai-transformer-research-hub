# Planned Updates: ai-wiki-dataset-preprocessor

## Priority: High

### Fixed Evaluation Split
- Produce a deterministic 10 K-sample held-out split alongside each full dataset build
- Version the split with a hash so downstream repos can verify they are using the same data
- Coordinate with `ai-attention-throughput-optimizer` and `ai-transformer-efficiency-comparison` to adopt this split as the shared benchmark dataset

### Provenance Metadata
- Write a `metadata.json` alongside each shard directory: dump date, Wikipedia language, filter settings, shard count, and SHA-256 of source dump
- Enables reproducibility audits and dataset versioning

## Priority: Medium

### Parallel Processing
- Replace single-threaded text extraction with a multiprocessing pool (or Ray) for large dumps
- Target 4–8× speedup on a 16-core machine for the full English Wikipedia (~20 GB compressed)

### Apache Arrow / Parquet Output
- Add an optional `--output-format parquet` flag for direct compatibility with HuggingFace Datasets `load_dataset`
- Keeps JSONL as the default for human readability

## Priority: Low

### Docker Image
- Publish a versioned Docker image with WikiExtractor and all preprocessing dependencies
- Include a `docker-compose` profile in the hub's Phase 2 multi-project environment

### HuggingFace Datasets Hub
- Push processed shards to a private HF Dataset repo for easy reuse across all hub projects
