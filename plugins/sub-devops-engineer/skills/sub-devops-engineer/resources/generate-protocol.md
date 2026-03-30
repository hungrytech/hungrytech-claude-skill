# 파일 생성 프로토콜

> Phase 3: 설계에 따라 인프라 파일을 생성한다.

---

## 생성 절차

### Step 1: 템플릿 선택

설계 결정에 맞는 템플릿 선택:
- `templates/dockerfile-multistage.Dockerfile`
- `templates/github-actions-ci.yml`
- `templates/github-actions-cd.yml`
- `templates/k8s-deployment.yaml`
- `templates/terraform-module.tf`

### Step 2: 프로젝트 맞춤 커스터마이징

플레이스홀더를 프로젝트 정보로 교체:
- `{APP_NAME}` → 실제 앱 이름
- `{JVM_VERSION}` → 감지된 JVM 버전
- `{BUILD_COMMAND}` → 빌드 명령어

### Step 3: 보안 강화

모든 생성 파일에 보안 모범 사례 적용:
- non-root USER
- 최소 권한
- 시크릿 외부화
- 버전 핀닝

## 출력

- 생성된 파일 목록
- 각 파일의 보안 적용 사항
