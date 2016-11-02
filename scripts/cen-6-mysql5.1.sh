#!/bin/bash
#
# Usage:
#   cen-6-lamp.sh
#
# Description:
#   CentOS 6 で MySQL 5.1 環境を構築します。
#   リポジトリの追加は行いません。
#   root パスワードは vagrant です。
#   すべての SQL クエリを /var/log/mariadb/query.log に出力します。
#
###########################################################################

set -eux

echo "MySQL インストールと設定"
yum -y install mysql-server
# 自動起動設定と起動
chkconfig mysqld on
service mysqld start
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
sed -i -e 's|\[mysqld\]|\[mysqld\]\ngeneral_log=1\ngeneral_log_file=/var/log/mysql/query.log|' /etc/my.cnf
mkdir -p /var/log/mysql/
touch /var/log/mysql/query.log
chown -R mysql:mysql /var/log/mysql/
# ログローテート
cat > /etc/logrotate.d/mysql <<EOF
/var/log/mysql/*.log {
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
service mysqld restart
