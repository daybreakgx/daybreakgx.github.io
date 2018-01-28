---
layout: post
title: "Ubuntu常用总结"
categories: tools
tags: vim
---

* content
{:toc}



# Ubuntu常用总结

## 开机自启动

在/etc/rc.local文件中添加相应的执行代码就可以，如：
```
/usr/bin/sslocal -c ~/ss.json
```

## 添加环境变量
* 在~/.profile文件中添加
  ```
  export PATH="$PATH:add_your_path_1:add_your_path_2"
  ```
  保存该文件后退出，注销再登录，变量生效，该种方式只对当前用户有效。


* 也可以在直接在终端中输入
  ```
  sudo export PATH="$PATH:add_your_path_1:add_your_path_2"
  ```
  这种方式变量立即生效，但是用户注销或重启后则失效。

* 使用sudo是提示cmd not found

  执行命令sudo visudo，修改secure_path，将cmd命令所在的path添加进去


## 快捷键

+ 显示桌面 : ctrl + super + d
+ 在新窗口中打开terminal : alt + ctrl + t
+ 在当前窗口的新标签中打开terminal : ctrl + shift + t
+ 在Terminal中进行不同标签切换 : alt + <1-9>


## 包管理

* deb包安装命令: dpkg -i xxx.deb

  如果提示deb包有依赖为安装，解决方法:
  先执行
  ```
  sudo apt-get -f -y install
  ```
  然后再执行安装命令

* 查看已安装的软件: dpkg -l

* 删除已安装的软件: 
    dpkg -P pkg
	apt-get purge pkg

	
## 解决开机启动时显示"System program problem detected"问题

Ubuntu有个apport程序在检测应用程序状态，当有应用程序出现crash后，在/var/crash目录下就会记录crash信息。
可以通过删除/var/crash目录下的日志信息
也可以通过修改/etc/default/apport文件中的enable选项关闭approt功能




