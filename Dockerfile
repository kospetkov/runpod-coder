FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
WORKDIR /app

# Базовые утилиты и Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip git curl && \
    rm -rf /var/lib/apt/lists/*

# Устанавливаем последние версии vLLM и transformers
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir \
    "vllm>=0.4.3" \
    "transformers>=4.44.0" \
    "huggingface_hub" \
    "torch>=2.3.0" \
    "accelerate" \
    "sentencepiece"

# Копируем скрипты
COPY scripts/entrypoint.sh /app/entrypoint.sh
COPY scripts/prefetch.py   /app/prefetch.py
RUN chmod +x /app/entrypoint.sh

# Переменные окружения
ENV MODEL_NAME="Qwen/Qwen2.5-Coder-14B-Instruct" \
    VLLM_PORT=9090 \
    VLLM_API_KEY="ll-koss" \
    VLLM_MAX_MODEL_LEN=32768 \
    VLLM_GPU_MEM_UTIL=0.90 \
    VLLM_QUANTIZATION=auto \
    VLLM_KV_CACHE=fp8 \
    DOWNLOAD_DIR="/models" \
    PREFETCH=1

EXPOSE 9090

CMD ["/app/entrypoint.sh"]
