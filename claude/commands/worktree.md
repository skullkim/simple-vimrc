---
description: JIRA 티켓 기반 git worktree 생성/조회/제거/초기화
allowed-tools: Bash, Read, Write, Edit, AskUserQuestion
---

JIRA 티켓 번호를 받아 정해진 네이밍 규칙으로 git worktree를 생성하거나, 이미 생성된 worktree를 조회·제거하거나, 저장된 설정을 초기화한다.

## 설정 파일

- 경로: `~/.claude/worktree-config.json`
- 스키마:

```json
{
  "nickName": "",
  "ticketPrefix": "",
  "worktrees": {}
}
```

- `nickName`, `ticketPrefix`: 전역 1개씩 (모든 레포 공유)
- `worktrees`: 키 `"{repo-name}/{PREFIX}-{num}"`, 값 `"{base-branch-name}"`
- 파일이 없거나 JSON이 손상되었으면 사용자에게 알리고 종료한다. 손상된 파일을 자동 덮어쓰지 않는다.

## 브랜치 네이밍 규칙

| Type | 패턴 | 예 |
|---|---|---|
| feature | `feature/{nickName}/{PREFIX}-{num}` | `feature/skull/OADM-3597` |
| epic | `feature/epic/{PREFIX}-{num}` | `feature/epic/OADM-3600` |

## worktree 경로 규칙

`~/.git-worktrees/{repo-name}/{PREFIX}-{num}`

`{repo-name}` = `git rev-parse --show-toplevel`의 basename.

## 최상위 라우팅

`$ARGUMENTS`를 확인한다.

- 인자가 비어 있으면 AskUserQuestion으로 서브커맨드를 선택하게 한다:
  - `create` — worktree 생성 (섹션: "create 서브커맨드")
  - `list` — worktree 조회 (섹션: "list 서브커맨드")
  - `remove` — worktree 제거 (섹션: "remove 서브커맨드")
  - `reset` — 설정 초기화 (섹션: "reset 서브커맨드")
- 인자의 첫 토큰이 `create` / `list` / `remove` / `reset` 중 하나이면 해당 서브커맨드로 직접 분기한다. 나머지 토큰은 해당 서브커맨드로 전달한다.
- 그 외 토큰이면 `create` 서브커맨드로 전체 `$ARGUMENTS`를 전달한다 (역호환: 숫자만 입력하는 기존 사용자 흐름).

## config 읽기/쓰기

### 읽기

```bash
CONFIG=~/.claude/worktree-config.json
if [ ! -f "$CONFIG" ]; then
  echo '{"nickName":"","ticketPrefix":"","worktrees":{}}' > "$CONFIG"
fi
# 유효성 검사
jq empty "$CONFIG" 2>/dev/null || { echo "config 파일이 손상되었습니다: $CONFIG"; exit 1; }
NICK=$(jq -r '.nickName // ""' "$CONFIG")
PREFIX=$(jq -r '.ticketPrefix // ""' "$CONFIG")
```

### 쓰기 (특정 키 업데이트)

```bash
# 예: nickName 업데이트
tmp=$(mktemp)
jq --arg v "$NEW_NICK" '.nickName = $v' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
```

### worktree 맵 업데이트

```bash
tmp=$(mktemp)
jq --arg k "$REPO_NAME/$TICKET" --arg v "$BASE" '.worktrees[$k] = $v' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
```

### 키 삭제/초기화

```bash
tmp=$(mktemp)
# nickName을 빈 문자열로
jq '.nickName = ""' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
# worktrees 맵 전체 비우기
jq '.worktrees = {}' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
```

## create 서브커맨드

### 1단계: 사전 조건 확인

