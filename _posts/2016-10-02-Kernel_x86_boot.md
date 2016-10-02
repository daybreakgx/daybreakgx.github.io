---
layout: post
title: "Linux X86引导协议"
categories: boot
tag: kernel boot X86
---

* content
{:toc}

#### 内容参考

* 内核文档: linux-4.4.23/Documentation/x86/boot.txt

#### 简述

在x86的平台中，linux内核采用了一种相当复杂的引导方式。 在早期的时候内核是被设计为具有自我引导功能的，加上复杂的PC内存模型以及当时实模式Dos逐渐成为主流操作系统等原因，一步步演进导致了现在的这个结果。

目前，Linux/x86 包含以下几种版本的引导协议:

  * Old kernels: 仅仅支持zImage/Image。 有些早期的内核甚至可能都不支持命令行参数。

  * Protocol 2.00: (Kernel 1.3.73) 增加了对bzImage和initrd的支持， 使得boot loader和内核之间有了一种正式的通信方式。 setup.S被编译为可重定向的，但是仍然保留了传统setup区域的可写性。

  * Protocol 2.01: (Kernel 1.3.76) 增加了堆溢出的告警。

  * Protocol 2.02: (Kernel 2.4.0-test3-pre3) 提供了一个新的命令行(command line)协议。 降低了传统的内存上限。 该版本的协议没有覆盖传统的setup区域， 使得系统可以使用EBDA(Extended BIOS Data Area)从SMM或32-bit的BIOS入口更安全的进行引导启动。 此时zImage已经是不赞成使用，但是该版本仍然支持。

  * Protocol 2.03: (Kernel 2.4.18-pre1) 明确指定了bootloader可以使用initrd的高地址。

  * Protocol 2.04: (Kernel 2.6.14) 将syssize字段扩展为4字节。

  * Protocol 2.05: (Kernel 2.6.20) 提供了保护模式下内核的可重定位功能。 引入了relocatable_kernel 和 kernel_alignment字段。

  * Protocol 2.06: (Kernel 2.6.22) 增加一个字段用于保存引导的命令行的大小。

  * Protocol 2.07: (Kernel 2.6.24) 增加了半虚拟化引导协议。 引入了 hardware_subarch 和 hardware_subarch_data 字段，并在load_falgs中新增了KEEP_SEGMENTS标志。

  * Protocol 2.08: (Kernel 2.6.26) 增加了CRC32校验和ELF格式有效载荷功能。 引入payload_offset 和 payload_length 字段用于定位(locate)有效载荷(payload)。

  * Protocol 2.09: (Kernel 2.6.26) 增加了一个64-bit的指针字段， 指向setup_data结构体的单链表。

  * Protocol 2.10: (Kernel 2.6.31) Added a protocol for relaxed alignment beyongd the kernel_alignment added, new init_size and pref_address fields. Added extended boot loader IDS.

  * Protocol 2.11: (Kernel 3.6) 增加了一个字段handover_offset 用于保存EFI(Extensible Firmware Interface, 可扩展固件接口) handover协议入口地址的偏移量。

  * Protocol 2.12: (Kernel 3.8) 增加了一个xloadflags字段，扩展了struct boot_params结构体，使其能够在64bit系统中能够在4G以上的地址中加载bzImage和ramdisk。


#### 内存布局

##### 传统内存布局

早期的用于Image或zImage的内核加载器的内存布局如下图所示:

  ![old_mem_layout](/image/kernel_init/old_mem_layout.png)

大于0x100000 的地址称为高内存("high memory")
0x1000 - 0x100000 之间的地址称为低内存("low memory")

当使用bzImage的时候，Protected-mode kernel会被重定位到0x100000("high memory")，同时内核实模式块(kernel real-mode block)，包括boot sector, setup, and stack/heap, 被设计为可重定位到 从 0x10000 到 0x100000 之间的任何位置。 不幸的是，在2.00和2.01版本中，0x90000+ 的内存区间仍然被内核用来存放实模式代码，2.02之后的版本解决了这个问题。

由于新的BIOS中包含了EBDA(Extended BIOS Data Area, 扩展BIOS数据域)， 需要申请较多的内存，所以bootloader的内存上限(memory ceiling)，即bootloader占用的低内存最高处的地址，越低越好。 bootloader通常应该使用"INT 12h"中的来检查低内存还有多少空间可以使用。

不幸的是，如果"INT 12h"上报没有足够的内存使用时，bootloader除了能报告一个错误为用户外，没有其他办法。 所以bootloader通常应该被设计为尽可能少的占用低内存空间。 对于zImage或者老的bzImage的内核(需要将数据写到0x90000段)，bootloader应该要保证不会使用0x9A000+ 的地址空间，但是很多BIOS都会破坏这一点。

##### 现代版本的内存布局

对于协议版本 >= 2.02 的使用bzImage的内核，内存布局如下图所示:

  ![modern_mem_layout](/image/kernel_init/modern_mem_layout.png)

  地址X应该在bootloader所允许的范围内尽可能的低。

