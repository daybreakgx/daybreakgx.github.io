---
layout: post
title: "C++ primer读书笔记（七）--- IO Library "
categories: c++
tags: c++
---

* content
{:toc}


###### IO库类型和头文件

* 为了支持不同种类的IO操作，在iostream之外，标准库还定义了其他一些IO类型。
  + iostream 定义了用于读写流的基本类型
  + fstream 定义了读写命名文件的类型
  + sstream 定义了读写内存string对象的类型

  > 为了支持宽字符语言，标准库还定义了一组类型和对象来操作wchar_t类型的数据。宽字符的版本的类型和函数的名字以一个w开始。

  头文件|类型|说明
  iostream|istream,wistream |从流读取数据
          |ostream,wostream |向流写入数据
          |iostream,wiostream |读写流
  fstream|ifstream,wifstream |从文件读取数据
         |ofstream,wofstream |向文件写入数据
         |fstream,wfstream |读写文件 
  sstream|istringstream,wistringstream |从string读取数据
         |ostringstream,wostringstream |向string写入数据
         |stringstream,wstringstream |读写string


###### IO库之间的关系


继承关系如下图

  ![sizeof type](/image/iostream.gif)

  ![sizeof type](/image/io_library.png)


