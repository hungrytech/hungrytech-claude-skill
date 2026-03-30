# 구현 프로토콜

> Phase 3: 설계를 기반으로 컴포넌트, 훅, 스타일을 구현한다.

---

## 실행 절차

### Step 1: 컴포넌트 구현

**파일 구조 컨벤션**:

```
src/components/
├── ui/              # 범용 UI 컴포넌트 (Button, Input, Modal)
├── layout/          # 레이아웃 컴포넌트 (Header, Sidebar, Footer)
└── features/        # 기능별 컴포넌트 (OrderList, UserCard)
    └── order/
        ├── OrderList.tsx
        ├── OrderItem.tsx
        └── index.ts     # barrel export
```

**컴포넌트 작성 규칙**:
- `export function` 선언 사용 (arrow function보다 명시적)
- Props 인터페이스는 컴포넌트 파일 상단에 정의
- `children`을 받는 경우 `PropsWithChildren` 또는 `ReactNode` 사용
- 이벤트 핸들러는 `handle*` 접두사 (`handleClick`, `handleSubmit`)
- 컴포넌트 반환 JSX는 가독성을 위해 소괄호로 감싸기

### Step 2: 커스텀 훅 작성

**훅 작성 규칙**:
- `use*` 접두사 필수
- 관심사 분리: UI 로직 훅 vs 데이터 페칭 훅
- 반환 타입 명시

```typescript
// 데이터 페칭 훅 (TanStack Query 래퍼)
export function useOrders(filters: OrderFilters) {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: () => orderApi.getOrders(filters),
  });
}

// UI 로직 훅
export function useModal(initialOpen = false) {
  const [isOpen, setIsOpen] = useState(initialOpen);
  const open = useCallback(() => setIsOpen(true), []);
  const close = useCallback(() => setIsOpen(false), []);
  return { isOpen, open, close } as const;
}
```

### Step 3: 스타일링 (Tailwind CSS)

**패턴**:
- 유틸리티 클래스 우선, 반복 시 `@apply`로 추출
- 조건부 클래스: `clsx` 또는 `cn` 유틸 사용
- 반응형: `sm:`, `md:`, `lg:` 브레이크포인트 활용
- 다크 모드: `dark:` 접두사 사용

```typescript
import { cn } from '@/lib/utils';

function Button({ variant, className, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'px-4 py-2 rounded-lg font-medium transition-colors',
        variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
        variant === 'secondary' && 'bg-gray-200 text-gray-800 hover:bg-gray-300',
        className
      )}
      {...props}
    />
  );
}
```

### Step 4: API 클라이언트 연동

**패턴**: Axios/fetch → TanStack Query 래퍼

```typescript
// src/api/client.ts
const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

// src/api/orders.ts
export const orderApi = {
  getOrders: (filters: OrderFilters) =>
    apiClient.get<OrderListResponse>('/orders', { params: filters }),
  getOrder: (id: string) =>
    apiClient.get<Order>(`/orders/${id}`),
};
```

### Step 5: 상태 관리 구현

**Zustand 스토어**:

```typescript
// src/store/auth.ts
interface AuthState {
  user: User | null;
  token: string | null;
  login: (credentials: LoginDto) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  token: null,
  login: async (credentials) => {
    const { user, token } = await authApi.login(credentials);
    set({ user, token });
  },
  logout: () => set({ user: null, token: null }),
}));
```

## 출력

- **생성된 파일 목록**: 컴포넌트, 훅, 유틸, 스토어 파일 경로
- **import 관계도**: 파일 간 의존 관계
- **미구현 항목**: TODO/FIXME 목록 (있다면)
