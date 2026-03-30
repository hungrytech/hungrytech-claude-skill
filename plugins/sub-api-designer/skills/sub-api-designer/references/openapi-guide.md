# OpenAPI 3.1 가이드

> OpenAPI 3.1 스펙 작성을 위한 레퍼런스.

---

## 기본 구조

```yaml
openapi: 3.1.0
info:
  title: API Title
  version: 1.0.0
  description: API 설명
servers:
  - url: https://api.example.com/v1
paths:
  /resources:
    get:
      summary: 리소스 목록 조회
      operationId: listResources
      parameters: [...]
      responses:
        '200':
          description: 성공
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ResourceList'
components:
  schemas: {}
  securitySchemes: {}
```

## 데이터 타입

| JSON Schema | OpenAPI | 설명 |
|-------------|---------|------|
| string | string | 문자열 |
| integer | integer | 정수 (format: int32, int64) |
| number | number | 실수 (format: float, double) |
| boolean | boolean | 불리언 |
| array | array | 배열 (items 필수) |
| object | object | 객체 (properties) |

## $ref 참조

```yaml
$ref: '#/components/schemas/Order'
$ref: './common/error.yaml#/ErrorResponse'
```

## 보안 스키마

```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    apiKeyAuth:
      type: apiKey
      in: header
      name: X-API-Key
```

## Discriminator (다형성)

```yaml
components:
  schemas:
    Payment:
      oneOf:
        - $ref: '#/components/schemas/CardPayment'
        - $ref: '#/components/schemas/BankTransfer'
      discriminator:
        propertyName: payment_type
```
