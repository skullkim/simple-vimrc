---
description: Jira 티켓 기반 커밋 (git add + commit)
allowed-tools: Bash, Read, Grep, Glob, AskUserQuestion
---

변경된 파일을 git add 하고, Jira 티켓 번호가 포함된 커밋 메시지로 커밋한다.

## 커밋 메시지 형식

```
[TICKET-ID]type: 설명 (30자 이내)
```

- type: `feat` (기능 생성), `refactor` (리팩터링), `fix` (에러 수정), `test` (테스트 수정)

## 작업 절차

### 1단계: 브랜치에서 Jira 티켓 번호 추출

```bash
git branch --show-current
```

브랜치명의 마지막 `/` 뒤 문자열이 티켓 ID이다.
- 예: `feature/skull/SKUL-4` -> `SKUL-4`
- 예: `feature/OAMD-1234` -> `OAMD-1234`

만약 티켓 번호를 추출할 수 없으면 (예: `main`, `develop` 등) 사용자에게 티켓 번호를 직접 물어본다.

### 2단계: 변경 사항 확인

다음 명령어를 병렬로 실행한다:

```bash
git status
git diff --staged
git diff
```

### 3단계: 커밋 타입 결정 및 메시지 작성

변경 내용을 분석하여:

1. **커밋 타입 결정**: 변경 내용에 따라 `feat`, `refactor`, `fix`, `test` 중 하나를 선택한다.
2. **설명 작성**: 변경 내용을 요약하여 30자 이내 한글로 작성한다.
3. **사용자 확인**: 커밋 메시지를 사용자에게 보여주고 확인을 받는다. 반드시 확인을 받은 후에만 다음 단계로 진행한다.

예시:
```
[SKUL-4]feat: 광고체험단 성과 측정 API 구현
```

### 4단계: git add 및 커밋

사용자가 확인한 후에만 실행한다:

```bash
git add -A
git commit -m "<확인받은 커밋 메시지>"
```

## 주의사항

- 커밋 메시지의 설명 부분은 반드시 30자 이내로 작성한다.
- 사용자 확인 없이 커밋하지 않는다.
- `Co-Authored-By` 는 붙이지 않는다.
