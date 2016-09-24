#!/bin/bash
#
# Usage:
#   cen-6-mongo-express.sh ipadress
#     ipadress - IP アドレス
#
# Description:
#   MongoDB をインストールします。
#   Mongo Express をインストールします。
#   http://ipadress:8081 からアクセスします。
#   Basic 認証は、admin:pass です。
#
###########################################################################

set -eux

echo "MongoDB インストールと設定"
# Install MongoDB Community Edition on Red Hat Enterprise or CentOS Linux — MongoDB Manual 3.2 https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/
# リポジトリ導入
cat > /etc/yum.repos.d/mongodb-org-3.2.repo <<"EOF"
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=0
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
EOF
# インストール
yum install -y --enablerepo=mongodb-org-3.2 mongodb-org
# 外部からの接続を受付
cp -a /etc/mongod.conf /etc/mongod.conf.org
sed -i -e 's|  bindIp: 127.0.0.1|# bindIp: 127.0.0.1|' /etc/mongod.conf
# 自動起動設定
chkconfig mongod on
service mongod start

echo "Mongo Express インストールと設定"
# Installing Node.js via package manager | Node.js https://nodejs.org/en/download/package-manager/
# リポジトリ導入
curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
sed -i -e 's|enabled=1|enabled=0|' /etc/yum.repos.d/nodesource-el.repo
# Node.js インストール
yum install -y --enablerepo=nodesource nodejs
# Mongo Express インストール
npm install -g mongo-express > /dev/null 2>&1
# 設定
cp /usr/lib/node_modules/mongo-express/config.default.js /usr/lib/node_modules/mongo-express/config.js
# ウェブブラウザからアクセスする時の URL を定義
# URL はシェルスクリプト引数の IP アドレス
sed -i -e "s/host:             process.env.VCAP_APP_HOST                 || 'localhost',/host:             process.env.VCAP_APP_HOST                 || '$1',/" /usr/lib/node_modules/mongo-express/config.js
# すべてのデータベースを扱えるように設定
sed -i -e "s/admin: process.env.ME_CONFIG_MONGODB_ENABLE_ADMIN ? process.env.ME_CONFIG_MONGODB_ENABLE_ADMIN.toLowerCase() === 'true' : false,/admin: true,/" /usr/lib/node_modules/mongo-express/config.js
# Mongo Express を自動起動する
# デーモン化するためのパッケージ導入
npm install -g forever initd-forever > /dev/null 2>&1
# Mongo Express をデーモン化
cd /usr/lib/node_modules/mongo-express/
initd-forever -a /usr/lib/node_modules/mongo-express/app.js -n mongo-express
chmod +x mongo-express
mv mongo-express /etc/init.d/
# Mongo Express の自動起動設定・起動
chkconfig mongo-express --add
chkconfig mongo-express on
service mongo-express start
echo "."
echo "."
echo "."
echo "."
echo "."
echo "##################################################"
echo "Mongo Express server listening at http://admin:pass@$1:8081"
echo "##################################################"
