---
layout: post
title: "C++ primer 读书笔记（一）--- 变量和数据类型"
categories: c++
tags: c++
---

* content
{:toc}

> 默认环境: **Ubuntu 16.04** + **gcc 5.3.1** + **intel x86_64**

##### 变量和基本类型

* 字符型被分成了三种: `char`/`signed char`/`unsigned char`。尽管字符型有三种，但是字符的表现形式却只有两种: 带符号和无符号的。类型`char`具体表现为上述两种形式的哪一个，是由编译器决定的。
  因为类型`char`在一些机器上是有符号的，在另外一些机器上又是无符号的，所以如果使用`char`进行算数运算特别容易出问题，如果需要使用一个不大的整数时，那么明确指定它的类型是`signed char`或`unsigned char`。

* 执行浮点运算时通常使用`double`，这是因为`float`通常精度不够而且双精度浮点数和单精度浮点数的计算代价相差无几。事实上，对于某些机器来说，双精度运算甚至比单精度运算还快。

* C++ 算术类型

  类型|含义|最小尺寸
  ---|---|---
  bool|布尔类型|未定义
  char|字符|8位
  wchar_t|宽字符|16位
  char16_t|Unicode字符|16位
  char32_t|Unicode字符|32位
  short|短整型|16位
  int|整型|16位
  long|长整型|32位
  long long|长整型|64位
  float|单精度浮点数|6位有效位
  double|双精度浮点数|10位有效位
  long double|扩展精度浮点数|10位有效位

  C++语言规定，`int`类型的大小要 >= `short`，`long`类型大小 >= `int`，`long long`类型大小 >= `long`。

  ![sizeof type](/image/sizeof_type.png)

##### 强制类型转换

###### 一些基本规则

* 把一个浮点数赋给整数类型时，仅保留浮点数中小数点之前的部分。

* 把一个整数赋给浮点数类型时，小数部分记为0。如果该整数所占的空间超过了浮点类型的容量，精度可能有损失。

* 赋给无符号整数类型一个超出它表示范围的值时，结果是初始值对无符号类型表示数值总个数取模后的余数(从二进制上看，相当于将前面超出表示范围的位都丢掉)。 

* 赋给有符号整数类型一个超出它表示范围的值时，结果时未定义的（undefined）。程序可能继续工作，可能崩溃，也可能生成垃圾数据。

      int i = 3.14;             //i的值为3
      double pi = 3;            //pi的值为3.0
      unsigned char c = -1;     //假设char占8bits，c的值为255

      //编译时会告警，c的值为66，因为unsigned char能表示的数值为0~255,有256个，322 % 256 = 66
      //322 用二进制表示为0000 0001 0100 0010 = 0x0142
      //inter 采用小端模式存储数据，0x42保存在低地址
      //unsigned char能表示的有效位只有8bits，所以只有低8位是有效数据，c的值为0x42,即66
      c = 322;

      signed char c2 = 322;     //假设char占8bits, c2的值是未定义的,gcc 输出结果为66

* 当一个算术表达式中既有无符号数又有int值时，那个int值会转换为无符号数，编程时要尽量避免这种情况发生。因为带符号数为负数时，可能会出现不是我们所期望的结果,把负数转换成无符号数时，会将该负数按照无符号数的规则去解析，出现符号位的反转。

###### 隐式强制类型转换发生条件

+ 在大多数表达式中，比`int`类型小的整型值首先提升为较大的整数类型
+ 在条件表达式中，非布尔值转换成布尔类型
+ 初始化过程中，初始值转换成变量的类型；在赋值语句中，右侧运算对象转换成左侧运算对象的类型
+ 如果算术运算或关系运算的运算对象有多种类型，需要转换成同一种类型
+ 函数调用时也会发生类型转换

> 算术类型之间的隐式转换被设计得尽可能避免损失精度。很多时候，如果表达式中既有整数类型的运算对象也有浮点数类型的运算对象，整型会转换成浮点数。
  例如，下面的表达式:   
      int ival = 3.541 + 3;  
  表达式中的3首先转换成double类型，然后执行浮点数加法，所得结果的类型是double。接下来就是完成初始化的任务了，在初始化时，因为被初始化的对象的类型无法改变，所以初始值被转换成该对象的类型，即double类型的结果被转换成int类型的值。

