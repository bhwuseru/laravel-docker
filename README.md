# 環境構築資料（Ansible対応版）

- [環境構築資料（Ansible対応版）](#環境構築資料ansible対応版)
  - [置くところ](#置くところ)
    - [構造](#構造)
  - [dockerでSSLをつかう(windowsの方法)](#dockerでsslをつかうwindowsの方法)
  - [Ansible + Docker開発環境構築手順](#ansible--docker開発環境構築手順)
    - [必要条件とツールの導入](#必要条件とツールの導入)
    - [構築手順](#構築手順)
    - [Ansible構成ファイル](#ansible構成ファイル)
  - [コンテナ初回起動後の作業](#コンテナ初回起動後の作業)
  - [開発環境URLアクセス法](#開発環境urlアクセス法)
  - [Makeコマンド](#makeコマンド)
  - [Dockerコマンド](#dockerコマンド)

# Ansible + Docker開発環境構築手順

## 必要条件とツールの導入

以下が導入されていることを確認してください。

- Docker
- Docker Compose（旧式またはプラグイン）
- mkcert
- Ansible
- GNU Make

Ubuntu での Ansible 導入：

```sh
sudo apt update && sudo apt install -y ansible
```

## 構築手順

1. `ansible/vars/secrets.example.yml` を `ansible/vars/secrets.yml` にリネームし、プロジェクト設定を記述：

```yml
project_name: sample
db_name: sample_db
db_user: user
db_password: password
nodejs_version: 20.x
laravel_version: 11.*
proxy_template_name: default.conf.templateForSSL
...
```

2. Make コマンドで開発環境を初期化：

```sh
make container-init
```

このコマンドにより以下が自動実行されます：

- `.devcontainer` → `.{{ project_name }}` にリネーム
- `.env` ファイルの生成（テンプレートから）
- `init.sql` の生成（テンプレートから）
- `proxy/ssl` ディレクトリの作成と pem ファイルの発行（mkcert）
- Docker Compose によるビルド＆起動

## Ansible構成ファイル

- `ansible/environment-setup.yml`: 開発環境をセットアップする
- `ansible/docker-build-up.yml`: コンテナビルド＆起動
- `ansible/docker-container-reset.yml`: コンテナ停止＆削除
- `vars/secrets.yml`: 環境変数の定義（project\_name など）
- `templates/env.j2`, `templates/init.sql.j2`: .env や SQL のテンプレート

# コンテナ初回起動後の作業

初回起動後、Laravel プロジェクトが未作成であれば、install.sh スクリプトを実行すると自動的に `/var/www/html/${PROJECT_NAME}` にLaravelプロジェクトが作成されます。

MySQL コンテナ起動時には以下の SQL が実行され、開発用とテスト用の2つのDBが作成されます：

```sql
-- 本番用データベースの作成
CREATE DATABASE IF NOT EXISTS `{{ project_name }}_db` ...

-- テスト用データベースの作成
CREATE DATABASE IF NOT EXISTS `{{ project_name }}_db_test` ...
```

# 開発環境URLアクセス法

- Laravel アプリ: `http://127.0.0.1:PROXY_PUBLIC_PORT/`
- PhpMyAdmin: `http://127.0.0.1:PHP_MYADMIN_PUBLIC_PORT/`


# Makeコマンド

```sh
make container-init       # 初期セットアップ（環境 + ビルド＆起動）
make docker-setup-env     # 環境のみセットアップ（env, SQL, sslなど）
make container-build-up   # コンテナビルド＆起動
make container-remove     # コンテナ停止＆データ削除＆初期化状態へ
```

# Dockerコマンド

```sh
# コンテナ停止
cd .devcontainer && docker compose down

# ボリューム・イメージも含め削除
cd .devcontainer && docker compose down --rmi all --volumes --remove-orphans

# 未使用（dangling）イメージ削除
docker rmi $(docker images -f "dangling=true" -q)

# キャッシュ削除
docker builder prune
```