현재 디렉토리가 git repo인지 확인한다:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "현재 디렉토리는 git repo가 아닙니다"; exit 1; }
REPO_NAME=$(basename "$REPO_ROOT")
```

### 2단계: nickName / ticketPrefix 확보

config에서 값이 비어 있으면 AskUserQuestion으로 입력받아 저장한다.

- `nickName` 비어있으면: "브랜치 네이밍용 nick-name을 입력하세요 (예: skull)" 질문 후 입력값 저장
- `ticketPrefix` 비어있으면: "JIRA 티켓 prefix를 입력하세요 (예: OADM)" 질문 후 입력값 저장

두 값 모두 "config 쓰기" 절차로 즉시 저장한다. 이미 채워져 있으면 질문을 건너뛴다. AskUserQuestion의 옵션 대신 자유 입력이 필요하면 사용자가 "Other"를 선택해 직접 입력하도록 유도한다.

### 3단계: worktree 타입 선택

AskUserQuestion으로 `feature` / `epic` 중 선택.

- 인자로 전달된 토큰 중 `feature` 또는 `epic`이 있으면 질문 생략하고 그 값 사용.

### 4단계: 티켓 번호 수집

공백으로 구분된 숫자 하나 이상을 받는다 (예: `3597 3598`).

- 인자에 이미 숫자 토큰이 있으면 그대로 사용.
- 숫자가 하나도 없으면 AskUserQuestion("Other")로 직접 입력받는다.
- 각 숫자 `N`에 대해 티켓 키는 `{PREFIX}-{N}`.

### 5단계: base branch 감지 + 선택

```bash
CANDIDATES=()
for name in develop main master; do
  if git show-ref --verify --quiet "refs/heads/$name" || git show-ref --verify --quiet "refs/remotes/origin/$name"; then
    CANDIDATES+=("$name")
  fi
done
```

- 후보가 0개면: 에러 출력 후 종료 ("develop/main/master 중 어느 것도 찾을 수 없음")
- 후보가 1개면: 그 값을 base로 사용
- 후보가 2개 이상이면: AskUserQuestion으로 선택

인자 토큰 중 후보에 포함되는 값이 있으면 질문 생략하고 그 값 사용.

### 6단계: 병렬로 worktree 생성 + 서브모듈 초기화

각 티켓 `{PREFIX}-{N}`에 대해 **병렬** 실행:

```bash
# feature: BRANCH_NAME="feature/$NICK/$PREFIX-$N"
# epic:    BRANCH_NAME="feature/epic/$PREFIX-$N"
WT_PATH=~/.git-worktrees/$REPO_NAME/$PREFIX-$N
git worktree add -b "$BRANCH_NAME" "$WT_PATH" "$BASE" || { echo "[$PREFIX-$N] worktree 생성 실패 (skip)"; continue; }
(cd "$WT_PATH" && git submodule update --init --recursive) || echo "[$PREFIX-$N] 서브모듈 초기화 실패 (worktree는 유지)"
```

**중요:** 여러 티켓을 동시에 생성할 때는 반드시 병렬 Bash 호출로 실행한다 (단일 메시지 내 여러 Bash 툴 호출).

### 7단계: config 업데이트

성공적으로 생성된 각 worktree에 대해:

```bash
tmp=$(mktemp)
jq --arg k "$REPO_NAME/$PREFIX-$N" --arg v "$BASE" '.worktrees[$k] = $v' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
```

### 8단계: Warp 새 탭 + IntelliJ 실행

호스트 터미널이 Warp 이고, 손쉬운 사용(Accessibility) 권한이 부여된 상태에서만 실행한다. 그 외 환경에서는 이 단계를 **건너뛰고** 9단계로 진행한다 (워닝만 출력).

Warp 감지는 다음 조건 중 하나라도 충족하면 Warp로 간주한다 (tmux 안에서 실행되면 `TERM_PROGRAM=tmux`로 잡히므로 `WARP_*` 환경변수 fallback 필요):

- `TERM_PROGRAM = "WarpTerminal"`
- `WARP_CLIENT_VERSION` 이 비어있지 않음
- `__CFBundleIdentifier` 가 `dev.warp.*` 로 시작

각 성공한 worktree에 대해 순차 실행한다.

```bash
is_warp_host() {
  [ "$TERM_PROGRAM" = "WarpTerminal" ] && return 0
  [ -n "$WARP_CLIENT_VERSION" ] && return 0
  case "$__CFBundleIdentifier" in dev.warp.*) return 0;; esac
  return 1
}

