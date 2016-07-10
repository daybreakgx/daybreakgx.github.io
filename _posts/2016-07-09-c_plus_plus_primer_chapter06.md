---
layout: post
title: "C++ primer读书笔记（五）---函数"
categories: c++
tags: c++
---

* content
{:toc}

###### 形参和实参 
 
* 实参是形参的初始值。第一个实参初始化第一个形参，第二个实参初始化第二个形参，以此类推。尽管实参与形参存在对应关系，但是并没有规定实参的求值顺序。编译器能以任何可行的顺序对实参求值。

* 形参的类型决定了形参和实参交互的方式。如果形参是引用类型，它将绑定到对应的实参上；否则，将实参的值拷贝后赋给形参

  + 当形参是引用类型时，我们说它对应的实参被**引用传递(passed by reference)**或者函数被**传引用调用(called by reference)**。和其他引用一样，引用形参也是它绑定的对象的别名。
    
    - 使用引用能避免拷贝，拷贝大的类类型或者容器对象比较低效，甚至有的类类型根本不支持拷贝操作。当某种类型不支持拷贝操作时，函数只能通过引用形参访问该类型的对象。
    
    - 如果函数无须改变引用形参的值，最好将其声明为常量引用。

      > 把函数不会改变的形参定义成普通的引用是一种比较常见的错误，这么做带给函数的调用者一种误导，即函数可以修改它的实参的值。此外，使用普通引用而非常量引用也会极大的限制函数所能接受的实参类型（不能把`const`对象，字面值或者需要类型转换的对象传递给普通的引用形参）。


    - 一个函数只能返回一个值，然而有时候函数需要同时返回多个值，引用形参为我们返回多个结果提供了有效的途径。


  + 当实参的值被拷贝给形参时，形参和实参是两个相互独立的对象。我们说这样的实参被**值传递(passed by value)**或者函数被**传值调用(called by vaule)**

  > 熟悉C语言的程序员常常使用指针类型的形参访问函数外部的对象。在C++语言中，建议使用引用类型的形参代替指针。

* 实参为数组时，数组是以指针的形式传递给函数的，所以函数并不知道数组的具体大小，因此调用者需要提供一些额外信息，保证访问数组时不会越界

  + 使用标记指定数组长度，这种情况通常用于字符串，因为字符串的最后一个为空字符

        void print(const char* cp)
        {
            if(cp)
                while(*cp)
                    cout << *cp++;
        } 

  + 显示传递一个表示数组大小的形参

        void print(const int ia[], size_t size) {
            for(size_t i = 0; i != size; ++i) {
                cout << ia[i] << endl;
            }
        }

  + 使用标准库规范

        //begin指向要输出的首元素，end指向尾元素的下一位置
        void print(const int* begin, const int* end) {
            while(begin != end)
                cout << *begin++ << endl;
        }

* 指针的引用形参举例

      void swap(int* &a, int* &b)
      {
          int * temp = a;
          a = b;
          b = temp;
          return; 
      }
      int main()
      {
          int a = 10, b = 20;
          int* pa = &a, *pb = &b;
          cout << "a: " << pa << endl;
          cout << "b: " << pb << endl;

          //不能使用swap(&a, &b),编译会出错
          //提示invalid initialization of non-const reference of type ‘int*&’ from an rvalue of type ‘int*’
          //因为 &a 表达式返回的是个右值，而引用需要的是左值
          swap(pa, pb);
          cout << "a: " << pa << endl;
          cout << "b: " << pb << endl;
          return 0;
      }


