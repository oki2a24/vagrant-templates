#!/bin/bash
#
# Usage:
#   cen-7-docker.sh
#
# Description:
#   CentOS 7 の docker インストール・設定を行います。
#
###########################################################################

set -eux

echo "docker リポジトリ、パッケージのインストール、設定、起動"
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --disable docker-ce-stable
yum makecache fast
yum install  --enablerepo=docker-ce-stable -y docker-ce
systemctl enable docker.service
systemctl start docker.service
