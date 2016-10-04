#!/bin/bash
#
# Usage:
#   cen-7-php7.sh
#
# Description:
#   CentOS 7 で PHP7 環境を構築します。
#   Apache で動かすことを前提にしています。
#   EPEL、Remi リポジトリの追加を行います。
#   xdebug、 PHPUnit、phpMyAdmin をインストールします。
#
###########################################################################

set -eux

echo "PHP インストールと設定"
# EPEL、Remi リポジトリ追加
yum -y install epel-release
set +e
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
set -e
yum --enablerepo=remi -y update remi-release
# 無効化。EPEL のみ。Remi は最初から無効
sudo sed -i -e 's/^enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
# php7 と図形、日本語、php-mysql、キャッシュ、PHPUnit をインストール
yum --enablerepo=epel,remi,remi-php70 -y install php php-gd php-mbstring php-mysqlnd php-opcache php-pecl-xdebug php-phpunit-PHPUnit
# php.ini 設定
cp -a /etc/php.ini /etc/php.ini.org
sed -i -e 's|;error_log = php_errors.log|error_log = "/var/log/php_errors.log"|' /etc/php.ini
touch /var/log/php_errors.log
chown apache:apache /var/log/php_errors.log
cat > /etc/logrotate.d/php <<EOF
/var/log/php_errors.log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        /sbin/service httpd reload > /dev/null 2>/dev/null || true
    endscript
}
EOF
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
chown apache:apache /var/log/xdebug.log
cat > /etc/logrotate.d/xdebug <<EOF
/var/log/xdebug.log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        /sbin/service httpd reload > /dev/null 2>/dev/null || true
    endscript
}
EOF
# Xdebug　用に php.ini 設定
# エラーをウェブブラウザに表示
sed -i -e 's|display_errors = Off|display_errors = On|' /etc/php.ini
# 設定完了したので、設定反映
systemctl restart httpd.service

echo "phpMyAdmin インストールと設定"
# インストール
yum -y --enablerepo=epel,remi,remi-php70 install phpMyAdmin
# エイリアスのみ設定し、認証系設定は削除
cp -a /etc/httpd/conf.d/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf.org
cat > /etc/httpd/conf.d/phpMyAdmin.conf <<EOF
Alias /phpMyAdmin /usr/share/phpMyAdmin
Alias /phpmyadmin /usr/share/phpMyAdmin

<Directory /usr/share/phpMyAdmin/>
  AllowOverride all
  Require all granted
</Directory>
EOF
# 設定完了したので、設定反映
systemctl restart httpd.service
