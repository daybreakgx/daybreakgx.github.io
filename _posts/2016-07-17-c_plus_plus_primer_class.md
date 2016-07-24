---
layout: post
title: "C++ primer读书笔记（六）--- 类"
categories: c++
tags: c++
---

* content
{:toc}


> 类的基本思想是**数据抽象(data abstraction)**和**封装(encapsulation)**。

> 数据抽象是一种依赖于**接口(interface)**和**实现(implementation)**分离的编程（以及设计）技术。类的接口包括用户所能执行的操作；类的实现则包括类的数据成员、负责接口实现的函数以及定义类所需的各种私有函数。
  封装实现了类的接口和实现的分离。封装后的类隐藏了它的实现细节，也就是说，类的用户只能使用接口而无法访问实现部分。

>  类要想实现数据抽象和封装，需要首先定义一个**抽象数据类型(abstract data type)**。在抽象数据类型中，由类的设计者负责考虑类的实现过程；使用该类的程序员则只需要抽象地思考类做了什么，而无须了解类的工作细节。


##### 类的构造函数

* 构造函数的名字和类名相同。和其他函数不同的是，构造函数没有返回类型。类可以包含多个构造函数，和其他重载函数差不多，不同的构造函数之间必须在参数数量或参数类型上有所区别。

* 不同于其他成员函数，构造函数不能被声明成const的。当我们创建类的一个const对象时，直到构造函数完成初始化过程，对象才能真正取得其“常量”属性。因此，构造函数在const对象的构造过程中可以向其写值。

* 当类没有显示的定义构造函数时，编译器会隐式的定义一个默认构造函数，它又被称为**合成的默认构造函数(synthesized default constructor)**。对于大多数类来说，这个合成的默认构造函数将按照如下规则初始化类的数据成员：
  
  + 如果存在类内初始值，用它来初始化成员。
  + 否则，默认初始化该成员。

  合成的默认构造函数只适合非常简单的类，对于一个普通的类来说，必须定义它自己的默认构造函数，原因主要包括：
  
  + 编译器只有在发现类不含任何构造函数时，才会生成一个默认的构造函数。一旦我们定义了一些其他构造函数，那么除非我们再定义一个默认的构造函数，否则类将没有默认构造函数。
  + 对于某些类来说，合成的默认构造函数可能执行错误的操作。内置类型或复合类型对象在默认初始化时，它们的值是未定义的。
  + 有的时候编译器不能为某些类合成默认的构造函数。例如，如果类中包含一个其他类类型的成员且这个成员的类型没有默认构造函数，那么编译器将无法初始化该成员。

* 常见构造函数举例

      struct Sales_data {
          // C++11新标准，如果我们需要默认的行为，可以在参数列表后面加上=default来要求编译器生成构造函数 
          Sales_data() = default; 

          // 冒号与大括号之间的部分称为构造函数初始值列表
          Sales_data(const std::string& s): bookNo(s) { }
          Sales_data(const std::string& s, unsigned n, double p): bookNo(s), units_sold(n), revenue(p*n) { }
          Sales_data(std::istream&);

          // 默认初始化为空串
          std::string bookNo;
          // 类内初始化
          unsigned units_sold = 0;
          double revenue = 0.0;
      };

      Sales_data::Sales_data(std::istream& is) {
          read(is, *this);
      }

* 通常情况下，构造函数使用类内初始化不失为一种号的选择，因为只要这样的初始值存在，我们就能确保为成员赋予一个正确的值。不过，如果编译器不支持类内初始值，则所有构造函数都应该显示的初始化每一个内置类型的成员。

  > 构造函数不应该轻易覆盖掉类内的初始值，除非新赋的值与原值不同。

###### 构造函数初始化列表

