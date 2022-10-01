# 環境構築資料

- [環境構築資料](#環境構築資料)
  - [Laravelのライブラリ導入とコマンド一覧](#laravelのライブラリ導入とコマンド一覧)
  - [circleciの設定](#circleciの設定)
    - [ファイル全体構成](#ファイル全体構成)
  - [AWS環境構築手順](#aws環境構築手順)
    - [AWSリソース構成](#awsリソース構成)
    - [CloudFormationを利用したEC2環境構築手順](#cloudformationを利用したec2環境構築手順)
  - [Docker開発環境構築手順](#docker開発環境構築手順)
    - [Dockerファイル全体構成](#dockerファイル全体構成)
    - [必要条件とツールの導入](#必要条件とツールの導入)
    - [Dockerインフラ構築](#dockerインフラ構築)
    - [コンテナ内での作業](#コンテナ内での作業)
      - [プロジェクトの作成](#プロジェクトの作成)
  - [開発環境URLアクセス法](#開発環境urlアクセス法)
  - [Dockerコマンド](#dockerコマンド)

## Laravelのライブラリ導入とコマンド一覧
`laravel/README.md`にライブラリ導入手順や`artisan`コマンドの一覧が記述されています。
## circleciの設定
PHP8・NodeJS、MySQLのcicrlecici公式提供のDocker最新イメージを利用すると自動テストが止まらない現象や他不具合が
発生するため、後ほど調査予定。

### ファイル全体構成 
- .circleci/
  - circleciで利用する。リソースが格納。

## AWS環境構築手順

### AWSリソース構成
- aws/CloudFormation/
  - CloudFormationで利用する。スタックのリソースが格納。

### CloudFormationを利用したEC2環境構築手順
`aws/CloudFormation/README.md`の手順に従い実施してください。

## Docker開発環境構築手順

### Dockerファイル全体構成

- .devcontainer/
  - 開発環境で利用する`docker-compse`のリソースが格納。
- .devcontainer/db/
  - `docker-compse build`で利用するMySQLの設定が格納。
- .devcontainer/php/
  - `docker-compose build`で利用するphpの設定が格納。
- .devcontainer/proxy/
  - `docker-compose build`で利用するnginxの設定が格納。
- Makefile
  - 開発環境を構築する際に利用するコマンドが記載されています。
### 必要条件とツールの導入
[Docker の公式サイト](https://www.docker.com/)から手順に従って導入し`docker-compose`コマンドを利用できるようにします。
[docker-composeの詳細](https://docs.docker.com/compose/compose-file/)はリファレンスを参考にしてください。
[docerk-composeコマンド](https://matsuand.github.io/docs.docker.jp.onthefly/engine/reference/commandline/compose/)はリファレンスを参考にしてください。
[Dockerプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)を導入してください。
### Dockerインフラ構築
- **複数コンテナを稼働させる場合**
  1. ルートディレクトリ下の`.devcontainer`ディレクトリ名を任意の名前変更。
  上記のディレクトリ名がcomposeのコンテナ名になるので複数立ち上げる場合は重複させないようにディレクトリ名を変更する。
- **起動しなくなった場合**
  1. `.devcontainer/`下で `docker-compose down --rmi all --volumes`を実行。 
  2. `.devcontainer/db/data`ディレクトリ(存在する場合は)削除
  3. Docker本体を再起動。
  4. `.devcontainer/`下で`docker-compose up -d --build`を実行。

- **コンテナ立ち上げ後に`.devcotainer/.env`を編集した場合**
  1. 画面左の[Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)パネルをクリック。
  2. 対象のコンテナをクリックしCompose Downを実行。
  3. `docker-compose up -d --build`を実行。


1. `.devcontainer`ディレクトリ下で`.env`ファイルを作成し`env.example`の内容をコピーします。
2. 作成した`.env`ファイルを作成するアプリケーションに応じて編集します。
    - **複数環境を立ち上げる場合は.envファイル内のポートを変更。**
    - DB_PORT、PHP_MYADMIN_PORT、PROXY_PORTは重複しないように変更する。
    ```
    PROJECT_NAME=プロジェクト名
    APP_NAME=アプリケーション名
    DB_DATABASE=データベース名
    DB_USER=データベースユーザー名
    DB_PASSWORD=パスワード
    USER=バックエンドのユーザー名
    PROXY_PORT=Webサーバーのポート番号
    PHP_MYADMIN_PORT=PhpMyAdminのポート番号
    DB_PORT=データベースのポート番号
    BACKEND_PORT=バックエンドのポート番号
    FRONTEND_PORT=フロントエンドのポート番号
    ```
    編集が完了したら`.devcontainer/db/init/init.sql`を新規作成します。
    - `init.sql`ファイル内に下記内容を追記します。
    `CREATE DATABASE IF NOT EXISTS .envファイル追記したデータベース名 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;`

     ~~`.devcontainer/proxy/server.conf`ファイルの以下項目を変更します.~~
      ~~`$APP_NAME`は.`.env`ファイル記載の`APP_NAME=アプリケーションを指定`~~
      ~~```root   /var/www/html/`$APP_NAME`/public;```~~
      **補足**
      `default.conf.template`のrootパスとlaravelプロジェクトを作成するコンテナのパスが一致することを確認してください。
      $PROJECT_NAMEは.devcontainer/.env記載の環境変数
      ```
      # default.conf.templateのルートパス定義
      root   /var/www/html/${PROJECT_NAME}/public;
      # phpコンテナ内のlaravelプロジェクトのパス
      /var/www/html/${PROJECT_NAME}/public;
      ```

3. `/.devcontainer`ディレクトリに移動し`docker-compose up -d --build`を実行。
  - 上記手順で`ERROR: for proxy  Cannot start service proxy: Mounts denied:`が出力された場合
  - DockerアプリのPreferences > Resources > File sharing設定にプロジェクトディレクトリのパスを追加。
  - Apply & Restartボタンで再起動。
### コンテナ内での作業

[Dockerプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- 導入済みの場合
エディタ画面左側にDocdkrのアイコンが表示されます。
アイコンをクリックし最上段にある`CONTAINERS`をクリックします。
コンテナリストが表示されサフィックスに`*-php`が表示されている箇所をクリックします。
Attach Shellと表示されている箇所をクリックします。
VSCodeにコンテナのターミナル画面が表示されます。

~~以下のコマンドでphpコンテナに入ります。~~
~~`${APP_NAME}`は.`.env`ファイル記載の`APP_NAME=アプリケーションを指定`~~
~~`docker exec -it ${APP_NAME}-php bash`~~

#### プロジェクトの作成
1. 下記コマンドを実行し新規プロジェクトを作成する。
 `$PROJECT_NAME`は`.devcontainer/.env`に記載してあるアプリケーション名を指定
  `composer create-project laravel/laravel $PROJECT_NAME "8.*" --prefer-dist`
  - 警告: バージョンが不一致警告が出力された場合
    - `php --version`でバージョンを確認し`composer config platform.php バージョン番号`でバージョンを合わせる。
    - `composer install`を実行する。
    - `php artisan key:generate`を実行する。
2. 作成したプロジェクトに移動し`.env`ファイル内を`.devcontainer/.env`に基づいて下記値に変更する。
    ```
    APP_NAME=`.devcontainer/.env`に記載されているアプリ名
    ...
    DB_CONNECTION=mysql
    DB_HOST=db
    DB_PORT=3306
    DB_DATABASE=`.devcontainer/.env`に記載されている接続先データベース
    DB_USERNAME=`.devcotainer/.env`に記載されているDBユーザー
    DB_PASSWORD=`.devcotainer/.env`に記載されているパスワード
    ```
3. `http://127.0.0.1:{.devcontainer/.env記載のPhpMyAdminのポート}`でPhpMyAdminにアクセスできるか確認します。
4. Gitからクローンした場合(プロジェクト新規作成の場合は不要)
    プロジェクトディレクトリ内で```composer install```を実行。
5.  下記コマンドを実行しマイグレーション・データを作成
    ```php artisan migrate --seed```
## 開発環境URLアクセス法
  1. コンテナが起動していない場合はコマンド `cd .devcontainer`で移動し`docker-compose  up -d`を実行。
  2. コンテナ立ち上げ後に下記URLでアクセス。
  - ドメイン
      - URL: http://127.0.0.1:Webサーバーのポート番号/
  - PhpMyAdmin
      - URL: http://127.0.0.1:PhpMyAdminのポート番号/
  - URLアクセス時画面に`No application encryption key has been specified.`が出力された場合
    1. `php artisan key:generate`を実行。
    2. サーバーを再起動。
    3. 起動後に`cd プロジェクト名`を実行。
    4. `php artisan config:clear`を実行。

## Dockerコマンド
 コンテナ削除などのコマンド
- docker-compseのダウン
    - `cd .devcontainer`でディレクトリに移動し`docker-compose down`
- docker-compseのコンテナ、イメージ、ボリューム、ネットワークの一括削除。
    - docker-compse.ymlが配置されているディレクトリで`docker-compose down --rmi all --volumes --remove-orphans`
- Dockerで作成したコンテナを全削除
    - `docker rm $(docker ps -a -q)`
- Dockerのイメージを全削除
