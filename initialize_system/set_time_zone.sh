if [ -n "$TZ_WIN" ]; then
  HOURS=$(echo "$TZ_WIN" | cut -d':' -f1)
  
  # 使用 Bash 的算术扩展 $((...))需要在外面套上双括号，并对系统强制指定十进制解析
  # 否则凡是以 0 开头的数字，系统都会默认它是“八进制”（Octal）数！
  HOURS_CLEAN=$((10#$(echo "$HOURS" | sed 's/[-+]//')))

  if [ "$HOURS_CLEAN" -eq 0 ]; then
    MY_TZ="Etc/UTC"
  elif [[ "$HOURS" == -* ]]; then
    MY_TZ="Etc/GMT+${HOURS_CLEAN}"
  else
    MY_TZ="Etc/GMT-${HOURS_CLEAN}"
  fi

  # export 的真正威力不是向上改变父进程，而是向下影响它自己的子进程。
  # source 命令则是在当前进程中读入并执行这个脚本
  # export TZ="$MY_TZ"
  echo "正在将系统全局时区设置为: $MY_TZ"
  timedatectl set-timezone "$MY_TZ"
  date
fi
