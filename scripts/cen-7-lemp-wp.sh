#!/bin/bash
#
# Usage:
#   wordpress.sh ipadress
#     ipadress - IP アドレス
#
# Description:
#   Nginx、MySQL を設定し、WordPress をセットアップします。
#
###########################################################################

# 引数の取り方、コメントの書き方は次のページを参考にした。
# 引数を処理する | UNIX & Linux コマンド・シェルスクリプト リファレンス http://shellscript.sunone.me/parameter.html
# シェルスクリプト Tips | UNIX & Linux コマンド・シェルスクリプト リファレンス http://shellscript.sunone.me/tips.html

set -eux

# DB、ユーザ、パスワードの作成・設定
mysql -u root -pvagrant <<EOF
GRANT ALL PRIVILEGES ON wpdb.* TO wpdbuser@localhost IDENTIFIED BY 'wpdbpass';
FLUSH PRIVILEGES;
CREATE DATABASE wpdb CHARACTER SET utf8;
EOF

# Nginx 設定ファイル編集
cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
    # ポート
    listen       80;
    # サーバ名
    server_name  localhost;
    # ドキュメントルート設定
    root /var/www/html;
    # /で終わるURI時に返すファイルを指定
    index index.php index.html index.htm;
    # 実ファイルがない場合のアクセスファイル
    try_files $uri $uri/ /index.php;

    location / {
        # WordPress パーマリンク設定を利用可能にする
        if (!-e $request_filename) {
            rewrite ^.+?(/wp-.*) $1 last;
            rewrite ^.+?(/.*\.php)$ $1 last;
            # ドキュメントルートから WordPress までの相対パス
            # (ドキュメントルートにインストールしたため相対パスは記入なし)
            rewrite ^ /index.php last;
        }
    }

    # PHP-FPM 設定
    location ~ \.php$ {
        fastcgi_pass   unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF
# 設定読み込み
systemctl restart nginx
systemctl restart php-fpm

# WordPress インストール
# wp-cli インストール
cd ~
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
# wp コマンドで使用可能にする(実行権限付与とパスを通す)
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
# 今後は php wp-cli.phar と実行しなくとも wp で実行可能だが、
# sudo による別ユーザでの実行では使用できなかったため、フルパスで実行する。
# WordPress ダウンロード
cd /var/www/html/
chown -R vagrant:vagrant /var/www/html/
sudo -u vagrant -i -- /usr/local/bin/wp core download --locale=ja --path=/var/www/html
# wp-config.php のセットアップ
sudo -u vagrant -i -- /usr/local/bin/wp core config --dbname=wpdb --dbuser=wpdbuser --dbpass=wpdbpass --locale=ja --path=/var/www/html --extra-php <<PHP
define('WP_POST_REVISIONS', 3);
PHP
# WordPress 初期設定
# URL はシェルスクリプト引数の IP アドレス
sudo -u vagrant -i -- /usr/local/bin/wp core install --url=http://$1/ --title=test --admin_user=wploginuser --admin_password=wploginpass  --admin_email=test@example.com --path=/var/www/html
# 所有者、所有グループを設定し、プラグインをインストールできるようにする。
chown -R nginx:nginx /var/www/html/
# WordPress 設定したもの確認
sudo -u vagrant -i -- /usr/local/bin/wp user list --path=/var/www/html
sudo -u vagrant -i -- /usr/local/bin/wp option get siteurl --path=/var/www/html
sudo -u vagrant -i -- /usr/local/bin/wp option get blogname --path=/var/www/html
