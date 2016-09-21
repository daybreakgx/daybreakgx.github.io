---
layout: post
title: "Sublime Text 3 使用说明"
categories: tool editor
tags: sublime
---

* content
{:toc}

##### 快捷键

* ctrl + ` : 打开/关闭控制台(console)

* ctrl + shift + p : 打开/关闭命令面板(command palette)

##### package control安装

在console中输入以下代码

    import urllib.request,os; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); open(os.path.join(ipp, pf), 'wb').write(urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ','%20')).read()) 


##### 插件安装与卸载

* 下载插件安装包，直接解压到【菜单->Perferences->Browse Packages…】目录；卸载的话就直接在此目录下删掉对应的插件文件夹就可以了。

* 使用package control安装

    + 打开command palette, 输入install/remove/upgrade package, 回车，然后再输入要安装的插件名即可。

##### 常用插件

* ConvertToUTF8 : 用于解决文件中的中文乱码

* Material Theme

* Markdown Preview

    + 使用快捷键 alt + b 可以在markdown文件所在目录生成对应的html文件

    + 在 【Preferences】 -> 【Key Bindings - User】 中添加以下代码后，可以使用 alt + m 快捷键直接用浏览器显示对应的html格式
        
            {"keys":["alt+m"], "command":"markdown_preview", "args":{"target":"browser", "parser":"markdown"}},

##### 常用配置

自定义配置在 【Preferences】 -> 【Settings - User】 中添加

* 设置tab的空格数　　　"tab_size": 4

* 用空格替换tab　　　　"translate_tabs_to_spaces": true

* 显示空白字符　　　　 "draw_white_space": "all"

* 自动换行　　　　　　 "word_wrap": true


