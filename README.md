# RunPod vLLM (Qwen Coder) — build from GitHub

Запускаем OpenAI-совместимый vLLM-сервер на RunPod **напрямую из репозитория**.
Порт по умолчанию: **9090**.

## 1) Структура репозитория
```text
.
├── Dockerfile
├── .dockerignore
├── README.md
├── scripts/
│   ├── entrypoint.sh
│   └── prefetch.py
└── .github/workflows/
    └── build-and-push-ghcr.yml   # (опционально) сборка в GHCR
```

- **Dockerfile** лежит **в корне**. Это важно: в RunPod в поле *Dockerfile Path* указываем `Dockerfile`, а *Build Context* — `.`
- Все нужные скрипты — в `scripts/`.
- VLLM слушает `0.0.0.0:9090`, healthcheck — `GET /v1/models`.

## 2) Деплой на RunPod (из репозитория)
1. **Create / Deploy → From GitHub Repository**
2. Выбери ветку: `main`
3. **Dockerfile Path**: `Dockerfile`
4. **Build Context**: `.`
5. GPU: 48 GB VRAM (или выше)
6. **Network Volume**: создать и примонтировать в `/models`
7. **HTTP Ports**: добавить `9090`
8. **ENV**:
   - `MODEL_NAME=Qwen/Qwen2.5-Coder-14B-Instruct`
   - `VLLM_API_KEY=<случайный_секрет>`
   - `PREFETCH=1` (прогреть веса на volume)
   - `DOWNLOAD_DIR=/models`
   - `VLLM_QUANTIZATION=fp8`
   - `VLLM_KV_CACHE=fp8`
   - `VLLM_MAX_MODEL_LEN=32768`
   - `HF_TOKEN=<если модель gated>`

Нажми **Deploy**. Первая сборка/загрузка весов — самая долгая; дальше быстрее (кэш слоёв + volume).

## 3) Проверка из консоли пода
```bash
curl -s http://127.0.0.1:9090/v1/models
curl -s -X POST http://127.0.0.1:9090/v1/chat/completions       -H "Authorization: Bearer $VLLM_API_KEY" -H "Content-Type: application/json"       -d '{"model":"Qwen/Qwen2.5-Coder-14B-Instruct","messages":[{"role":"user","content":"Напиши функцию sum(a,b) на TS"}],"temperature":0.2}'
```

## 4) Подключение Cline (пример конфига)
См. `cline.config.example.json`:
```json
{
  "provider": "openai",
  "baseUrl": "http://<RUNPOD_HOST>:9090/v1",
  "apiKey": "<VLLM_API_KEY>",
  "model": "Qwen/Qwen2.5-Coder-14B-Instruct",
  "temperature": 0.2,
  "maxTokens": 2048
}
```

## 5) Частые вопросы
**Где лежит Dockerfile?** — В корне репозитория.  
**Какой путь Build Context?** — `.` (корень репо).  
**Где хранятся веса?** — В примонтированном volume по пути `/models`.  
**Где включить прогрев весов?** — `PREFETCH=1` (использует `scripts/prefetch.py`).  
**Как сменить модель?** — Меняешь `MODEL_NAME` в ENV и перезапускаешь.  
**Почему 9090?** — 8080 часто занят — 9090 свободнее.  
**Нужен ли GHCR?** — Для прод/масштабирования — да (см. workflow в `.github/workflows`).

---

### Локальный тест (опционально, если установлен Docker + NVIDIA)
```bash
docker build -t vllm-qwen:dev .
docker run --gpus all -p 9090:9090       -e MODEL_NAME="Qwen/Qwen2.5-Coder-14B-Instruct"       -e VLLM_API_KEY="test"       -e PREFETCH=0       vllm-qwen:dev
```
