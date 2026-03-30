# 부하 테스트 가이드

---

## k6

### 기본 스크립트
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 10 },   // ramp-up
    { duration: '3m', target: 10 },   // steady
    { duration: '1m', target: 0 },    // ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(99)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('http://localhost:8080/api/v1/orders');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

## 테스트 유형

| 유형 | 목적 | 부하 패턴 |
|------|------|----------|
| Smoke | 기본 동작 확인 | 1-2 VU, 1분 |
| Load | 정상 부하 검증 | 예상 동시 사용자, 5-10분 |
| Stress | 한계 탐색 | 점진 증가 → 포화 |
| Spike | 급증 대응 | 순간 10x 부하 |
| Soak | 장시간 안정성 | 정상 부하, 1-4시간 |
