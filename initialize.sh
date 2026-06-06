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
用这个命令去修改，其中语言必须是已经编译好的语言，否则会抱错
update-locale LANG="C.UTF-8"

# Linux 系统为了节省空间，默认不会把全世界几百种语言的字库、排序规则、时间格式全部生成出来（那会占用大量内存和硬盘）。
# 里面放的是生成（Compilation）语言包的“配方源列表”。
 nano /etc/locale.gen
 取消注释需要的语言
 sudo sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
 # 然后运行下面命令，系统就会去读这个文件，只把那些前面没有 # 号的语言编译出来。
 locale-gen
# 而当你后面加上了具体的参数它会命令系统：“别管 /etc/locale.gen 文件的状态了，现在立刻、单独给我把 zh_CN.UTF-8 这个语言包编译出来！”
# 这个命令非常智能。它在帮你临时生成中文包的同时，还会顺手帮你把 /etc/locale.gen 文件里对应的 # zh_CN.UTF-8 UTF-8 前面的 # 号删掉（自动取消注释）。
locale-gen zh_CN.UTF-8

 也可以运行下面命令在蓝色的图形界面里勾选 zh_CN.UTF-8 UTF-8。这个工具在幕后做的事情，其实就是帮你去修改 /etc/locale.gen 并自动取消掉那行的 # 号，然后运行生成。
 dpkg-reconfigure locales

 source /etc/default/locale 或者重启终端

 nginx 配置的长度是80
