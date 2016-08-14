---
layout: post
title: "C++ primer读书笔记（八）--- Containers "
categories: c++
tags: c++
---

* content
{:toc}

> 顺序容器(sequential container)为程序员提供了控制元素存储和访问顺序的能力。元素在顺序容器中的顺序与其加入容器时的位置相对应。

> 关联容器中元素的位置由元素相关联的关键字值决定。

> 所有容器类都共享公共的接口，不同容器按不同方式对其扩展。这个公共接口使容器的学习更加容易---基于某种容器所学习的内容也都适用于其他容器。每种容器都提供了不同的性能和功能的权衡。

##### 容器公共特性

###### 容器库概述

* 一般来说，每个容器都定义在一个头文件中，文件名与类型名相同。即，deque定义在头文件deque中，list定义在头文件list中，以此类推。

* 容器均定义为模板类。对大多数，但不是所有容器，还需要额外提供元素类型信息，如对于vector，必须提供额外信息来生成特定的容器类型:

      list<Sales_data>      // 保存Sales_data对象的list
      deque<double>         // 保存double的deque

* 可以在容器中保存几乎任何类型，但某些容器操作对元素类型有其自己的特殊要求，这时，定义的容器就无法执行这些容器操作。
  例如，顺序容器构造函数的一个版本接收容器大小参数，它使用了容器元素类型的默认构造函数。但某些类没有默认构造函数时，我们在构造这种元素类型的容器时，就不能使用该构造函数。

      // 假定 noDefault 是一个没有默认构造函数的类型
      vector<noDefault> v1(10, init);       // 正确:提供了元素初始化器
      vector<noDefault> v2(10);             // 错误:必须提供一个元素初始化器

###### 迭代器

* 与容器一样，迭代器有着公共的接口:
  如果一个迭代器提供某个操作，那么所有提供相同操作的迭代器对这个操作的实现方式都是相同的。例如，标准容器类型上的所有迭代器都允许我们访问容器中的元素，而所有迭代器都是通过解引用运算符来实现这个操作的。类似的，标准容器的所有迭代器都提供了递增运算符，从当前元素移动到下一元素。

* 标准容器迭代器的运算符

  *iter| 返回迭代器iter所指向元素的引用
  iter->mem | 解引用iter并获取该元素的名为mem的成员，等价于(*iter).mem
  ++iter | 令iter指向容器的下一个元素
  - -iter | 令iter指向容器的上一个元素
  iter1 == iter2 | 判断两个容器是否相等
  iter1 != iter2 | 判断两个容器是否不相等

  > 如果两个迭代器指示的是同一个元素或者是同一个容器的尾后迭代器，则相等；反之，不相等

  > **forward_list的迭代器不支持递减运算符(- -)**

  > 执行解引用的迭代器必须合法并确实指示着某个元素。试图解引用一个非法迭代器或者尾后迭代器都是未被定义的行为。

* 迭代器支持的算术运算

  |iter + n | 结果仍是一个迭代器，结果迭代器指示的位置与iter相比**向前移动**了n个元素。结果迭代器或者指示容器内的第一个元素，或者指示容器尾元素的下一位置|
  |iter - n | 结果仍是一个迭代器，结果迭代器指示的位置与iter相比**向后移动**了n个元素。结果迭代器或者指示容器内的第一个元素，或者指示容器尾元素的下一位置|
  |iter1 += n | 迭代器加法的复合赋值语句，将iter1加n的结果赋给iter1|
  |iter1 -= n | 迭代器减法的复合赋值语句，将iter1减n的结果赋给iter1|
  |iter1 - iter2 | 两个迭代器相减的结果是它们之间的距离。参与运算的两个迭代器必须指向的是同一个容器|
  |> >= < <= | 如果某个迭代器指向的容器位置在另一个迭代器所指向位置之前，则说前者小于后者。参与运算的两个迭代器必须指向的是同一个容器|

  > **上述的运算只能用于string、vector、deque和array的迭代器**。不能将它们用于其他任何容器类型的迭代器。

* 获取迭代器

  c.begin() | c.end() | 返回指向容器c的首元素和尾元素之后位置的迭代器
  c.cbegin() | c.cend() | 返回const_iterator
  c.rbegin() | c.rend() | 返回指向容器c的尾元素和首元素之前位置的迭代器
  c.crbegin() | c.crend() | 返回const_reverse_iterator

  > 反向迭代器不支持forward_list

  > 一个迭代器范围（iterator range）由一对迭代器表示，它是一个左闭合区间 [begin, end)，表示范围自begin开始，于end之前（不包括end）结束。
    其中begin和end必须满足下面两个条件:
    1)它们指向同一个容器中的元素，或者是容器最后一个元素之后的位置。
    2)end可以与begin指向相同的位置，但不能指向begin之前的位置，即可以通过反复递增begin来到达end

  > 因为end()操作返回的迭代器并不实际指向某个元素，所以不能对其进行递增或解引用操作。

  不以c开头的函数都是被重载过的。也就是说，实际上有两个名为begin/rbegin的成员。以c开头的版本是C++11新标准引入的，用于支持auto与begin和end函数的结合使用。

      // 显示指定类型
      list<string>::iterator it5 = a.begin();
      list<string>::const_iterator it6 = a.begin();

      // 是iterator还是const_iterator依赖与a的类型
      auto it7 = a.begin();   // 仅当a是const时，it7是const_iterator
      auto it8 = a.cbegin();  // it8是const_iterator

  当auto与begin或end结合使用时，获得的迭代器类型依赖于容器类型。但以c开头的版本还是可以获得const_iterator的，而不管容器的类型是什么。