###### 隐式转换之算术转换
* 算术转换的含义是把一种算术类型转换成另外一种算术类型。
  算术转换的规则定义了一套类型转换的层次，其中运算符的运算对象将转换成最宽的类型。例如，如果一个运算对象的类型是`long double`，那么不论另外一个运算对象的类型是什么都会转换成`long double`。
  还有一种更普遍的情况，当表达式中既有浮点类型也有整数类型时，整数值将转换成相应的浮点类型。

* 整型提升

  整型提升负责把小整数类型转换成较大的整数类型。对于`bool`、`char`、`signed char`、`unsigned char`、`short`和`unsigned short`等类型来说，只要他们所有的可能值都能存在`int`里，它们就会提升成`int`类型；否则提升成`unsigned int`类型。
  较大的`char`类型（`wchar_t`、`char16_t`、`char32_t`）提升成`int`、`unsigned int`、`long`、`unsigned long`、`long long`和`unsigned long long`中最小的一种类型，前提是转换后的类型要能容纳原类型所有可能的值。

* 无符号类型的运算对象

  如果某个运算符的运算对象类型不一致，这些运算对象将转换成同一种类型。但是如果某个运算对象的类型是无符号类型，那么转换的结果就要依赖于机器中各个整数类型的相对大小了。

  - 首先进行整型提升。
 
    + 如果结果的类型匹配，无须进行进一步的转换。两个（提升后的）运算对象的类型要么都是带符号的、要么都是无符号的，则小类型的运算对象转换成较大类型。
    + 如果一个运算对象是无符号类型，另外一个运算对象是带符号类型。 
      - 无符号类型不小于带符号类型，那么带符号的运算对象转换成无符号的。例如，假设两个类型分别是`unsigned int` 和 `int`，则`int`类型的运算对象转换成`unsigned int`类型。需要注意的是，如果`int`类型的值恰好为负值，可能会出现不是我们所期望的结果（符号位反转）。
      - 带符号类型大于无符号类型，此时转换的结果依赖于机器。
        + 如果无符号类型的所有值都能存在该带符号类型中，则无符号类型的运算对象转换成带符号类型。
        + 如果不能，那么带符号类型的运算对象转换成无符号类型。

          例如，如果两个运算对象的类型分别是`long`和`unsigned int`，并且`int`和`long`的大小相同，则`long`类型的运算对象转换成`unsigned int`类型；
          如果`long`类型占用的空间比`int`更多，则`unsigned int`类型的运算对象转换成`long`类型。

* 算术转换举例

      bool flag;
      char cval;  
      short sval;
      unsigned short usval;
      int ival;
      unsigned int uival;
      long lval;
      unsigned long ulval;
      float fval;
      double dval;

      3.141592L + 'a';          // 'a'提升成int，然后int转换成long double
      dval + ival;              // ival 转换成 double
      dval + fval;              // fval 转换成 double
      ival = dval;              // dval 转换成（切除小数部分）int
      flag = dval;              // 如果dval是0，则flag是false，否则flag是true
      cval + fval;              // cval提升成int，然后该int值转换成float
      sval + cval;              // sval 和 cval都提升成int
      cval + lval;              // cval 转换成long
      ival + ulval;             // ival 转换成 unsigned long
      usval + ival;             // 根据unsigned short 和int所占空间的大小进行提升
      uival + lval;             // 根据unsigned int 和long所占空间的大小进行转换


###### 其他隐式类型转换 

* 数组转换成指针
    
  + 在大多数用到数组的表达式中，数组自动转换成指向数组首元素的指针：

        int ia[10];
        int* ip = ia; // ia转换成指向数组首元素的指针 
    
    + 当数组被用作`decltype`关键字的参数，或者作为取地址符（`&`）、`sizeof`及`typeid`等运算符的运算对象时，上述转换不会发生
    + 如果用数组初始化一个引用时，上述转换也不会发生

          int arr[10];
          int (&arrRef)[10] = arr;    // arrRef引用一个含有10个整数的数组


* 指针的转换

  + 常量整数值0或者字面值`nullptr`能转换成任意指针类型
  + 指向任意非常量的指针能转换成void*
  + 指向任意对象的指针能转换成const void*
  + 在有继承关系的类型间还有另外一种指针转换方式


