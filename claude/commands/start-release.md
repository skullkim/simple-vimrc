---
description: 배포용 release 브랜치 생성 및 푸시 (release/{module-name}/YYMMDD-HHMM)
allowed-tools: Bash, AskUserQuestion
---

사용자가 지정한 base branch를 기준으로 `release/{module-name}/{YYMMDD-HHMM}` 형식의 release 브랜치를 만들고 원격에 push 한다.

## 작업 절차

### 1단계: 작업 트리 상태 확인

```bash
git status
```

untracked/modified 파일이 있으면 사용자에게 알리고, 그대로 진행할지 확인한다. (release 브랜치는 base branch에서 새로 체크아웃하므로, 커밋되지 않은 변경 사항은 새 브랜치로 따라간다.)

### 2단계: base branch 입력 받기

`AskUserQuestion` 으로 base branch를 묻는다.

- 질문: "release 브랜치의 base branch는?"
- 옵션 예시: `develop`, `main`, `직접 입력`
- 기본값을 강제하지 말고, 반드시 사용자가 명시적으로 선택/입력한 값을 사용한다.

### 3단계: module-name 입력 받기

`AskUserQuestion` 으로 module-name 을 묻는다.

- 질문: "release 브랜치의 module-name은?"
- 기본값을 강제하지 말고, 반드시 사용자가 명시적으로 입력/선택한 값을 사용한다.
- 입력값은 브랜치 이름에 그대로 들어가므로 공백/슬래시 등 부적절한 문자가 포함된 경우 사용자에게 다시 확인한다.

### 4단계: base branch 최신화

```bash
git fetch origin <BASE_BRANCH>
git checkout <BASE_BRANCH>
git pull origin <BASE_BRANCH>
```

base branch가 로컬에 없으면 `git checkout -b <BASE_BRANCH> origin/<BASE_BRANCH>` 로 받아온다.

### 5단계: release 브랜치 이름 생성

현재 시각과 입력받은 module-name 으로 브랜치 이름을 만든다.

```bash
RELEASE_BRANCH="release/<MODULE_NAME>/$(date +'%y%m%d-%H%M')"
echo "$RELEASE_BRANCH"
```

생성될 브랜치명을 사용자에게 보여주고 확인을 받는다.

### 6단계: release 브랜치 생성

확인 후에만 실행한다.

```bash
git checkout -b "$RELEASE_BRANCH"
```

### 7단계: 원격에 push

```bash
git push -u origin "$RELEASE_BRANCH"
```

push 결과(원격 브랜치 URL 등)를 사용자에게 보여준다. 실패 시 에러 내용과 함께 해결 방법을 안내한다.

## 주의사항

- base branch는 절대 임의로 추정하지 않는다. 반드시 사용자에게 묻는다.
- 브랜치 이름의 시각은 `date` 명령으로 생성하며, 한 번 생성한 후 단계 사이에 다시 호출해 시각이 바뀌지 않도록 변수에 저장해 재사용한다.
- force push (`--force`, `-f`)는 절대 사용하지 않는다.
- 이미 같은 이름의 브랜치가 원격에 존재하면 (1분 단위 충돌) 사용자에게 알리고 1분 뒤 재시도하거나 다른 이름을 받는다.