###### 容器类型成员

* 类型成员信息见下表

    iterator | 此容器类型的迭代器类型 
    const_iterator | 可以读取元素，但不能修改元素的迭代器类型 
    size_type | 无符号整数类型，足够保存此种容器类型最大可能容器的大小
    difference_type | 带符号整数类型，足够保存两个迭代器之间的距离
    value_type | 元素类型
    reference | 元素的左值类型: 与value_type&含义相同
    const_reference | 元素的const左值类型（即 const value_type& )
    reverse_iterator | 按逆序寻址元素的迭代器
    const_reverse_iterator | 不能修改元素的逆序迭代器

    > 反向迭代器 **reverse_iterator 和 const_reverse_iterator 不支持forward_list**容器。它是一种反向遍历容器的迭代器，与正向迭代器相比，各种操作的含义都发生了颠倒。例如，对一个反向迭代器执行++操作，会得到上一个元素。

    > 通过value_type、reference和const_reference，可以在不了解容器中元素类型的情况下使用它。如果需要元素类型，可以使用容器的value_type。如果需要元素的一个引用，可以使用reference或const_reference。这些元素相关的类型别名在泛型编程中非常有用。

* 容器类型成员使用举例:

      list<string>::iterator iter;
      vector<int>::difference_type count;

###### 容器定义和初始化

* 容器定义和初始化操作
  
  操作 | 描述 | array容器附加要求
  C c; | 默认构造函数。| c中元素按默认方式初始化。
  C c1(c2) | c1初始化为c2的拷贝。c1和c2必须是相同类型 | 两个相同类型且相同大小 
  C c1 = c2 | 同上 | 同上
  C c{a,b,c...} | c初始化为初始化列表中的元素的拷贝。列表中元素类型必须与c的元素类型相容 | 列表中元素数目必须等于或小于array的大小，任何遗漏的元素都进行值初始化
  C c={a,b,c...} | 同上 | 同上
  C c(b,e) | c初始化为迭代器b和e指定范围中的元素拷贝。范围中元素的类型必须与C的元素类型相容 | array不支持 


   > 每个容器类型都定义了一个默认构造函数。除array之外，其他容器的默认构造函数都会创建一个指定类型的空容器。
  
   > 对于除array之外的容器，使用列表初始化方式进行初始化时，隐含的指定了容器的大小: 容器将包含与初始值一样多的元素。

   > c1 和 c2 必须是**相同类型容器**要求: 它们必须是相同的容器类型 且 保存的是相同的元素类型。

   > **元素类型相容**指，只要能将要拷贝的元素转换为要初始化的容器的元素类型即可。 


* 代码举例:

      // 每个容器有三个元素，用给定的初始化器进行初始化
      list<string> authors = {"Milton", "Shakespeare", "Austen"};
      vector<const char*> articles = {"a", "an", "the"};

      list<string> list2(authors);  // 正确: 类型匹配
      deque<string> deque1(authors); // 错误: 容器类型不匹配
      vector<string> vector1(articles); // 错误: 容器元素类型不匹配

      // 正确: 可以将const char* 转换为string
      forward_list<string> words(articles.begin(), articles.end());
      // 正确: 拷贝元素，直到(但不包括)it指向的元素 (假设it表示authors中的一个元素)
      deque<string> authList(authors.begin(), it);

      array<int, 32> a1;  // 类型为 保存32个int的数组
      array<string, 10> a2; // 类型为 保存10个string的数组
      array<int, 10>::size_type i; // 正确
      array<int>::size_type j; // 错误: array<int> 不是一个类型


###### 容器赋值和swap

* 操作列表

  操作 | 描述 | array附加情况
  c1 = c2 | 将c1中的元素替换为c2中元素的拷贝。c1和c2必须具有相同的类型| 无
  c = {a,b,c...} | 将c中元素替换为初始化列表中元素的拷贝 | 不支持
  swap(c1, c2) | c1和c2必须具有相同的类型。swap通常比从c2向c1拷贝元素快的多| 交换两个array所需时间与array中元素的数量成正比
  c1.swap(c2) |同上|同上


* 赋值运算符将其左边容器中的全部元素替换为右边容器中元素的拷贝。赋值相关运算会导致左边容器内部的迭代器、指针和引用失效。

* swap操作交换两个相同类型容器的内容。swap操作不会导致指向容器的迭代器、引用和指针失效（容器类型array和string的情况除外）。

  > 除array外，swap不会对任何元素进行拷贝、删除或插入操作，交换的两个容器内的元素本身并为交换，swap操作指示交换了两个容器的内部数据结构。
    而对于array容器，swap操作会真正交换它们的元素，因此，交换两个array容器所需时间与array中元素的数目成正比。

  > 除string和array外，指向容器的迭代器、引用和指针在swap操作后不会失效，。它们仍指向swap操作之前所指向的那些元素。但是，在swap之后，这些元素已经属于不同的容器了。
    对与string调用swap，会导致迭代器、引用和指针失效。
    对于array，在swap之后，指针、引用和迭代器所绑定的元素保持不变，但是元素值已经与另外一个array中对应元素的值进行了交换。

  > 在C++11新标准中，容器即提供了成员函数版本的swap，也提供了非成员函数版本的swap。
    而早期标准库只提供了成员函数版本。
    非成员版本的swap在泛型编程中是非常重要的，因此，统一使用非成员版本的swap是一个好习惯。

