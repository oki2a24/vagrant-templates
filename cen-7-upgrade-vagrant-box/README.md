# cen-7-upgrade-vagrantbox
## 使い方
```bash
git clone https://github.com/oki2a24/vagrant-templates.git
cd vagrant-templates/cen-7-upgrade-vagrant-box
vagrant up

vagrant package --output centos-7-x86_64.box
```

1. [Vagrant box oki2a24/centos-7-x86_64 - Vagrant Cloud](https://app.vagrantup.com/oki2a24/boxes/centos-7-x86_64) にアクセスし、[New Version] から新しいバージョン情報を記入する。
1. [Add a provider] から生成された centos-7-x86_64.box をアップロードする。
   - provider: virtualbox
   - File Hosting: Upload to Vagrant Cloud
   - Continue to upload
1. [Release version]

## 概要
- [oki2a24/packer-templates: packer で作成する Vagrant Box です。](https://github.com/oki2a24/packer-templates) のアップデートの位置づけ
  - Vagrant Box のパッケージ最新化

## Virtualbox Guest Additions の最新化について
- マウントができないためシェルスクリプトでは行わない。
- [dotless-de/vagrant-vbguest: A Vagrant plugin to keep your VirtualBox Guest Additions up to date](https://github.com/dotless-de/vagrant-vbguest) の自動アップデートを利用する。
