#!/bin/bash
#
# Usage:
#   cen-7-php5.4.sh
#
# Description:
#   CentOS 7 で PHP5.4 環境を構築します。
#   Apache での使用を前提とします。
#   リポジトリの追加は行いません。
#   xdebug、 PHPUnit をインストールします。
#
###########################################################################

set -eux

echo "PHP インストールと設定"
yum -y install php php-devel php-mysql
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

echo "Xdebug インストールと設定"
yum -y --enablerepo=epel install php-pecl-xdebug
# Xdebug 設定
# リモートデバッグを許可。var_dump 内容をすべて表示
cat >> /etc/php.d/xdebug.ini <<EOF

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

echo "PHPUnit インストール"
yum -y --enablerepo=epel install php-phpunit-PHPUnit