* 代码举例:

      c1 = c2;    // 将c1的内容替换为c2中元素的拷贝
      c1 = {1, 2, 3}; // 赋值后，c1大小为3

      array<int, 10> a1 = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}; 
      array<int, 10> a2 = {0};  // 所有元素都为0
      a1 = a2; // 替换a1中的元素
      a2 = {0}; // 错误: 不能将一个花括号列表赋予数组

      vector<string> sv1(10); 
      vector<string> sv2(20);
      vector<string>::iterator it1 = sv1.begin() + 3;  // it1 指向sv1[3]的string
      swap(sv1, sv2);  // it1 指向sv2[3]的元素


###### 容器关系运算

* 容器关系运算操作

  == != | 所有容器都支持相等（不相等）操作
  < <= > >= | 无序关联容器不支持

  > 关系运算符左右两边的运算对象必须是相同类型的容器，且必须保存相同类型的元素。

* 关系运算规则

  + 如果两个容器具有相同大小且所有元素都两两对应相等，则这两个容器相等；否则，两个容器不等。
  + 如果两个容器大小不同，但较小容器中每个元素都等于较大容器中的对应元素，则较小容器小于较大容器。
  + 如果两个容器都不是另外一个容器的前缀子序列，则它们的比较结果取决于第一个不相等的元素的比较结果。

* 容器的关系运算符使用元素的关系运算符完成比较

  只有当元素类型定义了相应的关系运算符时，我们才可以使用关系运算符来比较两个容器。

* 代码举例:

      vector<int> v1 = {1, 3, 5, 7, 9 12};
      vector<int> v2 = {1, 3, 9};
      vector<int> v3 = {1, 3, 5, 7};
      vector<int> v4 = {1, 3, 5, 7, 9, 12};

      v1 < v2; // true
      v1 < v3; // false
      v1 == v4; // true
      v1 == v2; // false

      vector<Sales_data> storA, storB;  // 假设Sales_data类中没有定义 < 运算符操作
      if(storA > storB) ...    // 错误操作


###### 容器大小

* 容器大小操作

  操作 | 描述 | 特殊说明
  c.size() | c中元素的数目 | forward_list不支持该操作
  c.max_size() | c可保存的最大元素数目|
  c.empty() | 若c中存储了元素，返回false，否则返回true| 
 


###### 容器添加/删除元素

* 相关操作

  c.insert(args) | 将args中的元素拷贝进c
  c.emplace(inits) | 使用inits参数构造c中的一个元素
  c.erase(args) | 删除args指定的元素
  c.clear() | 删除c中的所有元素，返回void

  > 这些操作不适用于array容器

  > 在不同的容器中，这些操作的接口都不同


##### 顺序容器

###### 顺序容器类型

* 下表列出了标准库中的顺序容器，所有顺序容器都提供了快速顺序访问元素的能力。但是这些容器在以下方面都有不同的性能折中。
  + 向容器中添加或从容器中删除元素的代价
  + 非顺序访问容器中元素的代价

  类型|描述|添加删除元素操作|元素访问方式|尾部插入删除元素|头部插入删除元素|其他位置插入删除元素
  array| 固定大小数组 | X | 快速随机访问| X | X | X
  vector| 可变大小数组 | 支持 | 快速随机访问 | 快速 | 可能很慢 | 可能很慢 
  string| 与vector类似的容器，专门用于保存字符 | 支持 | 快速随机访问 | 快速 | 可能很慢 | 可能很慢
  list| 双向链表 | 支持 | 双向顺序访问 | 快速 | 快速 | 快速
  forward_list| 单向链表 | 支持 | 单向顺序访问 | 快速 | 快速 | 快速
  deque| 双端队列 | 支持 | 快速随机访问 | 快速 | 快速 | 可能很慢

  > 现代C++程序应该使用标准库容器，而不是更原始的数据结构，如内置数组。

* 顺序容器选择原则
  + 除非你有很好的理由选择其他容器，否则应使用vector。
  + 如果你的程序有很多小的元素，且空间的额外开销很重要，则不要使用list或forward_list。
  + 如果程序要求随机访问元素，应使用vector或deque。
  + 如果程序要求在容器的中间位置插入或删除元素，应使用list或forward_list。
  + 如果程序要求在头尾位置插入或删除元素，但不会在中间位置进行插入或删除操作，则使用deque。
  + 如果程序只有在读取输入时才需要在容器的中间位置插入元素，随后需要随机访问元素
    - 首先，确认是否真的需要在容器中间插入元素。当处理输入数据时，通常可以很容易的向vector追加数据，然后调用标准库的sort函数来重排容器中的元素，从而避免在中间位置添加元素。
    - 如果必须在中间位置插入元素，考虑在输入时使用list，一旦输入完成，将list中的内容拷贝到一个vector中。

  > 如果程序中既需要随机访问元素，又要在容器中间位置插入元素，容器选择取决于 在list或forward_list中访问元素与vector或deque中插入/删除元素的相对性能。一般来说，应用中占主导地位的操作决定了容器类型的选择。在此情况下，对两种容器分别测试应用性能可能就是必须的了。

  > 如果不确定使用哪种容器，可以在程序中只使用vector和list公共的操作：使用迭代器，不使用下标操作，避免随机访问。这样，在必要时选择使用vector或list都很方便。



