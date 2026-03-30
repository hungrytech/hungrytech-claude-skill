# 배포 전략

> Blue-Green, Canary, Rolling, A/B 전략 비교.

---

## Rolling Update (기본)

점진적으로 이전 Pod를 새 Pod로 교체.

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

- **장점**: 간단, 무중단
- **단점**: 롤백 느림, 두 버전 동시 실행
- **적합**: 일반적인 업데이트

## Blue-Green

두 환경(Blue/Green)을 교대로 사용.

- **장점**: 즉각 롤백 (트래픽 전환만), 동일 버전 보장
- **단점**: 2배 리소스 필요
- **적합**: 다운타임 0 + 빠른 롤백 필요

## Canary

소수 트래픽에 새 버전 배포 후 점진 확대.

- **장점**: 위험 최소화, 실제 트래픽 검증
- **단점**: 구현 복잡 (트래픽 분할 필요)
- **적합**: 대규모 사용자, 위험한 변경

## A/B Testing

사용자 세그먼트별 다른 버전 노출.

- **장점**: 기능 효과 측정
- **단점**: 구현 복잡, 데이터 분석 필요
- **적합**: 기능 실험, UX 테스트
