from fastapi import FastAPI, File, UploadFile
from fastapi.responses import HTMLResponse
import subprocess
import os
import re

app = FastAPI()

# ファイル名をサニタイズする関数
def sanitize_filename(filename: str) -> str:
    return re.sub(r'[^\w\-_\.]', '_', filename)

# フレームに分解する関数
def extract_frames(video_path: str, output_dir: str):
    os.makedirs(output_dir, exist_ok=True)
    command = [
        "ffmpeg", "-i", video_path, "-vf", "fps=24", f"{output_dir}/frame_%04d.png"
    ]
    subprocess.run(command, check=True)

# フレームをアップスケールする関数
def upscale_frames(input_dir: str, output_dir: str):
    os.makedirs(output_dir, exist_ok=True)
    command = [
        "python3", "/var/www/html/Real-ESRGAN/inference_realesrgan.py",
        "-i", input_dir, "-o", output_dir, "-n", "RealESRGAN_x4plus"
    ]
    subprocess.run(command, check=True)

# フレームを再結合して動画に戻す関数
def combine_frames_to_video(input_dir: str, output_path: str, fps: int = 24):
    command = [
        "ffmpeg", "-framerate", str(fps), "-i", f"{input_dir}/frame_%04d.png",
        "-c:v", "libx264", "-pix_fmt", "yuv420p", output_path
    ]
    subprocess.run(command, check=True)

@app.get("/")
async def read_root():
    html_content = """
    <html>
    <body>
        <h1>AI Upscaling Web UI</h1>
        <form action="/process" enctype="multipart/form-data" method="post">
            <input name="file" type="file">
            <button type="submit">Upload and Process</button>
        </form>
    </body>
    </html>
    """
    return HTMLResponse(content=html_content)

@app.post("/process")
async def process_video(file: UploadFile = File(...)):
    storage_path = "./storage/tmp"
    frames_dir = os.path.join(storage_path, "frames")
    upscaled_frames_dir = os.path.join(storage_path, "upscaled_frames")
    # ファイル名をサニタイズ
    safe_filename = sanitize_filename(file.filename)
    input_path = os.path.join(storage_path, safe_filename)
    output_video_path = os.path.join(storage_path, f"output_{safe_filename}")

    os.makedirs(storage_path, exist_ok=True)

    try:
        # ファイルを保存
        with open(input_path, "wb") as f:
            f.write(await file.read())

        # 動画をフレームに分解
        extract_frames(input_path, frames_dir)

        # フレームをアップスケール
        upscale_frames(frames_dir, upscaled_frames_dir)

        # フレームを再結合して動画に戻す
        combine_frames_to_video(upscaled_frames_dir, output_video_path)

        return {"status": "success", "output": output_video_path}

    except subprocess.CalledProcessError as e:
        return {"status": "error", "message": f"Command '{e.cmd}' failed with return code {e.returncode}"}
    except Exception as e:
        return {"status": "error", "message": str(e)}