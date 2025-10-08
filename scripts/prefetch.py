import os
from huggingface_hub import snapshot_download

repo = os.getenv("MODEL_NAME", "Qwen/Qwen2.5-Coder-14B-Instruct")
dst  = os.getenv("DOWNLOAD_DIR", "/models")
token = os.getenv("HF_TOKEN")

print(f"[prefetch] Downloading {repo} to {dst}")
snapshot_download(repo_id=repo, local_dir=dst, local_dir_use_symlinks=False,
                  resume_download=True, token=token)
print("[prefetch] Done")
