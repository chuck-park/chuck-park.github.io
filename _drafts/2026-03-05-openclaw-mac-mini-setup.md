## 문서 메타데이터 (표준)

| 항목 | 값 |
| --- | --- |
| 문서 제목 | Mac mini에 OpenClaw 설치하기 (무작정 따라하기) |
| 초안 작성 날짜 | 2026-03-05 |
| 예상 독자 | Mac mini에서 OpenClaw를 처음 설치하는 사용자(비개발자 포함) |
| 예상 읽기 시간 | 약 5분 (946 words, 분당 220 words 기준) |

# Mac mini에 OpenClaw 설치하기 (무작정 따라하기)

이 문서는 설치 절차만 다룹니다. 후기/회고는 별도 문서에 작성합니다.

## 1단계. 장비 켜기
- [ ] Mac mini를 HDMI로 모니터에 연결
- [ ] 전원 버튼 1회 눌러 부팅
- [ ] 키보드/트랙패드 연결

## 2단계. 계정 분리
- [ ] 관리자(admin) 사용자 계정 준비
  - 메인 로그인, GUI, 원격 접속 관리용
- [ ] 서비스 계정(service) 생성
  - OpenClaw 실행, 토큰/로그/런타임 전용

## 3단계. 관리자 계정에서 선행 설치
- [ ] OpenClaw 전용 계정 준비
  - Apple
  - Google
- [ ] Chrome 설치
- [ ] 원격 접속 도구 설치
  - Chrome Remote Desktop
  - VNC(Virtual Network Computing)
  - Tailscale
- [ ] Homebrew 설치

원격 접속 방식 비교(3-1~3-3 진행 전 확인):

| 방식 | 장점 | 단점 | 추천 상황 |
| --- | --- | --- | --- |
| Chrome Remote Desktop | 설치 후 브라우저에서 바로 접속 가능, UI가 직관적이라 입문자도 사용 쉬움 | 구글 계정 로그인/권한 설정 단계가 많음 | 가장 쉽게 GUI 원격 접속을 시작하고 싶을 때 |
| VNC | macOS 기본 기능(화면 공유)이라 추가 서비스 의존이 적음 | 같은 와이파이(같은 네트워크)에서 가장 안정적, 외부 접속은 Tailscale 같은 별도 구성 필요 | 집/사무실에서 같은 와이파이로 접속할 때 |
| Tailscale | 외부망에서도 사설망처럼 안전하게 접속 가능, SSH와 조합해 강력함 | CLI 기반 사용이 많아 비개발자는 진입장벽이 높음 | 외부에서 SSH/GUI를 함께 운영하고 싶을 때 |

## 3-1단계. Chrome Remote Desktop 접속 설정
Chrome Remote Desktop는 구글 계정 기반으로 브라우저에서 원격 화면을 붙는 도구입니다.

- [ ] Mac mini에서 Chrome 로그인(원격용 Google 계정)
- [ ] Chrome Remote Desktop 설치/활성화
  - https://remotedesktop.google.com/access
- [ ] 안내에 따라 Host 설치 파일 다운로드 후 설치
- [ ] Mac mini 이름과 PIN(6자리 이상) 설정
- [ ] macOS 권한 허용
  - `시스템 설정 > 개인정보 보호 및 보안 > 손쉬운 사용`에서 Chrome Remote Desktop 허용
  - `시스템 설정 > 개인정보 보호 및 보안 > 화면 및 시스템 오디오 녹화`에서 Chrome Remote Desktop 허용
- [ ] 접속할 기기에서 같은 Google 계정 로그인 후 원격 접속 테스트

문제 시 점검:
- [ ] Mac mini 전원/네트워크 연결 상태 확인
- [ ] Chrome Remote Desktop Host가 실행 중인지 확인
- [ ] PIN 재입력 후 재시도

## 3-2단계. VNC 접속 설정
VNC(Virtual Network Computing)는 macOS 기본 화면 공유 기능으로 접속하는 방식입니다.

- [ ] Mac mini에서 `시스템 설정 > 일반 > 공유 > 화면 공유` 켜기
- [ ] `허용된 사용자`를 관리자 계정으로 제한
- [ ] 접속할 기기에서 VNC 클라이언트 준비
  - Mac 기본 화면 공유 앱 또는 RealVNC Viewer 사용
