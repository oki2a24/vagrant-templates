#!/bin/bash
#
# Usage:
#   cen-7-phpPgAdmin.sh
#
# Description:
#   CentOS 7 で phpPgAdmin 環境を構築します。
#   EPEL リポジトリを使用してインストールします。
#   PHP、PostgreSQL が既にインストールされていることを前提とします。
#
###########################################################################

set -eux

echo "phpPgAdmin インストールと設定"
# インストール
yum -y --enablerepo=epel install phpPgAdmin
# 設定
# エイリアスのみ設定し、認証系の設定は削除
mv /etc/httpd/conf.d/phpPgAdmin.conf /etc/httpd/conf.d/phpPgAdmin.conf.org
cat > /etc/httpd/conf.d/phpPgAdmin.conf <<EOF
Alias /phpPgAdmin /usr/share/phpPgAdmin
Alias /phppgadmin /usr/share/phpPgAdmin

<Directory /usr/share/phpPgAdmin/>
  AllowOverride all
  Require all granted
</Directory>
EOF
# スーパーユーザ postgres でもログイン可能に設定
cp -a /usr/share/phpPgAdmin/conf/config.inc.php /usr/share/phpPgAdmin/conf/config.inc.php.org
sed -i -e "s/\$conf\['extra_login_security'\] = true;/\$conf\['extra_login_security'\] = false;/" /usr/share/phpPgAdmin/conf/config.inc.php
# 設定完了したので、設定反映
systemctl restart httpd.service
