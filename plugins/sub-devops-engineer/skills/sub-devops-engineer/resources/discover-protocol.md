# 인프라 탐색 프로토콜

> Phase 1: 프로젝트의 기존 인프라 파일과 기술 스택을 탐색한다.

---

## 실행 절차

### Step 1: 기존 인프라 파일 탐색

```bash
scripts/detect-infra.sh [project-root]
```

### Step 2: 프로젝트 스택 감지

빌드 파일 분석으로 언어, 프레임워크, 런타임 결정:
- Gradle/Maven → JVM (Java/Kotlin)
- package.json → Node.js (TypeScript/JavaScript)
- go.mod → Go
- requirements.txt → Python

### Step 3: 기존 설정 분석

발견된 인프라 파일의 현재 상태 평가:
- Dockerfile 있으면 → 베스트 프랙티스 준수 여부
- CI 파이프라인 있으면 → 커버리지, 단계 구성
- K8s 매니페스트 있으면 → 보안, 리소스 설정

## 출력

- 기존 인프라 인벤토리
- 프로젝트 기술 스택
- 추가/개선 필요 영역 목록
