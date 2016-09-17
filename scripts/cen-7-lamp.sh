#!/bin/bash
#
# Usage:
#   cen-7-lamp.sh
#
# Description:
#   CentOS 7 で LAMP 環境を構築します。
#   Apache、MariaDB、PHP のインストールのためにリポジトリの追加は行いません。
#   xdebug、 PHPUnit をインストールします。
#   EPEL リポジトリを利用して、phpMyAdmin をインストールします。
#
###########################################################################

set -eux

echo "Apach インストールと設定"
yum -y install httpd-devel
# .htaccess を全許可
sed -i -e 's/AllowOverride none/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i -e 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
# 自動起動設定と起動
systemctl enable httpd.service
systemctl start httpd.service
# ファイアーウォール有効化
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

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

echo "MariaDB インストールと設定"
yum -y install mariadb-server
# 自動起動設定と起動
systemctl enable mariadb.service
systemctl start mariadb.service
# 初期設定
# Enter current password for root (enter for none): 
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
#cp -a /etc/my.cnf /etc/my.cnf.org
cp -a /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.org
sed -i -e 's|\[mysqld\]|\[mysqld\]\ngeneral-log\ngeneral-log-file=/var/log/mariadb/query.log|' /etc/my.cnf.d/server.cnf
touch /var/log/mariadb/query.log
chown -R mysql:mysql /var/log/mariadb/
# ログローテート
cp -a /etc/logrotate.d/mariadb /etc/logrotate.d/mariadb.org
cat > /etc/logrotate.d/mariadb <<'EOF'
var/log/mariadb/*.log {
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
yum -y --enablerepo=epel install phpMyAdmin
# エイリアスのみ設定し、認証系設定は削除
# Apach 2.4 系では、Directory ディレクティブのアクセス設定が必須であった。注意！
# CentOS7でphpMyAdminに403 forbiddenを出され続けた話 - サナギわさわさ.json http://kakakazuma.hatenablog.com/entry/2015/03/19/234754
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
