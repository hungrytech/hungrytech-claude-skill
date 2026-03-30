# API 검증 프로토콜

> Phase 3: 설계된 API 스펙을 검증한다.

---

## Breaking Change 감지

### 감지 규칙

| 변경 유형 | Breaking? | 설명 |
|----------|-----------|------|
| 엔드포인트 제거 | Yes | 기존 클라이언트 동작 불가 |
| 필수 파라미터 추가 | Yes | 기존 요청이 유효하지 않음 |
| 응답 필드 제거 | Yes | 클라이언트 파싱 실패 가능 |
| 응답 필드 타입 변경 | Yes | 역직렬화 실패 |
| 선택 파라미터 추가 | No | 기존 요청 그대로 유효 |
| 응답 필드 추가 | No | 기존 클라이언트 무시 가능 |
| 새 엔드포인트 추가 | No | 기존 동작에 영향 없음 |

### 검증 절차

```bash
scripts/validate-openapi.sh openapi.yaml
```

## 스펙 린트 규칙

- 모든 엔드포인트에 description 존재
- 모든 스키마에 example 포함
- 일관된 naming convention (camelCase 또는 snake_case)
- 모든 에러 응답 정의
- 보안 스키마 정의

## 출력

- 검증 결과 (통과/실패)
- Breaking Change 목록
- 린트 경고 목록
