#!/bin/bash
#
# Usage:
#   cen-6-php5.3.sh
#
# Description:
#   CentOS 6 で PHP5.3 環境を構築します。
#   Apache での使用を前提とします。
#   リポジトリの追加は行いません。
#   xdebug をインストールします。
#
###########################################################################

set -eux

echo "PHP インストールと設定"
yum -y install php php-devel php-mysql
# php.ini 設定
sed -i -e 's|;default_charset = "iso-8859-1"|default_charset = "UTF-8"|' /etc/php.ini
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
sed -i -e 's|;mbstring.internal_encoding = EUC-JP|mbstring.internal_encoding = UTF-8|' /etc/php.ini
sed -i -e 's|;mbstring.http_input = auto|mbstring.http_input = auto|' /etc/php.ini
sed -i -e 's|;mbstring.detect_order = auto|mbstring.detect_order = auto|' /etc/php.ini
sed -i -e 's|;date.timezone =|date.timezone = "Asia/Tokyo"|' /etc/php.ini

echo "Xdebug インストールと設定"
yum -y install php-pear
# CentOS 6 標準の PHP 5.3 の場合、サポートしている Xdebug のバージョンは 2.2.7 まで
# https://xdebug.org
# > [2015-02-22] - Xdebug 2.3.0 is out!
# > This release drops support for PHP 5.2 and PHP 5.3, and raises the default max nesting level to 256. It also fixes a bunch of issues as found in Xdebug 2.2.7.
pecl install xdebug-2.2.7
# Xdebug 設定
# Xdebug を使用可能に。リモートデバッグを許可。var_dump 内容をすべて表示
cat > /etc/php.d/xdebug.ini <<EOF
zend_extension=/usr/lib64/php/modules/xdebug.so
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
# var_dump を装飾
sed -i -e 's|html_errors = Off|html_errors = On|' /etc/php.ini
# 設定完了したので、設定反映
service httpd restart
