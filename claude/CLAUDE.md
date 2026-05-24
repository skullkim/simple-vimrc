# Global Claude Code Instructions

## 품질 유지 규칙

### 편집 전 반드시 읽기
- 파일을 수정하기 전에 반드시 Read로 대상 파일을 읽을 것
- 대상 파일뿐 아니라 관련 파일(호출부, 인터페이스, 테스트)도 읽어서 맥락을 파악할 것
- Write(전체 덮어쓰기) 대신 Edit(정밀 편집)을 우선 사용할 것

### 조기 중단 금지
- "이 정도면 충분합니다", "계속할까요?", "좋은 중단 지점입니다" 등의 표현 금지
- 태스크가 완료될 때까지 스스로 멈추지 말 것
- 작업 완료를 주장하기 전에 빌드 또는 테스트로 검증할 것

### 복잡한 작업은 Plan 모드 우선
- 3개 이상의 파일을 수정해야 하는 작업은 먼저 계획을 세우고 사용자 확인을 받을 것
- 바로 구현에 들어가지 말고, 어떤 파일을 어떤 순서로 수정할지 정리할 것

### 태스크 크기 제한
- 한 번에 너무 큰 범위를 수정하지 말 것
- 변경 단위를 작게 유지하고, 각 단위마다 검증할 것

## Jira/Confluence 연동

Jira 티켓이나 Confluence 문서를 조회할 때는 아래 스크립트를 사용한다.

```bash
~/scripts/fetch-jira.sh <ISSUE_KEY>        # 예: ~/scripts/fetch-jira.sh SKUL-4
~/scripts/fetch-confluence.sh <PAGE_ID|URL> # 예: ~/scripts/fetch-confluence.sh 5014519854
```

### Jira 티켓 기반 작업 워크플로우 (비활성화됨)

<!-- 아래 워크플로우는 비활성화 상태입니다. 자동으로 Jira 티켓을 조회하지 않습니다.
     사용자가 명시적으로 티켓 조회를 요청할 때만 수행합니다.

worktree 브랜치가 `feature/<TICKET_ID>` 형식일 경우, 작업 시작 시 반드시 다음 단계를 수행:

1. **브랜치명에서 티켓 ID 추출**: `git branch --show-current`의 마지막 `/` 뒤 문자열이 티켓 ID (예: `feature/skull/SKUL-4` → `SKUL-4`, `feature/SKUL-4` → `SKUL-4`)
2. **Jira 티켓 조회**: `~/scripts/fetch-jira.sh <TICKET_ID>` 실행하여 요구사항 파악
3. **Confluence 링크 확인**: 티켓 출력에 `Confluence Links Found` 섹션이 있으면, 각 URL에 대해 `~/scripts/fetch-confluence.sh <URL>` 실행하여 추가 컨텍스트 확보
4. **전체 컨텍스트를 기반으로 작업 수행**: 티켓 설명 + Confluence 문서 내용을 종합하여 코드 작업, 테스트 실행
-->

### Agent Team 작업 시 규칙

- 각 subagent는 자신에게 할당된 worktree 디렉토리에서만 작업한다
- 다른 worktree의 파일을 수정하지 않는다
- 작업 완료 후 테스트를 실행하고, 실패하면 수정한다
- 커밋 메시지에 티켓 ID를 포함한다 (예: `SKUL-4: 광고체험단 성과 측정 API 구현`)
