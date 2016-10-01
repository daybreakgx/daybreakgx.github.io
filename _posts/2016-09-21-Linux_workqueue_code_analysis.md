---
layout: post
title: "Linux Kernel cmwq 代码分析"
categories: kernelCode
tags: cmwq wq workqueue
---

* content
{:toc}

##### 结构体关系图

下图中显示cmwq中主要结构体的关系

![cmwq_struct_relation](/image/cmwq/cmwq_struct_relation_v1.0.png)

##### cmwq初始化流程