* 在很多类中，初始化和赋值的区别事关底层效率问题:前者直接初始化数据成员，后者则先初始化在赋值。
 
  除了效率问题外更重要的是，一些数据成员必须被初始化（如const、引用或某种未提供默认构造函数的类类型），此时我们必须通过构造函数初始值列表为这些成员提供初始值。建议养成使用构造函数初始值的习惯，这样能避免某些意想不到的编译错误。

      Sales_data::Sales_data(const string& s, unsigned cnt, double price):
              bookNo(s), units_sold(cnt), revenue(cnt * price) {} // 列表值初始化

      // 没有使用构造函数初始值，这些成员将在构造函数体之前执行默认初始化，然后在进行赋值操作
      Sales_data::Sales_data(const string& s, unsigned cnt, double price) {
          bookNo = s;
          units_sold = cnt;
          revenue = cnt * price;
      };

      class ConstRef {
      public:
          ConstRef(int ii);
      private:
          int i;
          const int ci;
          int& ri;
      };

      // 错误:ci和ri必须被初始化
      ConstRef::ConstRef(int ii) {
          i = ii;    // 正确
          ci = ii;   // 错误:不能给const赋值
          ri = i;    // 错误:ri没被初始化
      }

* 构造函数初始值列表只说明用于初始化成员的值，而不限定初始化的具体执行顺序。

  成员的初始化顺序与它们在类定义中出现顺序一致:第一个成员先被初始化，然后第二个，依次类推。构造函数初始值列表中初始值的前后位置关系不会影响实际的初始化顺序。

  一般来讲，初始化的顺序没有什么特别要求，不过如果一个成员是用另一个成员来初始化时，那么这两个成员的初始化顺序就很关键了。

  有的编译器具备一项比较友好的功能，即当构造函数初始值列表中的数据成员顺序与这些成员声明的顺序不一致时会产生一条告警信息。

  > 最好令构造函数初始值的顺序与成员声明的顺序保持一致。而且如果可能的话，尽量避免使用某些成员初始化其他成员。

###### 默认实参和构造函数

* 如果一个构造函数为所有参数都提供了默认实参，则它实际上也定义了默认构造函数。

* 当对象被默认初始化或值初始化时自动执行默认构造函数

  默认初始化的情况包括

  + 当我们在块作用域内不使用任何初始值定义一个非静态变量或数组时。
  + 当一个类本身含有类类型的成员且使用合成的默认构造函数时。
  + 当类类型的成员没有在构造函数初始值列表中显式地初始化时。

  值初始化的情况包括
  
  + 在数组初始化过程中如果我们提供的初始值数量少于数组的大小时。
  + 当我们不使用初始值定义一个局部静态变量时
  + 当我们通过书写形如T()的表达式显示地请求值初始化时，其中T是类型名。

  类必须包含一个默认构造函数以便在上述情况下使用。

###### 委托构造函数

C++11标准扩展了构造函数初始值的功能，使得可以定义所谓的委托构造函数(delegating constructor)。一个委托构造函数使用它所属类的其他构造函数执行自己的初始化过程，或者说它把自己的一些（或全部）职责委托给了其他构造函数。

当一个构造函数委托给另一个构造函数时，受委托的构造函数的初始值列表和函数体被依次执行。

    class Sales_data {
        // 非委托构造函数使用对应的实参初始化成员
        Sales_data(std::string& s, unsigned c, double p): bookNo(s), units_sold(c), revenue(c*p) {  }
        
        // 其余构造函数全部委托给另一个构造函数
        Sales_data():Sales_data("", 0, 0) {}
        Sales_data(std::string s):Sales_data(s, 0, 0) {}
        Sales_data(std::istream& is):Sales_data() { read(is, *this); }
    };


##### 类的数据成员

###### 类数据成员的初始化

* 在C++11新标准中，最好将数据成员的默认值声明成一个类内初始值。

* 初始化类类型的成员时，需要为构造函数传递一个符合成员类型的实参。

* 类内初始值必须使用`=`的初始形式或者花括号括起来的直接初始化形式。

      class Screen {
      public:
          typedef std::string::size_type pos;
          Screen() = default;
          Screen(pos ht, pos wd, char c): height(ht), width(wd), contents(ht*wd, c) {}

      private:
          pos cursor = 0;
          pos height = 0, width = 0;
          std::string contents;     
      };

      class Window_mgr {
      private:
          // 对screens进行列表初始化
          std::vector<Screen> screens{Screen(24, 80, ' ')};
      };

###### 可变数据成员

