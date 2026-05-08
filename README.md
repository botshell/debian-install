首先得安装厂商提供的不安全的系统，不然带加密的系统在启动时候就内存不够，无法引导去做系统盘

知道打开手动分区那一刻开始才能加载加密模组

然后要选择手动分区
mkswap /dev/vda

echo -n "passphrase_for_swap_during_installation" | cryptsetup --batch-mode luksFormat "/dev/vdb6" --batch-mode --key-file -

echo -n "passphrase_for_swap_during_installation" | cryptsetup open "/dev/vdb6" crypt_lvm --key-file -

mkswap /dev/mapper/crypt_lvm



Some vps companies don't permit user to mount customized iso, however people concern about the preinstalled os.

- If the rescue-mode is provided and have access for internet, just transfer the rescue-os disk to an installation media.  
The reason for using the original-os instead of running the reinstallation script on the rescue os is that, on the rescue os, many components are missing due to the outdated system version, which can cause the script to fail.  
First, follow [these steps](https://github.com/botshell/debian-install/blob/main/install-from-rescue.md) to boot from original-os in grub menu when vps in rescue-mode.
- If no rescue-mode is provided or the rescue-mode disk is small to contain netinst.iso, then use the only hard disk to install new os. See [these](./install-from-origin.md) ways.

Run the code below to install automatically.  
This will reimage the entire disk with Debian in rescue mode and **WIPE ALL DATA** on the disk WITHOUT any interactive confirmation.  
The trailing "y" skips the disk format confirmation prompt.
```bash
bash <(wget -qO- https://raw.githubusercontent.com/botshell/debian-install/main/install.sh) y

```
Or run the code below to install manually.  
This performs the same Debian reinstallation in rescue mode, but WILL prompt you for confirmation before formatting the disk.  
Use this if you want to review or confirm destructive actions.
```bash
bash <(wget -qO- https://raw.githubusercontent.com/botshell/debian-install/main/install.sh)

```

Partition sample
| Partition  | Size   | Type             | FSTYPE   | Mode      | Use as                                                                                        |
| :--------- | -----: | :--------------- | :------- | :-------- | :-------------------------------------------------------------------------------------------- |
| /dev/sdX1/ | 1M     | BIOS boot        | biosgrub | Bios      | Reserved BIOS boot area, do not format it                                                     |
| /dev/sdX2/ | 100M   | EFI System       | FAT32    | Uefi      | ESP, unencrypted                                                                              |
| /dev/sdX3/ | 512M   | Linux filesystem | ext4     | Bios&Uefi | Boot partition for pure os to install, unencrypted                                            |
| /dev/sdX4/ | -2049M | Linux filesystem | ext4     | Bios&Uefi | /root and /swap partition for pure os to install, encrypted volume, then configure LVM on it. |
| /dev/sdX5/ | 1G     | Linux filesystem | ext4     | Bios&Uefi | Install-media, encrypted after installation                                                   |
| /dev/sdX6/ | 1G     | Linux swap       | swap     | Bios&Uefi | Swap memory for low memory machine during the installation, encrypted after installation      |
