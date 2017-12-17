---
layout: post
title: "vim使用"
categories: tools
tags: vim
---

* content
{:toc}


## vim-markdown插件
```
Bundle "godlygeek/tabular"
Bundle "plasticboy/vim-makrdown"
```

## vim-instant-markdown插件
```
Bundle "suan/vim-instant-markdown"
```
这是一个实时预览的插件，安装依赖node.js和npm
```
sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install nodejs

sudo apt-get install npm
sudo npm -g install instant-markdown-d
```

安装了该插件后，每次打开.md文件后会自动打开一个浏览器窗口实时预览，浏览器内容也会跟着md文件内容的修改实时更新