* 有时会出现这样一种情况，我们希望能改变类的某个数据成员，即使是在一个const成员函数内。可以通过mutable关键字来实现。

      class Screen {
      public:
          void some_member() const;
      private:
          mutable size_t access_ctr;  //即使在一个const对象内也能被修改
      };

      void Screen::some_member() const {
          ++access_ctr;
      }
  
  尽管some_member是一个const成员函数，它仍能改变access_ctr的值。该成员是个可变成员。


##### 类的成员函数

###### 定义成员函数

* 定义和声明成员函数的方式与普通函数差不多。成员函数的声明必须在类的内部，它的定义既可以在类内部也可以在类的外部。作为接口组成部分的非成员函数，他们的定义和声明都在类的外部。

  > 定义在类内部的函数是隐式的inline函数。


      struct Sales_data {
          std::string bookNo;
          unsigned units_sold = 0;
          double revenue = 0.0;

          std::string isbn() const { return bookNo; }
          Sales_data& combine(const Sales_data&);
          double avg_price() const;
      };

      //Sales_data的非成员接口函数
      Sales_data add(const Sales_data&, const Sales_data&);
      std::ostream &print(std::ostream&, const Sales_data&);
      std::instream &read(std::instream&, Sales_data&);
     

  上面的例子中成员函数isbn定义在了类内，而成员函数combine和avg_price函数定义在类外。 

* 在类的外部定义成员函数时，成员函数的定义必须与它的声明匹配。也就是说，返回类型、参数列表和函数名都得与类内部的声明保持一致。如果成员函数被声明为常量成员函数，那么它的定义也必须在参数列表后面明确指定const属性。同时，类外部定义的成员的名字必须包含它所属的类名。

      double Sales_data::avg_price() const {
          if(units_sold)
              return revenue/units_sold;
          else
              return 0;
      }

  当avg_price使用revenue和units_sold时，实际上它隐式的使用了Sales_data的成员。


###### 调用成员函数

    Sales_data total;
    total.isbn();

* 成员函数通过一个名为this的额外的隐式参数来访问调用它的那个对象。当我们调用一个成员函数时，会用请求该函数的对象地址初始化this。例如上面代码中的total.isbn()，编译器负责把total的地址传递给isbn的隐式形参this，可以等价的认为编译器将该调用重写成了如下的形式：

      //伪代码，用于说明调用成员函数的实际执行过程
      Sales_data::isbn(&total)

* 在成员函数内部，我们可以直接使用调用该函数的对象的成员，而无须通过成员访问运算符来做到这一点，因为this所指的就是这个对象。任何对类成员的直接访问都被看作this的隐式引用，也就是说，当isbn函数中使用bookNo时，它隐式的使用this指向的成员，就像我们书写了this->bookNo一样。

* 对我们来说，this形参是隐式定义的。实际上，任何自定义名为this的参数或者变量的行为都是非法的。我们可以在成员函数体内部使用this。因为尽管没有必要，但是我们还是能把isbn函数定义为如下形式：

      std::string isbn() const { return this->bookNo; }

* 因为this的目的总是指向“这个”对象，所以this是一个常量指针，不允许改变this中保存的地址。

* 编译器首先编译成员的声明，然后才轮到成员函数体（如果右的话）。因此，成员函数体可以随意使用类中的其他成员而无须在意这些成员出现的次序。


###### const成员函数

* isbn函数中紧随参数列表之后的const关键字的作用是修改隐式this指针的类型。

* 默认情况下，this的类型是指向类类型非常量对象的常量指针，即 class_type* const this。这就意味着（在默认情况下）我们不能把this绑定到一个常量对象上，也就表示不能在常量对象上调用普通的成员函数。

* 如果isbn是一个普通函数而且this是一个普通的指针参数，则我们应该把this声明成const class_type* const this。毕竟，在isbn的函数体内不会改变this所指的对象，所以把this设置成指向常量的指针有助于提高函数的灵活性。

* 然而，this是隐式的并且不会出现在参数列表中，所以在哪儿将this声明成指向常量的指针就称为一个问题。C++语言的做法是允许把const关键字放在成员函数的参数列表之后，此时，紧跟在参数列表后面的const表示this是一个指向常量的指针。像这样使用const的成员函数被称为**常量成员函数(const member function)**。

      //伪代码，说明隐式this指针是如何使用的
      //下面的代码是非法的：因为我们不能显示地定义自己的this指针
      //谨记此处的this是一个指向常量的指针，isbn是一个常量成员
      std::string Sales_data::isbn(const Sales_data *const this)
      { return this->isbn; }

