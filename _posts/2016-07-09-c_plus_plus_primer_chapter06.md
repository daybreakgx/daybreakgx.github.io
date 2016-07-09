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


