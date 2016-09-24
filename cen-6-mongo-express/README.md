# cen-6-mongo-express
## 使い方
```bash
git clone https://github.com/oki2a24/vagrant-templates.git
cd vagrant-templates/cen-6-mongo-express
vagrant up
```
## 構成等
- [cen-7-lemp](../cen-6-lamp/README.md) と同様

## Mongo Express について
- [mongo-express/mongo-express: Web-based MongoDB admin interface, written with Node.js and express](https://github.com/mongo-express/mongo-express)
- URL は http://admin:pass@92.168.56.11:8081 となります。  
  IP アドレス部分は、Vagrantfile 等の設定により適宜読み替えてください。
- ベーシック認証情報(URL に埋め込み済み)  
  ユーザ名: admin  
  パスワード: pass

## MongoDB Tips
- ダンプファイルから MongoDB へインポートしたい場合のコマンド  
  `mongorestore -db db_name /path/to/dump_data.bson`