* 含有可变形参的函数

  + C++11新标准提供了两种主要的方法
   
    * 如果所有的实参类型相同，可以传递一个名为`initializer_list`的标准库类型

      - `initializer_list`是一种标准库类型，和`vector`一样，也是一种模板类型，用于表示某种特定类型的值的数组，定义`initializer_list`对象时，必须说明列表中所含元素的类型。
      - `initializer_list`类型定义在同名的头文件中。
        
             #include <initializer_list>
             using std::initializer_list

      - 与`vector`不一样的是，`initializer_list`对象中的元素永远是常量值，不能改变`initializer_list`对象中元素的值。
      - `initialier_list`提供的操作
          
            initializer_list<T> lst;     //默认初始化; T类型元素的空列表

            // lst的元素数量和初始值一样多；lst的元素是对应初始值的副本；列表中的元素是const
            initializer_list<T> lst{a, b, c...};
            
            // 拷贝或赋值一个initializer_list对象不会拷贝列表中的元素；拷贝后，原始列表和副本共享元素
            lst2(lst);
            lst2 = lst;
    
            lst.size();                  //列表中元素数量
            lst.begin();                 //返回指向lst中首元素的指针
            lst.end();                   //返回指向lst中尾元素下一位置的指针


    * 如果实参类型不同，可以编写一种特殊的函数，就是所谓的可变参数模板


  + C++还有一种特殊的形参类型（即省略符），可以用它传递可变数量的实参。这种功能一般只用于与C函数交互的接口程序。

    省略符形参是为了便于C++程序访问某些特殊的C代码而设置的，这些代码使用了名为`varargs`的C标准库功能。通常，省略符形参不应用于其他目的，省略符形参应该仅仅用于C和C++通用的类型。特别应该注意的是，大多数类类型的对象在传递给省略符形参时都无法正确拷贝。


    省略符形参只能出现在形参列表的最后一个位置。

        void foo(parm_list, ...);
        void foo(...);

###### 函数返回值

* 不要返回局部对象的引用或指针。

  函数完成后，它所占用的存储空间也随之被释放掉。因此，函数终止意味着局部变量的引用将指向不再有效的内存区域。同样，一旦函数完成，局部对象释放，局部对象的指针也将指向一个不存在的对象。

* 引用返回左值

  函数的返回类型决定函数调用是否是左值。

  调用一个返回引用的函数得到左值，其他返回类型得到右值。可以像使用其他左值那样来使用返回引用的函数的调用，特别的，我们能为返回类型是非常量引用的函数的结果赋值。

      char& get_val(string &str, string::size_type ix)
      {
          return str[ix];
      } 

      int main()
      {
          string s("a value");
          cout << s << endl;
          get_val(s, 0) = 'A';     //将s[0]的值改为A
          cout << s << endl;       //输出 A value
          return 0;
      }

* 返回指向数组的指针

  + 使用类型别名的方式

        typedef int arrT[10]; //arrT是一个类型别名，它表示的类型是含有10个整数的数组
        using arrT = int[10]; //arrT的等价声明
        arrT* func(int i);    //func返回一个指向10个整数的数组的指针

  + Type (*function(parameter_list))[dimension]

    Type表示元素的类型，dimension表示数组的大小，（*function(parameter_list))两端的括号一定要有，如果没有括号，函数的返回类型将是指针的数组。

        int (*func(int i))[10];

    func(int i)表示调用func函数时需要一个int类型的实参

    (*func(int i))意味着我们可以对函数调用的结果执行解引用操作
  
    (*func(int i))[10]表示解引用func的调用将得到一个大小是10的数组

    int (*func(int i))[10]表示数组中的元素是int类型


  + 使用尾置返回类型

    在C++11新标准中还有一种可以简化上述func声明的方法，就是使用尾置返回类型(tailing return type)。

    任何函数定义都可以使用尾置返回，但是这种形式对于返回类型比较复杂的函数最有效。尾置返回类型跟在形参列表后面并以一个->符号开头。为了表示函数真正的返回类型跟在形参列表后面，我们在本应该出现返回类型的地方放置一个auto:
    
        //func接受一个int类型的实参，返回一个指针，该指针指向含有10个整数的数组
        auto func(int i) -> int(*)[10];

  + 使用decltype
    
    还有一种情况，如果我们知道函数返回的指针指向哪个数组，就可以使用decltype关键字声明返回类型。

        int odd[] = {1, 3, 5, 7, 9};
        int even[] = {0, 2, 4, 6, 8};
        //返回一个指针，该指针指向含有5个整数的数组
        decltype(odd) *arrPtr(int i)
        {
            return (i % 2) ? &odd : & even;
        }

    decltype并不负责把数组类型转换成对应的指针，所以decltype的结果是个数组，要想表示arrPtr返回指针还必须在函数声明时加一个*符号。

