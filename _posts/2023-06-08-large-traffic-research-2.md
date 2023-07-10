---
title: 대규모 서비스에 대한 연구 2 - I/O 부하 분산과 Memory, Disk
categories: backend
tags:
  - CS
  - Infra
---

> Memory와 Disk는 생각보다 많이 다르다.

지난 시간에 이어서 서버에 부하가 있을 때 해결하는 방법 중 I/O 부하를 해결하는 법에 대해 좀 더 알아보자.

개요와 대규모 트래픽 분산 처리의 기초에 대한 내용은 [이전 글](https://chuck-park.github.io/cs/large-traffic-research-1/)을 참고해주기를 바란다.

이전 글에서 I/O 부하는 단순히 로드 밸런싱만 해서는 큰 효율이 없을 수 있다고 했는데, 그 이유를 알기 위해서는 먼저 Memory와 Hard disk에 대한 이해가 필요하다.

먼저 Memory와 Hard disk에 대한 기억을 되살려보자.

![differences between memory and storage](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FqV2y5%2Fbtsi10a7j3J%2FSChrafB2eM2flV0uDB6WT1%2Fimg.webp)

Memory가 빠르고 Disk는 느리다 정도는 많이 들어봤을텐데 왜 그런지 좀 더 자세히 살펴보자.

이미지에 적혀있는 것처럼

- Memory는 단기 기억, 전기로 동작, 한번에 얼마나 기억할 수 있는지
- Disk는 장기 기억이고 자석, 광학 또는 빛, 얼마나 많이 적어 놓을 수 있는지

가 핵심 키워드이다.

## 탐색 속도
즉, 둘 다 뭔가를 기억(데이터를 저장)하는 장치인데 Memory는 전기의 속도로 읽고 쓰고, Disk는 자석과 빛을 이용해서 읽고 쓴다는 것이다. 빛이라고해서 Disk가 더 빠르게 느껴질 수도 있지만, 실제로 Disk가 데이터를 저장하는 원리를 보면 가운데 원반이 여러겹 쌓여있고 이 원반이 물리적으로 빙글빙글 돌고 있을 때 헤드가 자기를 이용해서 특정 위치에 데이터를 쓰고 읽는 방식이다(참고, 하드디스크의 동작원리).

예를 들면 중간에 있는 디스크의 한쪽 부분에 있는 데이터를 찾기 위해서는 헤드가 그쪽으로 이동해서 해당 디스크의 한쪽 부분이 헤드의 위치까지 올때까지 기다렸다가 헤드를 붙여서 데이터를 읽어야한다. 반면에 Memory는 전기적으로 데이터를 읽고 쓰기 때문에 데이터가 어디에 있던 마이크로초 단위로 포인터를 이동시켜서 데이터를 읽을 수 있다.

![how hard disk drives work](https://blog.kakaocdn.net/dn/td7FV/btsj09QLfMH/x3bigqN5Skm1266YKDeR51/img.gif)

실제 속도로 비교해보면 Disk는 밀리초(10^-3 sec) 단위의 속도이고 Memory는 마이크로초(10^-6 sec) ~ 나노초(10^-9 sec) 이다. Memory의 경우에는 기본적으로 마이크로초지만 CPU의 캐시에 올리기 쉬운 알고리즘이나 데이터 구조라면 CPU 캐시에 올라가서 나노초 단위로 더 빠르게 움직일 수 있기에 결론적으로, Memory와 Disk는 10 ~ 100만 배의 속도 차이가 난다(참고, [컴퓨터 처리 속도 단위](https://onlyit.tistory.com/entry/%EC%BB%B4%ED%93%A8%ED%84%B0-%EC%A0%80%EC%9E%A5%EB%8B%A8%EC%9C%84-%EB%B0%8F-%EC%B2%98%EB%A6%AC%EC%86%8D%EB%8F%84-%EB%8B%A8%EC%9C%84)).

![speed differences with processor, memory, disk](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FLPrMc%2FbtsjZxEAkXC%2FlLHlbqPZ2k7t8NGfQp8oik%2Fimg.jpg)

## 전송 속도
찾는데도 이렇게 속도 차이가 나는데, 원하는 데이터를 찾았으면 이제 처리를 위해 CPU로 전송을 해야한다. 즉, I/O 부하 처리는 탐색 속도 뿐만 아니라 전송 속도도 고려해야한다. Disk에서 필요한 데이터를 탐색을 했으면 거기서 끝나는게 아니라 서로 연결되어있는 Bus를 통해 Memory나 CPU로 보내야하는데 Memory와 CPU가 연결되어있는 Bus가 100배 이상 빠르다. 참고로 SSD(Solid State Disk)는 전기적으로 동작하기 때문에 탐색은 빠르지만 버스 속도나 구조적인 문제로 메모리 만큼의 속도는 나오지 않는다고 한다(참고, [일반적인 SSD 속도](https://www.makeuseof.com/ways-test-ssd-speed-performance/#:~:text=Common%20speeds%20for%20an%20SSD,both%20read%20and%20write%20speeds.)).

ex) 전송 속도

- Memory: 7.5GB / sec
- Disk: 58MB / sec

(참고, [메모리 별 전송 속도](https://www.crucial.kr/support/memory-speeds-compatability))

정리해보자면, **서버에서 안정적으로 데이터를 serving 하기 위해서는 100만 배나 느린 Disk는 최대한 쓰지 않는게 좋다.** I/O 병목에서도 Disk I/O의 병목이 특히 문제인 것이다.

다행히 OS가 소프트웨어적으로 이 물리적인 속도 차이를 최대한 개선하려고 많은 작업들을 하고 있다. 예를 들면 Disk에 데이터를 저장할 때 연속된 데이터를 같은 위치에 쌓고 읽을 때는 일정 사이즈의 블록(4KB)을 한꺼번에 불러와서 탐색 횟수를 줄이는 방법, 또는 Disk에서 한번 읽은 데이터를 메모리에 저장해두고 다음에 더 빨리 찾을 수 있게하는 페이지 캐시 등이 있다.

OS의 노력에 대해서는 다음 글에서 더 알아보도록 하자.