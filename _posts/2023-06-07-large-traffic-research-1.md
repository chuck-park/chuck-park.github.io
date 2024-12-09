---
title: 대규모 서비스에 대한 연구 1 - 부하 분산(Load balancing)
categories: dev
tags:
  - cs
  - infra
---

> 백엔드 개발자는 대규모의 실시간 트래픽 경험, 고가용성의 확장 가능한 설계를 할 수 있는 것이 중요하다는 이야기를 많이 듣는다.

나는 4년차 개발자로 아직 개발 경력이 짧지만, IT 스타트업 특성 상 짧은 기간 동안 운 좋게도 하나의 신규 서비스를 바닥부터 프로덕션 상태까지 만들고, 구조와 언어를 완전히 바꾸는 등 저연차에 경험하기 쉽지 않은 일들을 많이 할 수 있었다.

물론 아쉬웠던 점도 있었는데, 회사의 서비스가 B2B에 가깝다보니 MAU가 평균 10만 정도여서 B2C 기업에서 말하는 대규모, 대용량 서비스를 다루는 경험을 해보지 못한 것이다. 하지만 나름대로 귀여운 트래픽 안에서도 여러가지 문제가 터지고 그 문제들을 해결하며 자연스럽게 어떻게 해야 더 큰 트래픽을 더 안전하게 받을 수 있을지에 대한 고민을 많이 했다. 그래서 공부도 할 겸 나의 작고 소중한 경험과 다른 대규모 트래픽을 받는 기업의 유즈케이스를 참고해서 작은 규모부터 대규모까지 이해하고 만들어보려고한다.

내가 주로 경험한 것이 웹서비스이기 때문에 웹서비스를 기준으로 얘기하고 공부의 목적도 있으니 AWS 등에서 간편하게 해주는 것들도 최대한 원리까지 파헤쳐보겠다.

이 시리즈는 아래와 같이 작성할 예정이다.

