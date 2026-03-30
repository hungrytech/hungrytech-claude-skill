# REST 설계 패턴

> RESTful API 설계 시 적용할 표준 패턴.

---

## Cursor Pagination

```
GET /api/v1/orders?cursor=abc123&size=20
```

응답:
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "def456",
    "has_next": true,
    "size": 20
  }
}
```

## Offset Pagination

```
GET /api/v1/orders?page=2&size=20
```

응답:
```json
{
  "data": [...],
  "pagination": {
    "page": 2,
    "size": 20,
    "total_elements": 157,
    "total_pages": 8
  }
}
```

## 필터링

```
GET /api/v1/orders?filter[status]=pending&filter[created_after]=2024-01-01
```

## 정렬

```
GET /api/v1/orders?sort=-created_at,total_amount
```
- `-` prefix = DESC, 기본 = ASC

## RFC 7807 Problem Details

```json
{
  "type": "https://api.example.com/errors/not-found",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "Order with id 'ord-123' was not found",
  "instance": "/api/v1/orders/ord-123"
}
```

## Content Negotiation

```
Accept: application/json
Content-Type: application/json
```

## HATEOAS Links (선택적)

```json
{
  "data": {...},
  "_links": {
    "self": {"href": "/api/v1/orders/123"},
    "cancel": {"href": "/api/v1/orders/123/cancel", "method": "POST"}
  }
}
```
