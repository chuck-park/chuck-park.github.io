---
title: [테크콘 리뷰] 대규모 트랜잭션을 처리하는 배민 주문시스템 규모에 따른 진화 - 우아콘2023
categories: dev
tags:
  - techcon
---


# Introduction
우아콘2023에서 발표된 '대규모 트랜잭션을 처리하는 배민 주문시스템 규모에 따른 진화' 내용을 리뷰해보았습니다.

# Contents
기술적인 이야기에 앞서 배민 서비스와 배민 주문시스템에 대해서 간단하게 소개해주었습니다.

### 배민 서비스의 특징
배민 서비스는 푸드 테크 특성 상 점심, 저녁 시간에 트래픽이 몰린다는 특성이 있습니다.
![1](/assets/images/images/2024-12-29-large-scale-transaction-woowacon2023/image-1.png)

### 배민 주문시스템 소개
주문시스템은 크게 장바구니, 주문하기, 주문내역을 담당하는 도메인이며
![0](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image.png)

### 배민 주문시스템의 특징
현재 기준으로 아래와 같은 특징을 가지고 있다고 합니다.

1. MSA
장애 전파를 방지하기 위해 MSA로 느슨한 결합을 가져가고 있음
2. 대용량 데이터
일 평균 300만 건의 주문을 저장하고, 수년 간 데이터를 보관해야함
3. 대규모 트랜잭션
일 평균 300만 건의 주문이 발생
4. 이벤트 기반 통신
이벤트 기반으로 통신하고 있어서 이벤트 유실이 발생했을 때 어떻게 잘 재소비할 수 있게할지, 이벤트의 흐름을 잘 볼 수 있을지에 대해 고민이 많음

![2](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-2.png)
![3](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-3.png)
![4](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-4.png)
![5](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-5.png)

### 서비스의 성장과 이에 따른 성장통
주문수가 일평균 40만 ~ 300만까지 증가하면서 서비스의 여러 문제가 발생하기 시작했다고 합니다.

1. 단일 장애 포인트
하나의 시스템 장애가 전체 시스템의 장애로 전파
2. 대용량 데이터
RDBMS 조인 연산만으로는 조회 성능이 악화
3. 대규모 트랜잭션
주문수 증가로 저장소의 쓰기 처리량의 한계에 도달
4. 복잡한 이벤트 아키텍처
규칙 없는 이벤트 발행으로 서비스의 복잡도가 증가

![6](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-6.png)
![7](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-7.png)

이제 하나씩 자세하게 어떻게 해결해나갔는지 알아봅시다.

### 1. 단일 장애 포인트
2018년 배민의 아키텍처는 루비(MS SQL)라는 중앙 집중 디비에 의존하고 있었습니다.
![ruby](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-28.png)
[이미지 출처 2020 우아콘]

그래서 당시에는 특정 *시스템에 장애가 발생하면 루비의 부하가 커졌고, 루비의 부하가 커지면 모든 시스템이 장애로 이어졌습니다.
![8](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-8.png)
![9](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-9.png)
![10](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-10.png)

