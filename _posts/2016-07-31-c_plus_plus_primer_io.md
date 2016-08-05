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

  -----表1-----

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


###### 公共特性

下面所描述的标准库流特性可以无差别的应用与普通流、文件流和string流，以及char或宽字符流版本。

* 不能拷贝或对IO对象赋值，也不能将形参或返回类型设置为流类型。

  进行IO操作的函数通常以引用方式传递和返回流。读写一个IO对象会改变其状态，因此传递和返回的引用不能是const的。

      ofstream out1, out2;
      out1 = out2;              // 错误：不能对流对象赋值
      ofstream print(ofstream); // 错误：不能初始化ofstream参数
      out2 = print(out2);       // 错误：不能拷贝流对象

* IO库条件状态

  下面表格中的strm是一种IO类型，在<表1>中已经列出。

  成员|描述
  strm::iostate| iostate是一种机器相关的类型，提供了表达条件状态的完整功能
  strm::badbit| 用来指出流已经崩溃
  strm::failbit| 用来指出一个IO操作失败了
  strm::eofbit| 指出流到达了文件结束
  strm::goodbit| 用来指出流未处于错误状态。此值保证为零
  s.eof()| 若流s的eofbit置位，则返回true
  s.fail()| 若流s的**failbit或badbit**置位，则返回true 
  s.bad()| 若流s的badbit置位，则返回true
  s.good()| 若流s处于有效状态（eofbit/failbit/badbit均未被置位）,则返回true
  s.clear()| 将流s中所有条件状态复位，即将流的状态设置为有效，返回void
  s.clear(flags)| 根据给定的flags标志位，将流s中对应条件状态**复位**。flags的类型为strm::iostate。返回void
  s.setstate(flags)| 根据给定的flags标志位，将流s中对应条件状态**置位**。flags的类型为strm::iostate。返回void
  s.rdstate()| 返回流s的当前条件状态，返回类型为strm::iostate


  只有当一个流处于无错状态时，才可以从它读取数据或向它写入数据。一旦流发生错误，其上后续的IO操作都会失败。

  由于流可能处于错误状态，因此在使用一个流之前应检查其是否处于良好状态。

      while(cin >> word)
          // OK: 读操作成功......

  ios中operator bool运算符操作的返回值的定义为:

   + true if none of failbit or badbit is set.
   + false otherwise.

  到达文件结束位置，eofbit和failbit都会被置位。


* 输出缓冲

  每个输出流都管理一个缓冲区，用于保存程序读写的数据。

  导致缓冲刷新（即，数据真正写到输出设备或文件）的原因有:

    + 程序正常结束，作为main函数的return操作的一部分，缓冲刷新被执行。
    + 缓冲区满时，需要刷新缓冲，而后新的数据才能继续写入缓冲区。
    + 可以使用操作符endl来显示刷新缓冲区。
    + 使用操纵符**unitbuf**设置流的内部状态，所有输出操作后都会立即刷新缓冲区。默认情况下，对cerr是设置unitbuf的，因此写入cerr的内容都是立即刷新的。
    + 一个流可以被关联到另一个流。当读写被关联的流时，关联到的流的缓冲区会被刷新。例如，默认情况下，cin和cerr都关联到cout，因此读cin或写cerr时都会导致cout的缓冲区被刷新。

  操纵符使用举例：

      cout << "hi!" << endl;    // 输出hi和一个换行符，然后刷新缓冲区
      cout << "hi!" << flush;   // 输出hi，然后刷新缓冲区，不附加任何额外字符
      cout << "hi!" << ends;    // 输出hi和一个空字符，然后刷新缓冲区

      cout << unitbuf;          // 所有输出操作后都会立即刷新缓冲区

      // 任何输出都立即刷新，无缓冲

      cout << nounitbuf;        // 回到正常的缓冲方式

  > 如果程序异常终止，输出缓冲区是不会被刷新的。当一个程序崩溃后，它所输出的数据很有可能停留在输出缓冲区中等待打印。

###### 文件输入输出

* fstream特有的操作

  下表中的fstream是头文件fstream中定义的一个类型。

  fstream fstrm;| 创建一个未绑定的文件流。
  fstream fstrm(s);| 创建一个fstream，并打开名为s的文件。s可以是string类型，也可以是一个char*。这种构造函数是explicit的。默认的文件模式mode依赖于fstream的类型
  fstream fstrm(s, mode);| 与上一个构造函数类似，但按照指定mode打开文件
  fstrm.open(s)| 打开名为s的文件，并将文件与fstrm绑定。s可以是string类型也可以是一个char*。默认文件mode依赖于fstream的类型。
  fstrm.close()| 关闭与fstream绑定的文件。返回void
  fstrm.is_open()| 返回一个bool。指出与fstrm关联的文件是否成功打开且尚未关闭。


* 创建文件流对象时，可以提供文件名，此时，open会自动被调用。如果没有提供文件名，则需要调用open来将该流对象与文件关联起来，如果调用open失败，failbit会被置位。

* 一旦一个文件流已经打开，它就保持与对应文件的关联。对一个已经打开的文件流调用open会失败，并会导致failbit被置位。随后的试图使用文件流的操作都会失败。为了将文件流关联到另一个文件，必须首先关闭已经关联的文件。

* 当一个fstream对象被销毁时，close会被自动调用。

* 在C++11标准中，文件名既可以是string类型对象，也可以是C风格字符数组。旧版本中标准库只允许C风格字符数组。

* 文件打开模式

  模式| 描述
  in| 以读方式打开
  out| 以写方式打开
  app| 每次写操作前均定位到文件末尾（追加写）
  ate| 打开文件后立即定位到文件末尾
  trunc| 截断文件
  binary| 以二进制方式进行IO

  指定文件模式有如下限制：

   + 只可以对ofstream和fstream对象设定out模式
   + 只可以对ifstream和fstream对象设定in模式
   + 只有当out也被设定时才可以设定trunc模式
   + 只要trunc模式没被设定，就可以设定app模式。在app模式下，即是没有显示指定out模式，文件也总是以out模式被打开
   + 默认情况下，即是我们没有指定trunc，以out模式打开的文件也会被截断。为了保留以out模式打开的文件内容，必须同时指定app模式或者同时指定in模式
   + ate和binary模式可用于任何类型的文件流对象，且可以与其他任何文件模式组合使用。

  out模式打开文件举例(以open方式打开文件相同):

      ofstream out("file1");     //隐含以输出模式打开文件并截断文件
      ofstream out2("file1", ofstream::out);   //隐含的截断文件
      ofstream out3("file1", ofstream::out|ofstream::trunc);
      //为了保留文件内容，必须显示指定app模式
      ofstream out4("file1", ofstream::app);   //隐含为输出模式
      ofstream out5("file1", ofstream::out|ofstream::app);


###### string流

* stringstream特有的操作

  下表中的sstream是头文件sstream中定义的一个类型。

  sstream strm;| 定义一个未绑定的stringstream对象。
  sstream strm(s);| 定义一个sstream对象，保存string s的一个拷贝。此构造函数是explicit的。
  strm.str()| 返回strm所保存的string的拷贝
  strm.str(s)| 将string s拷贝到strm中，返回void



