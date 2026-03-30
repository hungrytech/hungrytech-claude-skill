# 검증 프로토콜

> Phase 4: 생성된 인프라 파일을 검증한다.

---

## Dockerfile 검증

```bash
scripts/validate-dockerfile.sh Dockerfile
```

## YAML 구문 검증

기본 구문 유효성:
- 들여쓰기 일관성
- 키-값 쌍 유효성

## 보안 체크리스트

- [ ] non-root 사용자
- [ ] 시크릿 하드코딩 없음
- [ ] 최소 권한 원칙
- [ ] 버전 핀닝 (latest 태그 미사용)
- [ ] 리소스 제한 설정
- [ ] 헬스체크 정의

## 출력

- 검증 결과 (통과/경고/실패)
- 개선 제안 목록