* 因为this是指向常量的指针，所以常量成员函数不能改变调用它的对象的内容。在上例中，isbn可以读取调用它的对象的数据成员，但是不能写入新值。

  > 常量对象，以及常量对象的引用或指针都只能调用常量成员函数。

###### 内联成员函数

* 定义在类内部的成员函数是自动inline的。

* 对于定义在类外部的成员函数，可以在类的内部把inline作为声明的一部分显示的声明成员函数，同样的，也在类的外部用inline关键字修饰函数的定义。
  
  虽然无须在定义和声明的地方同时说明inline，但是这么做是合法的。通常情况只需要在类外部定义的地方说明inline，这样可以使类更容易理解。

  > 和我们在头文件中定义inline函数一样，inline成员函数也应该与相应的类定义在同一个头文件中。

###### 重载成员函数

* 和普通函数一样，成员函数也可以被重载，只要函数之间在参数的数量和/或类型上有所区别就行。成员函数的函数匹配过程同样与非成员函数类似。

* 基于const的重载

      class Screen {
      public:
          using pos = std::string::size_type;
          Screen& set(char);
          Screen& set(pos, pos, char);
          const Screen& display(std::ostream&) const;
      private:
          pos cursor = 0;
          pos height = 0, width = 0;
          std::string contents;
      };

  从逻辑上来说，通过display显示一个Screen并不需要改变它的内容，因此我们将display定义为一个const成员，此时，this指针将是一个指向const的指针而*this是一个const对象。但是此时，我们不能把display嵌入到一组动作的序列中去:

      Screen myScreen;
      // 如果display返回常量引用，则调用set将引发错误
      myScreen.display(cout).set('*');

  解决方法如下：

      class Screen {
      public:
          Screen& display(std::ostream& os) {
              do_display(os); return *this;
          }
          const Screen& display(std::ostream& os) const {
              do_display(os); return *this;
          }
      private:
          void do_display(std::ostream& os) const { os << contents; }
      };
  
  当一个成员调用另外一个成员时，this指针在其中隐式地传递。当do_display完成后，display函数各自返回解引用this所得的对象。在非常量版本中，this指向一个非常量对象，因此display返回一个普通的引用；而const成员则返回一个常量引用。

  当我们在某个对象上调用display时，该对象是否是const决定了应该调用display的哪个版本

      Screen myScreen(5, 3);
      const Screen blank(5, 3);
      myScreen.set('#').display(cout);  //调用非常量版本
      blank.display(cout);              //调用常量版本


###### 定义返回this对象的成员函数

* 函数combine的设计初衷类似于复合赋值运算符+=，调用该函数的对象代表的是赋值运算符左侧的运算对象，右侧运算符则通过显示的实参被传入函数。

      Sales_data& Sales_data::combine(const Sales_data& rhs)
      {
          units_sold += rhs.units_sold;
          revenue += rhs.revenue;
          return *this;
      } 

  该函数一个值得关注的部分是它的返回类型和返回语句。一般来说，当我们定义的函数类似于某个内置运算符时，应该令该函数的行为尽量模仿这个运算符。内置的赋值运算符把它的左侧运算对象当成左值返回，因此为了与它保持一致，combine函数必须返回引用类型。

      total.combine(trans);

  return 语句解引用this指针以获得执行该函数的对象，换句话说，上面的这个调用返回total的引用。  



##### 类对象的拷贝、赋值和析构

* 除了定义类的对象如何初始化以外，类还需要控制拷贝、赋值和销毁对象时发生的行为。

  + 对象在几种情况下会被拷贝，如我们初始化变量以及以值的方式传递或返回一个对象等。
  + 当我们使用赋值运算符时会发生对象的赋值操作。
  + 当对象不再存在时执行销毁操作，如一个局部对象会在创建它的块结束时被销毁，当vector（或数组）对象销毁时存储在其中的对象也会被销毁。

* 如果我们不主动定义这些操作，编译器会替我们合成他们。一般来说，编译器生成的版本将会把对象的每个成员执行拷贝、赋值和销毁操作。

