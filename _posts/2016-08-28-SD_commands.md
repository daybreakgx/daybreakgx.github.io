---
layout: post
title: "SD Commands"
categories: sd
tags: sd
---

* content
{:toc}

##### 命令类型

* 下面是4种用于控制SD卡的命令:

  + Broadcast commands(bc), no response.

  + Broadcast commands with response(bcr)

  + Address(point-to-point) commands(ac) no data transfer on DAT
    由HOST发送到指定的卡设备，没有数据传输 

  + Address(point-to-point) data transfer commands(adtc) data transfer on DAT
    由HOST发送到指定的卡设备，且伴随有数据传输

* 所有的命令和响应都是通过CMD线进行传输。

##### 命令格式

所有的命令长度都是48bits。格式如下:

  ![cmd_format](/image/sd/sd_cmd_format.png)

  > 表格中的'x'表示，这些位的具体内容根据不同的命令填充不同的值。
  
  一个命令总是由一个起始bit(固定为0)开始，跟在起始bit后面的是bit位表示传输的方向(host = 1)。

  接下来的6个bit位表示命令的索引值，6个bit位最多支持64个命令。

  有些命令需要参数，参数内容由32个bit位表示。所有的命令都有CRC校验功能。


##### 命令分类

* SD卡的命令集被分成了12类，见下图所示:

  ![sd_cmd_classes](/image/sd/sd_cmd_classes.png)

  > CCC: Card Command Class

* 命令分类实现

  + Class 0,2,4,5和8是所有的SD卡都必须支持的。

  + Class 7中除了CMD40以外，是SDHC和SDXC卡都必须支持的。

  + 其他类别的命令都是可选实现。

  > 详细的命令实现信息参见 << Physical_Specification>> Table: Command Support Requirements。

* SD卡的分类支持情况信息保存在CSD(card specific data)寄存器的CCC域内。提供给主机如何访问该卡的信息。


##### 命令响应

* 所有的响应也是通过cmd线进行传输的。不同的响应的数据长度不同。

* 响应总是右一个起始bit位(固定为0)开始，跟在起始位后面的bit位表示传输方向(card = 0)。
  除了R3，其他的所有响应都有CRC校验功能，所有的响应都是由一个结束bit位(固定为1)结尾。

* 响应分类

  具体分类如下，其中R4和R5是SDIO中特有的。

  + R1(normal response command)
    
    ![sd_rsp_r1](/image/sd/sd_rsp_r1_format.png)

  + R1b
   
    R1b is identical to R1 with an optional busy signal transmitted on data line. The card may become busy after receiving these commands based on its state prior to the command reception. The Host shall check for busy at the response.

  + R2(CID, CSD register)
   
    用来响应CMD2和CMD10，返回CID寄存器的内容。
    用来响应CMD9，返回CSD寄存器内容

    ![sd_rsp_r2](/image/sd/sd_rsp_r2_format.png)

    > 响应中只传输了CID和CSD寄存器的[127...1]bits。寄存器中的bit0被响应的结束bit位取代。

  + R3(OCR register)
   
    用来响应ACMD41，返回OCR寄存器的内容

    ![sd_rsp_r3](/image/sd/sd_rsp_r3_format.png)

  + R6(Published RCA response)
  
    分配相对卡地址的响应

    ![sd_rsp_r6](/image/sd/sd_rsp_r6_format.png)

  + R7(Card interface condition)
  
    响应CMD8，返回卡支持的电压信息。

    ![sd_rsp_r7](/image/sd/sd_rsp_r7_format.png)

  + R4(CMD5)

    响应CMD5，并把OCR寄存器作为响应数据

  + R5(CMD52)

    CMD52是一个读写寄存器的指令，R5用于CMD52的响应。

 
