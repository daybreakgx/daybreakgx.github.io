---
layout: post
title: "SD Commands"
categories: driver
tags: sd
---

* content
{:toc}

##### SD总线协议

* SD总线之间的通信是基于命令和数据比特流的。它们都是开始于起始位，终止于结束位。

  + Command: 一个命令代表了一个操作的开始。命令总是由主机发送给单个(addressed command)或所有(broadcast command)的卡。命令是通过CMD线串行传输的。

  + Response: a response is a token that is sent from an addressed card, or (synchronously) from all connected cards, to the host as an answer to a previously received command. A response is transferred serially on the CMD line.

  + Data: data can be transferred from the card to the host or vice versa. Data is transferred via the data lines.

* 卡的寻址是通过session address实现的。它是在卡的初始化阶段就被分配好的。SD总线中最基础transaction 就是 command/response。这种模式下，总线直接通过命令或响应的结构体进行信息传递。除此之外，其他操作有数据传递。

  数据传输是以block为单位的。数据块后面总是带有CRC校验位。数据传输分为单块和多块数据传输。多块数据传输通常由stop命令来结束数据传输操作。

  主机(HOST)可以配置数据传输方式为单块或多块。

  在块写操作中，使用了一种简单的等待机制。通过判断DATA0信号状态来判断卡是否busy还是ready。

  ![sd_bus_cmd_resp](/image/sd/sd_bus_cmd_resp_mode.png)

  ![sd_bus_read_mode](/image/sd/sd_bus_read_mode.png)

  ![sd_bus_write_mode](/image/sd/sd_bus_write_mode.png)

* command and response 
  
  + 都是由start bit(0)开始，由end bit(1)终止

  + 命令长度为48bits，响应长度为48bits或136bits
  
  + 都包含CRC校验位

  + CMD line上的数据传输方式: MSB(Most Significant Bit) 先传输，LSB(Least Significant Bit)后传输

  ![sd_cmd_token_format](/image/sd/sd_cmd_token_format.png)

  ![sd_reps_token_format](/image/sd/sd_resp_token_format.png)

* data packet format

  + Usual data(8-bit width): 在字节之间先传输低字节，在字节内部先传输高比特位。  
  
  + Wide width data(SD Memory Register): 共有512 bit，先传输高比特位，后传输低比特位。

  ![sd_bus_usual_data](/image/sd/sd_bus_usual_data_mode.png)

  ![sd_bus_wide_width_data](/image/sd/sd_bus_wide_width_data_mode.png)

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


##### 命令详细

###### Basic Commands

  ![basic_commands](/image/sd/sd_basic_commands.png)

###### Block-Oriented Read Commands

  ![block_read_commands](/image/sd/sd_block_read_commands.png)

###### Block-Oriented Write Commands

  ![block_write_commands](/image/sd/sd_block_write_commands.png)

###### Block-Oriented Write Protection Commands 

  ![block_write_protection_commands](/image/sd/sd_block_write_protection_commands.png)

###### Erase Commands

  ![erase_commands](/image/sd/sd_erase_commands.png)

###### Lock Card Commands

  ![lock_card_commands](/image/sd/sd_lock_card_commands.png)

###### Application-Specific Commands

  ![app_spec_commands](/image/sd/sd_app_specific_commands.png)

  The following table describes all the application-specific commands supported/reserved by the SD Memory Card. All the following ACMDs shall be preceded with APP_CMD commands(CMD55).

  ![ACMD_commands](/image/sd/sd_ACMD_commands.png)

###### I/O Mode Commands
 
  ![io_mode_commands](/image/sd/sd_io_mode_commands.png)

###### Switch Function Commands

  ![switch_func_commands](/image/sd/sd_switch_func_commands.png)

###### Function Extension Commands

  ![function_extension](/image/sd/sd_func_ext_commands.png)