###### 与顺序容器大小相关的构造函数

* 除了与关联容器相同的构造函数外，顺序容器(array除外)还提供另一个构造函数，它接受一个容器大小和一个（可选的）元素初始值。

  C seq(n) | seq 包含n个元素，这些元素进行了值初始化；此构造函数是explicit的。 | array不支持
  C seq(n, t) | seq 包含n个初始化为值t的元素 | array不支持

      vector<int> ivec(10, -1);       // 10个int元素，每个都初始化为-1
      list<string> svec( 10, "hi");   // 10个string元素，每个都初始化为"hi"
      forward_list<int> ivec(10);     // 10个int元素，每个都初始化为0
      deque<string> svec(10);         // 10个元素，每个都是空string

* 如果容器中的元素是内置类型或者是具有默认构造函数的类类型，可以只为构造函数提供一个容器大小参数；如果元素是没有默认构造函数的类类型，除了大小参数外，还必须指定一个显示的元素初始值。

* 只有顺序容器的构造函数才接受大小参数，关联容器并不支持。

###### array容器构造与初始化说明

* 与内置数组一样，标准库array的大小也是类型的一部分。当定义一个array时，必须同时指定元素类型和容器大小。

* 默认构造的array是非空的: 它包含了与其大小一样多的元素。 这些元素都被默认初始化。

* 对array进行列表初始化时，初始值的数目必须小于等于array容器的大小。如果初始值数目小于array的大小，则后面剩余的元素都会进行默认初始化。

* 不能对内置数组类型进行拷贝或对象赋值操作，但是可以对array进行，要求两者必须容器类型、元素类型和容器大小都一致。

      array<int, 10> ia1;            // 10个默认初始化的int
      array<int, 10> ia2 = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}; // 列表初始化
      array<int, 10> ia3 = {3};      // ia3[0]为3，剩余元素为0

      int digs[3] = {0, 1, 2};
      int cpy[3] = digs;           // 错误: 内置数组不支持拷贝或赋值
      array<int, 3> digits = {0, 1 2};
      array<int, 3> copy = digits;  // 正确: 只要数组类型和大小匹配就合法

###### 使用assign(仅使用于除array之外的顺序容器)

  seq.assign(b, e)  | 将seq中的元素替换为迭代器b和e所表示范围中的元素。迭代器b和e不能指向seq中的元素
  seq.assign(il) | 将seq中的元素替换为初始化列表il中的元素
  seq.assign(n, t) | 将seq中的元素替换为n个值为t的元素

* 赋值运算符要求两边的运算对象具有相同的类型。顺序容器（除array外）还定义了一个名为assign的成员，允许我们从一个不同但相容的类型赋值，或从容器的一个子序列赋值。

* assign操作用参数所指定的元素的拷贝替换左边容器中的所有元素。

      list<string> names;
      vector<const char*> oldstyle;
      names = oldstyle;  // 错误: 容器类型不匹配
      // 正确: 可以将const char* 转换为string
      names.assign(oldstyle.cbegin(), oldstyle.cend()); 
      
      list<string> slist1(1);    //1个元素，为空string
      slist1.assign(10, "Hiya"); //10个元素，每个都是"Hiya"
 

###### 向顺序容器中添加元素

