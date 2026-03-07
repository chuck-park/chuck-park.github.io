# OpenClaw 실사용 운영 정리: 도메인·SEO·Obsidian 워크플로우

## 왜 이 글을 썼나
오늘은 OpenClaw를 실제 비서처럼 운영하면서 부딪힌 문제를 정리했다.
핵심은 세 가지였다.

1. GitHub Pages 커스텀 도메인 연결과 SEO 정합성
2. 원격 환경에서 CLI 중심 운영 원칙 확립
3. Obsidian 문서 운영을 안전하게 유지하는 방법

---

## 1) GitHub Pages 도메인 연결은 “붙였다”가 끝이 아니다
`blog.chuckpark.kr`를 `chuck-park.github.io`에 연결했는데, 처음엔 접속만 되는 상태였다.
문제는 SEO 기준 URL이 여전히 옛 도메인을 가리키고 있었다는 점이다.

### 실제로 틀어졌던 지점
- canonical URL이 `https://chuck-park.github.io/`
- `og:url`도 동일하게 옛 도메인
- `robots.txt`의 sitemap 주소도 옛 도메인
- `sitemap.xml` 내부 URL도 옛 도메인

즉, 검색엔진 관점에서는 새 도메인으로 완전히 이전되지 않은 상태였다.

### 수정 포인트
Jekyll `_config.yml`의 `url`을 아래처럼 수정했다.

```yml
url: "https://blog.chuckpark.kr"
baseurl: ""
```

`CNAME` 파일은 `blog.chuckpark.kr`로 유지.
이후 재배포하면 canonical/og/sitemap이 새 도메인 기준으로 정렬된다.

---

## 2) HTTPS 발급 지연은 대개 정상이다
GitHub Pages에서 “TLS certificate is being provisioned (up to 15 min)” 메시지가 뜨면 불안해지기 쉽다.
하지만 DNS가 맞다면 대부분 시간 문제다.

### 먼저 확인할 것
- DNS: `blog CNAME -> chuck-park.github.io`
- Pages Custom domain: `blog.chuckpark.kr`
- 레포 `CNAME` 파일: `blog.chuckpark.kr`

셋이 맞으면 보통 기다리면 해결된다.

---

## 3) 원격 운영은 브라우저보다 CLI가 훨씬 덜 피곤하다
실사용 중 명확해진 원칙:

- 가능하면 브라우저 자동화보다 CLI 우선
- 인증/권한 상태를 먼저 점검
- 같은 명령이라도 “어느 계정 컨텍스트에서 실행 중인지”를 항상 확인

특히 `ngrok`, `gh`, `brew`는 사용자 컨텍스트가 다르면
“설치했는데 안 보인다”가 쉽게 발생한다.

### 교훈
문제의 80%는 도구 자체가 아니라
**PATH/계정/토큰/세션 분리**에서 생긴다.

---

## 4) Obsidian은 “직접 iCloud 편집”보다 “로컬 미러 + 승인 반영”이 안전했다
개인 수기 작성은 iCloud 직편집도 충분히 가능하다.
하지만 에이전트 자동화가 만질 때는 다르다.

### 권장 운영
- 사람: iCloud Vault 직접 작성 가능
- 에이전트: 로컬 미러에서 수정
- 반영: diff 확인 후 승인 push

이렇게 하면 실수 반경을 줄이고, 복구보다 예방이 쉬워진다.

---

## 5) 비서 운영 룰을 명문화해야 재발이 줄어든다
오늘 확정한 운영 룰:

- 모델 변경 전 가용성 검증 필수
- 일정 조회는 복수 계정 통합 조회
- 일정/할 일 등록은 Google Calendar/Tasks 우선
- 문서 수정은 변경안 제시 후 승인 반영
- 가능하면 CLI 우선, 브라우저는 보조

자동화는 “능력”보다 “운영 규칙”이 품질을 만든다.

---

## 마무리
OpenClaw를 제대로 쓰려면 단순히 명령을 많이 아는 것보다,
어떤 순서로 점검하고 어떤 원칙으로 반영할지를 먼저 정해야 한다.

오늘의 결론은 간단하다.

**도구는 자동화하고, 의사결정은 통제하자.**
