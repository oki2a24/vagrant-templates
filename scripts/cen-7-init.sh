#!/bin/bash
#
# Usage:
#   cen-7-init.sh
#
# Description:
#   CentOS 7 の基本的なインストール・設定を行います。
#   既存パッケージのアップデート
#   Vim インストール
#   ファイアウォールインストール
#   Chrony インストール、設定、起動
#   SELINUX を無効化"
#
###########################################################################

set -eux

yum update -y

echo "Vim インストール"
yum install -y vim-enhanced

echo "ファイアウォールインストール"
yum install -y firewalld
systemctl enable firewalld.service
systemctl start firewalld.service

echo "時刻同期。パッケージインストール、設定、起動"
yum install -y chrony
systemctl enable chronyd.service
systemctl start chronyd.service

echo "SELINUX を無効化"
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce permissive