* 尽管编译器能替我们合成拷贝、赋值和销毁操作，但是对于某些类来说，合成的版本无法工作。特别是，当类需要分配类对象之外的资源时，合成的版本常常会失效。不过值得注意的是，很多需要动态内存的类能（而且应该）使用vector对象或string对象管理必要的存储空间。使用vector或者string的类能避免分配和释放内存带来的复杂性。

  > 如果类包含vector或string对象，则其拷贝、赋值和销毁的合成版本能够正常工作。当我们对含有vector成员的对象执行拷贝或者赋值操作是，vector类会设法拷贝或者赋值成员中的元素。当这样的对象被销毁时，将销毁vector对象，也就是依次销毁vector中的每一个元素。这一点与string是非常类似的。


##### 访问控制与封装 

* 在C++语言中，使用**访问说明符(access specifiers)**加强类的封装性：

  + 定义在public说明符之后的成员在整个程序内可以被访问，public成员定义类的接口

  + 定义在private说明符之后的成员可以被类的成员函数访问，但是不能被使用该类的代码访问，private部分封装了（即隐藏了）类的实现细节

        class Sales_data {
        public:
            Sales_data() = default;
            Sales_data(const std::string &s, unsigned n, double p):
                     bookNo(s), units_sold(n), revenue(p*n) {}
            Sales_data(const std::string &s): bookNo(s) {}
            Sales_data(std::istream&);
            std::string isbn() const { return bookNo; }
            Sales_data &combine(const Sales_data&);

        private:
            double avg_price() const { return units_sold ? revenue/units_sold : 0; }
            std::string bookNo;
            unsigned units_sold = 0;
            double revenue = 0.0;
        };

  > 一个类可以包含0个或多个访问说明符，而且对于某个访问说明符能出现多少次也没有严格限制。每个访问说明符指定了接下来的成员的访问级别，其有效范围直到出现下一个访问说明符或者到达类的结尾处为止。
 
  > 使用class和struct定义一个类的唯一区别是默认访问权限不一样。类可以在它的第一个访问说明符之前定义成员，对这种成员的访问权限依赖与类定义的方式。如果我们使用struct，则这些成员是public的；相反，如果我们使用class，则这些成员是private的。

* 当使用class定义一个类，且使用private封装了类的实现细节时，如果类定义了非成员函数的接口，这些接口使用到了private中的成员时，必须将这些非成员函数接口声明为类的友元。

  类可以允许其他类或函数访问它的非公有成员，方法是令其他类或函数称为它的**友元(friend)**。如果类想把一个函数作为它的友元，只需要增加一条以friend关键字开始的函数声明语句即可。

      class Sales_data {
      friend Sales_data add(const Sales_data&, const Sales_data&);
      friend std::istream& read(std::istream&, Sales_data&);
      friend std::ostream& print(std::ostream&, const Sales_data&);

      private:
          std::string bookNo;
          unsigned units_sold = 0;
          double revenue = 0.0;
      public:
          ......
      };

      Sales_data add(const Sales_data&, const Sales_data&);
      std::istream& read(std::istream&, Sales_data&);
      std::ostream& print(std::ostream&, const Sales_data&);

  + 友元声明只能出现在类定义的内部，但是在类内出现的具体位置不限。友元不是类的成员也不受它所在区域访问控制级别的约束。
  + 友元的声明仅仅指定了访问的权限，而非一个通常意义的函数声明。为了能使类的用户能够调用某个友元函数，那么我们就必须在友元声明之外再专门对函数进行一次声明。
    许多编译器并未强制限定友元函数必须在使用之前在类的外部声明。但是最好还是提供一个独立的函数声明。这样即是更换了一个有这种强制要求的编译器，也不需要改变代码。

* 封装的益处

  + 确保用户代码不会无意间破坏封装对象的状态。
  + 被封装的类的具体实现细节可以随时改变，而无须调整用户级别的代码。但是使用了该类的源文件必须重新编译。

##### 类的类型成员

