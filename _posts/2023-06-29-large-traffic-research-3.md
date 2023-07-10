---
title: 대규모 서비스에 대한 연구 3 - I/O 부하 분산과 OS 캐시
categories: Backend
tags:
  - CS
  - Infra
---
> 익숙함에 속아 중요함을 잊지말자 - 운영체제

I/O 부하 분산 처리 방법을 얘기하기 전에 알고 있어야할 것들이 많다. 이번에는 OS 캐시에 대해 알아보자.

OS 캐시는 페이지라는 단위로 관리되기 때문에 페이지 캐시(Page Cache)라고도 불린다. OS 캐시 방식과 페이지 크기는 OS 마다 다른데, 이 글에서는 Linux([x86](https://phoenixnap.com/kb/x64-vs-x86))를 기준으로 알아보자.

## Cache(캐시)
캐시 메모리, 브라우저 캐시, 캐시 서버, '캐시를 추가한다', '데이터를 캐싱해둔다' 등 캐시는 컴퓨터 하드웨어 뿐만 아니라 웹에서 굉장히 많이 사용되는 용어다. 여기서 캐시란 정확히 무엇을 말하는걸까?

위키백과에 따르면, 캐시란 **'컴퓨터 과학에서 데이터나 값을 미리 복사해 놓는 임시 장소'** 이며, '캐시의 접근 시간에 비해 원래 데이터를 접근하는 시간이 오래 걸리는 경우나 값을 다시 계산하는 시간을 절약하고 싶은 경우에 사용한다.' 라고 한다. 현업에서는 '캐시를 해놓는다' 같이 캐시에 저장해둔다는 뜻의 동사로도 사용한다.

그럼 OS 캐시는 말 그대로 OS에서 더 빠르게 데이터에 접근하기 위해 따로 저장해놓은 장소일 것이다. 그럼 OS가 어디에, 어떻게 캐시를 해놓는지를 좀 더 알아보자.

## Virtual Memory(가상 메모리)
OS 캐시에 대해 좀 더 알아보기 위해서는 가상 메모리 개념을 먼저 알고있어야한다.

*1)가상 메모리는 OS가 물리 메모리를 논리적으로 추상화해서 관리하는 방식이다. 내부적으로는 페이지(4KB) 단위로 구성되며, 보다 효율적이고 안전하게 메모리를 관리하고 *2)실제 물리 메모리 크기보다 더 많은 메모리를 사용할 수 있다.

프로세스에서 메모리를 요청하는 경우, OS가 가상 메모리에서 비어있는 부분을 필요한 만큼 찾아서 전달하고 프로세스는 할당된 가상 메모리 공간에만 접근 가능하게된다. 이렇게 하면 물리 메모리의 어느 부분을 사용하고 있는지, 다른 프로세스의 영역을 침범하지 않았는지 등을 신경쓰지 않아도 되고 OS 입장에서도 메모리 관리가 훨씬 단순해져 문제가 발생할 확률도 줄어든다. 

![virtual memory and physical memory relation](https://www.baeldung.com/wp-content/uploads/sites/4/2021/06/virtual_memory-1024x545.png)
<p style="text-align: center; margin-top: -10px;">[가상 메모리와 물리 메모리의 관계]</p>

가상 메모리는 논리적인 개념이므로 프로세스 하나에 대해서 아래와 같은 형태로 생각할 수 있다. 가상 주소가 0부터 Max까지로 되어있고 *3)프로세스와 쓰레드를 공부할 때 많이 볼 수 있는 형태인 stack, heap, data, code로 구성되어있는 것을 확인할 수 있다.

<img src="https://mycareerwise.com/storage/editor/images/image(1620).png" />
<p style="text-align: center;">[프로세스의 메모리 주소 공간]</p>

프로세스가 데이터를 요청했을 때 불러오는 과정을 보면서 좀 더 자세히 이해해보자.

