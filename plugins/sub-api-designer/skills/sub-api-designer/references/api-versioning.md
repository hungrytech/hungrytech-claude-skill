# API 버전 관리

> API 버전 관리 전략과 Breaking Change 관리.

---

## 버전 관리 전략

### URL 버전 (권장)
```
/api/v1/orders
/api/v2/orders
```
- 장점: 명확, 라우팅 용이, 캐싱 용이
- 단점: URL 변경

### 헤더 버전
```
Accept: application/vnd.example.v2+json
```

### 쿼리 파라미터
```
/api/orders?version=2
```

## Deprecation 전략

1. **Sunset 헤더**: `Sunset: Sat, 31 Dec 2025 23:59:59 GMT`
2. **Deprecation 헤더**: `Deprecation: true`
3. **응답에 경고**: `Warning: 299 - "This endpoint is deprecated"`
4. **문서 업데이트**: deprecated 표시 + 대체 엔드포인트 안내
5. **모니터링**: deprecated 엔드포인트 트래픽 추적
6. **제거**: 트래픽이 0에 가까워지면 제거

## Breaking vs Non-Breaking Changes

### Breaking Changes (주의)
- 엔드포인트 제거
- 필수 파라미터 추가
- 응답 필드 제거/타입 변경
- HTTP status code 변경
- 인증 방식 변경

### Non-Breaking Changes (안전)
- 새 엔드포인트 추가
- 선택 파라미터 추가
- 응답 필드 추가
- 새 HTTP status code 추가
