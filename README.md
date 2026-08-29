Some vps companies don't permit user to mount customized iso, however people concern about the preinstalled os.

- If the rescue-mode is provided and have access for internet, just transfer the rescue-os disk to an installation media.  
The reason for using the original-os instead of running the reinstallation script on the rescue os is that, on the rescue os, many components are missing due to the outdated system version, which can cause the script to fail.  
First, follow [these steps](https://github.com/botshell/debian-install/blob/main/install-from-rescue.md) to boot from original-os in grub menu when vps in rescue-mode.
- If no rescue-mode is provided or the rescue-mode disk is small to contain netinst.iso, then use the only hard disk to install new os. See [these](./install-from-origin.md) ways.

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

开机后 nano /etc/ssh/sshd_config
然后 重启ssh服务
systemctl restart ssh

按照完成后根据该仓库的步骤完成初始化配置
https://github.com/botshell/debian-initialization/blob/main/main.sh