* 除了定义数据和函数成员之外，类还可以自定义某种类型在类中的别名。由类定义的类型名字和其他成员一样存在访问限制，可以是public或者private中的一种。

      class Screen {
      public:
          typedef std::string::size_type pos;    // using pos = std::string::size_type;

      private:
          pos cursor = 0;
          pos height = 0, width = 0;
          std::string contents; 
      };


* 在Screen类的public部分定义了pos，这样用户就可以使用这个名字，用户不需要知道Screen使用了string对象来存放它的数据，因此通过pos定义成public成员可以隐藏类的实现细节。

  用来定义类型的成员必须先定义后使用，这一点与普通成员有所区别。因此，类型成员通常出现在类开始的地方。

  对于类的类型成员使用作用域运算符访问。

      Screen::pos ht = 22, wd = 80;
      Screen scr(ht, wd, ' ');


##### 友元

###### 类之间的友元关系

* 如果一个类指定了友元类，则友元类的成员函数可以访问此类包括非公有成员再内的所有成员。

      class Screen {
          friend class Window_mgr;
      };

* 友元关系不存在传递性，也就是说，如果Window_mgr有它自己的友元，则这些友元并不能理所当然地具有访问Screen的权限。

###### 类的成员函数作为友元

* 除了指定整个类作为友元以外，还可以只为类中的某个成员函数提供访问权限。

      class Screen {
          friend void Window_mgr::clear(index);
      };

* 要想令某个成员函数作为友元，必须仔细组织程序的结构以满足声明和定义的彼此依赖关系

  + 首先定义Window_mgr类，其中声明clear函数，但是不能定义它。在clear使用Screen的成员之前必须先声明Screen类。

  + 接下来定义Screen类，包括对于clear的友元声明。
  
  + 最后定义clear，此时它才可以使用Screen的成员。

###### 函数重载和友元

尽管重载函数的名字相同，但是它们仍然是不同的函数。因此，如果一个类想把一组重载函数声明成它的友元，需要对这组函数中的每一个分别声明。


##### 类的作用域

* 一个类就是一个作用域。在类的外部，成员的名字被隐藏起来了。一旦遇到类名，定义剩余的部分就在类的作用域之内了，这里的剩余部分包括参数列表和函数体。结果就是，我们可以直接使用类的其他成员而无须再次授权了。

  另一方面，函数的返回类型通常出现在函数名之前。因此当成员函数定义在类的外部时，返回类型中使用的名字都位于类的作用域之外。这时，返回类型必须指明它是哪个类的成员。


* 编译器处理完类中的全部声明后才会处理成员函数的定义。因此成员函数体中可以使用类中定义的任何名字。但是这种处理只适用于成员函数体中使用的名字。

  成员函数声明中使用的名字，包括返回类型或者参数列表中使用的名字，都必须在使用前确保可见。如果某个成员的声明中使用了类中尚未出现的名字，则编译器将会在定义该类的作用域中继续查找。

      typedef duoble Money;
      string bal;
      class Account {
      public:
          Money balance() { return bal; }
      private:
          Money bal;
      };

  当编译器看到balance函数的声明语句时，它将在Account类的范围内查找Money的声明。编译器只考虑Account中使用Money前出现的声明，因为没有找到匹配的成员，所以编译器会接着到Account的外层作用域中查找。上面的例子中，编译器会找到Money的typedef语句，该类型被用作balance的返回类型和数据成员bal的类型。

  另一方面，balance函数体在整个类可见后才会被处理，因此，balance函数的return语句返回名为bal的成员，而非外层作用域的string对象。


* 一般来说，内层作用域可以重新定义外层作用域中的名字，即是该名字已经在内层作用域中使用过。然而在类中，如果成员使用了外层作用域中的某个名字，而该名字代表一种类型，则类不能在之后重新定义该名字。

      typedef double Money;
      class Account {
      public:
          Money balance() { return bal; } // 使用外层作用域中的Money
      private:
          typedef double Money;     //错误：不能重新定义Money
          Money bal;
      };


  尽管重新定义类型名字是一种错误的行为，但是编译器并不为此负责。一些编译器仍将顺利通过这样的代码，而忽略代码有错的事实。

  > 类型名的定义通常出现在类的开始处，这样就能确保所有使用该类型的成员都出现在类名的定义之后。