- [ ] 같은 와이파이(같은 네트워크)에서 접속
  - 주소 예시: `vnc://<Mac-mini-로컬-IP>`
- [ ] 계정/암호 입력 후 화면 접속 테스트

외부에서 접속할 때:
- [ ] 3-3단계(Tailscale) 완료 후 아래 주소로 접속
  - `vnc://<hostname.tailnet-name.ts.net>`
  - `vnc://100.x.x.x`

문제 시 점검:
- [ ] `화면 공유`가 켜져 있는지 재확인
- [ ] 접속 주소(IP/호스트명) 오타 확인
- [ ] Mac mini 절전 모드 해제 후 재시도

## 3-3단계. Tailscale로 Mac mini 접속 설정
- [ ] Mac mini와 접속할 기기(내 노트북/PC) 모두 Tailscale 설치
- [ ] 두 기기 모두 같은 Tailscale 계정으로 로그인
- [ ] Mac mini에서 `시스템 설정 > 일반 > 공유 > 원격 로그인` 켜기(SSH)

![[Screenshot 2026-03-05 at 17.19.52.png|311]]

- [ ] 화면까지 원격으로 볼 경우 `화면 공유`도 켜기(VNC)
- [ ] Mac mini 터미널에서 ip 주소 확인

```bash
tailscale status
```

- [ ] 접속할 기기에서 SSH 테스트

```bash
ssh <맥미니사용자>@<hostname.tailnet-name.ts.net>
```

- [ ] SSH가 안 되면 Tailscale 연결 상태 점검

```bash
tailscale status
tailscale ping <hostname.tailnet-name.ts.net>
```

주 컴퓨터(MacBook Air) -> 오픈클로용 컴퓨터(MacMini)의 관리자 계정 접속 성공 화면

![[Pasted image 20260305171751.png]]

## 4단계. 서비스 계정으로 전환
- [ ] 현재 계정에서 로그아웃 후 `service` 사용자로 다시 로그인
- [ ] `nvm` 설치
- [ ] Node.js 설치

## 5단계. OpenClaw 설치
아래 명령을 순서대로 실행:

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

## 6단계. Quick Start 설정
아래 값으로 진행:
- [ ] Default model: 기본 추천 모델 선택 (당시 기준: OpenAI GPT-5.3 Codex OAuth)
- [ ] Channel: Telegram
- [ ] Skills: Skip for now
- [ ] Hooks
  - `boot-md`
  - `command-logger`
  - `session-memory`

필요 시 Hooks 참고:
- https://twofootdog.tistory.com/555#toc6

## 7단계. 페르소나 입력
아래 문구를 그대로 붙여넣기:

```text
너의 이름은 '클로'야. 나는 'Chuck'이야. 너는 나를 주인님이라고 불러.
직접적이고 간결하며 정직하게 말해. 위험하거나 비효율적인 요청에는 먼저 반대 의견과 이유를 설명해.
파괴적이거나 되돌릴 수 없는 작업, 파일 삭제, 메시지 전송, 부작용 있는 명령 실행 전에는 반드시 확인해.
보안 이슈는 사전에 보고하고, 내가 추가 설명을 요청하지 않으면 답변은 짧게 유지해.
```

## 8단계. 설치 직후 점검
아래 명령을 순서대로 실행:

```bash
openclaw tui
openclaw security audit --deep
# 결과에서 수정 필요 항목이 있을 때만 아래 실행
openclaw security audit --fix
openclaw doctor
# doctor 결과에서 자동 수정이 필요한 경우에만 실행
openclaw doctor --fix
```

## 9단계. 첫 사용 확인
- [ ] Google 계정 연동(OAuth) 완료 확인
- [ ] Telegram 채널 연결 상태 확인
- [ ] Google Calendar 일정 조회 테스트

## 참고 링크
- https://stephenslee.medium.com/i-set-up-openclaw-on-a-mac-mini-with-security-as-priority-one-heres-exactly-how-050b7f625502
- https://goddaehee.tistory.com/504
- https://twofootdog.tistory.com/557
- https://yu-wenhao.com/en/blog/openclaw-tools-skills-tutorial/