###### 函数重载

> 如果同一个作用域内的几个函数名称相同但是形参列表不同，我们称之为**重载(overloaded)函数**。
  main函数不能重载。

* 定义重载函数

  对于重载函数来说，它们应该在形参数量或者形参类型上有所不同。不允许两个函数除了返回类型以外其他所有的要素都相同。

      Record lookup(const Account&);
      bool lookup(const Account&);    //错误: 与上一个函数相比只有返回类型不同


* 重载和const形参

  + 顶层const不影响传入函数的对象，一个拥有顶层const的形参无法和另一个没有顶层const的形参区分开来

        Record lookup(Phone);
        Record lookup(const Phone);      //重复声明了Record lookup(Phone)

        Record lookup(Phone*);
        Record lookup(Phone* const);     //重复声明了Record lookup(Phone*)

  + 如果形参是某种类型的指针或引用，则通过区分其指向的是常量对象还是非常量对象（底层const）可以实现函数重载。

        //下面定义了4个独立的重载函数
        Record lookup(Account&);
        Record lookup(const Account&);

        Record lookup(Account*);
        Record lookup(const Account*);

* 调用重载的函数

  > **函数匹配(function matching)**是指一个过程，在这个过程中我们把函数调用与一组重载函数中的某一个关联起来，函数匹配也叫**重载确定(overloaded resolution)**。

  当调用重载函数时有三种可能的结果:

    + 编译器找到一个与实参**最佳匹配(best match)**的函数，并生成调用该函数的代码
    + 找不到任何一个函数与调用的实参匹配，此时编译器发出**无匹配(no match)**的错误信息
    + 有多于一个函数可以匹配，但是每一个都不是明显的最佳选择。此时也将发生错误，称为**二义性调用(ambiguous call)**

###### 默认实参

* 默认实参作为形参的初始值出现再形参列表中。我们可以为一个或多个形参定义默认值，不过需要注意的是，一旦某个形参被赋予了默认值，它后面的所有形参都必须有默认值。

* 函数调用时实参按其位置接卸，默认实参负责填补函数调用缺少的尾部实参（靠右侧位置）。当设计含有默认实参的函数是，其中一项任务是合理设置形参的顺序，尽量让不怎么使用默认值的形参出现在前面，而让那些经常使用默认值的形参出现在后面。

* 局部变量不能作为默认实参。除此之外，只要表达式的类型能转换成形参所需的类型，该表达式就能作为默认实参。用作默认实参的名字在函数声明所在的作用域内解析，而这些名字的求值过程发生在函数调用时。

      typedef string::size_type sz;
      string screen(sz ht = 24, sz wid=80, char backgrnd = ' ');

      string window;
      window = screen();         //等价于screen(24, 80, ' ');
      window = screen(66);       //等价于screen(66, 80, ' ');
      window = screen(66, 256);  //等价于screen(66, 256, ' ');
      window = screen(66, 256, '#');

      window = screen(, , '?');   //错误: 只能省略尾部的实参

###### 内联函数和constexpr函数

* 内联函数

  内联函数通常就是将它在每个调用点上“内联地”展开。

  一般来说，内联机制用于优化规模较小、流程直接、频繁调用的函数。在函数的返回类型前面加上关键字inline，就可以将函数声明成内联函数了。

      inline const string& shorterString(const string &s1, const string &s2)
      {
          return s1.size() <= s2.size() ? s1 : s2;
      }

