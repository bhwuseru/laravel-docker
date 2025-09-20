#!/bin/bash

# プロジェクトディレクトリが存在しないnextjsを新規インストール
if [ ! -d "$PROJECT_NAME" ]; then
	npx create-next-app@latest "$PROJECT_NAME"
fi