* 除array外，所有标准库容器都提供灵活的内存管理。在运行时可以动态添加或删除元素来改变容器大小
  下面列出的是顺序容器(除array外)的添加元素的操作。

  操作| 说明 | array | vector | string | deque| list| forward_list
  c.push_back(t) | 在c的尾部创建一个值为t的元素。返回void | X | 支持 | 支持|支持|支持|X
  c.emplace_back(args) | 在c的尾部创建一个由args创建的元素。返回void | X | 支持 | 支持| 支持|支持|X
  c.push_front(t)|在c的头部创建一个值为t的元素。返回void | X | X | X| 支持|支持|支持
  c.emplace_front(args)|在c的头部创建一个由args创建的元素。返回void| X|X|X|支持|支持|支持
  c.insert(p, t)|在迭代器p指向的元素之前创建一个值为t的元素。返回指向新添加的元素的迭代器 | X | 支持|支持|支持|支持|专有版本
  c.emplace(p, args)|同上| X | 支持|支持|支持|支持|专有版本
  c.insert(p, n, t)|插入n个值为t的元素。返回指向新添加的第一个元素的迭代器，如果n为0，则返回p| X |支持|支持|支持|支持|专有版本
  c.insert(p, b, e)|插入迭代器b和e指定范围内的元素。b和e不能指向c中的元素。返回指向新添加的第一个元素的迭代器，如果范围为空，则返回p | X |支持|支持|支持|支持|专有版本
  c.insert(p, il) | 插入一个花括号包围的元素值列表。返回指向新添加的第一个元素的迭代器，如果列表为空，返回p | X |支持|支持|支持|支持|专有版本

  > 向一个vector/string或deque插入元素会是所有指向容器的迭代器、指针和引用失效。

  > 当使用这些操作时，不同容器使用不同的策略来分配元素空间，而这些策略直接影响性能。
    在一个vector或string的尾部之外的任何位置添加元素都需要移动元素。而且还有可能引起整个对象存储空间的重新分配，导致所有元素的移动。
    在一个deque的首尾之外的位置添加元素，都需要移动元素。
    
  > 当我们用一个对象初始化容器时，或者将一个对象插入到容器中时，实际上放入到容器中的是对象值的一个拷贝，而不是对象本身。

  > 虽然vector和string容器不支持push_front操作，但是可以通过insert操作实现与push_front相同的功能。

        vector<string> svec;
        list<string> slist;
        
        // 等价与调用slist.push_front("hello");
        slist.insert(slist.begin(), "hello");

        // vector不支持push_front，但可以插入到begin()之前
        // 警告: 插入到vector末尾之外的任何位置都可能很慢
        svec.insert(svec.begin(), "hello");

        // 将10个元素"anna"插入到svec的末尾
        svec.insert(svec.end(), 10, "anna");

        vector<string> v = {"abc", "bcd", "cde", "def"};
        // 将v的最后两个元素添加到slist的开始位置
        slist.insert(slist.begin(), v.end() - 2, v.end());
        slist.insert(slist.end(), {"123", "234", "256"});

        // 运行时错误: 迭代器表示要拷贝的范围，不能指向与目的位置相同的容器
        slist.insert(slist.begin(), slist.begin(), slist.end());

   > 在C++11新标准下，接受元素个数或范围的insert版本返回指向第一个新加入元素的迭代器。在旧版本中，这些操作返回void。
     如果范围为空，不插入任何元素，insert操作会将第一个参数返回。

   > C++11新标准引入了三个新成员---emplace、emplace_front和emplace_back，这些操作构造而不是拷贝元素。
     emplace函数的参数根据元素类型而变化，参数必须与元素类型的构造函数相匹配。

        // 在c的末尾构造一个Sales_data对象
        // 使用三个参数的Sales_data构造函数
        c.emplace_back("isbn001", 20, 19.99);
        // 错误: 没有接收三个参数的push_back版本
        c.push_back("isbn002", 20, 12.00);
        // 正确: 创建一个临时的Sales_data对象传递给push_back
        c.push_back(Sales_data("isbn_003", 20, 22);

        // iter指向c中一个元素，其中保存了Sales_data元素
        c.emplace_back(); // 使用Sales_data的默认构造函数
        c.emplace(iter, "isbn001"); // 使用Sales_data(string)构造函数
        c.emplace_front("isbn002", 10, 23);

###### 顺序容器访问元素

* 访问元素操作列表

  操作 | 说明| array| vector| string| deque| list| forward_list
  c.back() | 返回ｃ中尾元素的引用，如ｃ为空，函数行为未定义| 支持|支持| 支持| 支持| 支持| X
  c.front() | 返回ｃ中首元素的引用，如果ｃ为空，函数行为未定义|支持|支持|支持|支持|支持|支持
  c[n] | 返回ｃ中下标为ｎ的元素的引用，ｎ是一个无符号整数，如果n>c.size(), 则函数行为未定义 |支持|支持|支持|支持|支持|支持
  c.at(n) | 返回下标为ｎ的元素的引用。如果下标越界，则抛出out_of_range异常|支持|支持|支持|支持|X|X

  > 对一个空容器调用frong和back，就像使用一个越界的下标一样，是一种严重的程序设计错误。

  > 在解引用一个迭代器或调用front或back之前检查是否有元素

      if(!c.empty()) {
          // val 和 val2 是c中第一个元素值的拷贝
          auto val = *c.begin(), val2 = c.front();
          // val3 和 val4 是c中最后一个元素的拷贝
          auto last = c.end();
          auto val3 = *(--last); // 不能递减forward_list迭代器
          auto val4 = c.back(); // forward_list不支持
      }


* 访问成员函数返回的是引用

  front、back、下标和at返回的都是引用。如果容器是一个const对象，则返回值是const的引用，如果容器不是const的，则返回的是普通引用，我们可以用来修改元素的值。

      if(!c.empty()) {
          c.front() = 42;  // 将42赋给c中的第一个元素
          auto& v = c.back();  // 获得指向最后一个元素的引用
          v = 1024;  // 改变c中最后一个元素的值
          auto v2 = c.back();   // v2不是一个引用，它是c.back()的一个拷贝
          v2 = 0;    // 为改变c中的值
      }

* 保证下标有效是程序员的责任，下标运算符不检查下标是否在合法范围内。使用越界的下标是一种严重的程序设计错误，而且编译器不能检查出这种错误。

###### 删除元素

* 删除元素操作（array不支持）

  操作|说明|array|vector|string|deque|list|forward_list
  c.pop_back()|删除c中尾元素。若c为空，函数行为未定义。返回void|X|支持|支持|支持|支持|X
  c.pop_front()|删除c中首元素。若c为空，函数行为未定义。返回void|X|X|X|支持|支持|支持
  c.erase(p)|删除迭代器p所指定元素，返回被删元素之后元素的迭代器，若p指向尾元素，则返回尾后迭代器。若p是尾后迭代器，函数行为未定义|X|支持|支持|支持|支持|专有版本
  c.erase(b, e) |删除迭代器b和e指定范围内的元素。返回e后面的一个迭代器，如果e本身是尾后迭代器，则返回e | X|支持|支持|支持|支持|专有版本
  c.clear() |删除c中所有元素 |X|支持|支持|支持|支持|支持

  > 删除deque中除首尾位置之外的任何元素都会使所有迭代器、引用和指针失效。

  > 指向vector或string中删除点之后位置的迭代器、引用和指针都会失效。

  > 删除元素的成员函数并不检查其参数。在删除元素之前，程序员必须确保它们是存在的。

* pop_back() 和pop_front() 的返回void。如果你需要弹出的元素的值，必须在执行弹出之前保存它。

      while(!ilist.empty()) {
         process(ilist.front()); // 对ilist的首元素进行处理
         ilist.pop_front();    // 完成处理后删除首元素
      }

      list<int> lst = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
      auto it = lst.begin();
      while(it != lst.end()) {
         if(*it % 2 != 0)
             it = it.erase(it);
         else
             ++it;
      }

###### forward_list 专有版本的插入删除操作

* 由于forward_list是单向链表，在其中删除或插入一个元素时，需要改变该元素的前驱节点的next链接。在一个单向链表中，没有简单的方法来获取一个元素的前驱。
  所以，在一个forward_list中添加或删除元素的操作是通过改变给定元素之后的元素来实现的。这种实现的效果与其他顺序容器的添加或删除操作的效果是不同的。
  因此，forward_list并未定义insert、emplace和erase，而是定义了名为insert_after、emplace_after和erase_after的操作。

  lst.before_begin() | 返回指向链表首元素之前不存在元素的迭代器。此迭代器不能解引用
  lst.cbefore_begin() | 同上，返回一个const_iterator
  lst.insert_after(p, t) | 在迭代器p之后位置插入元素
  lst.insert_after(p, n, t)|t是对象，n是数量
  lst.insert_after(p, b, e) | b和e是表示范围的一对迭代器（b和e不能指向lst内）
  lst.insert_after(p, il) | il是一个花括号列表。返回指向最后一个插入元素的迭代器，若范围为空，则返回p。若p是尾后迭代器，则函数行为未定义
  lst.emplace_after(p, args) | 使用args在p之后创建一个元素。返回指向新元素的迭代器，若p为尾后迭代器，则函数行为未定义
  lst.erase_after(p) | 删除p之后的元素，返回指向被删除之后元素的迭代器，若不存在这样的元素，则返回尾后迭代器。如果p指向尾元素或尾后元素，则函数行为未定义
  lst.erase_after(b, e) | 删除b之后知道（但不包含）e之间的元素。

      forward_list<int> flst = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
      auto prev = flst.before_begin();
      auto curr = flst.begin();
      while(curr != flst.end()) {
          if(*curr % 2) {
              curr = flst.erase_after(prev); 
          } else {
              prev = curr; 
              ++curr;
          }
      }

###### 改变容器的大小

* 这类操作不适用与array

  c.resize(n) | 调整c的大小为n个元素。如果n<c.size()，则多出的元素被丢弃。若必须添加新元素，对新元素进行值初始化
  c.resize(n, t) | 任何新添加的元素初始值为t

* 如果resize缩小容器，则指向被删除元素的迭代器、引用和指针都会失效。

* 对vector、string或deque进行resize可能导致迭代器、指针和引用失效。

* 如果容器当前大小 小于 新大小，会将新元素添加到容器后面。

###### 容器操作可能导致迭代器失效

* 向容器中添加或删除元素的操作可能会使指向容器元素的指针、引用或迭代器失效。一个失效的指针、引用和迭代器不再表示任何元素。使用失效的指针、引用或迭代器是一种严重的程序设计错误，很可能引起与使用未初始化指针一样的问题。

  添加元素场景:

    + vector或string容器，且存储空间被重新分配，则指向容器的迭代器、引用和迭代器都会失效。
      如果存储空间没有重新分配，指向插入位置之前的迭代器、引用和指针仍有效，但指向插入位置之后的迭代器、引用和指针都会失效。

    + 对于deque，插入到除首尾位置之外的任何位置都会导致迭代器、指针和引用失效。
      如果在首尾位置插入，迭代器会失效，但指向存在的元素的引用和指针不会失效。

    + 对于list和forward_list，指向容器的迭代器、引用和指针不会失效。

  删除元素场景:

    + 所有容器，指向被少年出元素的迭代器、引用和指针都会失效。

    + 对于list和forward_list，执行容器其他位置的迭代器、引用和指针不会失效。

    + 对于deque，如果在首尾位置之外的地方删除元素，那么其他位置的迭代器、引用和指针也会失效；
      如果删除的是尾元素，则尾后迭代器也会失效, 其他迭代器、引用和指针不会失效。
      如果删除的是首元素，其他迭代器、引用和指针不会失效。

    + 对于vector和string，指向被删元素之前的迭代器、引用和指针仍有效。

  > 由于向迭代器添加或删除元素可能会导致迭代器失效，因此必须保证每次改变容器的操作之后都正确的重新定位迭代器，这个建议对vector、string和deque尤为重要。

  > 不要保存end()返回的迭代器

  
###### vector对象是如何增长的

* 为了支持快速随机访问，vector将元素连续存储---每个元素紧挨着前一个元素存储。为了减少容器空间重新分配次数，当不得不获取新的内存空间时，vector和string的实现通常会分配比新的空间需求更大的内存空间。容器预留这些空间作为备用，可以用于保存更多的新元素。

* 理解capacity和size的区别很重要。容器的size指它一ing保存的元素的数目；而capacity则是在不分配新的内存空间的前提下它最多可以保存多少元素。

* 管理容量的成员函数

  操作|描述|array|vector|string|deque|list|forward_list
  c.shrink_to_fit()|将capacity()减少为与size()相同大小| X | 支持|支持|支持|X|X
  c.capacity()| 不重新分配内存空间的话，c可以保存多少内存| X|支持|支持|X|X|X
  c.reserve(n)| 分配至少能容纳n个元素的内存空间| X|支持|支持|X|X|X

* 只有当需要的内存空间超过当前容量时，reserve调用才会改变vector的容量。
   
  + 如果需求大小大于当前容量(capacity)，reserve至少分配与需求一样大的空间(可能更大).
  + 如果需求大小小于或等于当前容量，reserve什么都不做。容器不会退回内存空间。

  > 调用reserve用于不会减少容器占用的内存空间。类似的，resize成员函数只改变容器中元素的数目，而不是容器的容量。

  > 在C++11新标准中，可以调用shrink_to_fit()来要求deque、vector或string退回不需要的空间。但是具体的实现可以选择忽略此请求。也就是说，调用shrink_to_fit也并不保证一定退回内存空间。

* 每个vector实现都可以选择自己的内存分配策略。但是必须遵循一条原则: 只有当迫不得已时才可以分配新的内存空间。

###### 额外的string操作

* 构造string的其他方法

  下表中的n、len2和pos2都是无符号值
  string s(cp, n) | s是cp指向的数组中前n个字符的拷贝。此数组至少应包含n个字符
  string s(s2, pos2)| s是string s2从下标pos2开始的字符的拷贝。若pos2 > s2.size()，构造函数的行为未定义
  string s(s2, pos2, len2) | s是string s2从下标pos2开始len2个字符的拷贝。若pos2 > s2.size()，构造函数行为未定义，不管len2是多少，构造函数至多拷贝s2.size() - pos2个字符。

      const char* cp = "Hello World!!!"; // 以空字符结尾的数组
      char noNull[] = ['H', 'i'];    // 不是以空字符结尾的数组
      string s1(cp);        // 拷贝cp中的字符直到遇到空字符;s1="Hello World!!!"
      string s2(noNull, 2); // 拷贝noNull中的前两个字符;s2="Hi"
      string s3(noNull);    // 未定义:noNull不是以空字符结尾
      string s4(cp+6, 5);   // 从cp[6]开始拷贝5个字符 s4="World"
      string s5(s1, 6, 5);  // 从s1[6]开始拷贝5个字符 s5="World"
      string s6(s1, 6);     // 从s1[6]开始知道s1末尾  s6="World!!!"
      string s7(s1, 6, 20); // 正确，只拷贝到s1末尾  s7="World!!!"
      string s8(s1, 16);    // 错误，抛出out_of_range异常


* substr操作

  substr操作返回一个string，他是原始string的一部分或全部的拷贝。可以传递给substr一个可选的开始位置和计数值:
  
  s.substr(pos, n); | 返回一个string，包含s中pos开始的那个字符的拷贝。pos的默认值为0。n的默认值为s.size()-pos，即拷贝从pos开始的所有字符

      string s("hello world");
      string s2 = s.substr(0, 5);   // s2 = hello
      string s3 = s.substr(6);      // s3 = world
      string s4 = s.substr(6, 11);  // s4 = world
      string s5 = s.substr(12);     // 抛出一个out_of_range异常

* 改变string的其他方法

  s.insert(pos, args) | 在pos之前插入args指定的字符。pos可以是一个下标或迭代器，如果是下标，返回一个指向s的引用；如果是迭代器，返回指向第一个插入字符的迭代器
  s.erase(pos, len) | 删除从pos位置开始的len个字符。如果len被省略，则删除从pos开始直到末尾的所有字符。返回一个指向s的引用
  s.assign(args) | 将s中的字符替换为args指定的字符。返回一个指向s的引用
  s.append(args) | 将args追加到s。返回一个指向s的引用
  s.replace(range, args) | 删除s中范围range内的字符，替换为 args指定的字符。range或者是一个下标加一个长度，或者是一对指向s的迭代器范围。返回一个指向s的引用

  args可以是下列形式之一，str不能与s相同，迭代器b和e不能指向s。

  arg| 说明 | append|assign| replace(pos, len, args) | replace(b,e,args) |insert(pos,args)|insert(iter, args)
  str| 字符串str | 支持|支持|支持|支持|支持|X
  str,pos,len| str中从pos开始最多len个字符|支持|支持|支持|X|支持|X
  cp,len|从cp指向的字符数组的前(最多)len个字符|支持|支持|支持|支持|支持|X
  cp|cp指向的以空字符结尾的字符数组|支持|支持|支持|支持|X|X
  n,c| n个字符c |支持|支持|支持|支持|支持|支持
  b2,e2| 迭代器范围|支持|支持|X|支持|X|支持
  初始化列表| 花括号包围的，以逗号分割的字符列表|支持|支持|X|支持|X|支持

* string搜索操作

  string类提供了6个不同的搜索函数，每个函数都有4个重载版本
  每个搜索函数都返回string::size_type值，表示匹配发生位置的下标。如果搜索失败，则返回一个名为string::npos的static成员。标准库将npos定义为const string::size_type类型。

  s.find(args)|查找s中args第一次出现的位置
  s.rfind(args)|查找s中args最后一次出现的位置
  s.find_first_of(args)| 在s中查找args中任意一个字符第一次出现的位置
  s.find_last_of(args) | 在s中查找args中任意一个字符最后一次出现的位置
  s.find_first_not_of(args) | 在s中查找第一个不在args中的字符
  s.find_last_not_of(args) |在s中查找最后一个不在args中的字符

  args必须是以下形式之一
 
  c,pos | 从s中位置pos开始查找字符c。pos默认为0
  s2,pos | 从s中位置pos开始查找字符串s2。pos默认为0
  cp,pos | 从s中位置pos开始查找指针cp指向的以空字符结尾的C风格字符串。pos默认为0
  cp,pos,n|从s中位置pos开始查找指针cp指向的数组的前n个字符。pos和n无默认值

  > 搜索是大小写敏感的

* compare函数
 
  除了关系运算符外，标准库string还提供了一组compare函数，根据s是等于、大于还是小于参数指定的字符串，s.compare返回0、正数或负数。

  s.compare的几种参数形式

  s2 | 比较s和s2
  pos1,n1,s2 | 将s中从pos1开始的n1个字符与s2比较
  pos1,n1,s2,pos2,n2| 将s从pos1开始的n1个字符与s2中从pos2开始的n2个字符进行比较
  cp | 比较s与cp指向的以空字符结尾的字符数组
  pos1,n1,cp| 将s中从pos1开始的n1个字符与cp指向的以空字符结尾的字符数组进行比较
  pos1,n1,cp,n2 | 将s中从pos1开始的n1个字符与cp指向的前n2个字符进行比较

* 数值转换

  to_string(val) | 一组重载函数，返回数值val的string表示。val可以是任何算术类型。对每个浮点类型和int或更大的整型都有相应版本的to_string。与往常一样，小整型会被提升
  stoi(s,p,b) | 返回s的起始字串(表示整数内容)的数值，返回类型为int
  stol(s,p,b) | 返回long, b表示转换所用的基数，默认是10
  stoul(s,p,b) |unsigned long, p是size_t的指针，用于保存s中第一个非数字字符的下标，默认为0，即函数不保存下标信息
  stoll(s,p,b) |long long
  stoull(s,p,b) | unsigned long long
  stof(s,p) | 返回s的起始字串（表示浮点数内容）的数字，返回float，p的作用与前面一致
  stod(s,p) | 返回值double
  stold(s,p) |返回值long double

  > 如果string不能转换成数值，这些函数会抛出一个invalid_argument异常
  
  > 如果转换得到的数值无法用任何类型来表示，则抛出一个out_of_range异常

###### 容器适配器

* 标准库定义了三个顺序容器的适配器: stack, queue 和  priority_queue。
  适配器是标准库中的一个通用概念。本质上，一个适配器是一种机制，能使某种事物的行为看起来像另外一种事物一样。

  一个容器适配器接受一种已有的容器类型，使其行为看起来向一种不同的类型。

* 所有容器适配器都支持的操作和类型

  size_type | 一种类型，足以保存当前类型的最大对象的大小
  value_type | 元素类型
  container_type | 实现适配器的底层容器类型
  A a; | 创建一个名为a的空适配器
  A a(c); |创建一个名为a的适配器，带有容器c的一个拷贝
  关系运算符| 支持 == != < <= > >= ,这些运算符返回底层容器的比较结果
  a.empty()| 若a包含任何元素，返回false，否则返回true
  a.size()| 返回a中的元素数目
  swap(a,b) | 交换a和b的内容，a和b必须相同的类型，且底层容器类型也必须相同
  a.swap(b)| 同上

  适配器对应的底层容器

  适配器 |  vector | deque | list
  stack | 支持 | 默认实现 | 支持
  queue | X | 默认实现 | 支持
  priority_queue | 默认实现 | 支持 | X

  > stack默认是基于deque实现的。stack只要求push_back、pop_back和back操作，因此可以使用除array和forward_list之外的所有容器实现。
  
  > queue默认也是基于deque实现的，它要求back、push_back、front和push_front操作，因此它可以构筑与list或deque之上。但不能基于vector构造。

  > priority_queue处了front、push_back和pop_back操作之外还要求随机访问能力，因此它可以构造与vector或deque之上。但不能基于list构造。

* stack适配器支持的特有操作

  s.pop() | 删除栈顶元素，但不返回该元素值
  s.push(item) | 创建一个新元素压栈，该元素通过拷贝或移动item而来
  s.emplace(args) | 创建一个新元素压栈，该元素由args构造
  s.top() | 返回栈顶元素，但不将元素弹出

      deque<int> deq = {1, 2, 3};
      stack<int> stk(deq);   // 从deq拷贝元素到stk  
      
      // 在vector上实现栈
      stack<int, vector<int>> stk;

  > stack默认是基于deque实现的。stack只要求push_back、pop_back和back操作，因此可以使用除array和forward_list之外的所有容器实现。

  > stack类型定义在stack头文件中。

* 队列适配器独有操作

  q.pop() | 返回queue的首元素或priority_queue的最高优先级的元素，但不删除此元素
  q.front() | 返回首元素，但不删除此元素，只适用于queue
  q.back() | 返回尾元素，但不删除此元素，只适用于queue 
  q.top() | 返回最高优先级元素，但不删除此元素，只适用于priority_queue
  q.push(item) | 在queue末尾或priority_queue中恰当位置创建一个元素
  q.emplace(args) | 同上

  > queue 和priority_queue适配器定义在queue头文件中。
 



