# 프론트엔드 프로젝트 탐색 프로토콜

> Phase 1: 프로젝트의 프론트엔드 스택과 기존 구조를 탐색한다.

---

## 실행 절차

### Step 1: 프론트엔드 스택 감지

```bash
scripts/detect-frontend-stack.sh [project-root]
```

package.json과 설정 파일을 분석하여 React, Vite, TypeScript, Tailwind, 상태 관리 라이브러리를 감지한다.

### Step 2: 기존 컴포넌트 구조 파악

디렉토리 구조 분석:

| 확인 항목 | 탐색 경로 |
|----------|----------|
| 컴포넌트 | `src/components/**/*.tsx` |
| 페이지 | `src/pages/**/*.tsx`, `src/routes/**/*.tsx`, `src/app/**/*.tsx` |
| 훅 | `src/hooks/**/*.ts` |
| 스토어 | `src/store/**/*.ts`, `src/stores/**/*.ts` |
| API 클라이언트 | `src/api/**/*.ts`, `src/services/**/*.ts` |
| 유틸리티 | `src/utils/**/*.ts`, `src/lib/**/*.ts` |
| 타입 | `src/types/**/*.ts` |

### Step 3: 설정 파일 분석

| 파일 | 확인 내용 |
|------|----------|
| `vite.config.ts` | 플러그인, alias, 프록시 설정 |
| `tsconfig.json` | paths, strict 모드, target |
| `tailwind.config.ts` | 테마 커스텀, 플러그인 |
| `postcss.config.js` | PostCSS 플러그인 체인 |
| `.eslintrc.*` | 린트 규칙 |
| `.prettierrc` | 포맷팅 규칙 |

### Step 4: 라우팅 구조 파악

- React Router DOM: `src/routes/` 또는 `src/App.tsx` 내 Route 정의
- TanStack Router: `src/routes/` 파일 기반 라우팅
- Next.js 스타일: `src/app/` 또는 `src/pages/` 파일 기반

## 출력

- **프론트엔드 스택**: React 버전, Vite 버전, TypeScript 설정
- **기존 컴포넌트 인벤토리**: 컴포넌트/페이지/훅 목록
- **상태 관리 현황**: 사용 중인 상태 관리 라이브러리와 패턴
- **빌드 설정 현황**: Vite 플러그인, alias, 프록시 설정
