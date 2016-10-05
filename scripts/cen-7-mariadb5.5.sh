#!/bin/bash
#
# Usage:
#   cen-7-mariadb5.5.sh
#
# Description:
#   CentOS 7 で MariaDB 5.5 環境を構築します。
#   リポジトリの追加は行いません。
#   クライアントとサーバの文字コードは絵文字も扱える utf8mb4 に設定します。
#   root パスワードは vagrant です。
#   すべての SQL クエリを /var/log/mariadb/query.log に出力します。
#
###########################################################################

set -eux

echo "MariaDB インストールと設定"
# インストール
yum -y install mariadb-server
# 設定ファイル編集
# 文字コードを絵文字も扱える utf8mb4 に設定
# 改行は \n、[ と ] はエスケープが必要で \[ と \] とする。
cp -a /etc/my.cnf.d/client.cnf /etc/my.cnf.d/client.cnf.org
sed -i -e 's/\[client\]/\[client\]\ndefault-character-set=utf8mb4/' /etc/my.cnf.d/client.cnf
cp -a /etc/my.cnf.d/server.cnf /etc/my.cnf.d/server.cnf.org
sed -i -e 's/\[server\]/\[server\]\ncharacter-set-server=utf8mb4/' /etc/my.cnf.d/server.cnf
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
