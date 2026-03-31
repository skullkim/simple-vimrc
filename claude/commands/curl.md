---
description: API curl 테스트 커맨드 생성
argument-hint: [API-endpoint-or-method]
allowed-tools: Read, Grep, Glob, Agent
---

사용자가 입력한 API 정보를 기반으로, 프로젝트 소스코드에서 해당 API를 찾아 테스트용 curl 커맨드를 생성한다.

## 입력

$ARGUMENTS

## 작업 절차

### 1단계: API 엔드포인트 탐색

- 입력값이 URL 경로(예: `/api/v1/stores`)이면, 프로젝트에서 해당 경로를 매핑하는 Controller/Router를 찾는다.
- 입력값이 메서드명(예: `selectStore`)이면, 해당 메서드가 정의된 Controller를 찾는다.
- 입력값이 curl 커맨드이면, URL과 HTTP 메서드를 파싱하여 해당 Controller를 찾는다.

검색 전략:
1. `@RequestMapping`, `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PatchMapping` 등의 어노테이션 검색
2. Express/NestJS의 경우 `@Get`, `@Post`, `@Put`, `@Delete`, `router.get`, `router.post` 등 검색
3. 매칭되는 Controller 파일을 찾으면 전체 파일을 읽어 클래스 레벨 `@RequestMapping`도 확인

### 2단계: API 로직 분석

Controller 메서드를 분석하여 다음을 파악한다:

- **HTTP 메서드**: GET, POST, PUT, DELETE, PATCH
- **전체 URL 경로**: 클래스 레벨 + 메서드 레벨 경로 결합
- **Path Variable**: `@PathVariable`, `:id` 등
- **Query Parameter**: `@RequestParam`, `@QueryParam` 등
- **Request Body**: `@RequestBody`가 붙은 DTO 클래스 → 해당 DTO 파일을 읽어 필드 확인
- **Request Header**: `@RequestHeader`, 커스텀 헤더 (예: `Member-Authorization`)
- **인증 방식**: Spring Security, JWT, 커스텀 필터 등

DTO/Entity 클래스를 찾아 읽고, 각 필드의 타입과 제약조건(`@NotNull`, `@NotBlank`, `@Valid` 등)을 확인한다.

### 3단계: 사전 호출 API 식별

해당 API 실행에 필요한 사전 조건을 분석한다:

- **인증이 필요한 경우**: 로그인/토큰 발급 API를 찾는다
  - Security Config에서 인증 제외 경로 확인
  - 인증 필터에서 토큰 헤더명 확인 (예: `Authorization`, `Member-Authorization`)
  - 로그인 API의 Controller, Request DTO를 분석
- **Path Variable에 다른 리소스 ID가 필요한 경우**: 해당 리소스 생성/조회 API를 찾는다
- **특정 상태가 선행되어야 하는 경우**: 상태 변경 API를 찾는다

### 4단계: curl 커맨드 생성

아래 규칙을 따른다:

- **base URL**: `http://localhost:8080` (프로젝트 설정에서 포트가 다르면 해당 포트 사용)
- **Content-Type**: Request Body가 있으면 `-H "Content-Type: application/json"` 추가
- **Request Body**: DTO 필드를 기반으로 현실적인 샘플 데이터 생성
- **Path Variable**: 의미 있는 샘플 값 사용 (UUID면 UUID 형식, 숫자면 숫자)
- **Query Parameter**: 필수 파라미터는 반드시 포함, 선택 파라미터는 주석으로 안내
- **인증 헤더**: 토큰이 필요하면 `<TOKEN>` 플레이스홀더 사용하고, 사전 호출 API의 응답에서 추출하라고 안내

## 출력 형식

- **curl 커맨드는 반드시 한 줄로 작성한다. 백슬래시(`\`) 개행을 사용하지 않는다.**

```
## API 테스트 curl

### 호출 순서

> 사전 조건이 있으면 순서대로 나열, 없으면 이 섹션 생략

#### 1. [사전 API 설명] (필요한 경우)
\`\`\`bash
curl -X POST http://localhost:8080/... -H "Content-Type: application/json" -d '{...}'
\`\`\`
> 응답에서 `token` 값을 아래 요청의 헤더에 사용

#### 2. [대상 API 설명]
\`\`\`bash
curl -X PUT http://localhost:8080/... -H "Content-Type: application/json" -H "Authorization: Bearer <TOKEN>" -d '{...}'
\`\`\`

### 참고
- 각 필드 설명 (필요시)
- 선택적 파라미터 안내
```

## 주의사항

- 실제 프로젝트 코드를 분석하여 정확한 경로, 필드명, 타입을 사용한다
- 추측하지 말고, 코드에서 확인된 정보만 사용한다
- DTO에 validation 어노테이션이 있으면 해당 제약조건을 만족하는 샘플 데이터를 생성한다
- 민감한 정보(비밀번호 등)는 플레이스홀더를 사용한다
