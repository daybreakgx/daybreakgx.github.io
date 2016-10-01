---
layout: post
title: "Linux Readme"
categories: kernelDoc
tags: kernel
---

* content
{:toc}


#### 内容参考:

* 内核文档: linux-4.4.23/README [链接](http://lxr.linux.no/#linux+v4.4.23/README)

* [linux kernel 源代码ReadMe文件翻译](http://blog.sina.com.cn/s/blog_8e037f440100vtld.html)

#### Linux kernel release 4.x

这是Linux 4版本的发行注解，仔细阅读这些内容，通过这篇文章可以了解如何安装内核以及出现错误时如何处理。

#### What is Linux

Linux是操作系统Unix的一个克隆版本，它是由Linus Torvalds和网络上一个松散组合的黑客团队共同完成的。它的目标是更符合POSIX和Single Unix规范标准。

Linux包含了现代成熟的Unix操作系统中的所有特性，如：真正的多任务(multitasking)，虚拟内存(virtual memory)，共享库(shared libraries)，按需加载(demand loading)，执行程序的共享写时拷贝(shared copy-on-write executables)，合适的内存管理(momery management)以及支持IPv4和IPv6的多网络协议栈(multistack networking)。

It is distributed under the GNU General Public License - see the
accompanying COPYING file for more details.

Linux的发布遵循GNU GPL(General Public License)，详情参见COPYING文件。


#### Linux运行的硬件环境

虽然Linux最初是为32位的x86架构(386或更高)的机器开发的，但是到目前为止，Linux还支持下面的硬件架构:
Compaq Alpha AXP, Sun SPARC and UltraSPARC, Motorola 68000, PowerPC, PowerPC64, ARM, Hitachi SuperH, Cell, IBM S/390, MIPS, HP PA-RISC, Intel IA-64, DEC VAX, AMD x86-64, AXIS CRIS, Xtensa, Tilera TILE, AVR32, ARC and Renesas M32R。

Linux很容易移植到支持分页内存管理单元(paged memory management unit, PMMU)机制和GUN C编译(gcc)接口的32位/64位的体系中。Linux也可以移植到不支持PMMU的体系架构中，但是功能上会有一些限制。Linux还能移植到它自己身上。你可以像用户空间的应用程序一样运行内核--这叫“用户模式 Linux”（UserMode Linux，简称UML）。

#### 文档

* 目前已经有大量的电子版或纸质的针对Linux或关于通用Unix问题的文档。建议仔细查看Linux中的documentation子目录中的LDP(Linux Documentation Project)。本文档不是作为系统的文档而提供的：有很多更好的资源适合你去阅读。

* 在Documantation子目录下有很多的readme文件，这些文件包含了内核特有的安装说明等内容。 Documentation/00-INDEX文件中列出了所有这些readme的简介。 Change文件中包含了新版本合入的问题信息，这些可以帮助确认是否需要升级内核。

* Documentation/DocBook 子目录中包含了一些内核开发和使用的指南。这些指南可以被转换为多种格式：PostScript (.ps), PDF, HTML, & man-pages等。内核安装完成后，可以使用"make psdocs"，"make pdfdocs"，"make htmldocs"或"make mandocs"命令生成对应格式的文档。

#### 内核源码安装

* 如果需要安装全量代码，首先将内核的tar包放到一个你拥有操作权限的目录(如home目录)，然后执行解压操作，解压时使用实际的版本号替换命令中的X。

        xz -cd linux-4.X.tar.xz | tar xvf -

    不要使用/usr/src/linux目录，该目录下包含了(通常不完全的)库头文件(library header)文件需要的内核头文件的集合。他们必须与库匹配，不应该因为内核变动导致有他们的匹配有变化。

* 也可以使用补丁方式在4.x发行版本之间进行升级。 补丁包采用xz格式进行发布。采用这种方式进行安装时，需要获取所有新的补丁包，进入内核源码的顶层目录(linux-4.x)，然后执行下面的命令，执行时根据实际情况替换命令中的x。

        xz -cd ../patch-4.x.xz | patch -pl

    如果想要移除备份文件(xxx~ 或xxx.orig)，确保没有打失败的补丁(xxx# 或xxx.rej)。如果有打失败的补丁，那么前面的某个环节一定出现过错误。
    
    与4.x内核的补丁不同，4.x.y(稳定版)的内核的补丁并不是递增的，而是在4.x的基础上替换的。例如，如果你的基础内核版本是4.0，你希望使用4.0.3版本的补丁，那么就不能安装4.0.1和4.0.2的补丁。同样的，如果你当前正在运行4.0.2的版本，同时希望升级到4.0.3，必须首先回退4.0.2的补丁然后再安装4.0.3的补丁。 在Documentation/applying-patches.txt文件中可以获取等更多的补丁升级方面的信息。

    另外也可以使用patch-kernel脚本自动完成补丁升级。这取决于当前内核版本以及提供的补丁。

        linux/scripts/pathc-kernel linux

    上面命令中的第一个linux表示内核代码的路径，补丁文件要么放在该路径下，要么放在第二个linux指定的目录下。

* 为了保证当前没有过期的.o文件或依赖关系，可以执行下面的命令:

        cd linux
        make mrproper

    到现在为止，已经完成了内核代码的安装。

#### 软件依赖

编译和运行4.x版本的内核需要更新一些软件包。可以查阅 Documentation/Changes文件获取所需软件的最低版本号及升级方式。注意如果使用很旧的软件包版本，可能会导致间接的错误，这些错误通常都很难定位跟踪，所以不要有在构建操作中出现问题后再升级软件包的想法。

#### 构建内核路径

编译内核的时候，所有的输出文件都默认都会保存在对应的内核源代码目录下。使用编译参数(make O=output/dir)可以指定输出文件到其他目录(包括.config)。

例如:

      kernel source code: /usr/src/linux-4.x
      build directory: /home/name/build/kernel

可以实现用下面的命令来配置和构建内核:

      cd /usr/src/linux-4.x
      make O=/home/name/build/kernel menuconfig
      make O=/home/name/build/kernel
      sudo make O=/home/name/build/kernel modules_install install

注意，一旦使用了‘O=output/dir’选项，那么多有的make命令都要使用它。

#### 配置内核编译

即使是在升级一个次要的版本时，也不要跳过这个步骤。每一个发行版本都会增加新的配置选项。如果没有按照要求配置时，可能会导致很多诡异的问题。如果想要保持当前已经存在的配置选项，可以使用"make oldconfig"命令，这样的话只需要配置新增的选项即可。

+ 配置的命令有以下几种:

  * "make config"-------------------简单的文字界面方式
  * "make menuconfig"---------------基于文字的图形化界面方式，包含菜单、对话框和radiolists，
  * "make nconfig"------------------Enhanced text based color menus.
  * "make xconfig"------------------基于Qt的配置工具
  * "make gconfig"------------------基于GTK+的配置工具
  * "make oldconfig"----------------根据已存在的./.config文件进行默认配置，只对新增的配置选项进行选择配置
  * "make silentoldconfig"----------与上一个类似，不过避免了已经回答了的问题在屏幕上的杂乱显示。增加了一些升级依赖。
  * "make defconfig"----------------根据 arch/$ARCH/configs/${PLATFORM}_defconfig 或 arch/$ARCH/defconfig文件自动生成与架构相关的config文件。
  * "make ${PLATFORM}_defconfig"----根据 arch/$ARCH/configs/${PLATFORM}_defconfig自动生成config文件。可以使用"make help"获取所有支持的平台架构的列表。
  * "make allyesconfig"-------------尽可能多的通过设置y来生成config配置文件
  * "make allmodconfig"-------------尽可能多的通过设置m来生成config配置文件
  * "make allnoconfig"--------------尽可能多的通过设置n来生成config配置文件
  * "make randconfig"---------------通过对设置赋随机值来生成config配置文件
  * "make localmodconfig"-----------根据当前的config和系统中已经加载的模块生成config配置文件。禁用当前系统中未加载的所有的模块选项。 
    可以通过将lsmod的信息存储到一个文件中，将其传给另外一台机器，在这台机器上创建localmodconfig时将其传递给LSMOD参数。

        target$ lsmod > /tmp/mylsmod
        target$ scp /tmp/mylsmod host:/tmp
        host$ make LSMOD=/tmp/mylsmod localmodconfig

    上述方式也可用于交叉编译的场景。

  * "make localyesconfig" 与localmodconfig类似，只不过会该种方式会将所有module的选项从m转换为y。

  可以从Documentation/kbuild/kconfig.txt文件中找到更多的关于linux内核配置工具的信息。

+ make config注意事项

  * 配置了不必要的驱动会增加内核的大小，在某些场景下也会导致一些问题，如探测一个不存在的控制卡可能会导致系统中其他控制卡功能混乱。

  * 编译内核时，如果Processor type 指定为386以上类型时，会导致内核不能在386下运行。内核在引导时会检测到该问题，然后放弃引导。

  * 如果系统中有协处理器且内核编译配置了数学仿真时，内核会将协处理器当作数据仿真器来使用。内核可能会变得大一些，但是可以在不同的机器上去运行，而不用去管它是否真的存在数学协处理器。

  * "kernel hacking"配置项通常会导致内核变大或运行变慢(或者两个都有)，在配置了用于查找内核问题的主动的例测项目时，甚至可能会导致内核变得不稳定。所以，要根据实际情况判断是否需要将"development", "experimental"或"debugging"特性配置设置为'n'。

#### 内核编译

* 确保gcc的版本大于等于3.2，可以查看 Documentation/Changes 获取更多信息。
    请注意当前版本的内核仍然可以运行a.out形式的用户程序。

* 执行make命令生成一个压缩的内核映像。 首先确认lilo是否已经安装，如果安装了lilo(linux loader)，就可以执行make install命令。
    真正的执行安装动作时，需要使用root权限，但是在编译时不需要root权限。

* 如果将内核的某个部分配置成了modules，还需要运行 make modules_install 命令。

* 内核编译/构建时的输出信息:

  通常情况下，内核编译系统运行在安静模式。 然而，有时候还是需要内核开发者确认编译，谅解或其他命令是否正确的执行。此时，可以使用"verbose"构建模式，只需要在make命令后面加上 V=1 的选项即可。

        make V=1 all

    如果需要知道重复编译某些目标文件的原因时，使用 V=2。 默认情况下， V=0。

* 保留一个备份的内核防止新内核安装过程中出现错误。特别是对于开发版本的内核，因为其中包含了未调试的新的代码。在执行make modules_install命令之前，确保保留一个与之前备份的内核相对应的各模块的备份。

    另外，在编译之前，可以使用"LOCALVERSION"配置选项在内核的版本后面添加一个唯一的后缀。"LOCALVERSION"在"General Setup"菜单中设置。

* 为了能够引导新的内核，必须拷贝内核的映像文件(如，编译后生成的 ../linux/arch/i386/boot/bzImage)到可以成功引导内核地方。

* 不使用引导程序(bootloader, 如LILO)而直接使用软盘启动内核的方式，现在已经不再支持。

    如果需要通过硬盘引导Linux，可以使用LILO，通过在文件/etc/lilo.conf 中指定内核映像来引导。内核的映像文件通常是 /vmlinuz, /boot/vmlinuz, /bzImage 或/boot/bzImage。 使用新的内核时，保留原来内核映像的拷贝，然后将新内核映像覆盖原来的内核映像。然后，必须重新运行LILO来重新加载映射。如果没有执行这个步骤，不能引导新的内核。

    重新安装LILO只需要运行/sbin/lilo即可。 可以编辑 /etc/lilo.conf 文件为旧的内核映像(如，/vmlinux.old)指定一个入口，从而停止运行新内核，重新运行旧内核。更多信息参见LILO文档。

    重新安装完LILO后，所有的工作就完成了。关闭系统，重启然后开启新的Linux内核。

    如果需要修改内核映像中的默认根设备，视频模式，ramdisk大小等，可以通过 'rdev'程序(或LILO的引导选项)完成，而不用重新编译内核来改变这些参数。

* 重启系统，开始新的内核之旅吧。

#### 遇到问题怎么办

* 如果遇到的问题看起来像是内核的bug，首先查看 MAINTAINERS 文件确认出错部分是否有人维护。 如果没有的话，发送邮件给torvalds@linux-foundation.org，或者有可能的话也可以发送给相关的内核邮件列表。

* 在所有的bug报告中，如果是新问题，请说清楚出现问题的是那个内核，如何复现问题以及你做了哪些配置。 如果是旧问题，说明是什么时候发现问题的。


* 如果问题出现后，在屏幕或系统日志中出现了下面的信息:

        unable to handle kernel paging request at address C0000010
        Oops: 0002
        EIP:   0010:XXXXXXXX
        eax: xxxxxxxx   ebx: xxxxxxxx   ecx: xxxxxxxx   edx: xxxxxxxx
        esi: xxxxxxxx   edi: xxxxxxxx   ebp: xxxxxxxx
        ds: xxxx  es: xxxx  fs: xxxx  gs: xxxx
        Pid: xx, process nr: xx
        xx xx xx xx xx xx xx xx xx xx

    或者类似的内核调试信息，请将这些完整准确的复制下来。这些信息对使用者来说可能是无用且不能理解的，但是它对于问题确认很有帮助。 dump上面的信息也很有帮助：它记录了内核崩溃的原因(上面的例子中，原因是使用了错误的内核指针)。 如果想了解更多的内核dump的信息，可以阅读 Documentation/oops-tracing.txt。

* 如果在编译的时候使用了 'CONFIG_KALLSYMS' 配置项，可以获取到前面的dump信息。 否则，必须使用 "ksymoops"程序来获取dump信息。 
    通常优先选择设置 'CONFIG_KALLSYMS' 配置项。 
    ksymoops 程序可以从下面的地址中获取:
    ftp://ftp.<country>.kernel.org/pub/linux/utils/kernel/ksymoops/ .

* 在上面的dump调试信息中，如果能看懂EIP的含义是很有用的。 这个十六进制数目前来看对我们的帮助不大，它的真实值依赖于具体的内核配置。 首先我们获取到这个十六进制数(不包括 0010)，然后在内核的namelist中查找这个十六进制数的地址位于那个函数中。

    为了找到对应的内核函数，需要从内核的二进制文件(linux/vmlinx)中提取信息。 执行下面的命令:

        nm vmlinux | sort | less

    这个命令会给出一个从小到大排好序的内核地址列表，通过它可以很容易的找到对应的内核函数。 需要注意的是，内核调试信息中给出的地址并不一定能够准确的与函数地址匹配(事实上都不能准确的匹配上)， 所以不能够通过grep的方式对列表进行过滤。 这个命令输出的列表能够给出每个内核函数的起始地址。 只要找到起始地址小于EIP对应的地址，且紧跟这的下一个函数的起始地址大于EIP对应的地址，那么就定位到了出现问题的函数。

    事实上，在提交的bug报告中，包含一些上下文信息是一个不错的主意。

    如果因为某些原因不能提供上述信息(如使用的是一个预编译好的内核映像或其他原因)， 那么就尽可能多的提供你的配置信息。更多信息参见 REPORTING-BUGS文件。

* 可以在一个运行的内核中是用gdb工具(只能读取信息，不能修改变量的值或设置断点)。 如果要使用这种方式，编译内核时需要设置 -g 编译选项， 修改 arch/i383/Makefile 文件，然后执行 make clean命令。 同时，需要在make config中使能 "CONFIG_PROC_FS" 配置项。

    重启新编译的内核后，执行gdb vmlinux /proc/kcore 命令后就可以使用通用的gdb命令了。查看系统崩溃的命令为 "l *0xXXXXXXXX"(将XXXXXXXX替换为EIP中的实际值)。

    使用gdb调试一个没有运行的内核时会失败，因为gdb会忽略内核编译时指定的起始地址偏移。

