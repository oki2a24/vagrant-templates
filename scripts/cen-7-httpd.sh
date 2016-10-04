#!/bin/bash
#
# Usage:
#   cen-7-httpd.sh
#
# Description:
#   CentOS 7 で Apache 環境を構築します。
#   リポジトリの追加は行いません。
#   ファイアーウォールがインストールされていることを前提とします。
#
###########################################################################

set -eux

echo "Apach インストールと設定"
# インストール
yum -y install httpd-devel
# 設定編集
cp -a /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.org
# .htaccess を全許可
sed -i -e 's/AllowOverride none/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i -e 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
# 自動起動設定と起動
systemctl enable httpd.service
systemctl start httpd.service
# ファイアーウォール有効化
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload
