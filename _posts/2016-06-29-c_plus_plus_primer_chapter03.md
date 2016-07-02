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
  `string`对象的下标运算符可以用于访问已经存在的元素，而不能用于添加元素。

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

###### 标准库类型`vector`

> 标准库类型`vector`表示对象的集合，其中所有对象的类型都相同。集合中的每个对象都有一个与之对应的索引，索引用于访问对象。
  因为`vector`容纳着其他对象，所以它也常被称为容器（container）。使用`vector`时必须包含头文件
  `#include <vector>`
  `using std::vector;`

* 定义和初始化`vector`

      vector<T> v1;                //v1是一个空vector
      vector<T> v2(v1);
      vector<T> v2 = v1;
      vector<T> v3(n, val);
      vector<T> v4(n);             //v4 包含了n个重复地执行了值初始化的对象
      vector<T> v5{a, b, c ...};
      vector<T> v6 = {a, b, c ...};

  通常情况下，可以只提供`vector`对象容纳的元素数量而略去初始值（例如v4），此时库会创建一个值初始化的元素初值，并把它赋给容器中的所有元素。这个初值由`vector`对象中元素的类型决定。
  如果`vector`对象的元素是内置类型，则元素初始值自动设为0。如果元素是某种类类型，则元素由类默认初始化，所以要求该类类型必须支持默认初始化。

  初始化过程会尽可能地把花括号里面的值当做是元素初始值的列表来处理，只有在无法进行列表初始化时才会考虑其他初始化方式，如默认值初始化。

      vector<int> v1(10);               //v1有10个元素，每个值都是0
      vector<int> v2{10};               //v2有1个元素，该元素的值是10
      vector<int> v3(10, 1);            //v3有10个元素，每个值都是1
      vector<int> v4{10, 1};            //v4有2个元素，分别是10 和 1

      vector<string> v5{"hi"};          //列表初始化，v5有一个元素
      vector<string> v6("hi");          //错误：不能使用字符串字面值构建vector对象
      vector<string> v7{10};            //v7有10个默认初始化的元素
      vector<string> v8{10, "hi"};      //v8有10个值为"hi"的元素


* `vector`对象上的操作

      v.empty()          //如果v为空则返回true，否则返回false
      v.size()           //返回值类型为vector<T>::size_type
      v.push_back(t)     //向v的尾端添加一个值为t的值
      v[n]               //返回v中第n个位置上元素的引用
      v1 = v2
      v1 = {a, b, c...}
      v1 == v2           //v1和v2相等当且仅当元素数量相同且对应位置的元素值都相同
      v1 != v2
      <, <=, >, >=       //以字典顺序进行比较


  C++标准要求`vector`应该能在运行时高效快速的添加元素。因此在定义`vector`对象的时候设定其大小就没有必要了，事实上如果这么做性能可能更差。
  通常都是先定义一个空的`vector`对象，然后在运行时向其中添加具体值。

  `vector`对象的下标运算符可以用于访问已经存在的元素，而不能用于添加元素。

* `vector`使用限制

  + 不能在范围`for`循环中向`vector`对象添加元素
  + 任何一种可能改变`vector`对象容量的操作（如`push_back`），都会使该`vector`对象的迭代器失效


###### 迭代器

> 除了`vector`之外，标准库还定义了其他几种容器（iterator）。所有标准库容器都可以使用迭代器，但是只有其中少数几种才同时支持下标运算符。
  `string`类型不属于容器，但是它支持很多与容器类似的操作，`string`类型也支持迭代器。
  类似于指针类型，迭代器也提供了对对象的间接访问。就迭代器而言，其对象为容器中的元素或者`string`对象中的字符。

* 迭代器类型

  拥有迭代器的标准库类型使用`iterator`和`const_iterator`来表示迭代器的类型
  
      vector<int>::iterator it;             //it能读写vector<int>的元素
      string::iterator it2;                 //it2能读写string对象中的字符

      vector<int>::const_iterator it3;      //it3只能读元素，不能写元素
      string::iterator it4;                 //it4只能读字符，不能写字符

  `const_iterator`和常量指针类似，能读取但是不能修改它所指向的元素值。相反，`iterator`的对象可读可写。如果`vector`对象或`string`对象是一个常量，只能使用`const_iterator`；如果`vector`对象或`string`对象不是常量，那么既能使用`iterator`也能使用`const_iterator`。

* 获取迭代器

  拥有迭代器的类型都有返回迭代器的成员函数。
  
      auto b = v.begin();
      auto e = v.end();

  begin方法返回指向第一个元素的迭代器，end方法返回指向容器“尾元素的下一位置”的迭代器，也就是说，该迭代器指示的是容器的一个本不存在的“尾后（off the end）”元素。

  > 如果容器为空，则begin和end返回的是同一个迭代器，都是尾后迭代器。

  begin和end返回的具体类型右对象是否是常量决定，如果对象是常量，begin和end返回`const_iterator`；如果对象不是常量，返回`iterator`。

      vector<int> v;
      const vector<int> cv;
      auto it1 = v.begin();        //it1的类型是vector<int>::iterator
      auto it2 = cv.beging();      //it2的类型是vector<int>::const_iterator

  C++11标准引入两个新函数，分别是`cbegin`和`cend`，无论`vector`对象本身是否是常量，返回值都是`const_iterator`。

* 标准容器迭代器的运算符

      *iter            //返回迭代器iter所指元素的引用
      iter->mem        //解引用iter并获取该元素的名为mem的成员，等价与(*iter).mem
      ++iter
      --iter
      iter1 == iter2   //两个迭代器指向的元素相同或者都是同一个容器的尾后迭代器，则返回true
      iter1 != iter2

  因为end操作返回的迭代器并不实际指向某个元素，所以不能对其进行递增或解引用操作。

