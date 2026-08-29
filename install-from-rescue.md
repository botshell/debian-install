首先得在控制面板安装vps厂商默认提供的较新版本的debian系统（该系统虽然硬盘没有加密，不带硬盘加密的不安全的，但是依赖是较为齐全的，可以临时运行制作重装系统盘的脚本），
不然带加密的系统在启动时候英文内存不够导致解密失败，无法进入系统，从而无法运行脚本以转变救援系统所在的硬盘去做系统盘

然后，启动救援模式，此时打开vnc后系统会自动进入救援模式的操作系统。此时可以通过发送 alt+ctrl+del重启至grub菜单，然后按住esc以停止继续引导至救援系统，然后按 c 键进入命令，通过grub菜单链式启动至vps厂商默认提供的不带硬盘加密的不安全的系统，

# Boot the original os. 
Enable rescue mode, and reboot to grub and press `esc` quickly via vnc, then press `c` to command line mode, input `ls` to see disks, if the original partition isn't shown, load the proper disk driver.
```
insmod part_gpt  # gpt
insmod part_msdos  # mbr
ls  # check recognized disk condition again
```

For bios mode:
```
set root=(hd1)
chainloader +1
boot
```

For uefi mode (works as well in bios mode):
```
set root=(hd1,gpt2)
linux /install.amd/vmlinuz priority=low  # could press `tab` to see if path autofilled to check correction
initrd /install.amd/initrd.gz
boot
```
此时引导进入完整依赖的不带硬盘加密的系统。然后

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

系统盘制作成功后，使用命令 `reboot`重启，此时会根据grub菜单默认顺序，进入原先救援模式所在的系统，也就是此时的重装系统盘，然后选择专家模式，在该模式下，即使bios启动，也可以把硬盘设置为gpt格式（gpt格式有两个分区表，相对mbr更加不容易丢失数据）

Ctrl + Alt + F2
cat /proc/partitions
得到分区信息

然后要选择手动分区，讲原系统盘作为共享内存
mkswap /dev/vda && swapon /dev/vda && free -h

Ctrl + Alt + F1
走流程，域名设置为空，主机名debian，直到硬盘检测后打开手动分区前那一刻开始才能加载加密模组

Ctrl + Alt + F2

echo -n "passphrase_for_swap_during_installation" | cryptsetup --batch-mode luksFormat "/dev/vdb6" --batch-mode --key-file -

echo -n "passphrase_for_swap_during_installation" | cryptsetup open "/dev/vdb6" crypt_lvm --key-file -

mkswap /dev/mapper/crypt_lvm

swapon /dev/mapper/crypt_lvm

关闭未加密的共享内存

swapoff /dev/vda && free -h

Ctrl + Alt + F1 继续流程
此时无法修改vda分区为gpt，因此可以先整体分区为root并清除扇道后重新进入，或者 一开始设置swap分区时候就设置一个分区而不是整个盘，也可以试试dd命令清除，但是没试过

# Download the debian cd-rom (ISO 9660) for a online install or dvd-rom for a offline install.
[Debian Archive Release](https://cdimage.debian.org/cdimage/archive/)  
[Debian Current Release](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/)  

Download and then dd. Follow [this](https://github.com/driverdrift/linux-docs/blob/main/downloader.md) way.

```
# 将文件精确调整为 1G (1024^3 字节)
truncate -s 1G debian_install.iso
它非常快，因为它并不真的往硬盘里写 300MB 的数据，而是通过改变文件系统的元数据来增加文件的“逻辑大小”（产生所谓的“稀疏文件”）。
实实在在的 0（不是稀疏文件）
fallocate -l 1G debian_install.iso
# 方法 1：保留原文件长度
dd if=debian-13.2.0-amd64-netinst.iso of=test.iso bs=4M conv=notrunc
思路两个：一个是dd到整个救援盘，然后破坏分区，另一个是iso放在原救援盘，如果足够大（用虚拟机测试），然后lookback启动iso，可以重建grub试试
如果验证哈希值时候，有时候需要屏蔽日志
dd if=/dev/vda bs=4M count=196 2>/dev/null | sha256sum
```

Warning!!!
```
dd if=debian_install.iso of=/dev/vda bs=4M status=progress && sync
```

add swap partition
```
sudo fdisk --wipe=never /dev/vdb
```

In pe mode, distinguish disks through size
```
cat /proc/partitions
```
```
swapon /dev/sdX6
free -h
```