- [대규모 서비스에 대한 연구1 - 부하 분산(Load balancing)](https://chuck-park.github.io/cs/large-traffic-research-1/)
- [대규모 서비스에 대한 연구2 - I/O 부하 분산과 Memory, Disk](https://chuck-park.github.io/cs/large-traffic-research-2/)
- [대규모 서비스에 대한 연구3 - I/O 부하 분산과 OS 캐시](https://chuck-park.github.io/cs/large-traffic-research-3/)
- 대규모 서비스에 대한 연구4 - I/O 부하 분산과 DB(MYSQL)
- 대규모 서비스에 대한 연구5 - 부하 분산과 네트워크

![front-back-image](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbfDkVv%2Fbtsi2hp3eQu%2FXeXhqunwQNZAYHNyaKQ48K%2Fimg.png)

우선 사이드 프로젝트든 대규모 서비스든 요즘 웹 서비스는 유저에게 가까운 쪽에서 데이터를 보여주거나 관리하는 '프론트엔드'와 보이지 않는 곳에서 안정적으로 데이터를 서빙하기 위해 노력하는 '백엔드'로 구성된다.

위의 그림이 웹서비스의 최소 조건으로 많이 쓰는 형태이다. 구성은 달라질 수 있는데 각 Web server와 Application server, DB가 하나의 서버에 다 있을수도 있고, 각각의 서버로 있거나 정적 페이지만 서빙하는 정말 심플한 서비스면 DB가 없을 수도 있다.

위 그림처럼 최소 조건으로 구성하고 각 Server와 Database에 사용되는 컴퓨터의 사양이 요즘 나오는 중상급 성능의 휴대폰 정도(4core CPU, 8GB 메모리)면 대략적으로 월 100만 PV(Page View) 정도를 처리할 수 있다고 한다. 조건에 따라 많이 다르니 참고용으로만 알아두자.

이 정도 사양의 서버 한 대로도 꽤 큰 트래픽을 감당할 수 있다니 놀랍지 않은가? 사실 공부하면서 필자가 놀랐다. 나중에 좀 더 자세히 언급하겠지만 내가 일하는 회사의 서버 구성은 App 서버용 8core CPU와 32GiB Memory의 EC2 6개, 2core CPU와 16GiB Memory의 RDS 2개로 트래픽에 비해 많이 과했다.

## 대용량이란
그렇다면 대용량이란 어느정도일까? 절대적인 기준은 없지만 월 1천만명 정도가 사용하는 서비스면 대부분의 개발자들은 대용량이라고 말할 수 있다고 생각한다. 그런데 사실 이 글 말머리에 언급한 '대규모의 실시간 트래픽 경험이 있는가'는 절대적으로 큰 서비스를 경험해보았는지에 대한 질문이라기보다 현재 서버의 상태에서 트래픽이 몰릴 것이 예상될 때 해결할 수 있는 능력이 있는가를 물어보는 것에 가깝다고 생각한다. 현재 내가 사용하는 서버가 감당할 수 없는 수준의 트래픽이 몰리면 어떻게 처리할지 알아보자.

## 서버에 트래픽이 몰리면 어떤 일이 일어날까?
크게 CPU와 I/O에 부하(Load)가 일어난다. 부하가 커져서 최대치에 가까워지면 컴퓨터는 점점 느려지거나 꺼지거나 고장난다. 어떤 서비스에서 깜짝 이벤트를 하거나 티켓팅할 때 서버가 죽었다라고 하는 경우가 이런 경우이다.

개발적으로 보면 웹 서버의 웹 어플리케이션의 복잡한 계산(ex. 암호 관련 계산, 과학 계산 등)이 CPU 부하, DB 서버의 대용량 데이터 읽기와 쓰기가 I/O 부하와 관련이 많다. 백엔드 개발자로서 이렇게 CPU나 DB의 부하가 커지고 있을 때 어떻게 대응 해야할까?

![traffic-image](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2Flxy6U%2Fbtsi5sKno6I%2F6uE1CiZpuGUND50pxn4C31%2Fimg.jpg "트래픽으로 인한 부하는 고속도로에 차가 많아져서 막히게 되는 것으로 비유해보면 이해가 쉽다.")

## 서버의 트래픽이 몰렸을 때 해결하는 방법
CPU 부하와 I/O 부하에 모두 적용되는 가장 기본적인 해결법은 scaling이다. scaling은 scale up과 scale out 두가지로 나뉘는데 scale up은 컴퓨터 사양을 더 좋게 하는거고, scale out은 다른 컴퓨터 하나를 더 붙여서 전체 시스템 성능을 올리는 방법이다. 돈이 많으면 scale up을 하는게 편하지만 좋은 부품 값은 생각보다 많이 비싸다. 그래서 복잡해지지만 저렴한 컴퓨터를 많이 사서 scale out하는 방법을 많이 사용한다.

### CPU 부하 처리
CPU 부하가 커지고 있는 경우에는 비교적 간단하게 처리할 수 있다. 앱 서버를 추가한 뒤 부하가 각 서버에 골고루 잘 분산되도록 설정해주면 된다. 부하 분산은 많이 들어본 Proxy나 Load Balancer를 이용해서 분배해주면 된다. Load Balancer의 종류와 기능, 동작 원리 등에 대해서도 알아두면 좋지만 그건 다른 글에서 자세히 알아보도록하고 우선은 기본적으로 Load Balancer는 Round Robin 알고리즘으로 부하를 분산시킨다 정도만 알아두자.

![scale-out-example-image](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbDgjjQ%2Fbtsi2QrVSQV%2F8IsEDExDROk91lbDniVpR1%2Fimg.png "앱 서버를 scale out 한 예")

### I/O 부하 처리
I/O 부하는 CPU 부하에 비해 좀 더 복잡하다. DB를 scale out 한 경우, Load Balancing 외에도 각 DB의 데이터를 동기화 시켜줘야한다. DB 데이터 동기화는 한쪽의 데이터를 다른쪽으로 복제하는 문제, 하드 디스크의 물리적인 속도 문제 등 좀 더 신경써야 할 부분이 많다.

DB의 Load Balancing은 앱 서버를 scalue out 했을 때와 같이 Proxy나 Load Balancer를 붙여줘도 되고, 또는 어플리케이션에서 로직으로 분배해주어도 된다(ORM을 많이 이용). DB끼리의 데이터의 복제는 RDBMS에 대부분 존재하는 replication 이라는 기능으로 쉽게 할 수 있다.

### read 작업 분산
replication이란 한 DB를 primary로 두고 다른 DB를 replica를 지정하면 replica가 primary를 polling해서 primary의 값을 replica로 복사하는 기능이다. replica가 primary의 데이터를 단방향으로 복사하는 replication 방식의 특성 상 write 작업은 primary에만 해야하기 때문에 primary는 분산이 안되고, read 작업은 load balancing해서 골고루 분배해줄 수 있다. 서비스가 커지면 primary도 부하 분산을 해줘야 하겠지만 일반적으로 write 작업은 read 작업에 비해 빈도가 10~100배 이상 적은 경우가 많으므로 어느 정도까지는 replication만으로도 부하 문제를 대부분 해결할 수 있다.

![DB-scale-out-example-image](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FbyQWqM%2Fbtsi00PFUmC%2FFqhe4rj1KzOMpKBvPHAee0%2Fimg.png "DB를 scale out한 예")

### write 작업 분산
만약 write 작업의 부하가 감당할 수 없을 정도가 되면 테이블 partitioning이라는 방법으로 문제를 해결할 수 있다. 테이블 partitioning이란 말 그대로 테이블을 쪼개서 다른 DB에 저장하는 방식인데, 자주 쓰이는 테이블끼리 모으고 관련이 적은 테이블끼리 나누는 방식으로 데이터를 partioning하면 write 작업을 분산 시킬 수 있다. 하지만 partioning을 하면 join SQL을 사용하지 못하기 때문에 where, in 등을 사용해서 쿼리를 두번 이상 불러야하는 등 DB에 위임했던 작업 중 어플리케이션 레벨에서 처리해야하는 것들이 많아지기 때문에 어플리케이션 로직이 복잡해지고, 어떤 DB가 어떤 DB인지를 기억하고 관리해야하는 등의 복잡도가 증가하기 때문에 가능하면 사용하지 않는 것이 좋다.

다른 방법으로는 RDBMS가 아닌 대규모 데이터 읽기 쓰기에 강한 NOSQL을 사용하는 것을 고려해볼 수 있다. NOSQL 역시 큰 주제여서 여기서는 자세히 다루지 않고 간단하게 알아보면, NOSQL의 대표적인 예로 데이터의 정합성의 중요성이 적고 단순 텍스트의 조회와 업데이트만 하면 되는 경우라면 Redis와 같이 메모리를 사용하는 in-memory key-value database를 사용하면 더 많은 write 작업을 감당할 수 있게 된다. 실제로 메신저 서비스를 메인으로하는 Line에서는 짧은 시간에 방대한 양의 메시지 write를 처리해야하기 때문에 수 많은 Redis를 Cluster 형태로 묶어서 사용하고 있고 크리스마스나, 1월 1일 등 예상할 수 있는 대규모 트래픽이 발생하기 전에 미리 Redis를 많이 늘려 놓는다고 들은 적이있다. 아마 다른 메신저 서비스에서 PC와 모바일 앱과의 메시지 히스토리 차이, 재설치해야하는 상황에 미리 백업 요청을 안해놓으면 메시지 히스토리가 다 날아가는 것도 메시지를 permanant하게 서버 DB에 저장하지 않고 메모리 디비와 client의 리소스를 조합해서 사용하기 때문이지 않을까 추측해본다.

자 이제 모든 문제가 해결됐을까? 이렇게 쉽게 문제를 해결 할 수 있다면 너무 좋을 것 같다. I/O 분산의 경우에는 CPU 분산보다 좀 더 까다롭다고 말한 이유가 있다. I/O 부하의 경우는 이렇게 나눠줬다고 하더라도 크게 효율이 없을 수 있는데 그건 바로...

다음 글에서 확인해보자.

# 참고
- 대규모 서비스를 지탱하는 기술