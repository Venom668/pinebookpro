#!/bin/sh
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit
fi

echo "Updating payload..."

cd /boot/levinboot
cmdline=$(cat /boot/levinboot/cmdline.txt)

cp /boot/dtbs/rockchip/rk3399-pinebook-pro.dtb rk3399-pinebook-pro.dtb

fdtput -pt s rk3399-pinebook-pro.dtb /chosen bootargs "$cmdline"
#mkinitcpio -z cat -g /boot/levinboot/initramfs-linux.img # Assuming initramfs is already zstd-compressed.

truncate -s 0 payload.img
zstd -c bl31.elf >> payload.img
zstd -c rk3399-pinebook-pro.dtb >> payload.img
zstd -c /boot/Image >> payload.img
cat /boot/initramfs-linux.img >> payload.img
#zstd -c initramfs-linux.img >> payload.img # So we can cat it instead of regenerating and compressing.

rm rk3399-pinebook-pro.dtb
#rm initramfs-linux.img

echo "Payload has to be flashed to the configured medium, e.g. partition with GUID 'e5ab07a0-8e5e-46f6-9ce8-41a518929b7c' on a GPT formatted drive."
echo "You can do that by running:"
echo "# dd if=/boot/levinboot/payload.img of=/dev/mmcblkXpN"
echo "Refer to the documentation."
