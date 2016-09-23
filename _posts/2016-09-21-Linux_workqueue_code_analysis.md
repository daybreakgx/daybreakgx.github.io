---
layout: post
title: "Linux cmwq 代码分析"
categories: kernel
tags: cmwq wq workqueue
---

* content
{:toc}

##### 结构体关系图

下图中显示cmwq中主要结构体的关系

![cmwq_struct_relation](/image/cmwq/cmwq_struct_relation_v1.0.png)

##### cmwq初始化流程

