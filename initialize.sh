模仿亚马逊服务器，将默认语言 设置为 C.UTF8 而不是en_US.UTF-8 以避免在脚本中暴露个人身份线索

# 查看系统已安装的所有语言，列出当前系统里已经编译并生成（Generated）的所有可用的 Locale 列表。
locale -a

# 显示当前终端会话正在使用的语言和区域设置。它会列出系统当前在处理文字编码、时间格式、货币单位等功能时所依据的环境变量。
locale

# 这是 Debian，无论哪个用户登录，只要他自己没有单独去修改，系统默认统统使用美式英语（en_US）以及 UTF-8 字符编码。的设置
# 说明这个文件不需要你手动去用 nano 或 vim 乱改，而是系统通过 update-locale 工具（或者你运行 dpkg-reconfigure locales 时）自动写入的。
# Linux 的配置是有优先级（覆盖机制）的：
# $$文本/终端的最终语言 \leftarrow 用户个人配置 (.bashrc) \leftarrow 系统全局默认 (/etc/default/locale)$$
cat /etc/default/locale
用这个命令去修改
update-locale LANG="en_US.UTF-8"

 nano /etc/locale.gen
 取消注释
 然后重新运行
 locale-gen

sudo sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
locale-gen zh_CN.UTF-8

 也可以
 dpkg-reconfigure locales

 source /etc/default/locale 或者重启终端

 nginx 配置的长度是80
