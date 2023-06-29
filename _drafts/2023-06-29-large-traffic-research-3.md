---
title: 대규모 서비스에 대한 연구 3 - I/O 부하 분산과 OS 캐시
categories: Backend
tags:
  - CS
  - Infra
---

I/O 부하 분산 처리 방법을 얘기하기 전에 알고 있어야할 것들이 많다. 이번에는 OS 캐시에 대해 알아보자.

이전 이야기가 궁금하신 분들은 [이전 글](https://chuck-park.github.io/cs/large-traffic-research-2/)을 참고해주시길 바란다.

OS 캐시는 페이지라는 단위로 관리되기 때문에 페이지 캐시(Page Cache)라고도 불린다. 페이지 사이즈는 OS 마다 다른데, Linux([x86](https://phoenixnap.com/kb/x64-vs-x86))를 기준으로 알아보자.

## 가상메모리
OS 캐시를 알아보기 전에 가상메모리의 개념부터 복기해보자.

가상메모리는 물리메모리를 추상화해서 관리하는 방식으로, OS가 효율적으로 메모리를 관리하고 실제 물리 메모리 크기보다 더 많은 리소스를 사용할 수 있게 해준다.

![virtual memory image](https://www.baeldung.com/wp-content/uploads/sites/4/2021/04/Compilation-Flow-Example-Page-2.svg)

가상 메모리는 물리 메모리를 페이지(4KB) 단위로 가져오며, 프로세스에서 메모리를 요청하면 OS가 가상메모리에서 비어있는 부분을 찾아서 그 부분의 시작 주소를 전달한다. 이렇게 하면 프로세스는 물리 메모리의 어느 부분을 사용하고 있는지를 신경쓰지 않아도 되어 복잡도가 줄어든다. OS 입장에서도 메모리 관리가 훨씬 단순해져서 관리에 필요한 리소스가 줄고 문제가 발생할 확률도 줄어든다.

프로세스는 주로 일부만 사용되기 때문에 전체가 항상 메모리에 올라가 있을 필요는 없다는 아이디어를 기반으로한다.

![virtual memory image](https://access.redhat.com/webassets/avalon/d/Red_Hat_Enterprise_Linux_for_Real_Time-7-Reference_Guide-en-US/images/e43a82d377ff4cf3a46398bc924a6893/5482.png)

## 페이지 캐시
OS는 한 번 메모리에 할당한 페이지를 해제하지 않고 계속 남겨두게 설정되어있는데 이게 바로 페이지 캐시다.
즉, Disk에서 데이터를 한번 읽으면 메모리에 저장되고 남아있기 때문에 다음에 또 해당 데이터에 엑세스할 때는 디스크가 아니라 메모리에서 읽기 때문에 훨씬 빠르게 처리할 수 있게 되는 것이다.

좀 더 자세한 이해를 위해 디스크에서 데이터를 읽어오는 과정를 살펴보자.
![read data from disk to process image](https://gabrieletolomei.files.wordpress.com/2013/10/mmu.jpg)


# 참고
- [Chapter 2. Memory Allocation, Red Hat Enterprise Linux for Real Time 7](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_for_real_time/7/html/reference_guide/chap-memory_allocation)
- [SP - 8.1 Virtual Memory Concepts](https://velog.io/@junttang/SP-8.1-Virtual-Memory-Concepts)
- [메인 메모리(main memory)](https://gyoogle.dev/blog/computer-science/operating-system/Memory.html)
- [Virtual Memory - baeldung](https://www.baeldung.com/cs/virtual-memory)