#!/bin/bash
#
# Usage:
#   cen-7-phpmyadmin.sh
#
# Description:
#   CentOS 7 で phpMyAdmin をインストールします。
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

<Directory /usr/share/phpMyAdmin/>
  AllowOverride all
  Require all granted
</Directory>
EOF
# 設定完了したので、設定反映
systemctl restart httpd.service
