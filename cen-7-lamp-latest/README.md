# cen-7-lamp-latest
## 使い方
```bash
git clone https://github.com/oki2a24/vagrant-templates.git
cd vagrant-templates/cen-7-lamp-latest
vagrant up
```
## 構成
- CentOS 7 x86_64
- Apache 2.4.6
- MariaDB 10.1
- PHP 7
  - Xdebug 2.4
  - PHPUnit 5.5
- phpMyAdmin 4.6

## ファイアーウォールについて
- 有効になっています。

## Apache について
- ドキュメントルートは /var/www/html/ です。

## MariaDB について
- 全クエリログを /var/log/mariadb/query.log に出力します。

## PHP について
- エラーログは /var/log/php_errors.log に出力されます。
- Xdebug を使用してリモートデバッグが可能です。  
  リモートデバッグログは、/var/log/xdebug.log に出力されます。

## phpMyAdmin について
- URL は http://192.168.56.11/phpMyAdmin/ となります。  
  IP アドレス部分は、Vagrantfile 等の設定により適宜読み替えてください。
- ユーザ名: root  
  パスワード: vagrant
