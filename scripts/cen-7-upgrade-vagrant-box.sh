#!/bin/bash
#
# Usage:
#   cen-7-upgrade-vagrant-box.sh
#
# Description:
#   CentOS 7 の最新化を行います。
#   既存パッケージの最新化
#   Virtualbox Guest Additions の最新化
#
###########################################################################

set -eux

# CentOS 7 の最新化
yum -y --enablerepo=epel update
systemctl restart dkms

# VirtualBox Guest Additions のインストール
mount -o loop,ro ~/VBoxGuestAdditions.iso /mnt/
/mnt/VBoxLinuxAdditions.run || :
umount /mnt/
rm -f ~/VBoxGuestAdditions.iso

# cleanup
rpm -q --whatprovides kernel | grep -Fv "$(uname -r)" | xargs yum -y autoremove
yum --enablerepo=epel clean all
yum history new
truncate -c -s 0 /var/log/yum.log

# minimize
dd if=/dev/zero of=/EMPTY bs=1M || :
rm /EMPTY

# In CentOS 7, blkid returns duplicate devices
swap_device_uuid=`/sbin/blkid -t TYPE=swap -o value -s UUID | uniq`
swap_device_label=`/sbin/blkid -t TYPE=swap -o value -s LABEL | uniq`
if [ -n "$swap_device_uuid" ]; then
  swap_device=`readlink -f /dev/disk/by-uuid/"$swap_device_uuid"`
elif [ -n "$swap_device_label" ]; then
  swap_device=`readlink -f /dev/disk/by-label/"$swap_device_label"`
fi
/sbin/swapoff "$swap_device"
dd if=/dev/zero of="$swap_device" bs=1M || :
/sbin/mkswap ${swap_device_label:+-L "$swap_device_label"} ${swap_device_uuid:+-U "$swap_device_uuid"} "$swap_device"