* 迭代器运算

      iter + n
      iter - n
      iter += n
      iter -= n
      iter1 - iter2        //参与运算的两个迭代器必须属于同一个容器
      >, >=, <, <=         //参与运算的两个迭代器必须属于同一个容器

  迭代器距离指的是右侧迭代器向前移动多少位置就能追上左侧迭代器，其类型为`difference_type`的带符号整型。`string`和`vector`都定义了`difference_type`，因为这个距离可正可负，所以`difference_type`是带符号类型的。



###### 数组

* 数组与`vector`比较

  + 与`vector`相似的地方是，数组也是存放类型相同的对象的容器，这些对象本身没有名字，需要通过其所在位置访问。
  + 与`vector`不同的地方是，数组的带笑傲确定不变，不能随意向数组中增加元素。

  > 如果不清楚元素的确切个数，请使用`vector`

  + 虽然标准库类型`string`和`vector`也能执行下标运算，但是数组与它们相比还是有所不同。标准库限定使用的下标必须是无符号类型，而数组的下标运算没有这个要求。

      int ia[] = {0, 2, 4, 6, 8};
      int *p = &ia[2];            // p指向索引为2的元素
      int j = p[1];               // p[1]等价与*(p+1)，就是ia[3]表示的那个元素
      int k = p[-2];              // p[-2]是ia[0]表示的那个元素


* 数组初始化

  + 数组声明时，必须指定数组的大小，大小必须是常量或常量表达式。
  + 定义数组的时候必须指定数组的类型，不允许用`auto`关键字由编译器根据初始值的列表推断类型。
  + 使用列表初始化时，此时允许忽略数组的大小，编译器会根据初始值的数量计算并推测出来。相反，如果指定了数组大小，那么初始值的总数量不应该超过指定大小；如果指定大小比初始值数量大，则用提供的初始值初始化靠前的元素，剩下的元素被初始化成默认值。
  + 不能将数组的内容拷贝给其他数组作为其初始值，也不能用数组为其他数组赋值。

  > 要想理解数组声明的含义，最好的办法是从数组的名字开始按照由内向外的顺序阅读

      int *ptrs[10];                //ptrs是含有10个整型指针的数组
      int &refs[10] = ...;          //错误：不存在引用的数组
      int (*Parray)[10] = &arr;     //Parray是一个指针，指向一个含有10个整数的数组
      int (&arrRef)[10] = arr;      //arrRef是一个引用，引用一个含有10个整数的数组
      int *(&arry)[10] = ptrs;      //array是数组的引用，该数组是一个含有10个整型指针的数组

* 访问数组元素

  使用数组下标的时候，通常将其定义为`size_t`类型。该类型被定义为一种机器相关的无符号类型，它被设计得足够大以便能表示内存中任意对象的大小。在`cstddef`头文件中定义了`size_t`类型。

      string nums[] = {"one", "two", "three"};
      string *p = &nums[0];
      string *p2 = nums;       // 等价于p2 = &num[0]

      int ia[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
      auto ia2(ia);            // ia2是一个整型指针，指向ia的第一个元素。当使用数组作为一个auto变量的初始值时，推断得到的类型是指针而非数组
      decltype(ia) ia3 = {0, 1, 2, 3, 4};     //ia3是一个含有10个整数的数组

  C++11新标准中引入了连个名为`begin`和`end`的函数。这两个函数与容器中的两个同名成员函数功能类似。

      int ia[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
      int *beg = begin(ia);      //指向ia首元素的指针
      int *last = end(ia);       //指向ia尾元素的下一位置的指针
  
  两个指针相减的结果的类型是一种名为`ptrdiff_t`的标准库类型，和`size_t`一样，`ptrdiff_t`也是一种定义在`cstddef`头文件中的机器相关的类型。由于差值可能为负值，所以`ptrdiff_t`是一种带符号类型。

* 多维数组

  当程序使用多维数组的名字时，也会自动将其转换成指向数组首元素的指针。

      int ia[3][4];
      int (*p)[4] = ia;       // p指向含有4个整数的数组
      p = &ia[2];             // p指向ia的尾元素

  遍历多维数组

      int ia[3][4];
      //方法一
      for(size_t i = 0; i != 3; ++i) {
          for(size_t j = 0; j != 4; ++j) {
              ia[i][j] = i * 4 +j;
          }
      }
      
      //方法二,
      //使用范围for语句处理多维数组时，除了最内层的循环外，其他所有循环的控制变量都应该是引用类型
      //如果需要修改内容时，最内层的循环也要使用引用类型
      size_t cnt = 0;
      for(auto &row : ia) {
          for(auto &col : row) {
              col = cnt;
              cnt++;
          }
      } 
      

      //方法三
      for(auto p = ia; p != ia + 3; ++p) {
          for(auto q = *p; q != *p + 4; ++q) {
              cout << *q << " ";
          }
          cout << endl;
      }

      //方法四
      for(auto p = begin(ia); p != end(ia); ++p) {
          for(auto q = begin(*p); q != end(*p); ++q) {
              cout << *q << " ";
          }
          cout << endl;
      }


###### C++与C风格

> 尽管C++支持C风格字符串，但是C++程序中最好还是不要使用它们。这是因为C风格字符串不仅使用起来不方便，而且极易引发程序漏洞，是诸多安全问题的根本原因。
  现代的C++程序应该尽量使用`vector`和迭代器，避免使用内置数组和指针；应该尽量使用`string`，避免使用C风格的基于数组的字符串。






