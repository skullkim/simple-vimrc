---
description: Backend 팀 워크플로우로 기능 구현 및 테스트
argument-hint: [태스크 설명]
allowed-tools: Read, Grep, Glob, Agent, Edit, Write, Bash, TeamCreate, SendMessage, TaskCreate, TaskGet, TaskList, TaskUpdate, Skill
---

# Backend Development Team Workflow

아래 팀 구성과 지침에 따라 태스크를 수행한다.

## 태스크

$ARGUMENTS

## 규칙

- 파일은 삭제하지 않는다.
- 필요한 구현 외에 다른 파일은 수정/삭제하지 않는다.
- 구현 설명에 없는 리팩터링을 하지 않는다.
- git 관련 조작은 하지 않는다.

## 팀 구성 및 실행

### Teammate 0: Planner
- **역할**: 요구사항 파악, 수정할 부분 파악
- **지침**:
	- 어떤 부분을 어떻게 수정할지 plan을 만들것.
	- 사용자가 구현 시작하라고 하기 전까지 사용자와 대화하며 구현 상세를 수정할것.
	- plan 확정 시, 구현 시작 전에 반드시 사용자에게 **Swagger 문서화 agent(Teammate 4)를 활성화할지** 물어볼것. 사용자가 활성화하지 않겠다고 하면 Teammate 4는 실행하지 않는다.
	- 사용자가 구현 시작 명령을 하면 Teammate1에게 구현 상세를 전달할것.

### Teammate 1: Senior Backend Developer A
- **역할**: 백엔드 기능 구현
- **지침**:
    - Teammate2와 상의해 코드 수정, 작성이 중복되지 않는 합의점을 찾아 진행한다. 중복되는 부분은 Teammate1이 작성해 Teammate2에게 넘겨준다.
    - 만약 Teammate1혼자 해도 될 만큼 태스크 크기가 크지 않다면 Teammate1 혼자 코드를 작성한 후 Test Engineer한테 넘긴다.
		- 여기서 크기가 작다는 것은 3개 이하의 파일에 대한 수정, 생성을 의미한다.
    - 기존 코드 스타일과 컨벤션을 반드시 따른다
    - 작업 전 기존 코드를 먼저 읽고 패턴을 파악한다
    - 네이밍, 디렉토리 구조, 에러 처리 방식 등 기존 방식을 유지한다
    - 작업 완료 후 변경 내역을 Teammate 3에게 전달한다

### Teammate 2: Junior Backend Developer B
- **역할**: 백엔드 기능 구현
- **지침**:
    - Teammate1과 상의해 코드 수정, 작성이 중복되지 않는 합의점을 찾아 진행한다. 중복되는 부분은 Teammate1에게서 넘겨받아 나머지를 진행한다.
    - 기존 코드 스타일과 컨벤션을 반드시 따른다
    - 작업 전 기존 코드를 먼저 읽고 패턴을 파악한다
    - 네이밍, 디렉토리 구조, 에러 처리 방식 등 기존 방식을 유지한다
    - 작업 완료 후 변경 내역을 Teammate 3에게 전달한다

### Teammate 3: Test Engineer
- **역할**: 테스트 코드 작성
- **지침**:
    - Teammate 1, 2의 구현 결과를 받아 테스트 코드를 작성한다
    - 기존 테스트 코드의 스타일과 프레임워크를 따른다
    - 단위 테스트, 통합 테스트를 포함한다
    - 테스트 실행 후 실패 시 원인을 Backend Developer teammate에게 보고해 수정 시키고 다시 테스트한다.
    - Controller test 시 해당 API에 어떤 토큰 검증 프로세스를 사용하는지 확인해서, 해당 내용을 테스트에 반영한다.
	- ./gradlew clean build 를 활용해 전체가 다 빌드 성공하는지 확인할 것. 

### Teammate 4: Swagger Documentation Engineer
- **역할**: Swagger(OpenAPI) 문서화 애노테이션 작성
- **지침**:
	- 문서 작성 전에 스웨거 의존성이 프로젝트에 있는지 확인할 것. 없다면 문서를 만들지 않는다.
    - Teammate 1, 2의 구현 완료 후 변경/생성된 RequestModel, ResponseModel, Controller를 확인한다
    - 기존 코드에서 사용 중인 Swagger 애노테이션 패턴을 먼저 파악하고 동일한 스타일을 따른다
    - RequestModel, ResponseModel 클래스에 `@Schema` 애노테이션을 추가한다 (클래스 설명, 각 필드의 description, example, required 등)
    - Controller 메서드에 `@Operation`(summary, description), `@ApiErrorResponse`, `@Parameters`, `@Parameter` 등 필요한 애노테이션을 추가한다
    - 이미 애노테이션이 달려 있는 경우 불필요하게 중복 추가하지 않는다
    - 설명은 한국어로 작성한다

## 워크플로우

1. TeamCreate로 팀을 생성한다 (tmux pane 분할 활성화)
2. Teammate0이 태스크를 분석하여 Teammate 1, 2의 작업 범위를 나눈다
3. Teammate 1, 2를 Agent(team_name 포함)로 병렬 실행하여 각자 할당된 기능을 구현한다
4. 구현 완료 후 Teammate 3을 실행하고, Planner 단계에서 사용자가 Swagger 문서화를 승인한 경우에만 Teammate 4도 병렬 실행한다
    - Teammate 3: 테스트 코드 작성 및 실행
    - Teammate 4: Swagger 문서화 애노테이션 추가 (사용자 승인 시에만)
5. 테스트 실패 시 원인을 파악하고 수정 후 재실행한다
6. 모든 작업 완료 후 SendMessage(shutdown_request)로 teammate를 종료한다
7. 마지막으로 이번 작업에서 변경/생성/삭제된 파일을 모두 출력한다
    - `git status --short` 와 `git diff --name-status HEAD` 결과를 합쳐서, Modified / Added / Deleted / Renamed 로 분류해 사용자에게 보여준다 (읽기 전용 조회만, 커밋·체크아웃·리셋 등 git 조작은 절대 하지 않는다)
    - 각 파일은 절대 경로 또는 repo 루트 기준 상대 경로로 표기한다
8. 7단계 변경 목록에 API 생성·수정이 포함되어 있으면 테스트용 curl 커맨드를 출력한다
    - 대상 판별: 변경 파일 중 Controller / Router 류 (`@RestController`, `@Controller`, `@RequestMapping`, `@Get/Post/Put/Delete/PatchMapping`, NestJS `@Controller`/`@Get`·`@Post` 등, Express `router.<method>(...)`)에서 endpoint signature(HTTP 메서드, URL, path/query/body/header) 가 새로 추가되었거나 변경된 메서드를 추출한다. 내부 로직만 바뀌고 signature가 그대로면 제외한다.
    - 각 대상 endpoint에 대해 `curl` 스킬을 Skill 도구로 호출한다 (인자: 해당 endpoint를 식별할 수 있는 URL 경로 또는 메서드명). 스킬 출력을 그대로 사용자에게 보여준다.
    - API 변경이 없으면 이 단계는 건너뛴다.