if ! is_warp_host; then
  echo "[warn] Warp 호스트가 아니므로 새 탭 자동 생성 생략"
fi

# IntelliJ는 background(`-g`)로 실행 — 포커스 빼앗지 않음.
open -ga 'IntelliJ IDEA' "$WT_PATH" || echo "[warn] IntelliJ 실행 실패 ($WT_PATH)"

# Warp 새 탭: URL scheme 사용. 메뉴 클릭/keystroke 방식은 macOS Sequoia + Warp 조합에서
# system event 가 Warp 로 전달되지 않아 동작하지 않는다. URL scheme 은 권한 의존 없음.
if is_warp_host; then
  open "warp://action/new_tab?path=$WT_PATH" || echo "[warn] Warp 새 탭 생성 실패 ($WT_PATH)"
fi
```

**동작 원리:**

1. IntelliJ는 `open -ga 'IntelliJ IDEA' "$WT_PATH"` 로 background 실행한다. `-g` 가 핵심: 포커스를 빼앗지 않으므로 Warp 탭 생성과 안전하게 병행된다.
2. Warp 새 탭은 `warp://action/new_tab?path=...` URL scheme 한 줄로 처리한다. Warp 가 path 파라미터를 받아 새 탭을 그 디렉토리에서 연다 — 별도의 `cd` 명령이 필요 없다.

**왜 osascript/keystroke 방식을 쓰지 않는가:**

- `click menu item "New Terminal Tab" of menu "File"` 은 활성 윈도우 인식이 불안정해서 종종 새 탭 대신 새 윈도우를 만든다. `AXRaise` 로도 완전히 막지 못한다.
- `keystroke "t" using {command down}` 은 macOS Sequoia 환경의 Warp 에 system event 가 도달하지 않아 무반응이다 (Warp 가 자체 입력 시스템을 사용하기 때문으로 추정). Accessibility 권한이 정상이고 frontmost 도 stable 로 설정되지만 키 이벤트가 누락된다.
- URL scheme 은 손쉬운 사용 권한, frontmost 상태, 클립보드 백업/복구 모두 불필요하다.

**전제조건 / 실패 시 동작:**

- Warp 가 설치되어 있어야 한다 (`warp://` URL scheme handler 등록 필요). 미설치 시 `open` 이 에러를 뱉지만 워닝만 출력하고 9단계로 진행한다.
- IntelliJ 실행은 `open -ga 'IntelliJ IDEA' "$WT_PATH"` 로 한다. `/Applications/IntelliJ IDEA.app` 이 없으면 실패하므로 앱 이름이 다르면 (`IntelliJ IDEA Ultimate` 등) 환경에 맞게 조정한다.
- 이 단계의 실패는 worktree 생성 결과(7단계까지)에 **영향을 주지 않는다**. 9단계 결과 테이블은 정상 출력한다.

### 9단계: 결과 테이블 출력

```
| Type | Ticket | Branch | Path | Base |
|---|---|---|---|---|
| feature | OADM-3597 | feature/skull/OADM-3597 | ~/.git-worktrees/messaging/OADM-3597 | develop |
```

skip된 티켓은 테이블 아래 "Skipped:" 섹션에 이유와 함께 표기.

## list 서브커맨드

### 1단계: 사전 조건

