# NVIDIAのCUDAベースイメージを使用
# FROM nvidia/cuda:12.2.0-cudnn8-runtime-ubuntu22.04

# NVIDIA CUDA 11.8 (安定版, Ubuntu 22.04 ベース)
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# ビルド時引数
ARG PROJECT_NAME
ARG PASSWORD
ARG USER

# 環境変数
ENV PROJECT_NAME=${PROJECT_NAME}
ENV USER=${USER}
ENV PASSWORD=${PASSWORD}
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:jp
ENV LC_ALL=ja_JP.UTF-8
ENV TZ=Asia/Tokyo

# bash をデフォルトシェルにする
SHELL ["/bin/bash", "-c"]

# パッケージのインストール
RUN apt-get update && apt-get install -y \
    locales \
    python3 python3-venv python3-pip \
    ffmpeg git vim direnv curl wget sudo \
    && echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen ja_JP.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# git のエディタを vi に
RUN git config --global core.editor "vi"

# ユーザー作成（一般権限）
RUN useradd -m -s /bin/bash ${USER} --uid 1000 && \
    gpasswd -a ${USER} sudo && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER}

# ユーザー切替
USER ${USER}
WORKDIR /var/www/html

RUN pip install --upgrade pip

# requirements.txt をコピー
COPY requirements.txt /var/www/html/requirements.txt
# RUN source venv/bin/activate && pip install -r requirements.txt

# .bashrc をコピー
COPY .bashrc /home/${USER}/.bashrc

# FastAPI 起動スクリプトなどをコピー
COPY install.sh /var/www/html/install.sh
COPY main.py /var/www/html/main.py
COPY start_app.sh /var/www/html/start_app.sh
