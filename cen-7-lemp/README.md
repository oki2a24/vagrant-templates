# cen-7-lemp
- CentOS 7 x86_64
- Nginx 1.10.1
- MariaDB 10.1.17
- PHP 7.0.11
  - Xdebug 2.4.1
  - PHPUnit 5.5.4
- phpMyAdmin 4

## ファイアーウォールについて
- 有効になっています。

## Nginx について
- ドキュメントルートは /var/www/html/ です。

## MariaDB について
- 全クエリログを /var/log/mariadb/query.log に出力します。

## PHP について
- エラーログは /var/log/php-fpm/error.log に出力されます。
- Xdebug を使用してリモートデバッグが可能です。

## phpMyAdmin について
- URL は http://192.168.56.11:8080 となります。
  IP アドレス部分は、Vagrantfile 等の設定により適宜読み替えてください。