* 转换成布尔类型
  存在一种从算术类型或指针类型向布尔类型自动转换的机制。如果指针类型或算术类型的值为0，转换结果为false；否则转换结果为true。


* 转换成常量

  + 允许将指向非常量类型的指针转换成指向相应的常量类型的指针
  + 对于引用也支持上一条的转换
  + 相反的转换不不存在

        int i;
        const int &j = i;    // 非常量转换成const int的引用
        const int *p = &i;   // 非常量的地址转换成const的地址
        int &r = j, *q = p;  // 错误：不允许const转换成非常量 

* 类类型定义的转换
  类类型能定义由编译器自动执行的转换，不过编译器每次只能执行一种类类型的转换。
  如果同时提出多个转换请求，这些请求将被拒绝。

###### 显示转换

* 命名的强制类型转换

  cast-name<type>(expression);

  type是转换的目标类型  

  expression是要转换的值  

  cast-name 是`static_cast`、`dynamic_cast`、`const_cast`和`reinterpret_cast`中的一种。

  + dynamic_cast 支持运行时类型识别
  + static_cast 

    任何具有明确定义的类型转换，只要不包含底层`const`，都可以使用static_cast。
              
        int i,j;
        double slope = static_cast<double>i/j;    // 进行强制类型转换以便执行浮点数除法

    当需要把一个较大的算术类型赋值给较小的类型时，static_cast非常有用。此时，强制类型转换告诉程序的读者和编译器：我们知道并且不在乎潜在的精度损失。一般来说，如果编译器发现一个较大的算术类型试图赋值给较小的类型，就会给出告警信息；但是当我们执行了显式的类型转换后，告警信息就会被关闭了。

    static_cast对于编译器无法自动执行的类型转换也非常有用。
              
        double d;
        void* p = &d;
        double* dp = static_cast<double*>(p);

        
  + const_cast

    const_cast只能改变运算对象的底层const。
    只有const_cast能改变表达式的常量属性，使用其他形式的命名强制类型转换改变表达式的常量属性都将引发编译器错误。同样的，也不能使用const_cast改变表达式的类型。    
        
    对于将常量对象转换成非常量对象的行为，我们一般称其为“去掉const性质”。一旦我们去掉了某个对象的const性质，编译器就不再阻止我们对该对象进行写操作了。如果对象本身不是一个常量，使用强制类型转换获得写权限是合法的行为。然而如果对象是一个常量，再使用const_cast执行写操作就会产生未定义的后果。

    const_cast通常用于函数重载的上下文中。
      
  + reinterpret_cast

    reinterpret_cast通常为运算对象的位模式提供较低层次上的重新解释。
    使用reinterpret_cast是非常危险的，它本质上依赖于机器。要想安全的使用reinterpret_cast必须对涉及的类型和编译器实现转换的过程都非常了解。

* 旧式的强制类型转换

  type (expr);    // 函数形式的强制类型转换
  (type)expr;     // C语言风格的强制类型转换

  > 与命名的强制类型转换相比，旧式的强制转换类型从表现形式上来说不那么清晰明了，容易被看漏，所以一旦转换过程出现问题，追踪起来更加困难。

> 强制类型转换干扰了正常的类型检查，因此强烈建议避免使用强制类型转换。这个建议对reinterpret_cast尤其适用，因为此类类型转换总是充满了风险。
   在有重载函数的上下文中使用const_cast无可厚非，但是其他情况下使用const_cast也就意味着程序存在某种设计缺陷。
   其他强制类型转换，比如static_cast和dynamic_cast，都不应该频繁使用。


##### 字面值常量

* 一个形如 `52` 、 `'a'` 、 `"Hello"` 、 `3.14L` 、 `99LL` 、 `u8"hi!"` 的值被称为字面值常量(literal)。每个字面值常量都对应一种数据类型，字面值常量的形式（前缀/后缀）和值大小决定了它的数据类型。

