# API 분석 프로토콜

> Phase 1: 기존 API 현황을 분석하고 요구사항을 파악한다.

---

## 실행 절차

### Step 1: 기존 API 스펙 탐색

```bash
# OpenAPI/Swagger 파일 탐색
find . -maxdepth 3 -name "openapi*.yaml" -o -name "openapi*.yml" -o -name "swagger*"
```

### Step 2: API 프레임워크 감지

```bash
scripts/detect-api-framework.sh [project-root]
```

### Step 3: 기존 엔드포인트 인벤토리

스펙 파일 또는 소스 코드에서 기존 엔드포인트 수집:
- `@RequestMapping`, `@GetMapping`, `@PostMapping` 등 어노테이션 스캔
- Express router, FastAPI decorator 스캔
- 결과: 엔드포인트 목록 (method, path, handler)

### Step 4: 요구사항 파싱

사용자 요청에서 추출:
- 리소스 (주문, 사용자, 상품 등)
- 동작 (CRUD, 검색, 집계 등)
- 제약조건 (인증, 페이지네이션, 필터링 등)

## 출력

- 기존 API 인벤토리
- 새로 설계할 엔드포인트 목록
- 사용할 REST 패턴 결정
