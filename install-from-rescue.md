# Install from rescue

## Prerequisites & Strategy
1. **Install Default Debian OS:** First, use the provider's control panel to install a standard, non-encrypted newest version of Debian. 
   > **Note:** Although unencrypted systems are insecure for long-term use, they include full dependency support required to run reinstallation scripts. An encrypted system cannot be used here because rescue mode usually provides low memory and low RAM in early boot stages will cause LUKS decryption to fail, preventing you from entering the OS to trigger the script.
1. **Rescue Mode Setup:** Boot into rescue mode and open the VNC console. The system will automatically attempt to load the rescue OS. 
1. **Interrupt GRUB:** Send `Ctrl + Alt + Del` in VNC to reboot. Repeatedly press `Esc` to stop auto-booting into the rescue OS, then press `c` to drop into the GRUB command prompt. From here, you will chainload into the default unencrypted OS.

## Boot the original os. 
Enable rescue mode, and reboot to grub and press `esc` quickly via vnc, then press `c` to command line mode, input `ls` to see disks, if the original partition isn't shown, load the proper disk driver.
```grub
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

## Convert the rescue disk into Installation Media

Once booted into the full, unencrypted system, execute the reinstallation script to turn the disk into an installer environment.

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

## Run the Installer & Configure Encryption

1. **Reboot into Installer:** Run `reboot`. Following the GRUB boot priority, the VPS will boot into the newly created reinstallation media.
1. **Select Expert Mode:** Choose **Expert Mode**. This allows you to force a GPT partition layout even on Legacy BIOS systems (GPT maintains dual partition tables, making it far more resilient against data corruption than MBR).
1. **Switch Consoles (TTY):** Press `Ctrl + Alt + F2` to open a secondary shell terminal.
1. **Inspect Partitions through its disk size:**
```
cat /proc/partitions
```
1. **Set Unencrypted Swap Memory:** Temporarily configure the original system disk to serve as swap space to ensure sufficient memory during installation:
```bash
mkswap /dev/vda && swapon /dev/vda && free -h
```
1. **Start Main Installer Flow:** Press `Ctrl + Alt + F1` to return to the installer interface. Proceed through initial settings (leave domain blank, set hostname to `debian`). Stop when you click the manual disk partitioning option, then you can load encryption modules at this specific point.
1. **Configure LUKS Encrypted Swap:** Switch back to `Ctrl + Alt + F2` and run:
```bash
echo -n "passphrase_for_swap_during_installation" | cryptsetup --batch-mode luksFormat "/dev/vdb6" --batch-mode --key-file -

echo -n "passphrase_for_swap_during_installation" | cryptsetup open "/dev/vdb6" crypt_lvm --key-file -

mkswap /dev/mapper/crypt_lvm && swapon /dev/mapper/crypt_lvm

# Disable temporary unencrypted swap
swapoff /dev/vda && free -h
```
1. **Complete Partitioning:** Return to `Ctrl + Alt + F1` and complete manual partitioning.

**Troubleshooting GPT Layout** on `/dev/vda`:
If the installer fails to switch `/dev/vda` to GPT format:
- Format the entire disk as a single root partition, wipe track sectors, and restart the partition manager.
- Alternatively, create a dedicated partition for swap initially instead of targeting the raw disk.
- Use dd to wipe the primary partition table headers if stale partition headers persist:
```bash
dd if=/dev/zero of=/dev/vda bs=512 count=34
```

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
