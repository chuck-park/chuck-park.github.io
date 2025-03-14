---
title: 멀티프로세싱(Multi Processing)과 멀티스레딩(Multi Threading)
categories: CS
tags:
  - OS
---

컴퓨터(Computer)는 핵심이 되는 장치인 CPU(Central Processing Unit)를 갖는다.

CPU는 물리 계산을 수행하는 핵심 부품인 코어(Core)를 갖고 있으며 CPU를 프로세서(Processor)라고도 부른다.

과거에는 하나의 컴퓨터에 프로세서가 한 개만 있었다. 이를 **싱글 프로세서 시스템(Single Processor System)**이라고 부른다. 싱글 프로세서 시스템에서는 프로세서가 한 번에 하나의 작업만 처리할 수 있다.

|![싱글 프로세서 시스템](/assets/images/2025-03-15-multi-processing-and-multi-threading/image.png)
|:--:|
|*싱글 프로세서 시스템*|

프로그램(Program)은 컴퓨터가 실행할 수 있는 명령어(Instruction)들의 집합이다. 주로 하드디스크에 저장된다.

프로그램이 실행된다는 것은 OS에 의해 프로그램의 일부가 메모리에 적재되고 CPU에 의해 명령어가 수행되는 것을 의미한다.

실행 중인 프로그램을 프로세스(Process)라고 부른다. 이 때 명령어는 사이클(클럭, Clock) 단위로 처리된다.

프로세스 안에서 논리적으로 작업이 수행되는 최소 처리 단위를 Thread라고 부른다.

![Thread](/assets/images/2025-03-15-multi-processing-and-multi-threading/image2.png)

프로세서의 성능을 높이기 위해 CPU의 클럭을 높이거나 캐시를 늘리는 방법이 먼저 사용됐지만 발열, 비용 등의 문제로 한계에 부딪혔다. 다른 방법으로 프로세서를 여러개 설치하여 병렬적으로 작업을 수행할 수 있게하는 방법이 적용됐다. 이를 멀티 프로세서 시스템(Multi Processor System)이라고 부른다.

![Multi Processor System](/assets/images/2025-03-15-multi-processing-and-multi-threading/image3.png)

멀티 프로세서 시스템에서 각 프로세서는 독립된 레지스터와 캐시를 가지며, 모든 프로세서는 시스템 버스를 통해 메인 메모리에 접근할 수 있다. 멀티 프로세서 시스템은 프로세서의 개수만큼 동시에 작업을 수행할 수 있는 장점이 있지만 싱글 프로세서 시스템에서 많은 설계의 변경이 필요하다.

설계의 변경 없이 기존 싱글 프로세서 시스템에서 여러 프로세스를 동시에 실행할 수 있게하는 방법이 등장했는데 바로 하나의 CPU에 물리적으로 여러 개의 코어를 추가한 **멀티 코어 시스템(Multi Core System)**이다. 멀티 코어 시스템에서는 코어 수 만큼 여러 작업을 동시에 처리할 수 있다.

코어가 1개이면 싱글 코어, 2개이면 듀얼 코어, 4개이면 쿼드 코어, 8개이면 옥타 코어 CPU라고 부른다.

![Multi Core System {caption=멀티 코어 시스템}](/assets/images/2025-03-15-multi-processing-and-multi-threading/image4.png)

또 다른 방법으로 하나의 코어가 2개 이상의 명령어를 처리할 수 있게 하는 방법인 멀티 쓰레딩(Multi Threading)이 있다. 

1960년대 IBM이 SMT(Simultaneous Multi-Threading)이라는 이름으로 사용되고 있었고, 2000년 대 초반에 인텔이 하이퍼쓰레딩(Hyper Threading)이라고 부르면서 이 이름으로 더 알려졌다.

멀티 쓰레딩에 대해 간단히 설명하면 하나의 물리적 코어 가 두 개의 논리적 코어처럼 작동하도록 하여 동시에 여러 작업을 처리하게 하는 방법이다. 

하나의 쓰레드가 작업을 처리할 때 100% 성능을 사용하는 경우가 많지 않기 때문에 한 쓰레드의 작업을 처리하고 남는 유휴 자원을 활용하여 다른 쓰레드에서 서로 의존성이 없는 명령어를 동시에 실행하는 원리이다. 한 쓰레드의 작업을 처리할 때 자원이 남아야하고 명령어의 의존성도 없어야 하기 때문에 실제로는 멀티 태스킹이 많은 환경에서 성능이 20~30% 정도 향상되고 멀티 쓰레딩을 지원하지 않는 프로세스를 실행 시킬 때는 오히려 성능이 떨어질 수 있다.

예를 들어 8코어 CPU에 하이퍼 쓰레딩을 지원한다면 논리적으로는 16개의 코어를 가지고 있다고 표현된다.

|![Hyper Threading ><](/assets/images/2025-03-15-multi-processing-and-multi-threading/image5.png)|
|:--:|
|*하이퍼 쓰레딩의 원리*|

현대의 컴퓨터는 멀티 코어 시스템에 멀티 쓰레드 시스템을 모두 적용하고 있다. 병렬처리 성능을 제대로 내려면 프로그램이 멀티 쓰레딩을 지원하는지도 중요하다.

|![The Relation of Multi Core Processor and Multi Thread Program](/assets/images/2025-03-15-multi-processing-and-multi-threading/image6.png)|
|:--:|
|*멀티 코어 프로세서와 멀티 쓰레드 프로그램의 관계(하이퍼 쓰레딩은 적용되지 않음)*|

# References

- [두둠칫 [OS] CPU, Processor, Core, Process, Thread 그리고 관계 정리](https://dmzld.tistory.com/18)
- [dhson CPU, 프로세서, 코어... 같은 용어인가?](https://donghoson.tistory.com/entry/CPU-%ED%94%84%EB%A1%9C%EC%84%B8%EC%84%9C-%EC%BD%94%EC%96%B4-%EA%B0%99%EC%9D%80-%EC%9A%A9%EC%96%B4%EC%9D%B8%EA%B0%80)
- [k9want [운영체제] 멀티프로그래밍, 멀티태스킹, 멀티스레딩, 멀티프로세싱](https://k9want.tistory.com/entry/%EC%9A%B4%EC%98%81%EC%B2%B4%EC%A0%9C-%EB%A9%80%ED%8B%B0%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D-%EB%A9%80%ED%8B%B0%ED%83%9C%EC%8A%A4%ED%82%B9-%EB%A9%80%ED%8B%B0%EC%8A%A4%EB%A0%88%EB%94%A9-%EB%A9%80%ED%8B%B0%ED%94%84%EB%A1%9C%EC%84%B8%EC%8B%B1)
- [www.naukri.com Code 360 by Coding Ninjas](https://www.naukri.com/code360/library/difference-between-multiprogramming-and-multitasking)
- [dhson 하이퍼 스레딩이란? - (1)](https://donghoson.tistory.com/entry/%ED%95%98%EC%9D%B4%ED%8D%BC-%EC%8A%A4%EB%A0%88%EB%94%A9%EC%9D%B4%EB%9E%80-1)
- [최초의 2코어 CPU 나온 지 13년, 이젠 32코어도?](https://it.donga.com/27894/)
- [namu.wiki - Simultaneous Multi-Threading](https://namu.wiki/w/SMT#s-4)