# API 설계 프로토콜

> Phase 2: 요구사항을 기반으로 API 엔드포인트를 설계한다.

---

## 실행 절차

### Step 1: 엔드포인트 설계

각 엔드포인트에 대해:
- HTTP Method (GET/POST/PUT/PATCH/DELETE)
- Path (`/api/v1/{resource}`)
- Path Parameters, Query Parameters
- Request Body Schema
- Response Schema (성공 + 에러)

### Step 2: 스키마 정의

OpenAPI Components/Schemas에 재사용 가능한 스키마 정의:
- 도메인 모델 → JSON Schema
- 공통 패턴: Pagination, Error Response, Audit fields

### Step 3: 페이지네이션 패턴

| 패턴 | 적용 조건 |
|------|----------|
| Cursor 기반 | 대용량 목록, 실시간 데이터 (기본값) |
| Offset 기반 | 관리자 UI, 페이지 번호 필요 시 |

Cursor 응답 구조:
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "abc123",
    "has_next": true,
    "size": 20
  }
}
```

### Step 4: 에러 응답 (RFC 7807)

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 400,
  "detail": "The 'email' field is not a valid email address",
  "instance": "/api/v1/users/123"
}
```

### Step 5: OpenAPI 3.1 스펙 작성

`templates/openapi-skeleton.yaml` 기반으로 스펙 작성:
- info (title, version, description)
- servers
- paths (엔드포인트)
- components/schemas
- security schemes

## 출력

- OpenAPI 3.1 스펙 파일 (YAML)
- 설계 결정 근거 문서
