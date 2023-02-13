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
    - [プロジェクトの作成とLaravel環境設定](#プロジェクトの作成とlaravel環境設定)
  - [Vite設定](#vite設定)
  - [テスト開発環境設定とDB設定](#テスト開発環境設定とdb設定)
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
    
    **コンテナを複数立ち上げる場合はブラウザからアクセスするポート番号を重複しないように変更する。**
    
    ```
    #### .devcontainer/.envファイル ###
    
    PROJECT_NAME=sample #プロジェクト名
    NODEJS_VERSION= # nodejsのバージョン
    LARAVEL_VERSION= # laravelのバージョン
    APP_NAME= # アプリ名: この名前がdockerコンテナのプレフィックス名になる 
    DB_DATABASE= # db名
    DB_USER=user # dbユーザー名
    USER=user # ユーザー名
    DB_PASSWORD=password # dbパスワード
    PROXY_PUBLIC_PORT= # webサーバー: ブラウザからアクセスするポート番号
    PHP_MYADMIN_PUBLIC_PORT= # PhpMyAdmin: ブラウザからアクセスするポート番号
    MEMORY_LIMIT=128M # sqlファイルのPhpMyAdminファイルのアップロードサイズ
    UPLOAD_LIMIT=64M #　sqlファイルPhpMyAdminアップロードサイズ
    ```
    
    編集が完了したら`.devcontainer/db/init/init.sql`を新規作成します。
    
    - `init.sql`ファイル内に下記内容を追記します。
    `CREATE DATABASE IF NOT EXISTS .envファイル追記したデータベース名 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;`
    
    `~~.devcontainer/proxy/server.conf`ファイルの以下項目を変更します.`$APP_NAME`は.`.env`ファイル記載の`APP_NAME=アプリケーションを指定root   /var/www/html/`$APP_NAME`/public;`~~**補足**`default.conf.template`のrootパスとlaravelプロジェクトを作成するコンテナのパスが一致することを確認してください。
    $PROJECT_NAMEは.devcontainer/.env記載の環境変数
    
    ```
    # default.conf.templateのルートパス定義
    root   /var/www/html/${PROJECT_NAME}/public;
    # phpコンテナ内のlaravelプロジェクトのパス
    /var/www/html/${PROJECT_NAME}/public;
    
    ```
    
3. `/.devcontainer`ディレクトリに移動し`docker-compose up -d --build`を実行。
- 上記手順で`ERROR: for proxy Cannot start service proxy: Mounts denied:`が出力された場合
- DockerアプリのPreferences > Resources > File sharing設定にプロジェクトディレクトリのパスを追加。
- Apply & Restartボタンで再起動。

### コンテナ内での作業

[Dockerプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)

- 導入済みの場合
エディタ画面左側にDocdkrのアイコンが表示されます。
アイコンをクリックし最上段にある`CONTAINERS`をクリックします。
コンテナリストが表示されサフィックスに`-php`が表示されている箇所をクリックします。
Attach Shellと表示されている箇所をクリックします。
VSCodeにコンテナのターミナル画面が表示されます。

~~以下のコマンドでphpコンテナに入ります。`${APP_NAME}`は.`.env`ファイル記載の`APP_NAME=アプリケーションを指定docker exec -it ${APP_NAME}-php bash`~~

### プロジェクトの作成とLaravel環境設定

1. “$APP_NAME名”(.devcontainer/.envファイルに記載)-php コンテナに入る。
2. 新規プロジェクトの場合は/var/www/htmlディレクトリで以下コマンドを実行

```bash
# /var/www/htmlディレクトリに下記スクリプトファイルが存在するので以下コマンドを実行
. ./create_laravel_project.sh
```

- 警告: バージョンが不一致警告が出力された場合
    - `php --version`でバージョンを確認し`composer config platform.php バージョン番号`でバージョンを合わせる。
    - `composer install`を実行する。
    - `php artisan key:generate`を実行する。
1. 作成したプロジェクトに移動し`.env`ファイル内を`.devcontainer/.env`に基づいて下記値に変更する。
    
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
    
2. `http://127.0.0.1:{.devcontainer/.env記載のPHP_MYADMIN_PUBLIC_PORT}`でPhpMyAdminにアクセスできるか確認します。
3. Gitからクローンした場合(プロジェクト新規作成の場合は不要)
プロジェクトディレクトリ内で`composer install`を実行。
4. 下記コマンドを実行しマイグレーション・データを作成
`php artisan migrate --seed`

## Vite設定
- `welcome.blade.php`に以下を追加
```
<!DOCTYPE html>
<html ...>
    <head>
        {{-- ... --}}
        # 下記を追加する 
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
```

- vite.config.jsまたはvite.config.tsをを以下を参考に編集する。
```
## vite.config.jsの設定
import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";

export default defineConfig({
    plugins: [
        laravel({
            // パス設定
            input: ["resources/css/app.css", "resources/js/app.js"],
            refresh: true,
        }),
    ],
    server: {
        host: true, // trueにすると host 0.0.0.0
        // ホットリロードHMRとlocalhost: マッピング
        hmr: { 
            host: "localhost", 
        },
        // ポーリングモードで動作 wsl2の場合これを有効しないとホットリロード反映しない
        watch: {
            usePolling: true,
        },
    },
});
```
- hostオプションを付与して下記コマンドを実行
  - `npm run dev -- --host`

## テスト開発環境設定とDB設定
***.env_testingを作成***
 `cp .env .env_testing`
  .env_testingファイル下記内容を変更
 `cp .env .env_testing`ファイルを作成
 .env_testingの下記を変更または追加
    ```php
    APP_ENV=test
    # dbは追加
    DB_TESTING_CONNECTION=mysql_testing
    DB_TESTING_HOST=ahr_db_testing
    DB_TESTING_PORT=3306
    DB_TESTING_DATABASE=test_ahr_db
    DB_TESTING_USERNAME=user
    DB_TESTING_PASSWORD=password
    ```

***database.phpを編集***
    
    ```php
    // mysqlの配列をコピーして貼り付け下記部分を変更
    'mysql_testing' => [　　　　名前変更
       'database' => 'test_db名',             変更点
    ],
    ```
    
****phpunitファイルの編集****
    
    phpunitを実行する際に使用するデータベースを設定。
    
    ```xml
    <php>
    <server name="APP_ENV" value="testing"/>
    <server name="BCRYPT_ROUNDS" value="4"/>
    <server name="CACHE_DRIVER" value="array"/>
    <server name="MAIL_MAILER" value="array"/>
    <server name="QUEUE_CONNECTION" value="sync"/>
    <server name="SESSION_DRIVER" value="array"/>
    <server name="TELESCOPE_ENABLED" value="false"/>
    <server name="DB_CONNECTION" value="mysql_testing"/>      変更点
    <server name="DB_DATABASE" value="test_db名"/>       変更点
    <server name="DB_HOST" value="127.0.0.1"/>
    </php>
    ```
    
***テスト用データベースを正しく使用できるか確認***
`php artisan migrate --env=testing`

    aravelにはデフォルトでuserのfactoryが用意されていて、seederも実行できる状態。

    テスト用dbにseederを実行して値が反映されているか確認。

****テストファイルの編集****

データベースと繋がっているのか確認。

```php
<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

use App\User;
use App\Item;

class ExampleTest extends TestCase
{
	use RefreshDatabase;
	
	public function setUp(): void
	{
		dd(env('APP_ENV'), env('DB_DATABASE'), env('DB_CONNECTION'));
	}
}
```

下記のコマンドを実行します。

```php
php artisan config:clear　　キャッシュ消してから

vendor/bin/phpunit

ファイル指定で実行したい場合は下記のコマンドで出来ます。

vendor/bin/phpunit tests/Feature/ExampleTest.php
```

## 開発環境URLアクセス法

1. コンテナが起動していない場合はコマンド `cd .devcontainer`で移動し`docker-compose up -d`を実行。
2. コンテナ立ち上げ後に下記URLでアクセス。
- ドメイン
    - URL: [http://127.0.0.1](http://127.0.0.1/):PROXY_PUBLIC_PORT/
- PhpMyAdmin
    - URL: [http://127.0.0.1](http://127.0.0.1/):.PHP_MYADMIN_PUBLIC_PORT/
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
