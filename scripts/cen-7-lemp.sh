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
systemctl start nginx.service
systemctl enable nginx.service
# ファイアーウォール設定
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

echo "PHP7 インストール"
# EPEL、Remi リポジトリ追加
yum -y install epel-release
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum --enablerepo=remi -y update remi-release
# 無効化。EPEL のみ。Remi は最初から無効
sudo sed -i -e 's/^enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
# php7 と図形、日本語、キャッシュ、PHPUnit をインストール
yum --enablerepo=epel,remi,remi-php70 -y install php php-gd php-mbstring php-mysqlnd php-opcache php-pecl-xdebug php-phpunit-PHPUnit
# php.ini 設定
cp -a /etc/php.ini /etc/php.ini.org
sed -i -e 's|;mbstring.language = Japanese|mbstring.language = Japanese|' /etc/php.ini
sed -i -e 's|;mbstring.detect_order = auto|mbstring.detect_order = auto|' /etc/php.ini
sed -i -e 's|;date.timezone =|date.timezone = "Asia/Tokyo"|' /etc/php.ini
# Xdebug 設定
# Xdebug を使用可能に。リモートデバッグを許可。var_dump 内容をすべて表示
cp -a /etc/php.d/15-xdebug.ini /etc/php.d/15-xdebug.ini.org
cat >> /etc/php.d/15-xdebug.ini <<EOF

xdebug.remote_enable = 1
xdebug.remote_host = 10.0.2.2
xdebug.remote_log = "/var/log/xdebug.log"
xdebug.var_display_max_children = -1
xdebug.var_display_max_data = -1
xdebug.var_display_max_depth = -1
EOF
# Xdebug ログ出力準備
touch /var/log/xdebug.log
chown nginx:nginx /var/log/xdebug.log
cat > /etc/logrotate.d/xdebug <<EOF
/var/log/xdebug.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 nginx adm
    sharedscripts
    postrotate
            [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}
EOF
# Xdebug　用に php.ini 設定
# エラーをウェブブラウザに表示
sed -i -e 's|display_errors = Off|display_errors = On|' /etc/php.ini
# 設定完了したので、設定反映
systemctl restart nginx.service

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
catch_workers_output = yes
EOF
# 起動と自動起動設定
systemctl start php-fpm.service
systemctl enable php-fpm.service

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
# 全クエリログ出力
cp -a /etc/my.cnf /etc/my.cnf.org
cat >> /etc/my.cnf <<EOF
[mysqld]
general-log
general-log-file=/var/log/mariadb/query.log
log-output=file
EOF
mkdir -p /var/log/mariadb/
touch /var/log/mariadb/query.log
chown -R mysql:mysql /var/log/mariadb/
# ログローテート
cat > /etc/logrotate.d/mariadb <<'EOF'
/var/log/mariadb/*.log {
    create 640 mysql mysql
    notifempty
    daily
    rotate 3
    missingok
    compress
    postrotate
    # just if mysqld is really running
    if test -x /usr/bin/mysqladmin && \
        /usr/bin/mysqladmin ping &>/dev/null
    then
        /usr/bin/mysqladmin flush-logs
    fi
    endscript
}
EOF
# 設定完了、再起動
systemctl restart mariadb.service

echo "phpMyAdmin インストールと設定"
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
# Nginx 対応設定
chown root:nginx /etc/phpMyAdmin/config.inc.php
chown -R nginx:nginx /var/lib/phpMyAdmin/*
chown -R root:nginx /var/lib/php/session/
systemctl restart nginx.service
# ファイアーウォール設定
firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --reload
