---
layout: post
title: "Linux X86引导协议"
categories: boot
tag: kernel boot X86
---

* content
{:toc}

#### 内容参考

* 内核文档: ![linux-4.4.23/Documentation/x86/boot.txt](http://lxr.linux.no/#linux+v4.4.23/Documentation/x86/boot.txt)

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

##### 实模式内核首部

在下文及内核引导序列(kernel boot sequence)中，一个扇区(sector)指的是512字节大小，与底层的介质真实的扇区大小是相互独立的。

内核加载的第一个步骤是加载实模式代码(boot sector 和 setup 代码)，然后检查0x01f1偏移量处的首部信息。 实模式代码能达到32K，虽然bootloader有可能只加载前面的两个扇区(1K)就会去检查首部信息。

首部信息如下:

    linux-4.4.23/arch/x86/include/uapi/asm/bootparam.h

    struct setup_header{
        //setup 代码的大小，单位为512字节。 
        //如果该字段被设置为0， 那么会当作4来使用。 
        //在实模式下该代码包括boot sector(通常一个扇区大小) 加上 setup代码
        __u8    setup_sects;
        //如果该字段不为0，表示root为readonly模式
        //该字段已经不再推荐使用，通常采用命令行中的'ro'或'rw'代替
        __u16   root_flags;
        //保护模式的代码大小，单位为16字节
        //对于低于2.04版本的协议，该字段只有2个字节大小，所以对于设置了"LOAD_HIGH"标志的内核，大小是不可信的
        __u32   syssize;
        //该字段已经废弃了
        __u16   ram_size;
        //详情看见 SPECIAL COMMAND LINE OPTIONS 
        __u16   vid_mode;
        //默认的根设备号，该字段已经不再推荐使用，通常采用命令行中的"root="来代替
        __u16   root_dev;
        //值为0xAA55
        __u16   boot_flag;
        //包含了x86的一个跳转指令，0xEB followed by a signed offset relative to byte 0x202
        //该字段可以用来确定header的大小
        __u16   jump;
        //Contains the magic number "HdrS" (0x53726448).
        __u32   header;
        //协议版本号，使用(major << 8) + minor格式，比如0x0204表示版本2.04，0x0a11表示不存在的版本10.17
        __u16   version;
        //bootloader hook，详细参见 ADVANCED BOOT LOADER HOOKS
        __u32   realmode_swtch;
        //The load low segment (0x1000). 已废弃
        __u16   start_sys;
        //如果该字段设置的是非零值，表示一个地址，在该地址加上0x200偏移量的地址指向一个人可以读懂的内核版本的字符串
        //该字段的值应该小于 0x200*setup_sects 
        //比如，如果字段的值为0x1c00，那么内核版本号的字符串保存在内核文件的0x1e00偏移处。
        //如果该字段的值为0x1c00，那么它只有在setup_sects >= 15 的情况下才有效。
        __u16   kernel_version;
        //如果bootloader被分配过ID，该字段里面填充的内容为0xTV, T表示bootloader的ID， V表示版本号
        //如果没有被分配过ID，那么就填充0xFF
        //如果T的值大于0xD，那么需要向该字段的T位置写如0xE，然后将 T - 0x10的值填入 ext_loader_type字段。
        //类似的，ext_loader_ver 字段用于扩展bootloader的版本
        //例如， T=0x15, V=0x234，那么type_of_loader = 0xE4, ext_loader_type = 0x05 and ext_loader_ver = 0x23
        //已经分配的bootloader的ID列表如下(十六进制):
        //  0  LILO         (0x00 reserved for pre-2.00 bootloader)
        //  1  Loadlin
        //  2  bootsect-loader  (0x20, all other values reserved)
        //  3  Syslinux
        //  4  Etherboot/gPXE/iPXE
        //  5  ELILO
        //  7  GRUB
        //  8  U-Boot
        //  9  Xen
        //  A  Gujin
        //  B  Qemu
        //  C  Arcturus Networks uCbootloader
        //  D  kexec-tools
        //  E  Extended     (see ext_loader_type)
        //  F  Special      (0xFF = undefined)
        //  10  Reserved
        //  11  Minimal Linux Bootloader <http://sebastian-plotz.blogspot.de>
        //  12  OVMF UEFI virtualization stack
        __u8    type_of_loader;
        //该字段表示一个位掩码
        //  Bit 0 (read): LOADED_HIGH
        //    0表示保护模式代码的加载位置为0x10000    (传统内存布局)
        //    1表示保护模式代码的加载位置为0x100000   (现代内存布局)
        //  Bit 1 (kernel internal): KASLR_FLAG
        //    内核内部使用，表示KASLR的状态，1表示KASLR开启，0表示KASLR关闭。
        //  Bit 5 (write): QUIET_FLAG
        //    0表示打印早期信息，1表示不打印早期信息
        //    该标志位要求内核不打印早期信息时，需要直接访问显示硬件设备。
        //  Bit 6 (write): KEEP_SEGMENTS
        //    Protocol: 2.07+
        //      0表示在进入保护模式时重新加载段寄存器
        //      1表示不重新加载段寄存器
        //  Bit 7 (write): CAN_USE_HEAP
        //    1表示heap_and_ptr的值是有效的
        //    0表示setup代码的功能将被禁止
        __u8    loadflags;
        //使用2.00或2.01版本的协议时，如果实模式内核没有加载到0x90000时，在稍后的加载时会将代码移动到0x90000
        //如果你想增加一些数据(如内核命令行)，那么就填充该字段。
        //The unit is bytes starting with the beginning of the boot sector
        //如果使用的是2.02及以上的协议或实模式的代码加载到了0x90000时，该字段可以被忽略
        __u16   setup_move_size;
        //该字段表示在保护模式下的跳转地址。 该地址表示内核的加载地址，该地址可以被bootloader使用。
        //该字段可能被修改的场景包括下面两个:
        // 1. 作为bootloader的hook(详情参见 ADWANCED BOOT LOADER HOOKS)
        // 2. 对于没有安装hook的bootloader需要在一个非标准地址加载一个可重定位的内核时，需要修改该字段的内容
        __u32   code32_start;
        //initial ramdisk或ramfs的线性地址，如果没有initial ramdisk 或ramfs时，设置为0
        __u32   ramdisk_image;
        //initial ramdisk或ramfs的大小，如果没有initial ramdisk或ramfs时，设置为0
        __u32   ramdisk_size;
        //该字段被废弃 
        __u32   bootsect_kludge;
        //该字段表示setup stack/heap结尾地址相对于实模式代码其实地址的偏移，减去0x200
        __u16   heap_end_ptr;
        //该字段用于type_of_loader中version的扩展。 最终的版本号为(type_of_loader & 0x0f) + (ext_loader_ver << 4)
        //2.6.31之前的内核版本不能识别该字段，但是在2.02及以上的版本中对该字段的设置仍然是安全的。
        __u8    ext_loader_ver;
        //该字段用于type_of_loader中type的扩展。
        //如果type_of_loader中的type为0xE，那么真实的类型应该是(ext_loader_type + 0x10)
        //如果type_of_loader中的type不为0xE，那么可以忽略该字段
        //2.6.31之前的内核版本不能识别该字段，但是在2.02及以上的版本中对该字段的设置仍然是安全的。
        __u8    ext_loader_type;
        //该字段用于保存内核命令行的线性地址。 内核的命令行可以被置于setup heap的end 至 0xA0000之间的任何位置
        //内核的命令行没有必要一定被置于与实模式代码相同的64K的段中
        //即使你的bootloader不支持命令行，最好也填充给字符，可以填充为空串(更好的情况是填充"auto")
        //如果该字段被设置为0，那么内核会假定为bootloader不支持2.02+以上的协议
        __u32   cmd_line_ptr;
        //initial ramdisk/ramfs可能用到的最大地址。 
        //对于2.02或更早的协议来说， 不存在该字段，最大地址为固定的0x37FFFFFF
        //如果你的ramdisk的大小为131072，且该字段的值为0x37FFFFFF，那么ramdisk的起始地址为0x37FE0000)
        __u32   initrd_addr_max;
        //该字段表示可重定位内核的对齐方式。 可重定位的内核在内核初始化的时候按照这种方式进行重新排列
        //从2.10版本的协议开始，该字段映射了内核的性能优化后的首选对齐方式。 
        //bootloader可以修改该字段为更小的对齐方式。 可以参考下面的min_alignment和pref_address字段
        __u32   kernel_alignment;
        //如果该字段不为0，那么保护模式的内核可以被加载到任何满足kernel_alignment对齐方式的地址中。
        //加载完成后，bootloader必须设置code_32_start字段为加载的代码的指针或boot的hook
        __u8    relocatable_kernel;
        //如果该字段的值不为0，2的该字段的幂次方表示内核引导的最小的对齐方式。
        //如果bootloader确认使用该字段，那么需要更新kernel_alignment字段为希望的值
        //通常情况下 kernel_alignment = 1 << min_alignment
        //出于采用未对齐的方式时可能会导致性能的降低，所以bootloader应该尽可能的采用
        //从kernel_alignment到该字段之间的 power-of-two 的值的对齐方式。
        __u8    min_alignment;
        // 该字段表示位掩码
        // Bit0(read): XLF_KERNEL_64
        //   1表示内核在0x200地址处有一个64-bit的入口地址
        // Bit1(read): XLF_CAN_BE_LOADED_ABOVE_4G
        //   1表示kernel/boot_params/cmdline/ramdisk可以使用4G以上地址
        // Bit2(read): XLF_EFI_HANDOVER_32
        //   1表示内核支持32bit EFI handoff入口地址(handover_offset)
        // Bit3(read): XLF_EFI_HANDOVER_64
        //   1表示内核支持64bit EFI handoff入口地址(handover_offset + 0x200)
        // Bit4(read): XLF_EFI_KEXEC
        //   1表示内核支持kexec EFI boot with EFI runtime support
        __u16   xloadflags;
        //命令行的大小的最大值(不包含结束符)。 这表示命令行可以包含最多cmdline_size个字符
        //2.05及之前的版本，最大值为255
        __u32   cmdline_size;
        //在半虚拟化的环境中，硬件底层的机制如中断处理，页表处理以及访问处理控制寄存器等需要不同的处理
        //该字段允许bootloader通知内核当前的运行环境，具体为以下几种：
        //  0x00000000    The default x86/PC environment
        //  0x00000001    lguest
        //  0x00000002    Xen
        //  0x00000003    Moorestown MID
        //  0x00000004    CE4100 TV Platform
        __u32   hardware_subarch;
        //该字段目前在x86/pc下面没有使用，不要修改该字段
        __u64   hardware_subarch_data;
        //如果该字段不为0，这表示payload相对保护模式代码起始地址的偏移量
        //有效载荷有可能会被压缩。 不管是压缩还是未被压缩的数据都会采用相同的魔数
        //当前支持的压缩方式有 gzip(magic: 1F8B or 1F9E), bzip2(magic: 425A)
        //LZMA(magic: 5D00), XZ(magic: FD37) 和 LZ4(magic: 0221)
        //未压缩的目前都是ELF格式(magic: 7F454C46)
        __u32   payload_offset;
        //The length of the payload
        __u32   payload_length;
        //该字段表示64-bit的物理地址，指向struct setup_data的单链表
        //该单链表用来定义一个可扩展的启动参数传递机制，setup_data的结构体如下:
        //  struct setup_data {
        //      u64 next;       //指向单链表的下一个节点
        //      u32 type;       //used to identify the contents of data
        //      u32 len;        //data 的长度
        //      u8 data[0];     //保存实际的payload数据
        //  }
        //在启动过程中可能会修改该链表。 因此，当修改这个链表的时候，必须考虑到链表中存在节点的情况
        __u64   setup_data;
        //该字段如果不为0表示内核的优先加载地址。 一个可重定向的bootloader应该能在该地址进行加载
        //一个不可重定位的内核接受无条件的移动并能在该地址进行加载。
        __u64   pref_address;
        //该字段表示大量的起始于内核运行时起始地址的连续的线性地址，
        //该起始地址是内核在其能检查自己的内存映射表之前所需的
        //该字段不同于内核引导需要的总内存大小，而是被可重定位的bootloader用于帮助内核选择一个安全的加载地址。
        //内核运行时起始地址的算法为:
        //  if(relocatable_kernel)
        //      runtime_start = align_up(load_address, kernel_alignment)
        //  else
        //      runtime_start = pref_address
        __u32   init_size;
        //该字段表示EFI handover协议入口地址相对内核映像起始地址的偏移量
        //采用EFI handover协议来引导内核的bootloader会跳转到该偏移地址
        //详细信息参考下面的 EFI HANDOVER PROTOCOL
        __u32   handover_offset;
    }


  Offset/Size | ProtoVer | Name | Meaning  | Type
  01F1/1 | All[^1] | setup_sects | The size of the setup in sectors | read
  01F2/2 | All | root_flags | If set, the root is mounted readonly | modify(optional)
  01F4/4 | 2.04+[^2] | syssize | The size of the 32-bit code in 16-bytes paras | read
  01F8/2 | All | ram_size | DO NOT USE - for bootsect.S use only | kernel internal
  01FA/2 | All | vid_mode | Video mode control | modify(obligatory)
  01FC/2 | All | root_dev | Default root device number | modify(optional)
  01FE/2 | All | boot_flag | 0xAA55 magic number | read
  0200/2 | 2.00+ | jump | Jump instruction | read 
  0202/4 | 2.00+ | header | Magic signature "HdrS" | read
  0206/2 | 2.00+ | version | Boot protocol version supported | read
  0208/4 | 2.00+ | realmode_swtch | Boot loader hook (see below) | modify(optional)
  020C/2 | 2.00+ | start_sys_seg | The load-low segment(0x1000) (obsolete) | read
  020E/2 | 2.00+ | kernel_version | Pointer to kernel version string | read
  0210/1 | 2.00+ | type_of_loader | Boot loader identifier | write(obligatory)
  0211/1 | 2.00+ | loadflags | Boot protocol option flags | modify(obligatory)
  0212/2 | 2.00+ | setup_mode_size | Move to high memory size (used with hooks) | modify(obligatory)
  0214/4 | 2.00+ | code32_start | Boot loader hook (see below) | modify(optional, reloc)
  0218/4 | 2.00+ | ramdisk_image | initrd load address (set by bootloader) | write(obligatory)
  021C/4 | 2.00+ | ramdisk_size | initrd size (set by bootloader) | write(obligatory)
  0220/4 | 2.00+ | bootsect_kludge | DO NOT USE - for bootsect.S use only | kernel internal
  0224/2 | 2.01+ | heap_end_str | Free memory after setup end | write(obligatory)
  0226/1 | 2.02+[^3] | ext_loader_ver | Extended boot loader version | write(optional)
  0227/1 | 2.02+[^3] | ext_loader_type | Extended boot loader ID | write(obligatory if(type_of_loader&0xf0) == 0xe0)
  0228/4 | 2.02+ | cmd_line_str | 32-bit pointer to the kernel command line | write(obligatory)
  022C/4 | 2.03+ | initrd_addr_max | Highest legal initrd address | read
  0230/4 | 2.05+ | kernel_alignment | Physical addr alignment required for kernel | read/modify(reloc)
  0234/1 | 2.05+ | relocatable_kernel | Whether kernel is relocatable or not | read(reloc)
  0235/1 | 2.10+ | min_alignment | Minimum alignment, as a power of two | read(reloc)
  0236/2 | 2.12+ | xloadflags | Boot protocol option flags | read
  0238/4 | 2.06+ | cmdline_size | Maximum size of the kernel command line | read
  023C/4 | 2.07+ | hardware_subarch | Hardware subarchitecture | write(optional, defaults to x86/PC)
  0240/8 | 2.07+ | hardware_subarch_data | Subarchitecture-specific data | write(subarch-dependent)
  0248/4 | 2.08+ | payload_offset | Offset of kernel payload | read
  024C/4 | 2.08+ | payload_length | Length of Kernel payload | read
  0250/8 | 2.09+ | setup_data | 64-bit physical pointer to linked list or struct setup_data | write(special)
  0258/8 | 2.10+ | pref_address | Preferred loading address | read(reloc)
  0260/4 | 2.10+ | init_size | Linear memory required during initialization | read
  0264/4 | 2.11+ | handover_offset | Offset of handover entry point | read

  [^1]: 为了向后兼容，如果setup_sectsd为0，会强制修改为4。

  [^2]: 在2.04之前的版本，使用的是低16bits。

  [^3]: 版本2.02 - 2.09中被忽略的，但是如果设置的话也没有问题。


如果0x202偏移处("header"字段)的magic不是"Hdrs", 表示boot protocol的版本是老的。加载的是旧内核，会假设下面的参数被设置:

    Image type = zImage
    initrd not supported
    Real-mode kernel must be located at 0x90000

否则，"version"字段就包含了协议的版本。比如， 协议版本是 2.01 的话，version里面的值为 0x0201， 注意一定要确保填写的各个字段的值是当前这个protocol协议所支持的。

> 类型说明
>>read : 表示信息从kernel 到 bootloader
>>write : 表示信息由bootloader填写
>>modify： 表示信息先从kernel 读到 bootloader，然后bootloader会做修改

>>所有普通意义上的bootloader都应该填写带有obligatory的字段。 
>>对于需要采用非标准地址加载内核的bootloader需要填写带有reloc标志的字段， 其他的bootloader可以忽略带有该标志的字段。

>所有字段的字节序为小端模式(x86)

