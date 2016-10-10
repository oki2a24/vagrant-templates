# cen-7-lapp
## 使い方
```bash
git clone https://github.com/oki2a24/vagrant-templates.git
cd vagrant-templates/cen-7-lapp
vagrant up
```
## 構成
- CentOS 7 x86_64
- Apache 2.4.6
- psql (PostgreSQL) 9.2.15
- PHP 5.4.16
  - Xdebug 2.2.7
  - PHPUnit 4.8.27
- phpPgAdmin 5.1

## ファイアーウォールについて
- 有効になっています。

## Apache について
- ドキュメントルートは /var/www/html/ です。

## PHP について
- エラーログは /var/log/php_errors.log に出力されます。
- Xdebug を使用してリモートデバッグが可能です。

## phpPgAdmin について
- URL は http://192.168.56.11/phpPgAdmin/ となります。  
  IP アドレス部分は、Vagrantfile 等の設定により適宜読み替えてください。
- ユーザ名: postgres  
  パスワード: vagrant
