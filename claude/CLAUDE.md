# Global Claude Code Instructions

## Jira/Confluence 연동

Jira 티켓이나 Confluence 문서를 조회할 때는 아래 스크립트를 사용한다.

```bash
~/scripts/fetch-jira.sh <ISSUE_KEY>        # 예: ~/scripts/fetch-jira.sh SKUL-4
~/scripts/fetch-confluence.sh <PAGE_ID|URL> # 예: ~/scripts/fetch-confluence.sh 5014519854
```

### Jira 티켓 기반 작업 워크플로우

worktree 브랜치가 `feature/<TICKET_ID>` 형식일 경우, 작업 시작 시 반드시 다음 단계를 수행:

1. **브랜치명에서 티켓 ID 추출**: `git branch --show-current`의 마지막 `/` 뒤 문자열이 티켓 ID (예: `feature/skull/SKUL-4` → `SKUL-4`, `feature/SKUL-4` → `SKUL-4`)
2. **Jira 티켓 조회**: `~/scripts/fetch-jira.sh <TICKET_ID>` 실행하여 요구사항 파악
3. **Confluence 링크 확인**: 티켓 출력에 `Confluence Links Found` 섹션이 있으면, 각 URL에 대해 `~/scripts/fetch-confluence.sh <URL>` 실행하여 추가 컨텍스트 확보
4. **전체 컨텍스트를 기반으로 작업 수행**: 티켓 설명 + Confluence 문서 내용을 종합하여 코드 작업, 테스트 실행

### Agent Team 작업 시 규칙

- 각 subagent는 자신에게 할당된 worktree 디렉토리에서만 작업한다
- 다른 worktree의 파일을 수정하지 않는다
- 작업 완료 후 테스트를 실행하고, 실패하면 수정한다
- 커밋 메시지에 티켓 ID를 포함한다 (예: `SKUL-4: 광고체험단 성과 측정 API 구현`)
