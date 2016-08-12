#!/bin/bash
#
# Usage:
#   cen-6-init.sh
#
# Description:
#   CentOS 6 の基本的なインストール・設定を行います。
#   不要なデーモンのストップ
#   ファイアウォールを全受け入れ設定
#   既存パッケージのアップデート
#   Vim インストール
#   NTP インストール、設定、起動
#   SELINUX を無効化"
#
###########################################################################

set -eux

echo "メモリ節約。不要なデーモンをストップ"
set +e
chkconfig auditd off
chkconfig lvm2-monitor off
chkconfig mdmonitor off
chkconfig netfs off
chkconfig restorecond off
chkconfig udev-post off
set -e
echo "ファイアウォール。すべて受入"
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
service iptables save

yum update -y

echo "Vim インストール"
yum install -y vim-enhanced

echo "時刻同期。NTP サーバーインストール、設定、起動"
yum install -y ntp
chkconfig ntpd on
/etc/init.d/ntpd start

echo "SELINUX を無効化"
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
setenforce permissive