*시스템: 배민에서는 각 도메인을 구현한 Micro Sevice를 시스템이라고 부르는 것으로 보입니다.
![domain-system](domain-system.png)
[이미지 출처: https://techblog.woowahan.com/13101/]

이를 해결하기 위해 도메인을 정리하고 하나씩 *마이크로서비스로 분리를 시작했고, 각 시스템들 간에는 메시지큐를 이용해서 통신하도록 했다고 합니다.

결과적으로 현재는 MSA로 전환이 완료된 상태이고, 특정 시스템에 장애가 발생했을 때는 메시지 발 관심이 없는 시스템은 영향을 전혀 받지 않고, 관심이 있는 시스템은 약간의 지연이 발생한 뒤 이벤트 재소비가 일어나면 빠르게 안정화 가능해졌다고 합니다.

*마이크로서비스: 배민에서 마이크로서비스의 기준은 디비까지 분리한 것을 의미한다고 합니다.

![11](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-11.png)
![12](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-12.png)

예를 들면, *주문중계 시스템에 장애가 나면 해당 시스템에 관심이 없는 가게 시스템과 그 외 다른 시스템(그림의 ETC System)은 아무런 영향을 받지 않고, 관심이 있는 주문 시스템은 장애가 났던 주문중계 시스템이 다시 살아나서 이벤트가 재발행되면 

*주문중계 시스템: 주문이 일어났을 때 가게 사장님들이 PC, 앱, 단말기 등을 통해 받을 수 있는데 이를 포워딩 해주는 gateway 서비스라고 합니다.
![13](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-13.png)
![14](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-14.png)
![15](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-15.png)

참고로 다른 컨퍼런스 내용을 보면 MSA로의 전환은 넷플릭스도 7년이나 걸렸다고하고, 배민도 2016년부터 시작해서 2019년 11월에 이르러서야 끝났다고 합니다.
개인적으로도 MSA로 전환을 시도하다가 실패한 경험이 있기 때문에 MSA 전환이 쉽지 않다는 것을 어느 정도는 알고있었는데, 개발 리소스가 훨씬 많은 다른 기업들의 사례들을 봐도 MSA 전환은 정말 어렵고 비용(시스템 마이그레이션 비용, 전환 후의 개발, 운영 비용의 증가 등)이 큰 일인 것 같습니다. 두 회사에서 공통적으로 얘기하는 것은 'MSA로의 전환은 선택의 문제가 아닌 생존의 문제였다'라는 겁니다. 비즈니스가 미친듯이 성장할 때 기존 시스템이 이 속도를 따라잡지 못해 장애가 일어날 것이 눈에 훤하게 보이는, 그런 상황에서만 ROI가 나오는 접근이 아닌가 싶습니다.

요약: 모놀리식 -> MSA(Micro Service Architecture)로 변경하고, 각 MS들은 이벤트 기반 통신하도록 변경

### 2. 대용량 데이터
DB에 데이터가 많이 쌓이면서 조회 시간이 너무 오래걸리게 됨.

이 문제를 좀 더 자세히 확인하기 위해 주문 시스템을 좀 더 자세히 알아보면,
기존 아키텍쳐에서는 주문 요청과 조회가 하나의 RDB를 통해서 일어나고 있는 것을 확인할 수 있음.
![16](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-16.png)
![17](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-17.png)
![18](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-18.png)

하지만 주문 내역을 보여줄 때만해도 아래와 같이 많은 정보가 필요하고 정규화된 RDB를 이용해서 이 데이터를 다 조회하려면 수 많은 join 연산이 필요하고 이는 조회 성능 저하로 이어짐.
![19](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-19.png)
![20](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-20.png)
![21](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-21.png)

이 문제를 해결하기 위해 documentDB인 몽고DB에 필요한 데이터를 역정규화하여 저장함.
이렇게하면 이제 여러 table을 join 할 필요 없이 id 값만으로 필요한 정보를 극대화하여 빠르게 조회 가능해짐.
![22](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-22.png)
![23](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-23.png)

역정규화해서 저장한 데이터는 주문 도메인 이벤트가 발생할 때마다 동기화해줌.
![24](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-24.png)
![25](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-25.png)

이렇게 주문 요청과 주문 정보 조회가 분리된 CQRS(Command and Query Responsibility Segregation) 패턴이 적용함으로서 문제를 해결함.
![26](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-26.png)
![27](/assets/images/2024-12-29-large-scale-transaction-woowacon2023/image-27.png)

# References
- [대규모 트랜잭션을 처리하는 배민 주문시스템 규모에 따른 진화 #우아콘2023 #우아한형제들](https://www.youtube.com/watch?v=704qQs6KoUk&ab_channel=%EC%9A%B0%EC%95%84%ED%95%9C%ED%85%8C%ED%81%AC)
- 배민스토어의 이벤트 기반 아키텍쳐 설명
  - [[배민스토어] 배민스토어에 이벤트 기반 아키텍처를 곁들인…](https://techblog.woowahan.com/13101/)
- MSA 중 하나의 MS 구현에 대한 설명(미시적 관점)
  - [회원시스템 이벤트기반 아키텍처 구축하기](https://techblog.woowahan.com/7835/)