* 成员函数中名字查找

  + 首先，在成员函数内查找该名字的声明。只有在函数使用之前出现的声明才被考虑。

  + 如果在成员函数内没有找到，则在类内继续查找，这是类的所有成员都可以被考虑。

  + 如果类内也没有找到该名字的声明，在成员函数定义之前的作用域内继续查找。

  一般来讲，不建议使用其他成员的名字作为某个成员函数的参数。


      int height;
      class Screen {
      public:
          typedef std::string::size_type pos;
          void dummy_fcn(pos height) {
              cursor = width * height;    // 参数height
          }
      
          void dummy_fcn2(pos height) {
              cursor = width * this->height; // 成员变量height
              cursor = width * Screen::height; // 成员变量height
          }

          void dummy_fcn3(pos, height) {
              cursor = width * ::height;    // class前面定义的全局变量height
          } 
      private:
          pos cursor = 0;
          pos height = 0, width = 0;
      };


##### 隐式的类类型转换

* 如果构造函数只接受一个实参，则它实际上定义了转换为此类类型的隐式转换机制，有时我们称这种构造函数为**转换构造函数(converting constructor)**。

* 编译器只会自动地执行一步类型转换。

      string null_book = "9-999-99999-9";
      
      // 构造一个临时的Sales_data对象
      // 该对象的units_sold 和 revenue等于0，bookNo等于null_book
      item.combine(null_book);


      // 错误: 需要用户定义的两种转换:
      // (1) 把9-999-99999-9 转换成string
      // (2) 再把这个临时的string转换成Sales_data
      item.combine("9-999-99999-9");
 
      // 正确: 显示的转换为string，隐式的转换为Sales_data
      itme.combine(string("9-999-99999-9"));

      // 正确: 隐式的转换为string，显示的转换为Sales_data
      item.combine(Sales_data("9-999-99999-9"));

* 可以通过将构造函数声明为`explicit`抑制构造函数定义的隐式转换

      class Sales_data {
      public:
          Sales_data() = default;
          Sales_data(const std::string& s, unsigned n, double p): bookNo(s), units_sold(n), revenue(n * p) {}
          explicit Sales_data(const std::string& s): bookNo(s) {}
          explicit Sales_data(std::istream&);
      };

      item.combine(null_book);     //错误: string构造函数是explicit的
      item.combine(cin);           //错误: istream构造函数是explicit的

  上面代码中，没有任何构造函数能用于隐式的创建Sales_data对象。

  关键字explicit只对一个实参的构造函数有效。需要多个实参的构造函数不能用于执行隐式转换，所以无须将这些构造函数指定为explicit的。

  只能在类内声明构造函数时使用explicit关键字，在类外部定义时不应重复。

      // 错误: explicit关键字只允许出现在类内的构造函数声明处
      explicit Sales_data::Sales_data(std::istream& is) {
          read(is, *this);
      }


  当执行拷贝形式的初始化时（使用=）会发生隐式转换。此时我们只能使用直接初始化

      Sales_data item1(null_book);     //正确: 直接初始化

      // 错误: 不能将explicit构造函数用于拷贝形式的初始化过程
      Sales_data item2 = null_book;

  尽管编译器不会将explicit的构造函数用于隐式转换过程，但是我们可以使用这样的构造函数显式地强制进行转换。

      // 正确: 实参是一个显式构造的Sales_data对象
      item.combine(Sales_data(null_book));

      // 正确: static_cast可以使用explicit的构造函数
      item.combine(static_cast<Sales_data>(cin));

##### 聚合类

* **聚合类(aggregate class)**使得用户可以直接访问其成员，并且具有特殊的初始化语法形式。当一个类满足如下条件是，我们说它是聚合的：
  
  + 所有的成员都是public。
  + 没有定义任何构造函数。
  + 没有类内初始值。
  + 没有基类，也没有virtual函数。

      struct Data {
          int ival;
          string s;
      };

  我们可以提供一个花括号括起来的成员初始值列表，并用它初始化聚合类的数据成员。初始值的顺序必须与声明的顺序一致，也就是说，第一个成员的初始值要放在第一个，然后是第二个，依次类推。

      //val1.ival = 0; val1.s = string("Anna")
      Data val1 = { 0, "Anna"};

      // 错误:不能使用"Anna"初始化ival，也不能使用1024初始化s
      Data val2 = {"Anna", 1024};

  与初始化数组元素的规则一样，如果初始值列表中的元素个数少于类的成员数量，则靠后的成员被值初始化。初始值列表的个数绝对不能超过类的成员数量。

  显示初始化类的对象的成员存在三个明显的缺点:
  
  + 要求类的所有成员都是public的
  + 将正确初始化每个对象的每个成员的重任交给了类的用户（而非类的作者）
  + 添加或删除一个成员之后，所有的初始化语句都需要更新

