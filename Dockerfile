FROM vllm/vllm-openai:latest

ENV MODEL_NAME="Qwen/Qwen2.5-Coder-14B-Instruct" \
    VLLM_PORT=9090 \
    VLLM_API_KEY="change-me" \
    VLLM_MAX_MODEL_LEN=32768 \
    VLLM_GPU_MEM_UTIL=0.90 \
    VLLM_QUANTIZATION=fp8 \
    VLLM_KV_CACHE=fp8 \
    DOWNLOAD_DIR="/models" \
    PREFETCH=0 \
    PYTHONUNBUFFERED=1

RUN mkdir -p /app /models
WORKDIR /app

# Скрипты
COPY scripts/entrypoint.sh /app/entrypoint.sh
COPY scripts/prefetch.py   /app/prefetch.py
RUN chmod +x /app/entrypoint.sh

# Утилиты + нужные питон-библиотеки
RUN apt-get update && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

# На некоторых версиях base-образа vLLM нужна явная установка
RUN python -m pip install --no-cache-dir --upgrade huggingface_hub

# Healthcheck на фиксированном порту 9090
HEALTHCHECK --interval=30s --timeout=5s --retries=20 \
  CMD curl -fsS http://127.0.0.1:9090/v1/models || exit 1

EXPOSE 9090
CMD ["/app/entrypoint.sh"]