* 字符和字符串字面值

  由单引号括起来的一个字符称为`char`型字面值

  双括号括起来的零个或多个字符则构成字符串字面值

    前缀 | 含义 | 类型
    --- | --- | ---
    u | Unicode 16 字符 | `char16_t`
    U | Unicode 32 字符 | `char32_t`
    L | 宽字符 | `wchar_t`
    u8 | UTF-8(仅用于字符串字面常量) | `char`


* 整型字面值

  默认情况下，十进制不带后缀的整数字面值是带符号数，它的类型是`int`/`long`/`long long`中能容纳它大小的最小的那个。
  八进制和十六进制不带后缀的整数字面值可能是带符号数，也可能是无符号数，它的类型是`int`/`unsigned int`/`long`/`unsigned long`/`long long`/`unsigned long long`中尺寸最小者。
  类型`short`没有对应的字面值。


    后缀 | 最小匹配类型
    --- | ---
    u or U | `unsigned`
    l or L | `long`
    ll or LL | `long long`


* 浮点型字面值

  默认的，浮点型字面值是一个`double`。


    后缀 | 类型
    --- | ---
    f or F | `float`
    l or L | `long double`


* 布尔字面值

  `true` 和 `false` 是布尔类型的字面值

* 指针字面值

  `nullptr`是指针字面值
 

##### 泛化的转义序列