##### 字面值常量类

数据成员都是字面值类型的聚合类是字面值常量类。如果一个类不是聚合类，但它符合以下要求，则它也是一个字面值常量类:

  + 数据成员都必须是字面值类型
  + 类必须至少包含一个constexpr构造函数
  + 如果一个数据成员含有类内初始值，则内置类型成员的初始值必须是一条常量表达式；或者如果成员属于某种类类型，则初始值必须使用成员自己的constexpr构造函数
  + 类必须使用析构函数的默认定义，该成员负责销毁类的对象。

通过前置关键子constexpr可以声明一个constexpr构造函数。

constexpr构造函数可以声明成=default的形式（或者是删除函数的形式）。否则，constexpr构造函数就必须既符合构造函数的要求（意味着不能包含返回语句），又要符合constexpr函数的要求（意味着它能拥有的唯一可执行语句就是返回语句）。综合这两点可知，constexpr构造函数体一般来说应该是空的。

constexpr构造函数必须初始化所有的数据成员，初始值或者使用constexpr构造函数或者是一条常量表达式。



##### 类的静态成员

> 有的时候类需要它的一些成员与类本身直接相关，而不是与类的各个对象保持关联。这时就需要静态成员了。


###### 声明静态成员 

通过在成员声明前加上关键字static使得其与类关联在一起。和其他成员一样，静态成员可以是public或private的。静态数据成员的类型可以是常量、引用、指针、类类型等。

同样的，静态成员函数也不与任何对象绑定在一起，它们不包含this指针。作为结果，静态成员函数不能声明成const的，而且我们也不能在static函数体内使用this指针。这一限制既适用于this的显示使用，也对调用非静态成员的隐式使用有效。

    class Account {
    public:
        void calculate() { amount += amount * interestRate; }
        static double reate() { return interestRate; }
        static void rate(double);
    private:
        std::string owner;
        double amount;
        static double interestRate;
        static double initRate(); 
    };

###### 使用静态成员

* 使用作用域运算符直接访问静态成员

      double r;
      r = Account::rate();

* 虽然静态成员不属于某个对象，但是我们仍然可以使用类的对象、引用或者指针来访问静态成员

      Account ac1;
      Account *ac2 = &ac1;

      // 调用静态成员函数rate的等价形式
      r = ac1.rate();
      r = ac2->rate();

* 成员函数不用通过作用域运算符就能直接使用静态成员

###### 定义静态成员

* 和其他成员一样，我们既可以在类的内部也可以在类的外部定义静态成员函数。在类的外部定义静态成员时，不能重复static关键字，该关键字只能出现在类内部的声明语句

* 因为静态数据成员不属于类的任何一个对象，所以它们并不是在创建类的对象时被定义的。这意味着它们不能由类的构造函数初始化。而一般来讲，我们不能在类的内部初始化静态成员。相反的，必须在类的外部定义和初始化每个静态成员。

      double Account::interestRate = initRate();

* 通常情况下，类的静态成员不应该在类的内部初始化。然而，我们可以为静态成员提供const整数类型的类内初始值，不过要求静态成员必须是字面值常量类型的constexpr。

      class Account {
      public:
          static double reate() { return interestRate; }
          static void rate(double);
      private:
          static constexpr int period = 20;
          double daily_tbl[period];
　　　};
      
      // 如果在类的内部提供了一个初始值，则成员的定义不能再指定一个初始值了。
      // 即使一个常量静态数据成员在类内部被初始化了，通常情况下，也应该在类的外部定义一下该成员。
      constexpr int Account::period;

* 可以使用静态成员作为默认实参，而非静态成员不能作为默认实参。


