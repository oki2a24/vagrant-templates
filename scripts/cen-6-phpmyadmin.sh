#!/bin/bash
#
# Usage:
#   cen-6-lamp.sh
#
# Description:
#   CentOS 6 で phpMyAdmin 環境を構築します。
#   Apache での使用を前提とします。
#   EPEL リポジトリを利用してインストールします。
#
###########################################################################

set -eux

echo "phpMyAdmin インストールと設定"
yum -y --enablerepo=epel install phpMyAdmin
# エイリアスのみ設定し、認証系設定は削除
cat > /etc/httpd/conf.d/phpMyAdmin.conf <<EOF
Alias /phpMyAdmin /usr/share/phpMyAdmin
Alias /phpmyadmin /usr/share/phpMyAdmin
EOF
# 設定完了したので、設定反映
service httpd restart