![page fault steps](https://www.cs.uic.edu/~jbell/CourseNotes/OperatingSystems/images/Chapter9/9_06_PageFaultSteps.jpg)

1. 프로세스가 특정 데이터에 접근한다(그림의 1)
2. OS는 해당 데이터가 가상 메모리에 존재하는지 확인한 뒤 있으면 해당 데이터를 반환하고, 없으면(page fault 발생) 디스크에서 찾는다(그림의 2~3)
3. 디스크에서 찾은 데이터는 가상 메모리에 쓴다(그림의 4~5)
4. 해당 가상 메모리 주소를 프로세스에게 전달한다(그림의 6)

 위 내용을 보면 프로세스는 물리 메모리에 직접 접근하지 못하고 가상 메모리에만 접근할 수 있는 것을 확인할 수 있다. 그리고 이때 프로세스의 작업이 끝나도 OS는 가상 메모리 위에 쓰여진 데이터를 바로 삭제하지 않는다. 그러면 다음에 어떤 프로세스에서 해당 데이터에 접근하려고 할 때 디스크를 갔다오지 않고 바로 메모리에서 불러올 수 있게된다. 이게 바로 OS 캐시다. 위 그림의 과정에 대한 더 자세한 설명은 [여기](https://www.cs.uic.edu/~jbell/CourseNotes/OperatingSystems/9_VirtualMemory.html)에서 확인할 수 있다.

## 페이지 캐시
다시 정리해보면, OS 커널이 한 번 메모리에 할당한 페이지를 해제하지 않고 가능하면 오래 남겨두는데 이게 바로 페이지 캐시다. 어떤 데이터를 남기고 지울지를 결정하는 알고리즘은 여러가지가 있지만 제일 오랫동안 접근되지 않은 데이터를 지우는 방식인 LRU(Least Recently Used)를 많이 사용한다. LRU를 사용하면 시간이 지날수록 가장 자주 사용되는 데이터만 남도록 캐시가 최적화 되기 때문에 점점 I/O 부하가 줄어들게 된다. 컴퓨터, DB를 재부팅하면 처음에는 느리다가 점점 빨라지는게 이 때문이다.

#
*1) 가상 메모리 구조는 내부적으로 어떤 가상 메모리 주소가 어떤 물리 메모리(RAM or Disk) 주소에 저장되어있는지를 찾아 변환해주는 역할을 하는 하드웨어인 MMU(Memory Management Unit)가 TLB(Translation Lookaside Buffer)와 Memory Map(Page Table)을 순차적으로 탐색하는 과정을 거친다

*2) 가상 메모리를 사용하면 어떻게 실제 물리 메모리 크기 보다 더 많은 메모리를 사용할 수 있을까?

  우선 'OS는 페이지 단위로 캐싱을 한다'와 '많은 경우에 프로세스의 일부만 메모리에 올라가 있어도 동작할 수 있다'는 아이디어를 기반으로하며, 메모리에는 부분만 load해 놓고 필요한 데이터가 메모리에 없는 경우(Page Fault)에 필요 없는 데이터를 지우고, 필요한 데이터를 사용자가 인식하지 못하게 메모리에 빠르게 올리는(Swap) 방식으로 동작하기 때문에 가능하다는 정도만 알아두자.

  ![read data from disk to process image](https://gabrieletolomei.files.wordpress.com/2013/10/mmu.jpg)

*3) 프로세스와 쓰레드 공부할 때 많이 보이는 이미지

  ![프로세스 vs 쓰레드](https://user-images.githubusercontent.com/15935262/251659946-00687bf6-70b1-4fc3-8644-a7f26d0af509.png)
  <p style="text-align: center;">[프로세스 vs 쓰레드]</p>

프로세스들끼리 공유하는 페이지도 있다

<img src="https://www.cs.uic.edu/~jbell/CourseNotes/OperatingSystems/images/Chapter9/9_03_SharedLibrary.jpg" />
<p style="text-align: center;">[프로세스들 간의 페이지 공유]</p>

# 참고
- [Chapter 2. Memory Allocation, Red Hat Enterprise Linux for Real Time 7](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_for_real_time/7/html/reference_guide/chap-memory_allocation)
- [Virtual Memory - baeldung](https://www.baeldung.com/cs/virtual-memory)
- [전공생이 설명하는 OS: 프로세스(Process)란? - 척척석사](https://letsmakemyselfprogrammer.tistory.com/92)
- [Operating Systems: Virtual Memory - www.cs.uic.edu](https://www.cs.uic.edu/~jbell/CourseNotes/OperatingSystems/9_VirtualMemory.html)
- [Memory layout for a Process - MyCareerwise](https://mycareerwise.com/content/memory-layout-for-a-process/content/exam/gate/computer-science)
- [SP - 8.1 Virtual Memory Concepts - Hyeok's Log](https://velog.io/@junttang/SP-8.1-Virtual-Memory-Concepts)
- [메인 메모리(main memory) - Tech Interview](https://gyoogle.dev/blog/computer-science/operating-system/Memory.html)