sudo sed -i '/AcceptEnv/ { /TZ_WIN/! s/$/ TZ_WIN/ }' /etc/ssh/sshd_config
sudo systemctl restart sshd





# powershell 临时导出变量
$env:TZ_WIN = $(Get-Date -Format "zzz")

ssh -o SendEnv=TZ_WIN user@your_vps_ip
# 临时传递
TZ_WIN=$TZ_WIN bash a.sh


# 修复命令
sudo sed -i '/AcceptEnv/s/ TZ_WIN//g' /etc/ssh/sshd_config
