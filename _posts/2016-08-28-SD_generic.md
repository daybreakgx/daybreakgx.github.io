---
layout: post
title: "SD基本概念及规格"
categories: driver
tags: sd 
---

* content
{:toc}


##### 基本概念

* MMC: Multi Media Card, 即多媒体卡。它是一种非易失性存储器件，体积小巧，容量大，耗电量低，传输速度快，广泛应用于消费电子产品中。

* SD: Secure Digital Memory Card，即安全数码卡。它在MMC的基础上发展而来，相比MMC它有两个主要优势:
  
  + SD卡强调数据的安全，可以设定存储的使用权限，防止数据被他人复制。
  + 传输速率比2.11版的MMC卡快。

  在数据传输和物理规范上，SD卡向前兼容了MMC卡，所有支持SD卡的设备也支持MMC卡。

* SDIO: Secure Digital Input and Output Card，即安全数字输入输出卡。SDIO是在SD标准上定义了的一种外设接口，通过SD的I/O引脚来连接外围设备，并且通过SD上的I/O数据位与这些外围设备进行数据传输。如下图中的一些设备: GPS、相机、WIFI、调频广播、条形码读卡器、蓝牙等。

  ![sdio_device](/image/sd/sdio_device.png)

* 相关网址

  + sd官网: [https://www.sdcard.org](https://www.sdcard.org)
  + Simple Specification 下载地址: [https://www.sdcard.org/downloads/pls/index.html](https://www.sdcard.org/downloads/pls/index.html)

    ![sd_spec_doc_structure](/image/sd/sd_spec_doc_structure.png) 

##### SD家族

  ![sd_family](/image/sd/sd_family.PNG)

##### SD存储卡分类

  ![sd_storage_card](/image/sd/sd_storage_card.png) 

* 根据容量划分

  + SD(SDSC): Standard Capacity SD Memory Card: Up to and including 2GB, using FAT12 and FAT16 file systems. All versions of the PLS define.

  + SDHC: High Capacity SD Memory Card: More than 2GB and up to and including 32GB, using FAT32 file system. It is defined from the PLS Ver2.00.

  + SDXC: Extended Capacity SD Memory Card: More than 32GB and up to and including 2TB, using exFAT file system. 

  > The Part 1 PLS Ver3.00 or later and Part 2 FSS Ver3.00 or later 支持上述所有容量类型的SD卡 


  ![sd_cap_type](/image/sd/sd_cap_type.png)

* 根据体积划分

  + SD: Standard Size SD Memory Card
  + miniSD
  + microSD

  ![sd_volume](/image/sd/sd_volume.png)

* 根据读写方式划分

  + Read/Write(RW) cards.
  + Read Only Memory(ROM) cards.

* 根据工作电压划分

  + High Voltage SD Memory Cards that can operate the voltage range of 2.7 - 3.6V.
  + UHS-II SD Memory Card that can operate the voltage range VDD1: 2.7 - 3.6V, VDD2: 1.70 - 1.95V. 

  > UHS-II: Ultra High Speed Phase II 


##### SD支持的总线速率模式

Bus Speed Mode(using 4 parallel data lines)

* Default Speed Mode: 3.3V signaling, Frequency up to 25MHZ, up to 12.5MB/sec

* High Speed Mode: 3.3V signaling, Frequency up to 50MHZ, up to 25MB/sec

* SDR12: UHS-I 1.8V signaling, Frequency up to 25MHZ, up to 12.5MB/sec

* SDR25: UHS-I 1.8V signaling, Frequency up to 50MHZ, up to 25MB/sec

* SDR50: UHS-I 1.8V signaling, Frequency up to 100MHZ, up to 50MB/sec

* SDR104: UHS-I 1.8V signaling, Frequency up to 208MHZ, up to 104MB/sec

* DDR50: UHS-I 1.8V signaling, Frequency up to 50MHZ, sampled on both clock edges, up to 50MB/sec

* FH156: UHS-II Full Duplex mode up to 156MB/sec at 52MHZ in Range B.

* HD312: UHS-II Half Duplex with 2 Lanes mode up to 312MB/sec at 52MHZ in Range B.

> SDR: Single Data Rate signaling, 单边数据采样，要么上升沿采样，要么下降沿采样
  DDR: Double Data Rate signaling, 双边数据采样，双边沿采样

  ![sd_bus_speed_mode](/image/sd/sd_bus_speed_mode.png)

  ![sd_bus_speed_mode_2](/image/sd/sd_bus_speed_mode_2.png)



