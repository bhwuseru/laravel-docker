
# AWS　Lightsailの設定(LAMP)

検証環境 LAMP (PHP 8) 8.3.11-0で検証

- [LAMP環境にnodeをインストールする方法](#LAMP環境にnodeをインストールする方法)
- [Supervisorのインストール方法](#Supervisorのインストール方法)
- [設定コマンド一覧](#設定コマンド一覧)

## LAMP環境にnodeをインストールする方法

1. node v20をパッケージに追加

    ```
    curl -sL https://deb.nodesource.com/setup_20.x | bash -
    ```

2. パッケージからnodeをインストール
    ```
    apt install -y nodejs  
    ```

3. プロジェクト直下のディレクトリで実行
    ```
    npm install
    export NODE_OPTIONS="--max-old-space-size=1024”
    npm run build
    ```

## Supervisorのインストール方法 
1. パッケージをインストール

    ```
    sudo apt-get update
    sudo apt-get install supervisor
    ```

2. Supervisorを起動
    ```
    sudo systemctl start supervisor
    sudo systemctl enable supervisor
    ```

3. 設定ファイルの編集

    ※ 設定ファイルを編集して、管理したいコマンドを追加: `/etc/supervisor/conf.d/` ディレクトリに `setting.conf`ファイル（ファイル名は任意）を作成する。

    例えば artisan queue:work などを設定する。

    サンプル
    ```
      [program:laravel_queue_worker]
      command=/opt/bitnami/php/bin/php /path/to/artisan queue:work
      autostart=true
      autorestart=true
      stderr_logfile=/var/log/laravel_queue_worker.err.log
      stdout_logfile=/var/log/laravel_queue_worker.out.log

      [program:laravel_reverb_worker]
      command=/opt/bitnami/php/bin/php /path/to/artisan reverb:start
      autostart=true
      autorestart=true
      stderr_logfile=/var/log/laravel_reverb_worker.err.log
      stdout_logfile=/var/log/laravel_reverb_worker.out.log
    ```

4. Supervisor側の設定確認と編集 

    `/etc/supervisor/supervisord.conf`ファイルの内容を確認して`chmod=0770` に変更する。`chown=root:supervisor`の項目が存在しない場合は追加する。

        ; supervisor config file

        [unix_http_server]
        file=/var/run/supervisor.sock   ; (the path to the socket file)
        chmod=0770                      ; sockef file mode (default 0700)
        chown=root:supervisor           ;存在しない場合は追加

5. グループの追加とそのグループにサービス実行者のユーザーを追加する。
    ```
    sudo groupadd supervisor
    sudo usermod -aG supervisor  $(whoami)
    ```

6. 設定を更新をして反映させる。
    ```
    sudo supervisorctl reread 
    sudo supervisorctl update

    # 起動してるか確認
    sudo supervisorctl status

    # 出力結果　起動している場合はステータスがRUNNINGになる
    laravel_queue_worker             RUNNING   pid 37536, uptime 0:00:12
    laravel_reverb_worker            RUNNING   pid 37537, uptime 0:00:12
    ```

## 設定コマンド一覧
  ```
  # 設定ファイルを再読み込み
  sudo supervisorctl reread 
  # 設定ファイルを反映させジョブ更新
  sudo supervisorctl update
  # サービスを全て停止
  sudo supervisorctl stop all
  # 指定のサービスを停止
  sudo supervisorctl stop laravel_queue_worker
  ```