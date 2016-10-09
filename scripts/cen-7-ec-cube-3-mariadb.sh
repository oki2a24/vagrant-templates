#!/bin/bash
#
# Usage:
#   cen-7-ec-cube-3-mariadb.sh
#
# Description:
#   CentOS 7 で MariaDB を用いた EC-CUBE 3 環境を構築します。
#   Apache、MariaDB、PHP はインストール済みであることを前提とします。
#
###########################################################################

set -eux

echo "PHP ライブラリインストール"
yum -y --enablerepo=epel install php-mcrypt php-pecl-apcu php-pecl-zendopcache
# 反映
systemctl restart httpd.service

echo "DB の準備"
# root ユーザのパスワード変更
# 初期設定
# Enter current password for root (enter for none): 
# Change the root password? [Y/n] Y
# New password: vagrant
# Re-enter new password: vagrant
# Remove anonymous users? [Y/n] Y
# Disallow root login remotely? [Y/n] Y
# Remove test database and access to it? [Y/n] Y
# Reload privilege tables now? [Y/n] Y
mysql_secure_installation <<EOF
vagrant
Y
password
password
Y
Y
Y
Y
EOF
# DB、ユーザ、権限を作成
mysql -u root -ppassword <<EOT
GRANT ALL PRIVILEGES ON cube3_dev.* TO cube3_dev_user@localhost IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
CREATE DATABASE cube3_dev DEFAULT CHARACTER SET utf8;
EOT