* 形式为`\x`后紧跟1个或多个十六进制数字，或者`\`后紧跟1个、2个或3个八进制数字，其中数字部分表示的是字符对应的数值。

    `\12` (换行符）`\115` (字符M) `\x4d` (字符M)


      std::cout << "Hi, \x4d-O-\155!\n";    //输出: Hi, M-O-M! 然后换行


  如果反斜线 `\` 后面跟着的八进制数超过3个，只有前3个跟 `\` 构成转义序列。
  相反，`\x` 要用到后面跟着的所有数字，例如，`\x1234` 表示一个16位的字符，该字符由这4个十六进制数所对应的比特唯一确定。因为大多数机器的`char`型数据都是占8位，所以上面这个例子可能会报错。一般来说，超过8位的十六进制字符都是与前面的字符与字符串字面值表中的某个前缀作为开头的扩展字符集一起使用的。 



##### 变量初始化

* C++中，初始化和赋值是两个完全不同的操作。初始化的含义时创建变量时赋予其一个初始值，而赋值的含义是把对象的当前值擦除，而以一个新值来替代。

* 列表初始化

  格式如下:

      int units_sold = {0};
      int units_sold{0};

  当用于内置类型的变量时，如果我们用列表初始化且初始值存在丢失信息的风险，则编译器将报错:
 
      long double ld = 3.1415926536;
      int a{ld}, b = {ld};         // 错误，转换未执行，因为存在丢失信息的危险 
      int c(ld), d = ld;           // 正确，转换执行，且确实丢失了部分值

  ![list initialization](/image/list_initialization.png)


* 默认初始化

  定义于函数体之外的内置变量默认初始化为0。

  定义于函数体内部的内置变量如果没有初始化，则其值未定义。

  类对象如果没有显式的初始化，其值由类确定，如果类要求每个对象都显示初始化，则会引发错误。

* 变量标识符

  标识符的长度没有限制，但是对大小写敏感。

  C++为标准库保留了一些名字。用户自定义的标识符不能连续出现两个下划线，不能以下划线紧连大写字母开头。此外定义在函数体外的标识符不能以下划线开头。(非强制标准，建议)


##### 复合类型

* 引用

  一般在初始化变量时，初始值会被拷贝到新建的对象中。然而在定义引用时，程序把引用和它的初始值绑定（bind）在一起，而不是将初始值拷贝给引用。一但初始化完成，引用将和它的初始值对象一直绑定在一起。因为无法令引用重新绑定到一个新的对象，因此引用必须初始化。

  + 引用必须初始化
  + 普通引用(相对于常量引用)的类型必须与绑定的对象的类型一致（即是绑定对象能转换成引用类型也不可以）
  + 普通引用不能绑定字面值
  
  引用并非对象，它只是为一个已经存在的对象所起的别名。不能定义引用的引用。

      int ival = 1024;
      int &refVal = ival;     // refVal 指向ival (是ival的另一个名字)
      int &refVal2;           // 错误：引用必须初始化
      refVal = 2;             // 把2赋给refVal指向的对象，此处即是赋给了ival
      int li = refVal;        // 与li = ival执行结果一样
      int &refVal3 = refVal;  // 正确：refVal3绑定到了那个refVal绑定的对象上，这里就是绑定到ival上

      int i = 1024, i2 = 2048;    // i 和 i2都是 int
      int &r = i, r2 = i2;        // r是一个引用，与i绑定在一起，r2是int
      int &r3 =i2, &r4 = i;       // r3 和 r4都是引用

      int &refVal4 = 10;          // 错误：引用类型的初始值必须是一个对象
      double dval = 3.14;
      int &refVal5 = dval;        // 错误：此处引用类型的初始值必须时int型对象

      int a = 8, &ra = a;
      double d = 3.14, &rd = d;
      a = rd;                     // a = 3
      rd = ra;                    // d = 3


* 指针

  得到空指针最直接的办法就是用字面值`nullptr`来初始化指针，这时c++11新标准中引入的一种方法。也可以用名为`NULL`的预处理变量给空指针赋值，这个变量在头文件cstdlib中定义。


      int i = 23;
      int *p;
      int *&r = p;    // r是一个对指针p的引用

      r = &i;         // r引用了一个指针，因此给r赋值&i就是令p指向i
      *r = 0;         // 解引用r得到i，也就是p指向的对象，将i的值改为0


  面对一条比较复杂的指针或引用的声明语句时，从右到左阅读有利于弄清楚它的真实含义。

  指针与引用的区别：

    - 指针本身就是一个对象，允许对指针赋值和拷贝，而且在指针的生命周期内它可以先后指向不同的对象
    - 指针无须在定义时赋初值。和其他内置类型一样，如果没有初始化，也将拥有一个不确定的值 



##### const限定符

* 因为`const`对象一旦创建后其值就不能再改变，所以`const`对象必须初始化。

* 默认情况下，`const`对象仅在文件内有效，当编译时初始化的方式定义一个`const`对象时，如

      const int bufSize = 512;

  编译器将在编译过程中把用到该变量的地方都替换成对应的值。

  > 如果想在多个文件之间共享`const`对象，必须在变量的定义之前添加`extern`关键字

* 对常量的引用
  
  可以把引用绑定到`const`对象上，就像绑定到其他对象上一样，我们称之为对常量的引用（reference to const）。与普通引用不同的时，对常量的引用不能被用作修改它所绑定的对象。

      const int ci = 1024;
      const int &r1 = ci;        // 正确：引用机器对应的对象都是常量
      r1 = 42;                   // 错误：r1是对常量的引用
      int &r2 = ci;              // 错误：试图让一个非常量引用指向一个常量对象

  前面提到过，引用的类型必须与其所引用的对象的类型一致，但是有两个例外。第一种例外情况就是在初始化常量引用时允许用任意表达式作为初始值，只要该表达式的结果能转换成引用的类型即可。尤其，允许为一个常量引用绑定非常量的对象、字面值，甚至是个一般表达式：

      int i = 15;
      const int &r1 = i;         // 允许const int &绑定到一个普通int对象上 r1 = 15
      const int &r2 = 23;        // 正确：r2是一个常量引用 r2 = 23
      const int &r3 = r1 * 2;    // 正确：r3是一个常量引用 r3 = 30
      int &r4 = r1 * 2;          // 错误：r4是一个普通的非常量引用

      r1 = 23;                   // 错误
      i = 33;                    // 正确： r1 = 33, r3 = 30

      double dval = 3.14;
      const int &r5 = dval;      // 正确 r5 = 3

      dval = 23.99;              // 正确 r5 = 3


  必须认识到，常量引用仅对引用可参与的操作做了限定，对于引用的对象本身是不是一个常量未做限定。因为对象也可能是个非常量，所以允许通过其他途径修改它的值。

* 指向常量的指针(pointer to const)

  指向常量的指针和对常量的引用类似。

      const double pi = 3.14;        // pi是个常量，它的值不能改变
      double *ptr = &pi;             // 错误：ptr是一个不同指针
      const double *cptr = &pi;      // 正确：cptr可以指向一个双精度常量
      *cptr = 23;                    // 错误：不能给*cptr赋值

      double dval = 3.14;            // dval是一个双精度浮点数，它的值可以改变
      cptr = &dval;                  // 正确：但是不能通过cptr改变dval的值


* 常量指针（const pointer）

  可以把指针本身定义为常量，常量指针必须初始化，而且一旦初始化完成，则它的值（也就是存放在指针中的那个地址）就不能再改变了。

      int errNumb = 0;
      int * const curErr = &errNumb;        // curErr将一直指向errNumb
      *curErr = 10;                         // 正确：errNumb = 10

      const double pi = 3.14159;
      const double * const pip = &pi;       // pip是一个指向常量对象的常量指针
      *pip = 2.72;                          // pip是一个指向常量的指针，常量的值不允许改变


  弄清楚这些声明和定义最行之有效的方法是从右向左阅读。

* 顶层`const`和底层`const`

  顶层`const`可以表示任意的对象是常量，这一点对任何数据类型都适用，如算术类型、类、指针等。

  底层`const`则与指针、引用等复合类型的基本类型部分有关。

      int i = 0;
      int *const p1 = &i;       // 不能改变p1的值，顶层const
      const int ci = 32;        // 不能改变ci的值，顶层const
      const int *p2 = &ci;      // 允许改变p2的值，底层const
      const int *const p3 = p2; // 左边是底层const，右边是顶层const
      const int &r = ci;        // 用于声明引用的都是底层const 


* 常量表达式（const expression）

  常量表达式是指不会改变并且在编译过程就能得到计算结果的表达式。

  一个对象或表达式是不是常量表达式由它的数据类型和初始值共同决定。

  c++11标准规定，允许将变量声明为`constexpr`类型以便由编译器来验证变量的值是否是一个常量表达式。声明为`constexpr`的变量一定是一个常量，而且必须用常量表达式初始化。




##### 类型别名

* 传统的方式是使用`typedef`关键字

      typedef double wages;        // wages 是double的别名
      typedef wages base, *p;      // base 是double的别名，p是double*的别名

      typedef char *pstring;
      const pstring cstr = 0;      // cstr 是指向char的常量指针
      const pstring *ps;           // ps是一个指针，它的对象是指向char的常量指针


  遇到一条使用了类型别名的声明语句时，往往会错误地尝试把类型别名替换成它本来的样子，以理解该语句的含义：

      const char *cstr = 0;       // 是对const pstring cstr的错误理解

  声明语句中用到pstring时，其基本数据类型是指针。可是使用`char*`重写了声明语句后，数据类型就变成了`char`。前者声明了一个指向`char`的常量指针，改写后的形式则声明了一个指向`const char`的指针。

* c++11新标准方式

      using SI = Sales_item;      // SI是Sales_item的别名

##### 新标准中引入的`auto`类型说明符和`decltype`类型指示符

* `auto`类型说明符
  
  C++11新标准中引入`auto`类型说明符，用它就能让编译器替我们去分析表达式所属的类型，`auto`定义的变量必须有初始值。

      auto i = 0, *p = &i;
      auto item = val1 + val2; 


* `decltype`类型说明符

  也是C++11新标准中引入的。它的作用是选择并返回操作数的数据类型，在此过程中，编译器分析表达式并得到它的类型，却不实际计算表达式的值。

      int ci = 0;
      decltype(f()) sum = x;
      decltype(ci) x = 0; 
  
  
      const int ci = 0, &cj = ci;
      decltype(ci) x = 0;         //x的类型是const int
      decltype(cj) y = x;         //y的类型是const int&，y绑定到变量x
      decltype(cj) z;             //错误: z是一个引用，必须初始化

      int i = 32, *p = &i, &r = i;
      decltype(r + 0) b;          //正确: 加法的结果是int，因此b是一个（未初始化的）int
      decltype(*p) c;             //错误: c是int&，必须初始化
      decltype(&p) pp;            //正确: pp是一个int**，一个指向整数指针的指针。

      //decltype的表达式如果是加上了括号的变量，结果将是引用
      decltype((i)) d;            //错误: d是int&，必须初始化
      decltype(i) e;              //正确: e是一个（为初始化的）int

  > decltype((variable)) （注意是双括号）的结果永远是引用，而decltype(variable)的结果只有当variable本事是一个引用时才是引用。




