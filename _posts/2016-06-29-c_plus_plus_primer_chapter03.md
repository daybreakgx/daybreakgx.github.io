---
layout: post
title: "C++ primer读书笔记（二）--- 标准库类型"
categories: c++
tags: c++
---

* content
{:toc}


> C++标准库一方面对库类型所提供的操作做了详细规定，另一方面也对库的实现者做出了一些性能上的需求。因此，标准库类型对于一般应用场合来说由足够的效率。


###### 使用命名空间成员

* 在函数中直接使用`namespace::name` 

* 使用`using namespace::name`声明

  位于头文件中的代码一般说不应该使用using声明
  每个名字都要需要独立的using声明

      #include <iostream>
      using std::cin; 
      using std::endl;
      int main()
      {
          int i;
          cin >> i;
          cout << i;    // 错误：没有对应的using声明，必须使用完成的名字
          std::cout << i << ednl;
          return 0;
      }


###### 标准库类型`string`


>  标准库类型`string`表示可变长的字符序列，使用`string`类型前必须首先包含头文件
   `#include <string>` 
   `using std::string`


* 定义和初始化`string`对象

      string s1;
      string s2(s1);
      string s2 = s1;
      string s3("value");
      string s3 = "value";
      string s4(10, 'c');
      string s4 = string(10, 'c');


  如果使用等号`=`初始化一个变量，实际上执行的是 **拷贝初始化(copy initialization)** 编译器把等号右侧的初始值拷贝到新创建的对象中去。与之相反，如果不使用等号，则执行的是 **直接初始化(direct initialization)**。

* `string`对象上的操作

      os<<s                //将s写到输出流os当中，返回os
      //从is中读取字符串赋给s，字符串以空白分割，返回is
      //在执行读取操作时，string对象会自动忽略开头的空白并从第一个真正的字符开始读起，直到遇见下一处空白为止
      is>>s
      
      //从is中读取一行赋给s，返回is
      //函数从is中读取数据，直到遇到换行符为止，s中不包含换行符，如果第一行是空行，则s为空字符串
      getline(is, s)
      s.empty()            //s为空返回true，否则返回false
      s.size()             //返回s中字符的个数，返回类型为string::size_type
      s[n]                 //返回s中的第n个字符的引用，位置n从0计数
      s1+s2                //返回s1和s2连接后的结果
      s1=s2                //用s2的副本代替s1中原来的字符
      s1==s2               //如果s1和s2中所包含的字符完全一样，则返回true，大小写敏感
      s1!=s2 
      <, <=, >, >=         //利用字符在字典中的顺序进行比较且对大小写敏感


  `string`类及其他大多数标准库类型都定义了几种配套的类型。这些配套类型体现了标准库类型与机器无关的特性，类型`size_type`即是其中的一种。`size_type`是一个无符号整型数，因此切记不要用`string.size()`的返回值跟有符号的整型数做比较。


  当把`string`对象和字符字面值以及字符串字面值混在一条语句中使用时，必须保证每个加法运算符的两侧运算对象中至少由一个是`string`对象。

      string s1 = "hello";
      string s2 = s1 + ", ";           // 正确，把一个string对象和一个字面值相加
      string s3 = "hello" + ", ";      // 错误，两个运算对象都不是string
      string s4 = s1 + ", " + "world"; // 正确，s1 + ", "的返回值是个string对象
      string s5 = "hello" + ", " + s1; // 错误，"hello" 和 ", " 是两个字面值

  由于某些历史原因，也为了与C兼容，所以C++中的字符串字面值并不是标准库类型`string`的对象。切记，**字符串字面值与string是不同的类型**


* 处理`string`对象中的字符

  cctype头文件中的函数
  
      isalnum(c)      //当c是字母或数字时为true
      isalpha(c)      //当c是字母时为true
      iscntrl(c)      //当c是控制字符时为true
      isdigit(c)      //当c是数字时为true
      isgraph(c)      //当c不是空格但可打印时为真
      islower(c)
      isprint(c)      //当c是可打印字符时为真（即c是空格或c具有可视形式）
      ispunct(c)      //当c是标点符号时为真
      isspace(c)      //当c是空白时为真（空格/横向制表符/纵向制表符/回车符/换行/走纸）
      isupper(c) 
      isxdigit(c)     //当c是十六进制数时为真
      tolower(c)
      toupper(c)


  > C++标准库中兼容了C语言的标准库。C语言的头文件形如name.h，C++则将这些文件命名为cname。
    在名为cname的头文件中定义的名字从属于命名空间std，而定义在名为.h的头文件中的则不然。
    一般来讲，C++程序应该使用名为cnmae的头文件而不是使用name.h的形式。


      #include <iostream>
      #include <string>
            
      using std::string;
      using std::cout; using std::cin; using std::endl;
       
      int main()
      {
          string s("Hello world!!!");
          
          for(auto &c : s)
              c = toupper(c);
          
          cout << s << endl;
          return 0;
      }

  
  C++标准并不要求标准库检测下标是否合法，一旦使用了一个超出范围的下标，就会产生不可预知的结果。

