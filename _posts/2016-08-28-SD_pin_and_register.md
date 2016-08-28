---
layout: post
title: "SD Memory Card-Pins and Registers"
categories: sd
tags: sd
---

* content
{:toc}

##### SD Bus Pin Assignment

* 标准大小的SD卡的外形和接口

  ![sd_ss_bus_pin](/image/sd/sd_ss_bus_pin.png)

* 引脚说明

  ![sd_ss_bus_pad_assignment](/image/sd/sd_ss_bus_pad_assignment.png)

* 内部结构

  ![sd_ss_arch](/image/sd/sd_ss_arch.png)

##### 寄存器

  ![sd_register](/image/sd/sd_registers.png)

###### OCR 寄存器

Operating Conditions Register(OCR)

* 这个32bits的寄存器保存了VDD电压(非UNS-II模式)/VDD1电压(UNS-II模式)信息。除此之外，该寄存器还保存了一些状态信息位。

  ![sd_OCR](/image/sd/sd_OCR.png)

* Bit31: Card power up status bit, 当sd卡的上电流程完成后，该标志位被设置

* Bit30: Card Capacity status bit

  + 0: 表示该卡为SDSC
  + 1: 表示该卡为SDHC/SDXC

  该bit位在卡上电完成且bit31位被设置后才有效。主机(HOST)通过读该bit来确认sd卡是SDSC还是SDHC/SDXC。

* Bit7: 该标志为是为Dual Voltage Card新定义的，默认值为0。
  当Dual Voltage Card没有接收到CMD8时，该标志位为0.
  当Dual Voltage Card接收到CMD8后，该标志被置位1.

* 当SD卡不支持某个电压范围时，对应的bit位被置位LOW。
  当卡的状态为busy时，bit31被设置为LOW。


###### CID 寄存器

Card Identification Register(CID)

* 该寄存器中保存了卡认证阶段(identification phase)需要的ID信息，所有的读写卡都有一个唯一标示的ID号。

  ![sd_CID](/image/sd/sd_CID.png)


###### CSD 寄存器

Card Specific Data Register(CSD)

* 该寄存器有两个版本，当CSD_STRUCTURE中的值为0表示版本1.0，对应标准容量的SD卡(SDSC)。
  当CSD_STRUCTURE中的值为1时表示版本2.0，对应高容量和超高容量的SD卡(SDHC/SDXC)。

  ![sd_CSD_1.0](/image/sd/sd_CSD_1.0.png) 

  
  ![sd_CSD_2.0](/image/sd/sd_CSD_2.0.png) 

* R = readable, W(1) = writable once, W = multiple writable

###### RCA 寄存器

Relative Card Address(RCA)

* 在SD总线模式下，该寄存器中保存了卡在认证阶段(identification)发布的器件地址信息。该地址用于认证完成后的主机与卡之间的通信。它的默认值为0x0000。

* 在UHS-II模式下，该寄存器中保存的是Node ID。


###### DSR 寄存器

Driver Stage Register(DSR)

该寄存器是可选的。

如果选择使用该寄存器，通常用于扩展总线的操作。
It can be optionally used to improve the bus performance for extended operating conditions(depending on parameters like bus length, transfer rate or number of cards).

CSD寄存器中有标志位保存DSR寄存器是否使用的信息。DSR寄存器的默认值为0x404


###### SCR 寄存器

SD Card Configuration Register(SCR)

SCR保存了SD卡支持的一些特殊特性信息，该寄存器的内容由制造商在生产过程中设置。

  ![sd_SCR](/image/sd/sd_SCR.png)


