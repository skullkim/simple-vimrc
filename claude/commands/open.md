사용자가 설명한 기능과 관련된 파일을 찾아 IntelliJ에서 열어주는 스킬이다.

## 입력
$ARGUMENTS 에 기능 설명이 들어온다. (예: "로그인", "결제 API", "사용자 프로필")

## 수행 절차

### 1단계: 관련 파일 탐색 (좁은 범위 → 넓은 범위)

검색은 **정확한 매칭부터 시작하여 점진적으로 넓혀가는** 전략을 사용한다.

**Step A: 복합 키워드로 정확 검색 (우선)**
- $ARGUMENTS 전체를 하나의 개념으로 간주하여 검색한다.
- 변환 패턴: CamelCase (`BusinessScope`), snake_case (`business_scope`), kebab-case (`business-scope`), 붙여쓰기 (`businessscope`) 등으로 변환하여 파일명 및 파일 내용을 검색한다.
- 한국어 복합 키워드도 시도한다 (예: "business scope" → "사업범위", "사업 범위").

**Step B: 결과 평가**
- Step A에서 결과가 있으면 → 해당 결과를 2단계로 넘긴다.
- Step A에서 결과가 없거나 2개 미만이면 → Step C로 진행한다.

**Step C: 키워드 분리 검색 (확장)**
- $ARGUMENTS 를 공백 기준으로 개별 키워드로 분리한다.
- 각 키워드를 개별 검색한 뒤, **모든 키워드가 포함된 파일(교집합)을 우선** 제시하고, 일부만 포함된 파일은 별도 섹션으로 분리한다.
- 테스트 파일, 설정 파일, 마이그레이션 파일 등도 포함한다.
- Glob, Grep, Read 등 도구를 활용하여 클래스명, 패키지명, 라우트, 설정 등을 검색한다.

### 2단계: 파일 목록 제시
- 찾은 파일들을 번호와 함께 나열한다.
- 각 파일마다 한 줄 설명을 붙인다.
- 카테고리별로 그룹핑한다 (예: Controller, Service, Repository, Test, Config 등).

출력 형식 예시:
```
## 관련 파일 목록

### Controller
  1. src/main/java/.../LoginController.java — 로그인 요청 처리 컨트롤러
  2. src/main/java/.../AuthController.java — 인증 관련 엔드포인트

### Service
  3. src/main/java/.../AuthService.java — 인증 비즈니스 로직
  4. src/main/java/.../TokenService.java — JWT 토큰 발급/검증

### Test
  5. src/test/java/.../LoginControllerTest.java — 로그인 컨트롤러 테스트

열고 싶은 파일 번호를 입력하세요 (예: 1,3,5 또는 all):
```

### 3단계: 사용자 선택 대기
- AskUserQuestion 도구를 사용하여 사용자에게 어떤 파일을 열지 물어본다.
- 사용자가 번호를 입력하면 (쉼표 구분 또는 "all") 해당 파일들을 선택한다.

### 4단계: IntelliJ에서 파일 열기
- 선택된 파일들을 `idea` 명령어로 연다.
- 명령어: `idea <파일경로>` (파일마다 개별 실행)
- 모든 파일이 열렸으면 완료 메시지를 출력한다.
