---
layout: post
title: "Linux Kernel macros"
categories: kernel 
tags: macro
---


* content
{:toc}

###### module_platform_driver

* module_platform_driver宏 定义在头文件 platform_device.h 中

      /* module_platform_driver() - Helper macro for drivers that don't do
       * anything special in module init/exit.  This eliminates a lot of
       * boilerplate.  Each module may only use this macro once, and
       * calling it replaces module_init() and module_exit()
       */
      #define module_platform_driver(__platform_driver) \
	  module_driver(__platform_driver, platform_driver_register, \
			platform_driver_unregister)

* modlue_driver宏 定义在头文件 device.h 中

      /**
       * module_driver() - Helper macro for drivers that don't do anything
       * special in module init/exit. This eliminates a lot of boilerplate.
       * Each module may only use this macro once, and calling it replaces
       * module_init() and module_exit().
       *
       * @__driver: driver name
       * @__register: register function for this driver type
       * @__unregister: unregister function for this driver type
       * @...: Additional arguments to be passed to __register and __unregister.
       *
       * Use this macro to construct bus specific macros for registering
       * drivers, and do not use it on its own.
       */
      #define module_driver(__driver, __register, __unregister, ...) \
      static int __init __driver##_init(void) \
      { \
          return __register(&(__driver) , ##__VA_ARGS__); \
      } \
      module_init(__driver##_init); \
      static void __exit __driver##_exit(void) \
      { \
          __unregister(&(__driver) , ##__VA_ARGS__); \
      } \
      module_exit(__driver##_exit);

* 因此 module_platform_driver(xxx);的展开后结果为:

      static int __init xxx_init(void)
      {
          return platform_driver_register(&(xxx));
      }
      module_init(xxx_init);
      static void __exit xxx_exit(void)
      {
          platform_driver_unregister(&(xxx));
      }
      module_exit(xxx_exit);


