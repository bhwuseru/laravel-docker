# NVIDIAのCUDAベースイメージを使用
# FROM nvidia/cuda:12.2.0-cudnn8-runtime-ubuntu22.04
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# コンテナ内の環境変数を定義するための引数
ARG PROJECT_NAME
ARG PASSWORD
ARG USER

# 環境変数を設定する
ENV PROJECT_NAME=${PROJECT_NAME}
ENV USER=${USER}
ENV PASSWORD=${PASSWORD}

# ロケール設定
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:jp
ENV LC_ALL=ja_JP.UTF-8

# タイムゾーンを設定
ENV TZ=Asia/Tokyo

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    nvidia-utils-535 \
    locales \
    python3 python3-venv python3-pip \
    ffmpeg \
    git \
    vim \
    direnv \
    curl \
    wget && \
    echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/* && \
    git config --global core.editor vim

# 必要なPythonライブラリをインストール
# RUN pip install --no-cache-dir \
#     --upgrade numba \
#     numpy==1.24.3 \
#     numba==0.60.0 \
#     fastapi \
#     uvicorn \
#     jinja2 \
#     basicsr \
#     opencv-python-headless \
#     python-multipart

# PyTorchのインストール（CUDA 11.8対応）
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# .bashrcをコピー
COPY .bashrc /home/root/.bashrc
COPY install.sh /var/www/html/install.sh
COPY main.py /var/www/html/main.py
COPY start_app.sh /var/www/html/start_app.sh

# 作業ディレクトリを設定
WORKDIR /var/www/html

# エントリポイントを指定
CMD ["python3"]