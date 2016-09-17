# cen-7-lamp
## 使い方
```bash
git clone https://github.com/oki2a24/vagrant-templates.git
cd vagrant-templates/cen-7-lamp
vagrant up
```
## 構成
- CentOS 7 x86_64
- Apache 2.4.6
- MariaDB 5.5.50
- PHP 5.4.16
  - Xdebug 2.2.7
  - PHPUnit 4.8.27
- phpMyAdmin 4.4.15.8

## ファイアーウォールについて
- 有効になっています。

## Nginx について
- ドキュメントルートは /var/www/html/ です。

## MariaDB について
- 全クエリログを /var/log/mariadb/query.log に出力します。

## PHP について
- エラーログは /var/log/php_errors.log に出力されます。
- Xdebug を使用してリモートデバッグが可能です。

## phpMyAdmin について
- URL は http://192.168.56.11/phpMyAdmin/ となります。
  IP アドレス部分は、Vagrantfile 等の設定により適宜読み替えてください。
- ユーザ名: root  
  パスワード: vagrant
