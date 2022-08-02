#!/bin/bash

#### 初回gitレポジトリプッシュ時の処理をする ####
source .envrc

echo "# ${PROJECT_NAME} " >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin "https://${USER_NAME}:${TOKEN}@github.com/${USER_NAME}/${PROJECT_NAME}.git"
git push -u origin main