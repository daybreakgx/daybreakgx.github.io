---
layout: post
title: "SD Memory Card Function Description"
categories: sd
tags: sd
---

* content
{:toc}


##### 概述

* 主机(Host)和sd卡之间的通信都是由主机Host(master)来控制的。主机发送的命令有两种:

  + Broadcast commands，广播命令。发送给所有挂在SD总线上的SD卡，有一些广播命令需要SD卡做出响应。

  + Addressed(point-to-point) commands，点对点寻址命令。寻址命令只发给具有相应地址的卡，并需要返回一个响应。

* SD Memory Card system(host and cards)定义了两种操作模式:

  + Card identification mode: 

    主机(Host)在被重置(reset)或主机查找SD总线上的新卡时，处于卡识别模式。

    卡(Card)在被重置(reset)后处于卡识别模式，直到接收到SEND_RCA(CMD3)命令。

  + Data transfer mode: 

    主机(Host)在识别完总线上的所有卡之后进入数据传输模式。

    卡(Card)在第一次发布(publish)RCA后进入数据传输模式。

  ![card_state_operation_mode](/image/sd/sd_card_state_operation_mode.png)


##### 卡识别模式(Card Identification Mode)

* 当处于该模式时，主机(Host)会重置所有处于卡识别模式的卡，确认操作电压范围，识别卡，请求卡发送(publish)相对卡地址(Relative Card Address, RCA)。这些操作都是在各自的CMD线上完成的。所有的通信都仅仅使用了CMD线。

  During the card identification process, the card shall operate in the SD clock frequecy of the identification clock rate fod.

* 卡识别模式的状态转换图

  ![card_ident_mode_state_diagram](/image/sd/sd_ident_mode_state_diagram.png)

###### 卡复位

* 在SD模式下，命令GO_IDLE_STATE(CMD0)是软复位命令，该命令会设置卡进入空闲状态(idle state)。处于非活动状态(inactive state)的卡接受到该命令时无响应。

* 所有的卡在被主机执行power-on之后都会进入 空闲状态(idle state)，即使是以前处于非活动状态的卡。

* 空闲状态的SD卡的CMD线处于输入状态，等待主机下发下一个命令。SD卡的RCA默认初始化为0x0000。 

###### 操作条件检测

* 在Host和card进行通信之前，Host可能不清楚card支持的电压范围。此时Host首先使用card可能支持的电压发送一条CMD0命令，紧接着发送一条CMD8命令获取SD卡支持的工作电压范围数据。

  SEND_IF_COND(CMD8)命令通常用于确认SD卡的工作条件。SD卡通过解析命令的argument域中的数据(VHS)确认Host当前使用的操作条件(工作电压)的有效性。Host通过CMD8的响应来确认SD卡是否能够在所给的电压下工作。

  当卡能够在Host给定的电压下工作时，卡会给Host发送响应回填CMD8命令中的argument域中的数据。

  当卡不能在Host给定的电压下工作时，SD卡不会发送响应给主机，并保持处于idle状态。

  SD_SEND_OP_COND(ACMD41)命令提供了一种机制来确认SD卡是否可以在Host给定的Vdd范围下工作。如果SD卡无法在给定的VDD范围内工作，则进入inactive state。需要注意的是，ACMD41命令是appliction-specific 命令，每次发送ACMD41命令之前都要先发送APP_CMD(CMD55)。在空闲状态CMD55命令使用默认的卡相对地址RCA=0x0000。


###### 卡初始化和识别流程

* SD卡的初始化开始于接收到ACMD41命令之后。

  如果ACMD41中的HCS(Host Capacity Support)域被设置为1，表示Host支持SDHC/SDXC卡，否则表示Host不支持。

  + 对于没有响应CMD8命令的卡，会忽略ACMD41命令中的HCS参数。所以，主机在向不响应CMD8命令的SD卡发送ACMD41命令时，应该将HCS置位0。
  + 对于响应了CMD8命令的卡，卡返回ACMD41命令的响应中，当busy bit为1时，如果CCS位被置位0，表示该卡为SDSC卡，如果CCS位被置位1，表示该SD卡为SDHC/SDXC卡。

  如果主机发送的ACMD41命令中HCS被置位0，当SDHC或SDXC卡接受到该命令时，会一直返回busy。

  ACMD41的响应为OCR寄存器的内容，其中的busy bit被SD卡用于通知Host，ACMD41命令是否处理完成，当busy bit被设置为0，表示sd卡仍在处理ACMD41命令，当busy bit被置位1，表示sd卡处理ACMD41命令完成。
  
  主机Host会重复发送ACMD41指令，直到返回的busy bit为1 或 连续发送时间超过1秒为止。在此期间，Host不能发送除了CMD0之外的其他命令。

  Host会对所有卡执行相同的流程，与Host不兼容的卡会进入inactive state.

