#!/bin/bash
#
# Usage:
#   cen-7-lemp.sh
#
# Description:
#   CentOS 7 で LEMP 環境を構築します。
#   MySQL ではなく、MariaDB をインストールします。
#   PHP はバージョン 7 をインストールします。
#   xdebug、PHPUnit をインストールします。
#
###########################################################################

set -eux

echo "PHP7 インストール"
# EPEL、Remi リポジトリ追加
yum -y install epel-release
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum --enablerepo=remi -y update remi-release
# 無効化。EPEL のみ。Remi は最初から無効
sudo sed -i -e 's/^enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
# php7 と図形、日本語、キャッシュをインストール
yum --enablerepo=epel,remi,remi-php70 -y install php php-gd php-mbstring php-mysqlnd php-opcache
# TODO PHP 設定

echo "PHP-FPM インストールと設定"
# インストール
yum --enablerepo=remi,remi-php70 -y install php-fpm
# 設定ファイル編集
cp -a /etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf.org
cat > /etc/php-fpm.d/www.conf <<EOF
[www]
user = nginx
group = nginx
listen = /var/run/php-fpm/php-fpm.sock
listen.allowed_clients = 127.0.0.1
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
slowlog = /var/log/php-fpm/www-slow.log
php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
EOF
# 起動と自動起動設定
systemctl start php-fpm.service
systemctl enable php-fpm.service

echo "Nginx インストールと設定"
# リポジトリ追加
cat > /etc/yum.repos.d/nginx.repo <<'EOF'
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=0
EOF
# Nginx インストール
yum --enablerepo=nginx -y install nginx
# バックアップ
cp -a /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org
# 設定ファイル編集
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

    # PHP-FPM 設定
    location ~ \.php$ {
        fastcgi_pass   unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF
# 起動と自動起動設定
systemctl start nginx
systemctl enable nginx

echo "MariaDB インストールと設定"
# リポジトリ追加
cat > /etc/yum.repos.d/MariaDB.repo <<EOF
# MariaDB 10.1 CentOS repository list - created 2016-02-21 01:37 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
enabled=0
EOF
# インストール
yum --enablerepo=mariadb -y install MariaDB-server MariaDB-client
# 設定ファイル編集
# 文字コードを絵文字も扱える utf8mb4 に設定
# 改行は \n、[ と ] はエスケープが必要で \[ と \] とする。
cp -a /etc/my.cnf.d/client.cnf /etc/my.cnf.d/client.cnf.org
sed -i -e 's/\[client\]/\[client\]\ndefault-character-set=utf8mb4/' /etc/my.cnf.d/client.cnf
cp -a /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.org
sed -i -e 's/\[server\]/\[server\]\ncharacter-set-server=utf8mb4/' /etc/my.cnf.d/server.cnf
# 起動設定
systemctl start mariadb.service
systemctl enable mariadb.service
# 初期設定
# you haven't set the root password yet, the password will be blank, so you should just press enter here.
# Set root password? [Y/n] Y
# New password: vagrant
# Re-enter new password: vagrant
# Remove anonymous users? [Y/n] Y
# Disallow root login remotely? [Y/n] Y
# Remove test database and access to it? [Y/n] Y
# Reload privilege tables now? [Y/n] Y
mysql_secure_installation <<EOF

Y
vagrant
vagrant
Y
Y
Y
Y
EOF
# TODO 全ログ出力設定

# phpMyAdmin
yum --enablerepo=epel,remi,remi-php70 -y install phpMyAdmin
# 設定ファイル編集# バーチャルホストで設定
cat > /etc/nginx/conf.d/phpMyAdmin.conf <<'EOF'
server {
    # ポート
    listen       8080;
    # サーバ名
    server_name  localhost;
    # ドキュメントルート設定
    root /usr/share/phpMyAdmin;
    # /で終わるURI時に返すファイルを指定
    index index.php index.html index.htm;

    # PHP-FPM 設定
    location ~ \.php$ {
        fastcgi_pass   unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF
# エイリアスで設定
# cat > /etc/nginx/conf.d/phpMyAdmin.conf <<'EOF'
# server {
#     location /phpMyAdmin {
#         alias /usr/share/phpMyAdmin;
#         index index.php;
#     }
#
#     location ~ /phpMyAdmin/.*\.php$ {
#         fastcgi_pass   unix:/var/run/php-fpm/php-fpm.sock;
#         fastcgi_index  index.php;
#         fastcgi_param  SCRIPT_FILENAME  /usr/share/$uri;
#         include        fastcgi_params;
#     }
# }
# EOF
# 2016/07/04 22:08:41 [error] 8987#8987: *5 FastCGI sent in stderr: "PHP message: # PHP Fatal error:  Uncaught Error: Call to undefined function __() in # /usr/share/phpMyAdmin/libraries/core.lib.php:245
# Stack trace:
# #0 /usr/share/phpMyAdmin/libraries/session.inc.php(100): PMA_fatalError('Error # during se...')
# #1 /usr/share/phpMyAdmin/libraries/common.inc.php(350): # require('/usr/share/phpM...')
# #2 /usr/share/phpMyAdmin/index.php(12): require_once('/usr/share/phpM...')
# #3 {main}
#   thrown in /usr/share/phpMyAdmin/libraries/core.lib.php on line 245" while reading response header from upstream, client: 192.168.56.1, server: localhost, request: "GET / HTTP/1.1", upstream: "fastcgi://unix:/var/run/php-fpm/php-fpm.sock:", host: "192.168.56.11:8080"
# 上記エラー
# 原因は、ファイル・ディレクトリの所有者が apache となっているため。
# nginx に変更する。
# 参考
# php - phpMyAdmin Fatal error: Call to undefined function __() - Stack Overflow http://stackoverflow.com/questions/27537617/phpmyadmin-fatal-error-call-to-undefined-function
# php - nginx の alias指定で phpMyAdmin に接続する時の File Not Found エラーの解消法 - スタック・オーバーフロー http://ja.stackoverflow.com/questions/2828/nginx-%E3%81%AE-alias%E6%8C%87%E5%AE%9A%E3%81%A7-phpmyadmin-%E3%81%AB%E6%8E%A5%E7%B6%9A%E3%81%99%E3%82%8B%E6%99%82%E3%81%AE-file-not-found-%E3%82%A8%E3%83%A9%E3%83%BC%E3%81%AE%E8%A7%A3%E6%B6%88%E6%B3%95
# Nginx - phpMyAdmin を使用する！ - mk-mode BLOG http://www.mk-mode.com/octopress/2013/01/21/nginx-phpmyadmin/
chown root:nginx /etc/phpMyAdmin/config.inc.php
chown -R nginx:nginx /var/lib/phpMyAdmin/*
chown -R root:nginx /var/lib/php/session/
systemctl restart nginx