* constexpr函数

  constexpr函数是指能用于常量表达式的函数。constexpr函数的定义需要遵循下面几项约定:

    + 函数的返回类型及所有形参的类型都是字面值类型
    + 函数体中必须有且只有一条return语句

  constexpr函数不一定返回常量表达式

  constexpr函数举例

      constexpr int new_sz() { return 32; }
      constexpr int foo = new_sz();          //foo是一个常量表达式

  编译器能在程序编译时验证new_sz函数返回的是常量表达式，所以可以用new_sz函数初始化constexpr类型的变量foo。
  
  执行初始化任务时，编译器把对constexpr函数的调用替换成其结果。为了能在编译过程中随时展开，constexpr函数被隐式地指定为内联函数。


* 通常将内联函数和constexpr函数定义在头文件中。

###### 调试帮助

  程序可以包含一些用于调试的代码，但是这些代码只在开发程序时使用，当C++应用程序编写完成准备发布时，要先屏蔽掉调试代码。这种方法用到两项预处理功能: assert 和 NDEBUG。

* assert预处理宏

  assert是一种预处理宏。所谓预处理宏其实是一个预处理变量，它的行为有点类似于内联函数。assert宏使用一个表达式作为它的条件:
      
      assert(expr);
  
  首先对expr求值，如果表达式为假（即0），assert输出信息并终止程序运行。如果表达式为真（即非0），assert什么也不做。

  assert宏定义在cassert头文件中。

  预处理名字由预处理器而非编译器管理，因此我们可以直接使用预处理名字而无须提供using声明。也就是说，我们应该使用assert而不是std::assert，也不需要为assert提供using声明。

  assert宏常用于检查“不能发生”的条件。

 
* NDEBUG预处理变量

  assert的行为依赖于一个名为NDEBUG的预处理变量的状态。如果定义了NDEBUG，则assert什么也不做。默认状态下没有定义NDEBUG，此时assert将执行运行时检查。

  可以使用一个#define 语句定义NDEBUG，从而关闭调试状态。
  很多编译器也提供了一个命令行选项使我们可以定义预处理变量:
  
      $CC -D NDEBUG main.cc
  
  这条命令等价于在main.cc文件的一开始写#define NDEBUG

  assert应该仅用于验证那些确实不可能发生的事情。我们可以把assert当成调试程序的一种辅助手段，但是不能用它替代真正的运行时逻辑检查，也不能替代程序本身应该包含的错误检查。

  除了用于assert外，也可以使用NDEBUG编写自己的条件调试代码。如果NDEBUG未定义，将执行#ifndef 和#endif之间的代码；如果定义了NDEUBG，这些代码将被忽略掉:

      void print(const int ia[], size_t size)
      {
      #ifndef NDEBUG
          //__func__ 是编译器定义的一个局部静态变量，用于存放函数的名字
          cerr << __func__ << ": array size is " << size << endl;
      #endif
      ...
      }
  
  \__func__     存放函数名的字符串字面值
  \__FILE__     存放文件名的字符串字面值
  \__LINE__     存放当前行号的整型字面值
  \__TIME__     存放文件编译时间的字符串字面值
  \__DATE__     存放文件编译日期的字符串字面值


###### 函数匹配


* 调用重载函数时应尽量避免强制类型转换，如果在实际应用中确实需要强制类型转换，则说明我们设计的形参集合不合理。

* 为了确定最佳匹配，编译器将实参类型到形参类型的转换划分成几个等级

  + 精确匹配，包括一下情况
  
    - 实参类型和形参类型相同
    - 实参从数组类型或函数类型转换成对应的指针类型
    - 向实参添加顶层const或者从实参中删除顶层const

  + 通过const转换实现的匹配

  + 通过类型提升实现的匹配

  + 通过算术类型转换或指针转换实现的匹配

  + 通过类类型转换实现的匹配

  
