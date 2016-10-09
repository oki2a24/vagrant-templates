# cen-7-ec-cube-3-mariadb
## 使い方
以下の操作を、ホストマシンから行います。

```bash
# vagrant templates の入手と起動
git clone https://github.com/oki2a24/vagrant-templates.git
cd cen-7-ec-cube-3-mariadb
vagrant up
# 仮想マシンへアクセスし、EC-CUBE3 セットアップ
vagrant ssh
```

続いて、次の操作を仮想マシン上で行います。

```bash
# EC-CUBE 3 ダウンロード
cd /var/www/
git clone https://github.com/EC-CUBE/ec-cube.git

# Apache ドキュメントルート変更
sudo sed -i -e 's|/var/www/html|/var/www/ec-cube/html|' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd.service

# インストール設定の調整
cd /var/www/ec-cube/
sed -i -e 's|export ROOT_URLPATH=${ROOT_URLPATH:-"/ec-cube/html"}|export ROOT_URLPATH=${ROOT_URLPATH:-""}|' eccube_install.sh
# インストール
./eccube_install.sh mysql
# インストールファイルの削除
rm -f html/install.php
```

## 構成等
- [cen-7-lamp](../cen-7-lamp/README.md) と同等です。
- EC-CUBE 3 は MariaDB を利用します。

## EC-CUBE 3  について
- フロント: http://192.168.56.11/
- 管理画面: http://192.168.56.11/admin/
  - ID: admin  
    パスワード: password

## phpMyAdmin について
- URL は http://192.168.56.11/phpMyAdmin/ となります。  
  IP アドレス部分は、Vagrantfile 等の設定により適宜読み替えてください。
- ユーザ名: root  
  パスワード: vagrant

## 仮想マシンリセット (削除・再生性) 時の注意
`vagrant destroy` で仮想マシンを削除できます。
このとき、一度 `git clone` したソースコードは削除されません。
一方で、DB データは仮想マシンとともに削除されます。

DB データを EC-CUBE をインストール完了時の状態に戻すには、
仮想マシンへアクセス (`vagrant ssh`) 後、次のようにしてください。

```bash
# Apache ドキュメントルート変更
sudo sed -i -e 's|/var/www/html|/var/www/ec-cube/html|' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd.service
# composerを実行しないで 再インストール
./eccube_install.sh mysql none
```

## 参考
- <a href="http://ec-cube.github.io/install.html" target="_blank">インストール方法 | EC-CUBE 3 開発ドキュメント</a>
- <a href="https://github.com/EC-CUBE/ec-cube/blob/master/eccube_install.sh" target="_blank">ec-cube/eccube_install.sh at master · EC-CUBE/ec-cube</a>
