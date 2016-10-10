#!/bin/bash
#
# Usage:
#   cen-7-postgresql.sh
#
# Description:
#   CentOS 7 で PostgreSQL 環境を構築します。
#   リポジトリの追加は行いません。
#   root パスワードは vagrant です。
#
###########################################################################

set -eux

echo "PostgreSQL インストールと設定"
# インストール
yum -y install postgresql-devel postgresql-server
# 初期設定
postgresql-setup initdb
systemctl enable postgresql.service
systemctl start postgresql.service
# 設定ファイル編集
# パスワード認証へ変更
cp -a /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.org
sed -i -i 's|local   all             all                                     peer|local   all             all                                     md5|' /var/lib/pgsql/data/pg_hba.conf
sed -i -i 's|host    all             all             127.0.0.1/32            ident|host    all             all             127.0.0.1/32            md5|' /var/lib/pgsql/data/pg_hba.conf
sed -i -i 's|host    all             all             ::1/128                 ident|host    all             all             ::1/128                 md5|' /var/lib/pgsql/data/pg_hba.conf
# スーパーユーザに (postgres) にパスワード設定
su - postgres <<EOT
psql -U postgres
ALTER USER postgres encrypted password 'vagrant';
\q
exit
EOT
# 再起動して設定反映
systemctl restart postgresql.service
