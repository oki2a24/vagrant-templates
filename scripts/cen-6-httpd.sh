#!/bin/bash
#
# Usage:
#   cen-6-httpd.sh
#
# Description:
#   CentOS 6 で Apache 環境を構築します。
#   リポジトリの追加は行いません。
#   ファイアーウォールがインストールされていることを前提とします。
#
###########################################################################

set -eux

echo "Apach インストールと設定"
yum -y install httpd-devel
# .htaccess を全許可
sed -i -e 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
# 自動起動設定と起動
chkconfig httpd on
service httpd start