* 随后Host会发送All_SEND_CID(CMD2)来获取各个卡的CID，SD卡在发送完CID后，进入识别状态(identificaiont state)。

* Host发送SEND_RELATIVE_ADDR(CMD3)命令要求各个SD卡更新相对卡地址信息。RCA信息发送完后，SD卡进入stand-by state。


  ![sd_init_ident_flow](/image/sd/sd_init_ident_flow.png)


##### 数据传输模式(Data Transfer Mode)

* 数据传输模式状态转换图

  ![sd_data_trans_state_diagram](/image/sd/sd_data_trans_state_diagram.png)

* 在SD卡结束识别模式之前，Host一直保持Fod的工作频率，在数据传输模式中，Host的工作频率会切换到Fpp。

* Host发送SEND_CSD(CMD9)命令来获取SD卡的CSD寄存器信息，如块长度，卡容量信息等。

  广播命令SET_DSR(CMD4)用于配置所有已识别卡的Driver Stages，它设置DSR寄存器中的bus layout(length)，卡的数量和数据传输频率。时钟频率也在此时被转换为Fpp。SET_DSR命令对于Host和卡都是可选的。

* CMD7命令用于选择一个卡，并将其设置为Transfer State。在任何时间，只能有一张卡处于传输状态。如果选择的卡当前已经处于传输状态时，再对其发送CMD7命令会将其转换到Stand-by 状态。

  当CMD7以保留地址0x0000发送时，所有的卡都被设置为stand-by状态。这个功能可以别用于识别新卡同时不重置其他已经注册的卡。处于stand-by状态且已经有RCA地址的卡不都会响应识别命令(CMD2, CMD3 ACMD41)。

* 所有的数据读命令在任意时刻都可以被停止命令(CMD12)终止。
  数据传输会终止，同时SD卡会返回Transfer State。
  读命令有：块读操作（CMD17）、多块读操作（CMD18）、发送写保护（CMD30）、发送scr（ACMD51）以及读模式下的普通命令（CMD56）。

* 所有的数据写命令在任意时刻都可以被停止命令(CMD12)终止。
  写命令应该在取消选择命令（CMD7）之前停止。
  写命令有：块写操作（CMD24，CMD25）、编程命令（CMD27）、锁定/解锁命令（CMD42）以及写模式下的普通命令（CMD56）。

* 数据传输一旦完成，SD卡会退出数据写状态，进入Programming状态（传输成功）或者Transfer状态（传输失败）

* 如果块写操作被停止，但是写操作包含的最后一个块的长度和CRC校验是正确的话，数据会被编程到SD卡（从缓存写入到Flash）。

* 卡可能提供块写缓冲。 这意味着在前一块数据被操作时，下一块数据可以传送给卡。如果所有卡写缓冲已满， 只要卡在 Programming State， DAT0 将保持低电平（BUSY）。

* 写CSD、CID、写保护和擦除时没有缓冲。这表明当卡在处理这些命令时，不再接收其他数据传输命令。 
  在卡处于busy 且处于Programming State时，DAT0 保持低电平。
  实际上如果SD卡的 CMD 和 DAT0 线分离，而且主机占有的忙 DAT0 线与其他卡的 DAT0 线没有连接时，主机可以访问其他卡。

* 在卡被编程(programming)时，不允许接收参数设置命令。参数设置命令包括：设置块长度（CMD16），擦除块开始(CMD32)和擦除块结束（CMD33）。

* 在卡被编程(programming)时，不允许接收读命令

* 使用 CMD7 指令把另一个卡从 Stand-by 状态转移到 Transfer 状态不会中止擦除和编程（programming）操作。卡将切换到 Disconnect 状态并释放 DAT 线。

* 使用 CMD7 指令可以选中处于 Disconnect 状态的卡。卡将进入 Programming 状态，重新激活忙指示。

* 使用 CMD0 或 CMD15 重置卡将中止所有挂起和活动的编程（programming）操作。这可能会破坏卡上的数据内容，需要主机保证避免这样的操作。

* CMD34-37 CMD50，CMD57保留。