현재 디렉토리가 git repo여야 한다.

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "현재 디렉토리는 git repo가 아닙니다"; exit 1; }
REPO_NAME=$(basename "$REPO_ROOT")
```

### 2단계: worktree 목록 수집

```bash
git worktree list --porcelain
```

각 엔트리에서 `worktree <path>` 와 `branch refs/heads/<branch>` 를 추출한다.

### 3단계: config의 base 맵 조회

```bash
jq -r --arg r "$REPO_NAME" '.worktrees | to_entries[] | select(.key | startswith($r + "/")) | "\(.key)\t\(.value)"' "$CONFIG"
```

결과: `messaging/OADM-3597	develop` 형태의 tab-separated 라인들.

### 4단계: 조인 및 분류

각 worktree에 대해:

1. branch 이름이 `feature/epic/{PREFIX}-{NUM}` 패턴이면 type=`epic`, 티켓=`{PREFIX}-{NUM}`
2. branch 이름이 `feature/{ANY}/{PREFIX}-{NUM}` 패턴이면 type=`feature`, 티켓=`{PREFIX}-{NUM}` (여기서 `{ANY}`는 `epic` 제외)
3. config `worktrees` 맵에서 `{REPO_NAME}/{PREFIX}-{NUM}` 키 조회
   - 있으면 그 base로 그룹핑
   - 없으면 `[unknown]` 그룹으로 분류
4. 위 패턴 중 어느 것도 매칭 안 되면 `[unknown]` 그룹, branch 전체 이름 + 경로 표기

stale 항목 (config엔 있지만 worktree 실제로 없음)은 무시 (출력 안 함, 자동 정리 없음).

### 5단계: 출력

형식:

```
[develop]
  feature: OADM-3597, OADM-3598
  epic   : OADM-3600
[main]
  feature: OADM-3601
[unknown]
  feature/other-branch (~/.git-worktrees/messaging/other-branch)
```

- 그룹 순서: config에 등장하는 base 이름 알파벳순 → 마지막에 `[unknown]`
- 티켓은 숫자 오름차순
- 빈 그룹은 출력하지 않음

## remove 서브커맨드

### 1단계: 사전 조건 확인

현재 디렉토리가 git repo인지 확인한다:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "현재 디렉토리는 git repo가 아닙니다"; exit 1; }
REPO_NAME=$(basename "$REPO_ROOT")
```

메인 worktree (`$REPO_ROOT`)는 절대 삭제 대상에 포함하지 않는다.

### 2단계: 대상 결정

인자 토큰을 분석한다:

- `prune` 단독 — `git worktree prune -v` 실행 후 종료. (디렉토리가 사라진 prunable worktree만 정리)
- `all` — 메인을 제외한 모든 worktree 대상. AskUserQuestion으로 최종 확인 (`Yes` / `Cancel`) 후 진행.
- 숫자 토큰 (예: `3597 3598`) — 각 숫자에 대해 `{REPO_NAME}/{PREFIX}-{N}` 키와 매칭되는 worktree를 대상으로 한다. config의 nickName / ticketPrefix가 비어 있으면 에러 후 종료.
- 인자가 없으면 `git worktree list --porcelain`로 메인을 제외한 worktree를 수집해 AskUserQuestion(multiSelect=true)로 선택받는다. 아무것도 선택하지 않으면 "취소됨" 출력 후 종료.

대상 worktree가 0개면 "삭제할 worktree가 없습니다" 출력 후 종료.

### 3단계: 변경사항 확인

각 대상 worktree에 대해 다음을 확인한다:

```bash
git -C "$WT_PATH" status --porcelain
git -C "$WT_PATH" log "@{u}..HEAD" --oneline 2>/dev/null  # upstream 미설정 시 무시
```

uncommitted 변경 또는 unpushed 커밋이 있는 worktree는 목록과 함께 AskUserQuestion으로 강제 삭제 여부(`Force` / `Skip`)를 묻는다. `Skip` 선택 시 해당 worktree는 결과의 "Skipped" 섹션으로 분류한다.

### 4단계: 브랜치 삭제 여부 선택

AskUserQuestion으로 worktree 제거 후 브랜치도 삭제할지 확인한다:

- `Yes` — `git branch -D <branch>`로 강제 삭제 (병합 여부 무관).
- `No` — 브랜치는 보존, worktree만 제거.

인자에 `--keep-branch` 또는 `--delete-branch` 토큰이 있으면 질문 생략하고 그 값 사용.

### 5단계: 실행

각 대상에 대해 순차 실행:

