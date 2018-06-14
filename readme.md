
This readme file is the documentation of the final project for the course 'Real-time Systems' at SDU in the spring semester of 2018.

## Introduction

The project is about the investigation of multithreaded C programs running on Linux. Of course such a technique has both pros like the usage of multiple processors, and cons, for example the increased number of context switches. My goal was to see how advantageous it is to use multiple threads and to reveal whether the pros outweigh the drawbacks.

Of course, not all algorithms are suitable for using multiple threads. To make measurements, an appropriate algorithm had to be found first. After some research, the parallelizable version of the bubble sort algorithm was chosen, which is called [odd-even transposition sort](https://en.wikipedia.org/wiki/Odd%E2%80%93even_sort). Although the algorithm itself was not in focus in this project, the answer to the question of interaction between the data and the threads was not obvious. 

During the measurement, I was expecting to find some elbow points or bottlenecks in the runtime as increasing the number of threads. The limit in the number of threads was also an opened question.

## Methods

The most relevant parameter to measure (and possibly optimize) in case of such an application of multithreading (and in sorting in general) is runtime. Of course runtime depends on a lot of parameters, for example

>* The computer on which the program is running
>>* Hardware setup (such as number and type of processors)
>>* Operating system
>>* Number of applications running at the same time
>>* etc.
> * Implementation
> * Dataset (in case of a sorting algorithm like odd-even sort)
> > * Size
> > * Number or required swaps
>  * Number of threads
>  * etc.

The idea is to measure runtime while keeping all the parameters constant except for the one which we vary. In my case, measurements are made at multiple sizes of dataset, with multiple number of threads, since there might be cases when using multiple threads is more advantageous (for example bigger datasets).

Another measurement is about the possible number of threads which can be run on Linux. Here, a fairly small dataset will be created and will be sorted while increasing the number of threads.

## Implementation

Although the algorithm is not in focus, it is important to describe the main problems and questions regarding such a sorting algorithm and multithreading. The main questions are the following:

* How to make the threads interact with the data?
* How to syncronize threads?

The solution was based on the code of user [Nalaka1693](https://github.com/Nalaka1693/pthread_odd_even_sort) on GitHub.

In case of a dataset with a size of *n* the algorithm is suitable for having a maximum of [*n/2* threads](https://en.wikipedia.org/wiki/Odd%E2%80%93even_sort). In case of the maximum number of threads, one thread basically has to take care of a single pair of numbers in the dataset. If we have less threads, we need to divide the dataset accordingly.

An important thing to mention is that, for example in case of two threads we can not simply divide the dataset in two halfs, because in this case, the two subsets would get sorted separately. As a result, there has to be an overlap in the indexes of the subsets so that the threads can "cooperate".

The threads do not need any syncronization during an even or an odd phase, but they do when they are making transition from one phase to another. For this sync, [pthread_barrier_wait](http://pubs.opengroup.org/onlinepubs/009695399/functions/pthread_barrier_wait.html) is used. This basically guarantees that all the threads are done with their subset before going to the next phase.

If any of the threads is unsorted, each thread has to reiterate and solve the problem, possibly using the overlaps between the subset indexes. The threads are using a global variable to indicate if their subset is sorted or not.

## Results

The results can be observed in the html files "laptop_fancyplot.html" and "zybo_fancyplot.html". The files can be opened with a web browser, e.g. Chrome.

![Laptop](/laptop_plot.png "Results on laptop")
![Zybo](/zybo_plot.png "Results on Zybo")

All in all, the shape of the plots are pretty much identical on both devices.

The first thing to mention is the difference in runtimes. It can be seen that the same thing on the Zybo took circa 10 times more than on the laptop.

It is worth mentioning how smooth the measurements on the Zybo were compared to the laptop. The reason might be the number of processes handled by the devices. The laptop operates a ton of other things, and the increased number of things to be handled by the OS should be the reason for the bigger variatons. The Zybo does not handle multiple processes, there's no network connection, screen, multimedia, etc., so the OS running on the board has to do a lot less things.

On the Zybo board, the algorithm is without doubt the fastest when running on 2 threads. It might worth mentioning that the processor on the board is a [ARM Cortex-A9 dual core processor](https://reference.digilentinc.com/reference/programmable-logic/zybo/start).

On the laptop, using 2 and 3 threads were similarly good. In general, we can see that above these thread numbers, the runtime only increases. In fact, we have to do the same job regardless of the number of the threads. Creating more threads without resources to exploit just adds more runtime because of unnecessary context switches.

I could not violate the number of threads per process which Linux can handle. I found out that the maximum number of processes and the maximum number of threads per process are so high that they are very difficult to violate. The maximum number of threads depend on the available RAM (and/or virtual memory) and the size of stack assigned to the threads. It is possible to adjust these parameters. There is a file at the following path:

`/proc/sys/kernel/threads-max`

"This file specifies the system-wide limit on the number
of threads (tasks) that can be created on the system."

On my laptop, this file contains the number 62434, while on the Zybo it is 7726.

## Laptop specs

* OS: Ubuntu 16.04.4 LTS
* Processor: [Intel® Core™ i5-3230M, 2 cores, 4 threads](https://ark.intel.com/products/72056/Intel-Core-i5-3230M-Processor-3M-Cache-up-to-3_20-GHz-BGA)


## Conclusion

The results were not unexpected, they can be explained pretty easily, however, there might be some more complicated mechanisms which are harder to reveal. It might be very interesting to try the same measurements on an 8-core processor.
