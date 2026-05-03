# Phase 1: Discover Protocol

목표: `TARGET_PATH`의 언어/빌드툴/프레임워크/MSA 시그널을 결정론적으로 감지하여 `discover-stack.json` 산출.

## 절차

1. **캐시 확인**
   - `~/.claude/cache/sub-codebase-explorer-{path-hash}-discover.json` 존재 + `build_hash` 일치 시 → 그대로 반환
   - 변경 감지 시 → 재실행

2. **스크립트 실행**
   ```bash
   ./scripts/discover-stack.sh "$TARGET_PATH" > /tmp/discover.json
   ```

3. **결과 해석**
   - `msa_recommended: true` → Phase 2에서 MSA 매핑 자동 활성화
   - `languages` 배열에 따라 Phase 3 데드코드/도메인 추출 시 사용할 grep glob 결정
   - `build_systems` 비어있음 → "이 프로젝트는 빌드 파일이 없는 스크립트/문서 위주 레포일 수 있다"고 사용자에게 알림

4. **출력 보고**
   ```
   📦 스택: {languages} / {build_systems}
   🏗  서비스: {service_dirs.length}개 ({service_dirs joined})
   📡 MSA 시그널: {msa_signals} → MSA 매핑 {활성/비활성}
   🧪 테스트: {test_frameworks}
   ```

## 트러블슈팅

- `python3` 없음 → Phase 2 순환 탐지 단순 모드(back-edge만)
- `jq` 없음 → 출력 JSON 검증 우회
- `ast-grep` 없음 → grep 폴백 (정밀도 ↓, 재현성 유지)
