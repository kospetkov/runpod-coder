#!/usr/bin/env bash
set -euo pipefail

PORT="${VLLM_PORT:-9090}"
MODEL="${MODEL_NAME:-Qwen/Qwen2.5-Coder-14B-Instruct}"
API_KEY="${VLLM_API_KEY:-change-me}"
DL_DIR="${DOWNLOAD_DIR:-/models}"

echo "[entrypoint] MODEL_NAME=${MODEL}"
echo "[entrypoint] PORT=${PORT}"
echo "[entrypoint] DOWNLOAD_DIR=${DL_DIR}"
echo "[entrypoint] QUANT=${VLLM_QUANTIZATION:-fp8} KV=${VLLM_KV_CACHE:-fp8}"

if [[ "${PREFETCH:-0}" == "1" ]]; then
  echo "[entrypoint] Prefetching model weights to ${DL_DIR} ..."
  python /app/prefetch.py || true
fi

python -m vllm.entrypoints.openai.api_server       --model "${MODEL}"       --host 0.0.0.0       --port "${PORT}"       --download-dir "${DL_DIR}"       --max-model-len "${VLLM_MAX_MODEL_LEN:-32768}"       --kv-cache-dtype "${VLLM_KV_CACHE:-fp8}"       --quantization "${VLLM_QUANTIZATION:-fp8}"       --gpu-memory-utilization "${VLLM_GPU_MEM_UTIL:-0.90}"       --trust-remote-code       --api-key "${API_KEY}"
