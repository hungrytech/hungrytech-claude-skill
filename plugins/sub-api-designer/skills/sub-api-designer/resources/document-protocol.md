# API 문서화 프로토콜

> Phase 4: 검증된 API 스펙으로부터 문서와 도구를 생성한다.

---

## 실행 절차

### Step 1: 인간 가독 문서

스펙에서 Markdown 문서 생성:
- 각 엔드포인트별 설명, 파라미터, 예제
- 인증 방법 설명
- 에러 코드 표

### Step 2: 예제 요청/응답

각 엔드포인트에 대해 cURL 예제 생성:
```bash
curl -X POST https://api.example.com/v1/orders \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"product_id": "prod-123", "quantity": 2}'
```

### Step 3: Mock 서버 설정

Prism 또는 WireMock 설정 파일 생성:
```bash
prism mock openapi.yaml --port 4010
```

### Step 4: Contract Test 스텁

sub-test-engineer에 위임하여 Contract Test 생성:
```xml
<sister-skill-invoke skill="sub-test-engineer">
  <caller>sub-api-designer</caller>
  <trigger>contract-test-generation</trigger>
  <targets>openapi.yaml</targets>
</sister-skill-invoke>
```

## 출력

- API 문서 (Markdown)
- Mock 서버 설정
- Contract Test 스텁 (위임)
