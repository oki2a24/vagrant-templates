# cen-6-lamp
## 使い方
```bash
git clone https://github.com/oki2a24/vagrant-templates.git
cd vagrant-templates/cen-6-lamp
vagrant up
```
## 構成
- CentOS 6 x86_64
- Apache 2.2
- MySQL 5.1
- PHP 5.3
  - Xdebug 2.2.7
- phpMyAdmin 4

## ファイアーウォールについて
- 有効になっています。
- 制限はかけておらず、全て受入、通過します。

## Apache について
- ドキュメントルートは /var/www/html/ です。

## MySQL について
- 全クエリログを /var/log/mariadb/query.log に出力します。

## PHP について
- エラーログは /var/log/php_errors.log に出力されます。
- Xdebug を使用してリモートデバッグが可能です。

## phpMyAdmin について
- URL は http://192.168.56.11/phpMyAdmin/ となります。  
  IP アドレス部分は、Vagrantfile 等の設定により適宜読み替えてください。
- ユーザ名: root  
  パスワード: vagrant
