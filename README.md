# 環境構築資料

- [環境構築資料](#環境構築資料)
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
    - [メール設定](#メール設定)
      - [Stripeの設定](#stripeの設定)
      - [Mailtrapの設定](#mailtrapの設定)
    - [各ライブラリの導入手順](#各ライブラリの導入手順)
      - [Laravel Sanctum](#laravel-sanctum)
      - [Laraval Breeze](#laraval-breeze)
      - [AdminLTE3](#adminlte3)
      - [Jetstream](#jetstream)
      - [`npm install`時のエラー対処](#npm-install時のエラー対処)
        - [Jetstreamの設定](#jetstreamの設定)
  - [VScodeの設定](#vscodeの設定)
    - [Xdebug設定](#xdebug設定)
  - [開発環境URLのアクセス法](#開発環境urlのアクセス法)
  - [その他TIPS](#その他tips)
    - [artisan コマンド](#artisan-コマンド)
  - [ダミーデータの作成方法](#ダミーデータの作成方法)
  - [フォーム画面注意点](#フォーム画面注意点)
  - [チートシート](#チートシート)
  - [コンテナ削除などのコマンド](#コンテナ削除などのコマンド)

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
[Dockerプラグイン](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)を導入してください。
### Dockerインフラ構築
1. `.devcontainer`ディレクトリ下で`.env`ファイルを作成し`env.example`の内容をコピーします。
**複数コンテナを稼働させる場合**
ルートディレクトリ下の`.devcontainer`ディレクトリ名を任意の名前(コンテナ名を重複させないため)に変更する。

1. 作成した`.env`ファイルを作成するアプリケーションに応じて編集します。
    ```
    APP_NAME=アプリケーション名
    DB_DATABASE=データベース名
    DB_USER=データベースユーザー名
    DB_PASSWORD=パスワード
    USER=バックエンドのユーザー名
    PROXY_PORT=Webサーバーのポート番号
    BACKEND_PORT=バックエンドのポート番号
    FRONTEND_PORT=フロントエンドのポート番号
    PHP_MYADMIN_PORT=PhpMyAdminのポート番号
    ```
    編集が完了したら`.devcontainer/db/init/init.sql`を新規作成します。
    - `init.sql`ファイル内に下記内容を追記します。
    `CREATE DATABASE IF NOT EXISTS .envファイル追記したデータベース名 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;`

    - `.devcontainer/proxy/server.conf`ファイルの以下項目を変更します.
      `$APP_NAME`は.`.env`ファイル記載の`APP_NAME=アプリケーションを指定`
      ```
      root   /var/www/html/`$APP_NAME`/public;
      ```

2. `/.devcontainer`ディレクトリに移動し`docker-compose build`を実行。
3. ビルドが完了したらコマンド`docker-compose up -d`を実行しコンテナを立ち上げる。
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

以下のコマンドでphpコンテナに入ります。
`${APP_NAME}`は.`.env`ファイル記載の`APP_NAME=アプリケーションを指定`
`docker exec -it ${APP_NAME}-php bash`

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
3. `http://127.0.0.1:8086`でPhpMyAdminにアクセスできるか確認します。
4. Gitからクローンした場合(プロジェクト新規作成の場合は不要)
    プロジェクトディレクトリ内で```composer install```を実行。
5.  下記コマンドを実行しマイグレーション・データを作成
    ```php artisan migrate --seed```
### メール設定
#### Stripeの設定
1. [Strip](https://stripe.com/jp)にアクセスしアカウント作成、またはログインする。
2. [APIキー](https://dashboard.stripe.com/test/apikeys)にアクセスし公開キーとシークレットキーをコピーする。<br>
3. Laravel環境変数`.env`ファイルに上記の公開・シークレットキーを下記項目に追記する。
    ```
    STRIPE_PUBLIC_KEY="コピーした公開キー"
    STRIPE_SERCRET_KEY="コピーしたシークレットキー"
    ```
#### Mailtrapの設定
1. [Mailtrap](https://mailtrap.io/)アクセスしユーザー情報を作成、またはログインする。
2. メニュー画面の Testing -> Inboxes -> Project内 MyInboxをクリックする。
3. My Inbox内のSMTP settingsを選択しIntegrations下部の選択ボックスのLaravel *+を選択。
下記6項目が表示されるので`.env`ファイル内項目を変更。
    ```
    MAIL_MAILER=smtp
    MAIL_HOST=
    MAIL_PORT=
    MAIL_USERNAME=
    MAIL_PASSWORD=
    MAIL_ENCRYPTION=
    ```
4. `php artisan config:clear`を実行しキャッシュをクリアする。
5. Dockerを再起動する。

### 各ライブラリの導入手順
下記を参考に実施する。

#### Laravel Sanctum
1. 以下のコマンドを実行する。
  ```
    composer require laravel/sanctum
    php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
    php artisan migrate:fresh
  ```

2. `Kernel.php`ファイルの以下の記載部分を変更する。
   ```
    'api' => [
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        \Illuminate\Session\Middleware\StartSession::class,
        // 'throttle:api',
        // \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],
   ```
3. `config/sanctum.php`ファイルの以下を自身の環境に合わせ変更する。
    ```
      'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
          '%s%s',
          'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
          env('APP_URL') ? ','.parse_url(env('APP_URL'), PHP_URL_HOST) : ''
      ))),
    ```

以下参考URL
- [Sanctum](https://laravel.com/docs/9.x/sanctum)
- [認証](https://laravel.com/docs/9.x/authentication)

- **ログイン時にステータスコード500が送出される場合は以下の記事を参考にする**。
  [ログイン認証エラー ステータスコード(500)の対処](https://laracasts.com/discuss/channels/laravel/sanctum-throws-session-store-not-set-on-request)

#### Laraval Breeze
- [参考1](https://reffect.co.jp/laravel/laravel8-breeze#Laravel_Breeze)
1. `composer require laravel/breeze --dev`
2. `php artisan breeze:install`
3. `npm install && npm run dev`

#### AdminLTE3
- [参考](https://chigusa-web.com/blog/laravel-crud/)
1. ```composer require jeroennoten/laravel-adminlte```
2. ```php artisan adminlte:install```

#### Jetstream
```
composer require laravel/jetstream
composer require laravel/sanctum
php artisan jetstream:install livewire
npm install && npm run dev
# viewsリソースを作成
php artisan vendor:publish --tag=jetstream-views
```

#### `npm install`時のエラー対処
1. `webpack-cli] Error: Unknown option '--hide-modules'`が発生した場合
`package.json`ファイル内で`--hide-modules`を検索し該当するオプションを削除する。

2. ```run `npm audit fix` to fix them, or `npm audit` for details```が発生した場合
  `npm audit`を実行。セキュリティエラーメッセージの警告に従い解決する。

3. 一旦キャッシュをクリーンにして下記コマンドを実行する
  ```
    npm cache clean --force
    rm -rf ~/.npm
    rm -rf node_modules
    install && nmp run dev
  ```

##### Jetstreamの設定
- プロフィール画像の表示方法
1. `config/jetstream.php`ファイルの`Features::profilePhotos()`変数のコメントアウトを外す。
2. ```
    # ストレージリンクを貼る
    php artisan storage:link
    ```
5. `.env`ファイルの項目を`APP_URL=http://localhost:8085`に変更する。
7. ```php artisan config:clear```でキャッシュをクリア。
8. `php artisan migrate:fresh`でDBに反映させる。


## VScodeの設定
### Xdebug設定
`.vscode/launch.json`の設定を下記項目に変更する。

    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9013,
            "pathMappings": {
                "/var/www/html": "${workspaceRoot}/php"
            }
        },
## 開発環境URLのアクセス法

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

## その他TIPS
### artisan コマンド
- キャッシュをクリア 
  ```
  php artisan cache:clear
  php artisan config:clear
  php artisan route:clear
  php artisan view:clear
  ```
- ストレージリンク
  ```
  php artisan storage:link
  ```
- リクエスト一覧
  ```
  php artisan route:list
  ```
- シーダー作成
  [参照](https://readouble.com/laravel/8.x/ja/seeding.html)
  1. 下記コマンド実行
      ```
      php artisan make:seeder ProductSeeder
      ```
  2. `database/seeders/ProductSeeder.php`に追記
      ```
      use Illuminate\Support\Facades\DB;
      use Illuminate\Support\Facades\Hash;
      ...

      public function run() {
          DB::table('products')->insert([
            'name' => 'test',
            'price' => 1000,
            'password' => Hash::make('p@ssw0rd'),
            'created_ad => '2020/12/12 12:12:12',
          ]);
      }
      ```
  3. `database/seeders/DatabaseSeeder.php`に追記
      ```
        public function run()
        {
            // \App\Models\User::factory(10)->create();
            $this->call([
                ProductSeeder::class
            ]);
        }
      ```
  4. `php artisan migrate:fresh --seed`を実行

- ダミーデータ作成
  ```
  php artisan make:factory ProductFactory --model=Product
  ```
- コントローラー作成
  [参照](https://readouble.com/laravel/8.x/ja/controllers.html)
  [同時作成参照(ver8.7.0以降)](https://zenn.dev/nshiro/articles/204ce98cf088b9)
  ```
  php artisan make:controller ProductsController -r

  # フォームリクエスト等も同時に作成する場合(ver 8.7.0以降)
  php artisan make:controller ProductController -R --model=Product

  Model created successfully.
  Request created successfully.
  Request created successfully.
  Controller created successfully.
  ```
- ルーティング作成
  `web.php`に追記
  ```
  use App\Http\Controllers\ProductsController;
  ...

  // ルーティング一覧(showを使用しない場合の例)
  Route::resource('product', ProductsController::class, ['except' => ['show']]);
  ```
- テーブル作成
  ```
  php artisan make:migration create_products_table
  php artisan migrate:fresh
  ```
- モデル作成
  [同時作成の参照(ver 8.7.0以降)](https://zenn.dev/nshiro/articles/204ce98cf088b9)
  ```
  php artisan make:model Product
  # フォームリクエスト等も同時に作成する場合
  php artisan make:model Product -rR

  Model created successfully.
  Request created successfully.
  Request created successfully.
  Controller created successfully.
  ```

- フォームリクエスト作成
  ```
  php artisan make:request ProductStoreRequest
  ```

## ダミーデータの作成方法
1. `composer.json`内に"fakerphp/faker": "^1.9.1"が存在するか確認する。
2. `config/app.php`内の`faker_locale => 'ja_JP'`に変更する。
3. `php artisan config:clear`を実行。
4. `php artisan make:factory モデルFactory --model=モデル名`で`モデルFactory.php`が生成される。
5. 上記で生成されたファイルを[URL](https://qiita.com/tosite0345/items/1d47961947a6770053af)を参考に修正する。


## フォーム画面注意点
  画面を作成する際は`@csrf, @method('DELETE')`を追記する

  ```
  <form method="POST" action="{{ route('owner.products.update', ['product' => $product->id]) }}">
    @csrf
    @method('PUT')
  ```

## チートシート
- [ダミーデータ](https://qiita.com/tosite0345/items/1d47961947a6770053af)
## コンテナ削除などのコマンド
- docker-compseのダウン
    - `cd .devcontainer`でディレクトリに移動し`docker-compose down`
- docker-compseのコンテナ、イメージ、ボリューム、ネットワークの一括削除。
    - docker-compse.ymlが配置されているディレクトリで`docker-compose down --rmi all --volumes --remove-orphans`
- Dockerで作成したコンテナを全削除
    - `docker rm $(docker ps -a -q)`
- Dockerのイメージを全削除
    - `docker rmi $(docker images -q)`
