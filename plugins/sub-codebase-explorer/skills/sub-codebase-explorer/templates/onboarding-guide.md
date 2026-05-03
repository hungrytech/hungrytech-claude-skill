# Onboarding Guide — {{PROJECT_NAME}}

> Welcome! 이 문서는 {{PROJECT_NAME}}에 합류한 신규 엔지니어를 위한 자동 생성 가이드입니다.
> 자동 분석 결과 기반이므로 팀 컨벤션과 다를 수 있습니다 — 의심나면 PR로 수정하세요.

## 1주차 체크리스트

### Day 1: Setup

- [ ] 레포 클론 + 의존성 설치
  ```bash
  {{INSTALL_COMMAND}}
  ```
- [ ] 빌드 / 테스트 실행
  ```bash
  {{BUILD_COMMAND}}
  {{TEST_COMMAND}}
  ```
- [ ] [`ARCHITECTURE.md`](./ARCHITECTURE.md) 읽기 (10분)

### Day 2-3: 핵심 파일 읽기 (Hotspot Top 10)

지난 6개월간 가장 많이 변경된 파일들 — 시스템 이해의 출발점:

{{HOTSPOT_TOP10_LIST}}

### Day 4-5: 도메인 모델 이해

핵심 엔티티 ({{DOMAIN_ENTITY_COUNT}}개):

{{DOMAIN_ENTITY_LIST_WITH_FILES}}

## 모듈 진입점 (in-degree 상위)

가장 많은 의존을 받는 모듈 = 시스템 핵심 라이브러리:

{{TOP_INDEGREE_MODULES}}

## MSA 통신 흐름

{{#HAS_MSA}}
신규 기능 추가 시 다음 흐름 참고:

- 서비스 간 통신: [`msa/00-overview.md`](./msa/00-overview.md)
- 호출별 상세: [`msa/api-calls/`](./msa/api-calls/)
- 이벤트 발행/구독: [`msa/events/`](./msa/events/)
{{/HAS_MSA}}
{{^HAS_MSA}}
_(단일 프로세스 — 인-프로세스 호출 그래프는 ARCHITECTURE.md 참고)_
{{/HAS_MSA}}

## 자주 묻는 질문

### Q. 어디서부터 PR을 시작할까?
A. Hotspot Top 10 중 하나에서 작은 개선/리팩토링부터 시작하세요. 도메인 이해와 코드베이스 탐색을 동시에 할 수 있습니다.

### Q. 테스트 어떻게 돌리나?
A. `{{TEST_COMMAND}}` (자동 감지). CI 동일 명령은 `.github/workflows/`나 `Jenkinsfile` 참조.

### Q. 아키텍처 의문이 생겼다면?
A. `/sub-team-lead`로 적절한 전문가에게 라우팅 요청하거나, `/sub-codebase-explorer onboard` 재실행.
