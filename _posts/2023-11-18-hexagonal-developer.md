---
title: 육각형 개발자
categories: book
tags:
  - book
  - 개발자
---

회사에서 스터디를 시작했다. 개발자들끼리 하는 스터디이지만 다양한 주제에 대한 책을 읽고 서로 느낀점을 공유하는 방식으로 진행하는데 이번에 읽은 책은 최범균님이 쓴 '육각형 개발자' 다. 전체적인 느낌은 선배 개발자가 이제 막 개발을 시작한 후배 개발자에게 들려주고 싶은 조언들을 담은 가볍게 읽을 수 있는 책이다.

1~2장에서는 저자가 처음 일을 시작했을때부터의 이야기가 나온다. 개인적으로는 서비스 회사에서 개발을 시작해서 SI나 대기업 파견, 협력 업체와의 협업 부분은 공감이 잘 안되긴 했다. 많이들 하는 이야기지만 가능하면 자체 IT 서비스가 있는 회사에서 시작하는게 더 좋은 것 같긴히다. 저자가 경력이 10년 이상 되다보니 지금은 거의 쓰지 않는 기술과 큰 패러다임의 변화들에 대한 이야기도 많이 나오는데 기술이 참 많으면서도 빨리 바뀐다는 생각이 들었다. 개인적으로 OOP, functional, reactive 등 개발 패러다임에도 관심이 있고 역사를 좋아하는데 관련해서도 스터디를 하고 글로 정리해보고 싶다. 참고로 개발 패러다임의 초기부터 현재 미래 전망에 관련해서 재밌게 읽었던 글이 있어 공유한다.

 > [개발 페러다임의 변화, 백엔드에서 프론트엔드로](https://brunch.co.kr/@jamess/100)

필요한 기술을 처음부터 깊게 학습하지 않는다라는 내용이 있는데 나도 그렇고 스터디에 참여한 다른 사람들도 처음에는 완벽하게 학습하려고 하다가 경력이 쌓일수록 점점 필요한 부분 위주로 빠르게 보는 방향으로 바뀌었다고해서 신기했다. 나 같은 경우는 CS나 언어까지는 책으로 한번 보는 것 같고 framework부터는 js로 치면 react나 nestjs, python으로 치면 django 같은 핵심이 되는 것들은 'Get started' 한번 따라해보고  docs에 advanced 전까지는 읽어보는 편, 그 외의 library들은 docs에서 딱 필요한 부분만 찾아서 보는 것 같다. 핵심 framework의 advanced 부분은 평소에는 거의 안보는 것 같고 그룹스터디 등을 통해 의도적으로 더 학습하고 library들의 내부 구현에 관해서는 성능이 중요한 경우나 버그가 있을 때 정도에 까보는 것 같다.

개발자로서의 역량이 단순히 코딩을 하는 것이 아니라 고객의 요구사항을 파악하고 원하는 것을 충족하는 기능을 개발한다는 것에 공감이 됐고 개발자로서의 역량을 아래처럼 크게 세가지로 분류했는데 머릿속에 모호하게 생각하던 것들을 클리어하게 해주는 느낌을 받아서 좋았다. 그리고 사실 이 내용에 대한 상세 내용이 이 책의 내용의 거의 전부이다.

### 개발자로서의 역량
- 구현 기술
  - 현재 사용 중인 기술
  - 문제를 해결하기 위한 기술
- 설계 역량
- 업무 관리와 요구 분석, 공유, 리드 & 팔로우

코드 품질과 개발 시간, 결함의 관계 그래프나 개발자가 코드를 변경할 때 코드 이해에 일반적으로 사용하는 시간(약 60%)등 여러가지 연구에서 확인된 정량 지표들이 나오는데, 정성적으로만 생각하고 있었던 부분에 대해 구체적인 수치를 알 수 있어서 좋았다.

전에는 최대한 주석 없이 코드만으로 이해할 수 있는 코드가 좋은 코드라는 생각을 했었는데 그러기 어려운 부분도 있다고 생각하고 필요하다면 친절한 주석도 달고 유비쿼터스 랭귀지를 정의하거나 다이어그램 등으로 시각화해서 팀원들 간의 싱크를 맞추는 등의 시도해보고 있었는데 마침 책에서 규모가 크고 복잡한 코드는 칠판에 그림을 그리거나 그래프 등을 이용해서 시각화하거나 코드를 종이에 출력해서 한번에 보는 방법(!?) 등을 추천해서 동질감을 느꼈다. 물론 코드 종에 출력하는건 처음 들어봤고 신박한 방법이라고 생각했다...

또 스크래치 리팩토링이라고 개선을 위한 것이라기 보다는 빠르게 이해하기 위해서 리팩토링을 진행하는 방법을 추천했는데, 마침 요즘 일하면서 리팩토링을 많이 하고 있다. 리팩토링 하면서 고구마 줄기처럼 얽혀있는 문제들을 하나 하나 해결하다보면 코드 베이스에 대한 이해가 빠르게 올라가는 것을 체감하고 있어서(괜히 건드렸나 하는 후회도 들긴 하지만) 어떤 목적이든 리팩토링은 적극 추천한다. 바꿔야할 최소 스콥이 너무 커서 실제 유의미한 개선까지 진행하기 어렵다고 생각된다면 책에서 말했던 스크래치 리팩토링도 좋은 방법일 것 같다.

응집도와 결합도에 대해서도 여러가지 그림을 보여주면서 설명하고 있는데 각각 한마디로 표현하면 아래와 같은데,

응집도: 같은 역할, 책임끼리 모여있는 정도
결합도: 모듈 간의 의존하고 있는 정도

좀 추상적이기도하고 응집도, 결합도에 관련해서 분류 방법들도 따로 있는 등 간단한 내용은 아니라서 아직 어렵다. 제대로 소화하려면 이 부분은 몇 번 다시 읽어봐야할듯.

이 외에는 레거시 코드에 대한 이야기, 더 좋은 코드로 리팩토링하는 방법, 테스트, 아키텍쳐 등의 개발에 가까운 이야기와 좋은 리더와 좋은 팔로워가 되기 위한 방법들 등 취준생, 이제 막 입사한 신입 개발자들이 읽으면 도움이 될 만한 이야기들이 많이 적혀있다.