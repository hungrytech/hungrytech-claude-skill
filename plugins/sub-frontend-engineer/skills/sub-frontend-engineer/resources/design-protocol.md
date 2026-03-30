# 컴포넌트/라우팅 설계 프로토콜

> Phase 2: 요구사항을 컴포넌트 트리와 상태 설계로 변환한다.

---

## 실행 절차

### Step 1: 컴포넌트 트리 설계

요구사항 분석 → 컴포넌트 트리 분해:

```
<PageComponent>
  ├── <Header />
  ├── <MainContent>
  │   ├── <FeatureSection />
  │   └── <DataList>
  │       └── <DataItem /> (반복)
  └── <Footer />
```

**분해 원칙**:
- 단일 책임: 하나의 컴포넌트 = 하나의 역할
- 재사용성: 2회 이상 반복되는 UI는 분리
- 컴포지션: children / render props로 유연한 조합

### Step 2: Props / State 인터페이스 정의

각 컴포넌트에 대해:

```typescript
interface ComponentNameProps {
  // 필수 props
  title: string;
  items: Item[];
  // 선택 props
  className?: string;
  onAction?: (id: string) => void;
}
```

**상태 분류**:
| 상태 유형 | 관리 도구 | 예시 |
|----------|----------|------|
| 서버 상태 | TanStack Query | API 응답 데이터, 캐싱 |
| 전역 클라이언트 상태 | Zustand | 인증 토큰, 테마, 사용자 설정 |
| 로컬 UI 상태 | useState | 모달 열림/닫힘, 입력 값 |
| URL 상태 | React Router | 필터, 페이지네이션, 검색어 |
| 폼 상태 | React Hook Form | 폼 필드 값, 검증 상태 |

### Step 3: 라우팅 설계

라우트 구조 정의:

```
/                    → HomePage
/login               → LoginPage
/dashboard           → DashboardPage (보호 라우트)
/dashboard/settings  → SettingsPage (중첩 라우트)
/users/:id           → UserDetailPage (동적 라우트)
```

**라우트 보호 패턴**:
- 인증 필요 라우트 → `ProtectedRoute` 래퍼
- 역할 기반 접근 → 역할 체크 미들웨어

### Step 4: 데이터 흐름 설계

```
API ──→ TanStack Query (캐싱) ──→ Component (표시)
                                      │
Zustand Store ←── User Action ────────┘
```

## 출력

- **컴포넌트 트리**: 계층 구조 + 각 컴포넌트 책임
- **인터페이스 목록**: 각 컴포넌트의 Props / State 타입
- **라우트 맵**: 경로 → 페이지 컴포넌트 매핑
- **상태 관리 전략**: 어떤 상태를 어디서 관리할지 결정
