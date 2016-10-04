#!/bin/bash
#
# Usage:
#   cen-7-phpmyadmin.sh
#
# Description:
#   CentOS 7 で phpMyAdmin 環境を構築します。
#   EPEL、Remi リポジトリの追加を行います。
#   Apache、PHP7 での稼働を前提とします。
#
###########################################################################

set -eux

echo "phpMyAdmin インストールと設定"
# EPEL、Remi リポジトリ追加
yum -y install epel-release
set +e
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
set -e
yum --enablerepo=remi -y update remi-release
# 無効化。EPEL のみ。Remi は最初から無効
sudo sed -i -e 's/^enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
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