```bash
# 1차 시도: 일반 제거 (3단계에서 force 승인된 항목은 --force)
OUT=$(git worktree remove "$WT_PATH" 2>&1) || \
  OUT=$(git worktree remove --force "$WT_PATH" 2>&1)
RC=$?

# 폴백: 서브모듈 포함 worktree는 submodule deinit 후 재시도
if [ $RC -ne 0 ] && echo "$OUT" | grep -q "working trees containing submodules"; then
  git -C "$WT_PATH" submodule deinit --all -f
  git worktree remove --force "$WT_PATH"
  RC=$?
fi

# 성공 시에만 후속 처리
if [ $RC -eq 0 ]; then
  # 4단계에서 브랜치 삭제 선택 시
  git branch -D "$BRANCH_NAME"
  # config worktrees 맵에서 키 제거
  tmp=$(mktemp)
  jq --arg k "$REPO_NAME/$TICKET" 'del(.worktrees[$k])' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
fi
```

**중요:** worktree 제거가 실패하면 브랜치 삭제 및 config 키 제거를 모두 건너뛴다. 성공한 항목에 한해서만 후속 처리한다.

티켓 키를 식별할 수 없는 worktree (브랜치가 `feature/{ANY}/{PREFIX}-{NUM}` 또는 `feature/epic/{PREFIX}-{NUM}` 패턴이 아닌 경우) 는 worktree만 제거하고 config 업데이트는 건너뛴다.

### 6단계: 결과 출력

```
| Ticket | Branch | Path | Branch deleted | Status |
|---|---|---|---|---|
| OADM-3597 | feature/skull/OADM-3597 | ~/.git-worktrees/messaging/OADM-3597 | yes | removed |
| -        | feature/other          | ~/.git-worktrees/messaging/other     | no  | removed |
```

skip된 항목은 테이블 아래 "Skipped:" 섹션에 사유와 함께 표기.

### 주의

- 메인 worktree (`git rev-parse --show-toplevel`) 는 절대 삭제하지 않는다.
- `git worktree remove`가 실패하면 해당 항목만 skip하고 다른 항목은 계속 처리한다.
- config의 `worktrees` 맵은 worktree 제거에 성공한 키만 삭제한다.

## reset 서브커맨드

### 1단계: 초기화 항목 선택

AskUserQuestion (multiSelect=true) 로 아래 항목을 제시:

- `nickName` — nick-name 초기화
- `ticketPrefix` — JIRA 티켓 prefix 초기화
- `worktrees` — worktree 맵 초기화 (실제 worktree는 삭제하지 않음)

최소 1개 이상 선택해야 진행. 아무것도 선택하지 않으면 "취소됨" 메시지 후 종료.

### 2단계: 선택된 키 삭제

선택된 항목에 대해 개별적으로 config를 업데이트한다:

```bash
CONFIG=~/.claude/worktree-config.json
tmp=$(mktemp)
# nickName 선택 시
jq '.nickName = ""' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
# ticketPrefix 선택 시
tmp=$(mktemp); jq '.ticketPrefix = ""' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
# worktrees 선택 시
tmp=$(mktemp); jq '.worktrees = {}' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"
```

### 3단계: 결과 보고

초기화된 항목과 남아있는 값을 보고한다. 예:

```
초기화됨: nickName, worktrees
남아있는 값: ticketPrefix=OADM
```

### 주의

- reset은 git repo가 아닌 디렉토리에서도 실행 가능.
- 실제 worktree 디렉토리와 브랜치는 **삭제하지 않는다**. 삭제는 `remove` 서브커맨드를 사용한다.

## 에러 처리 요약

| 상황 | 대응 |
|---|---|
| config 파일 JSON 손상 | 에러 후 종료. 자동 덮어쓰기 금지 |
| 현재 디렉토리가 git repo 아님 | create/list/remove는 에러 후 종료, reset은 허용 |
| remove에서 worktree 제거 실패 | 해당 항목만 skip, 나머지는 계속. 후속 처리(브랜치 삭제, config 키 제거)도 건너뛴다 |
| remove 시 서브모듈 에러 (`working trees containing submodules`) | `git submodule deinit --all -f` 후 `--force` 재시도 |
| base branch 후보 0개 | 에러 후 종료 |
| branch/worktree 이미 존재 | 해당 티켓만 skip, 나머지는 계속 |
| 서브모듈 초기화 실패 | 경고만 출력, worktree는 그대로 유지 |
| AskUserQuestion에서 사용자 취소 | 전체 작업 취소, 이미 쓴 설정은 유지 |
