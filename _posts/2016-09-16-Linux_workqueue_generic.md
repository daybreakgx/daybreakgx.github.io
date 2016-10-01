---
layout: post
title: "Linux Kernel cmwq 介绍"
categories: kernelDoc
tags: workqueue cmwq wq kernel
---

* content
{:toc}

##### cmwq

Concurrency Managed Workqueue

内容参考:

* 内核文档: linux-4.4.23/documentation/workqueue.txt

* [蜗窝科技](http://www.wowotech.net/irq_subsystem/cmwq-intro.html)

##### 介绍

* 工作队列(workqueue, wq)通常适用于需要异步处理流程的场景。

* 当需要一个异步执行上下文时，只需定义一个work(指定了异步处理函数)，并将其加入工作队列中，内核就会有一个独立的线程(worker)处理该需要异步执行的上下文。

* worker线程会一个接一个的执行wq中每一个work对应的异步处理函数，当所有work都执行完了后，worker线程进入idle状态。当一个新的work加入wq后，worker线程又被重新唤醒继续执行。 

##### 为什么需要cmwq

* 在最初的wq实现中，一个multi threaded(MT)类型的wq需要在每一个CPU上创建一个worker线程，而single threaded(ST)类型的wq在系统内只创建一个worker线程。每一个MT工作队列都要在系统内创建与CPU核数相同数量的worker线程。随着内核中使用MT工作队列的增多以及CPU核数的持续增加，有些系统在刚启动后就达到了线程个数的上限。

* 虽然MT工作队列消耗了大量的资源，但是并没有取得惊人满意的并发效果。每一个wq维护其独立的worker线程池。一个MT工作队列在每个CPU核上只能提供一个可执行上下文，一个ST工作队列在整个系统中只能提供一个可执行上下文。这就要求work必须在有限的可执行上下文中完成处理，很容易导致在单可执行上下文中常见的死锁等问题。

* 关于并发效果:

  + 对于ST wq，这种情况完全没有并发的概念，任何的work都是串行排队执行，如果正在执行的work很慢，那么队列中的其他work除了等待别无选择。

  + 对于MT的wq，虽然创建了线程池，但是线程池的数目是固定的：每个online的cpu上运行一个，而且是严格的绑定关系。也就是说本来线程池是一个很好的概念，但是传统的wq上的线程池却分割了每个线程，线程之间不能互通有无。例如，cpu0上的worker线程由于处理work而进入阻塞状态，那么该worker线程处理的wq上其他的work都被阻塞住，不能转移到其他cpu的worker线程中去，更有甚者，cpu0上随后挂入的work也有同样的命运(在某个cpu上schedule的work一定会运行在那个cpu上)，不能到其他空闲的worker线程上执行。

* 关于死锁：

  假设某个驱动模块比较复杂，使用了两个work，分别为A 和 B，如果A依赖B的执行结果，那么，当这两个work都调度到一个worker线程上的时候就会出现问题，由于worker线程不能并发执行A和B，因此该驱动模块可能会死锁。MT的工作队列能减轻这个问题，但不能从根本上解决，毕竟work A和work B还是有可能被调度到一个CPU上执行。造成这些问题的根本原因是众多的work竞争一个执行上下文导致的。

* 这种消耗了大量资源，但是没有提供良好并发性能的问题，导致了很多使用者不得不做出一些不必要的权衡。如libata模块中使用了ST wq来轮询(poll) PIO，就会有不能同时轮询(poll)两个PIO的限制。由于MT没有提供良好的并发效果，需要支持高并发的使用者(如async和fscache)不得不实现自己的一套线程池。

* cmwq是一套重构的wq机制，它的实现聚焦于以下目标：

  + 与之前的wq API兼容

  +  在不浪费大量资源的要求下，每个CPU使用统一的、对所有wq共享的worker线程池保证了灵活的并发性。

  +  自动调节worker线程池和并发度，这样，API的使用者就不需要关注具体的细节。

##### cmwq设计

* 为了减少函数的异步执行，对work进行了异步抽象。

* work是一个简单的结构体(work_struct)，它保存了一个待异步执行函数的指针。当驱动或子系统需要一个流程异步执行时，它必须创建一个work_struct，将异步调用函数指针保存其中，然后将work_struct加入wq中。

* worker线程从wq中取出work并执行其中的异步处理函数。当wq中没有work后，worker线程进入idle状态。所有worker线程被集中管理，称为worker-pool。

* cmwq设计明确区分了面向用户的前端工作队列接口和后端worker线程池的管理机制。

* cmwq的worker线程分为两种：

  + 与cpu绑定的线程池，这种线程池又分为普通优先级和高优先级两种。

  + 未与cpu绑定的线程池

  这些线程池的数量是动态变化的。

* 驱动和子系统可以通过API接口选择合适的方式创建work然后将其加入wq。用户可以通过创建wq并设置其flag来约束挂入该wq上work的处理方式。这些wq的flag包括cpu locality, 并发限制，优先级等。具体信息可以查看下面的alloc_workqueue的接口描述。

* 当一个work加入wq后，会根据wq的参数，属性和共享方式等将其交给系统中的某个work-pool进行处理。例如，除非进行了特殊设置，一个设置了绑定类型的wq中的work，将会交由当前cpu的普通或高优先级的work-pool进行处理。

* 对于所有worker线程池的实现，并发度的管理(多少个可执行上下文是active的)都是一个很重要的事情。cmwq尝试保持最小且足够用的并发度。本质上这是一个需要在并发性和系统资源消耗上进行平衡的问题。

* 每一个绑定到真实cpu上work-pool依赖调度器进行并发管理。当一个active的worker线程被唤醒或睡眠时，都会通知worker-pool，同时worker-pool会记录当前可运行(runnable)的worker的数量。通常情况下，work都不会设计为长时间占用cpu，这意味着维护能够预防work长时间处理且足够够用的并发是最佳选择。只要CPU上有一个或多个runnable的worker线程在运行，worker-pool就不会启动新的work执行动作，但是当最后一个running的worker线程睡眠后，worker-pool会立即调度一个新的worker线程，这样cpu就不会在有处于pending状态的work时进入idle状态。这样就会保持一直使用最小数量的worker线程但又不会丢失可执行线程带宽。

* 一直保持空闲的worker线程会消耗kthread的内存空间，当worker线程处于idle状态时，不会立即销毁它，而是保持一段时间，如果这是有新的work需要执行时，那么直接wakeup处于idle的worker线程即可。一段时间后仍然没有事情可做时，该worker线程会被销毁。

* 对于未绑定cpu的wq，线程池的数量的动态的。unbound的wq可以使用apply_workqueue_attrs()来指定属性。wq会自动创建匹配对应属性的work-pool。调节并发度的职责在使用者这边。对于bound的wq也可以通过设置flag来让内核忽略并发度的管理，详细信息参考API章节。

* wq机制前端处理依赖于当需要更多的可执行上下文时能够及时创建worker线程。当不能及时创建worker线程时，就需要通过rescue worker线程来处理。在内存不足的情况下，所有可能释放内存的work都会被加入到rescue-worker线程中。另外，对于会解除worker-pool中死锁等待的work也会做同样的操作。

##### API

* alloc_workqueue函数用于创建wq(workqueue_struct)。原来的crear_*workqueue函数已经被弃用并计划删除了。alloc_workqueue函数有三个参数:name，flags和max_active。

  + name参数表示wq的名字，如果wq用于rescuer，那么此参数还表示rescuer-worker线程的名字

  + max_active表示每个cpu上该wq在后台最多有多少个worker线程与之绑定。比如，如果max_active的值为16，那么表示该工作队列最多有16个work可以在同一个CPU上运行。

    对于一个绑定的wq，max_active的最大值为512，如果该值被设置为0则使用默认值256。对于非绑定的wq，最大值为512和4*num_possible_cpus两个里面的较大的那个。

    通常情况下，wq中的active的work的数量由wq的使用者控制的，更具体的说，是使用者同一时间放入wq中work的数量。除非有特殊的要求需要调整active worker的数量，否则建议将max_active设置为0。

    有一些使用者需要使用ST的wq且需要依赖严格的执行顺序，此时，设置max_active=1且flags=WQ_UNBOUND就可以满足要求。

  + flag

    * WQ_UNBOUND
      具有该标志的wq，说明其中的work处理都不需要绑定到特定的CPU上进行处理。这种情况下，wq只是作为一个简单的执行上下文的提供者，不负责并发管理。未绑定的worker-pool会尽可能快(ASAP)的执行work任务。如果系统中能找到匹配的线程池(根据wq的attribute)，那么就选择一个，如果找不到合适的线程池，wq就会创建一个worker-pool来处理work。这个标志的典型应用场景有以下两个:
        - 当需要创建大量的worker时。如果使用绑定的wq，会导致创建很多无用的worker线程(across different CPUs) 而不是期望的 through different CPUs。使用未绑定的wq可以少创建工作线程，节省系统资源。
        - 高CPU负载的系统中，调度器可以更好的管理线程。
   
    * WQ_FREEZABLE
      这是一个和电源管理相关的标志。在系统Hibernation或者suspend的时候，有一个步骤就是冻结用户空间的进程以及部分（标注freezable的）内核线程（包括workqueue的worker thread）。标记WQ_FREEZABLE的workqueue需要参与到进程冻结的过程中，worker thread被冻结的时候，会处理完当前所有的work，一旦冻结完成，那么就不会启动新的work的执行，直到进程被解冻。 

    * WQ_MEM_RECLAIM
      所有用于内存回收的任务必须设置这个标志。这个标志保证了即是在内存紧张的情况下，也至少有一个可执行上下文。 

    * WQ_HIGHPRI
      挂入该workqueue的work是属于高优先级的work，需要高优先级（比较低的nice value）的worker thread来处理。 注意普通优先级和高优先级的worker-pool是相互独立的，它们都维护各自的线程池和并发度管理。对于unbound的wq，该标记无意义。

    * WQ_CPU_INTENSIVE
      CPU密集型队列中任务对并发度的提高是没有帮助的。所以，要确保可运行的CPU密集型工作任务不能阻止其他任务被运行。这个标记对于在绑定CPU的工作队列上，并且预期会占用较多CPU周期的任务来说是有用的，设置了该标记后，系统调度就能控制CPU密集型work的执行，保证其他work不会一直都得不到cpu。
      该标记对于unbound的wq是无意义的。

    * 注意 WQ_NON_REENTRANT标记已经不存在了，因为所有的wq现在都是不可重入(non-reentrant)的。能够保证任何work在同一时间在整个系统中最多被一个worker线程执行。

##### 执行场景举例

下面用一个例子来说明在不同的配置条件下，cmwq的运行方式

现在有w0, w1 和w2 三个work，这三个work都加入到绑定cpu的wq q0中。w0执行时会占用5ms的cpu，然后睡眠10ms，然后再占用5ms的cpu。w1和w2执行时会先占用5ms的cpu然后睡眠10ms。

忽略其他所有任务 和 CPU 的情况下，假定采用简单的FIFO的调度方式。

* 在原来的wq机制下，简化后的执行顺序大概如下:

  TIME-IN-MSECS|        EVENT 
  0           |         w0 starts and burns CPU 
  5           |         w0 sleeps 
  15          |         w0 wakes up and burns CPU 
  20          |         w0 finishes 
  20          |         w1 starts and burns CPU
  25          |         w1 sleeps 
  35          |         w1 wakes up and finishes 
  35          |         w2 starts and burns CPU 
  40          |         w2 sleeps 
  50          |         w2 wakes up and finishes

* 采用cmwq机制，且max_active >= 3的情况下:

  TIME-IN-MSECS|         EVENT 
  0            |         w0 starts and burns CPU 
  5            |         w0 sleeps 
  5            |         w1 starts and burns CPU 
  10           |         w1 sleeps 
  10           |         w2 starts and burns CPU 
  15           |         w2 sleeps 
  15           |         w0 wakes up and burns CPU 
  20           |         w0 finishes 
  20           |         w1 wakes up and finishes 
  25           |         w2 wakes up and finishes

* 采用cmwq机制，且max_active = 2的情况下:

  TIME-IN-MSECS|         EVENT 
  0            |         w0 starts and burns CPU 
  5            |         w0 sleeps 
  5            |         w1 starts and burns CPU 
  10           |         w1 sleeps 
  15           |         w0 wakes up and burns CPU 
  20           |         w0 finishes 
  20           |         w1 wakes up and finishes  
  20           |         w2 starts and burns CPU 
  25           |         w2 sleeps 
  35           |         w2 wakes up and finishes

* 假设w0加入wq q0，w1和w2加入wq q1中，q1中设置有WQ_CPU_INTENSIVE标志

  TIME-IN-MSECS|         EVENT 
  0            |         w0 starts and burns CPU 
  5            |         w0 sleeps 
  5            |         w1 and w2 start and burn CPU 
  10           |         w1 sleeps 
  15           |         w2 sleeps 
  15           |         w0 wakes up and burns CPU 
  20           |         w0 finishes 
  20           |         w1 wakes up and finishes 
  25           |         w2 wakes up and finishes

##### 使用参考

* 当处理一个涉及内存回收的work的，不要忘记使用WQ_MEM_RECLAIM标志。每一个设置了该标志的wq都有一个预留的可执行上下文。

* 除非严格依赖执行顺序，否则没有必要使用ST wq

* 除非有特殊的需求，创建wq时，建议max_active的值设置为0

* 当work不涉及内存回收、flushed或其他特殊属性时，可以使用系统定义的wq。系统定义的wq和自定义的wq在执行时没有区别。

* 除非work需要占用大量的CPU资源，否则建议使用bound的wq，bound的wq在并发度管理和cache缓冲方面有优势

##### 调试

* worker 线程的呈现方式如下:

  root      5671  0.0  0.0      0     0 ?        S    12:07   0:00 [kworker/0:1] 
  root      5672  0.0  0.0      0     0 ?        S    12:07   0:00 [kworker/1:2] 
  root      5673  0.0  0.0      0     0 ?        S    12:12   0:00 [kworker/0:0] 
  root      5674  0.0  0.0      0     0 ?        S    12:13   0:00 [kworker/1:0]

* 当kworker占用大量cpu时，通常原因为一下两个:

  + 某些任务被连续快速的调度

  + 某个任务执行时需要消耗大量的cpu资源

  第一个问题可以通过下面的方式确认

    $ echo workqueue:workqueue_queue_work > /sys/kernel/debug/tracing/set_event 
    $ cat /sys/kernel/debug/tracing/trace_pipe > out.txt
    (wait a few secs)
    ^C 

  第二个问题可以通过检查对应线程的栈信息确认

    $ cat /proc/THE_OFFENDING_KWORKER/stack




