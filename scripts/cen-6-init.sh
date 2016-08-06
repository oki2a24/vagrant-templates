#!/bin/bash

set -e
set -x

yum update -y

# Vim
yum install -y vim-enhanced

# 時刻同期
# NTP サーバーインストール、設定、起動
yum install -y ntp
chkconfig ntpd on
/etc/init.d/ntpd start
# selinuxを無効
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
setenforce permissive
# メモリ節約。不要なデーモンをストップ
chkconfig auditd off
chkconfig lvm2-monitor off
chkconfig mdmonitor off
chkconfig netfs off
chkconfig restorecond off
# ファイアウォール
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
service iptables save
