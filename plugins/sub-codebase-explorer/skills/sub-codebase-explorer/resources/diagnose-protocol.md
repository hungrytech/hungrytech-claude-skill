# Phase 3: Diagnose Protocol

목표: Git hotspot + 데드코드 + 도메인 모델 추출.

## 절차

### 3-1. Hotspot
```bash
./scripts/analyze-git-hotspot.sh "$TARGET" "6 months ago" > /tmp/hotspots.json
```

상위 10개 hotspot의 의미 해석:
- `score = commits × lines` (변경 빈도 × 파일 크기)
- 높은 score = 핵심 파일 OR 기술 부채 hotspot
- `sub-code-reviewer`로 후속 위임 권장 알림

### 3-2. 데드코드
```bash
./scripts/detect-deadcode.sh "$TARGET" > /tmp/deadcode.json
```

휴리스틱 한계 명시: "정의 ↔ 참조 grep 매칭 기반, 동적 호출(reflection, eval, dynamic dispatch)은 false positive 가능".
사용자에게 후보 목록 제공 + 삭제 전 수동 검증 권장.

### 3-3. 도메인 모델
```bash
./scripts/extract-domain-model.sh "$TARGET" > /tmp/domain.json
```

ORM 매칭:
- JVM: `@Entity` (JPA)
- Python: SQLAlchemy `declarative_base()` 자식 / Pydantic `BaseModel`
- TypeScript: TypeORM `@Entity()` / Prisma `model X { ... }`

## 출력 보고

```
🔥 Hotspot 상위 10개 (commits × lines)
💀 데드코드 후보: {N}개 (정확도 ~70%)
🧬 도메인 엔티티: {M}개 ({언어별 분포})
```
