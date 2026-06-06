模仿亚马逊服务器，将默认语言 设置为 C.UTF8 而不是en_US.UTF-8 以避免在脚本中暴露个人身份线索

# 查看系统已安装的所有语言，列出当前系统里已经编译并生成（Generated）的所有可用的 Locale 列表。
locale -a

# 显示当前终端会话正在使用的语言和区域设置。它会列出系统当前在处理文字编码、时间格式、货币单位等功能时所依据的环境变量。
locale

# Linux 系统为了节省空间，默认不会把全世界几百种语言的字库、排序规则、时间格式全部生成出来（那会占用大量内存和硬盘）。
# 里面放的是生成（Compilation）语言包的“配方源列表”。
 nano /etc/locale.gen
 取消注释需要的语言
 sudo sed -i 's/^# *zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
 # 然后运行下面命令，系统就会去读这个文件，只把那些前面没有 # 号的语言编译出来。
 locale-gen

# 这是 Debian，无论哪个用户登录，只要他自己没有单独去修改，系统默认统统使用美式英语（en_US）以及 UTF-8 字符编码。的设置
# 说明这个文件不需要你手动去用 nano 或 vim 乱改，而是系统通过 update-locale 工具（或者你运行 dpkg-reconfigure locales 时）自动写入的。
# Linux 的配置是有优先级（覆盖机制）的：
# $$文本/终端的最终语言 \leftarrow 用户个人配置 (.bashrc) \leftarrow 系统全局默认 (/etc/default/locale)$$
# 用户层级：你登录了系统。如果你在自己的用户配置文件（比如 ~/.bashrc 或 ~/.profile）里写了一句 export LANG="zh_CN.UTF-8"，
# 那么你个人的设置就会覆盖系统的默认设置。
cat /etc/default/locale
用这个命令去修改，其中语言必须是已经编译好的语言，否则会抱错
update-locale LANG="C.UTF-8"

 #也可以运行下面命令在蓝色的图形界面里勾选 zh_CN.UTF-8 UTF-8。这个工具在幕后做的事情，其实就是帮你去修改 /etc/locale.gen 并自动取消掉那行的 # 号，然后运行生成。
 # dpkg-reconfigure locales
 # 里边有一条提示
 #  Please note that the C, C.UTF-8 and POSIX locales are always available and do not need to be generated.
 # 并且在这里的默认语言如果选无，那么保留原有的 /etc/default/locale 配置，否则会进行修改即执行 update-locale ，但并不会自动  source /etc/default/locale

# 因此无论是通过cli显式执行 update-locale 还是通过 gui dpkg-reconfigure 隐式修改默认语言选项，均需要重载环境变量或者重新进入终端后生效
 source /etc/default/locale

确实，在 C.UTF-8 环境下，中文、日文、甚至表情符号（Emoji）都能正常显示不乱码。既然如此，为什么还要折腾去装 zh_CN.UTF-8 呢？
这两者最核心的区别在于：C.UTF-8 只管“能认出这个字”（编码），而 zh_CN.UTF-8 还管“这个字怎么用、怎么本地化”（文化习惯）。
C.UTF-8： 系统的“世界语”。所有软件的报错信息、系统提示、帮助文档一律显示英文。
zh_CN.UTF-8： 系统的“普通话”。只要软件自带了中文翻译包，报错信息、终端提示、软件菜单都会自动变成中文。
当你在终端使用 ls 列出文件，或者数据库进行排序时，两者的逻辑完全不同。
C.UTF-8： 严格按照字符的 UTF-8 电脑二进制编码大小（Unicode 码位）进行排序。对中文来说，这几乎是随机的，不符合人类的阅读习惯。
zh_CN.UTF-8： 按照中文拼音（A-Z）或者部首笔画进行排序。

 nginx 配置的长度是80
