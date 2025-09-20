#!/bin/bash

# プロジェクトディレクトリを作成し、仮想環境をセットアップ
if [ ! -d "$PROJECT_NAME" ]; then
	CURRENT_PATH=$(pwd)
	mkdir "${PROJECT_NAME}"
	mkdir -p "${PROJECT_NAME}/templates"
	mkdir -p "${PROJECT_NAME}/storage/tmp"
	mkdir -p "${PROJECT_NAME}/storage/tmp/upscaled_frames"
	touch "${PROJECT_NAME}/templates/index.html"
	cp '/var/www/html/main.py' "/var/www/html/${PROJECT_NAME}"
	cp '/var/www/html/start_app.sh' "/var/www/html/${PROJECT_NAME}"
	cp '/var/www/html/.envrc' "/var/www/html/${PROJECT_NAME}"

	chmod 777 "$PROJECT_NAME"
	cd "$PROJECT_NAME"
	python3 -m venv venv
	source "${PROJECT_NAME}/venv/bin/activate"

	# pipをアップグレード
	pip install --upgrade pip
	pip install fastapi "uvicorn[standard]" jinja2 python-multipart wheel

	# Real-ESRGANをクローン
	git clone https://github.com/xinntao/Real-ESRGAN.git /var/www/html/Real-ESRGAN
	cd /var/www/html/Real-ESRGAN

	# requirements.txt の numpy バージョンを置き換え
	if [ -f requirements.txt ]; then
		sed -i 's/numpy>=1.16, <=1.23.5/numpy==1.24.3/g' requirements.txt
	fi

	# パッケージのインストール
	pip install -r requirements.txt || { echo "Real-ESRGANの依存関係インストールに失敗しました"; exit 1; }

	# RIFEをクローン
	git clone https://github.com/megvii-research/ECCV2022-RIFE.git /var/www/html/RIFE
	cd /var/www/html/RIFE

	# requirements.txt の numpy バージョンを置き換え
	if [ -f requirements.txt ]; then
		sed -i 's/numpy>=1.16, <=1.23.5/numpy==1.24.3/g' requirements.txt
	fi

	# パッケージのインストール
	pip install --upgrade --force-reinstall -r requirements.txt || { echo "RIFEの依存関係インストールに失敗しました"; exit 1; }
	
	echo "プロジェクトセットアップが完了しました。"
else
	echo "既存のプロジェクトディレクトリが見つかりました。新規作成をスキップします。"
fi