# 상태 관리 가이드

> Zustand + TanStack Query 기반 상태 관리 패턴과 설계 원칙.

---

## 상태 분류 원칙

| 상태 유형 | 도구 | 특징 |
|----------|------|------|
| **서버 상태** | TanStack Query | 캐싱, 재요청, 낙관적 업데이트 |
| **전역 클라이언트** | Zustand | 인증, 테마, 사이드바 상태 |
| **로컬 UI** | useState / useReducer | 모달, 입력값, 토글 |
| **URL 상태** | React Router | 필터, 페이지, 정렬 |
| **폼 상태** | React Hook Form | 필드 값, 검증, 제출 |

**원칙**: 서버에서 온 데이터는 TanStack Query가 소유. 클라이언트에서만 의미 있는 데이터만 Zustand로 관리.

---

## Zustand 패턴

### 기본 스토어

```typescript
import { create } from 'zustand';

interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

export const useCounterStore = create<CounterState>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

### Persist 미들웨어

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      login: async (credentials) => {
        const result = await authApi.login(credentials);
        set({ token: result.token, user: result.user });
      },
      logout: () => set({ token: null, user: null }),
    }),
    { name: 'auth-storage' }
  )
);
```

### Selector 패턴 (리렌더링 최적화)

```typescript
// Bad: 전체 스토어 구독 → 불필요한 리렌더링
const { count, user, theme } = useStore();

// Good: 필요한 값만 선택
const count = useStore((state) => state.count);
const user = useStore((state) => state.user);
```

### Slice 패턴

```typescript
// store/slices/auth.ts
export const createAuthSlice = (set: SetState): AuthSlice => ({
  user: null,
  login: async (cred) => { ... },
  logout: () => set({ user: null }),
});

// store/slices/ui.ts
export const createUISlice = (set: SetState): UISlice => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
});

// store/index.ts
export const useStore = create<AppState>()((...args) => ({
  ...createAuthSlice(...args),
  ...createUISlice(...args),
}));
```

---

## TanStack Query 패턴

### 기본 쿼리

```typescript
import { useQuery } from '@tanstack/react-query';

export function useOrders(filters: OrderFilters) {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: () => orderApi.getOrders(filters),
    staleTime: 5 * 60 * 1000, // 5분
  });
}
```

### 뮤테이션 + 캐시 무효화

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';

export function useCreateOrder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: orderApi.createOrder,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
    },
  });
}
```

### 낙관적 업데이트

```typescript
export function useToggleTodo() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: todoApi.toggle,
    onMutate: async (todoId) => {
      await queryClient.cancelQueries({ queryKey: ['todos'] });
      const previous = queryClient.getQueryData(['todos']);
      queryClient.setQueryData(['todos'], (old: Todo[]) =>
        old.map(t => t.id === todoId ? { ...t, done: !t.done } : t)
      );
      return { previous };
    },
    onError: (_err, _id, context) => {
      queryClient.setQueryData(['todos'], context?.previous);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] });
    },
  });
}
```

### 무한 스크롤

```typescript
export function useInfiniteOrders() {
  return useInfiniteQuery({
    queryKey: ['orders', 'infinite'],
    queryFn: ({ pageParam = 0 }) => orderApi.getOrders({ offset: pageParam }),
    getNextPageParam: (lastPage) => lastPage.nextOffset ?? undefined,
    initialPageParam: 0,
  });
}
```

---

## Query Key 컨벤션

```typescript
// 계층적 구조
['orders']                    // 모든 주문
['orders', { status: 'active' }]  // 필터링된 주문
['orders', orderId]           // 단일 주문
['orders', orderId, 'items']  // 주문 항목

// QueryKey Factory 패턴
export const orderKeys = {
  all: ['orders'] as const,
  lists: () => [...orderKeys.all, 'list'] as const,
  list: (filters: OrderFilters) => [...orderKeys.lists(), filters] as const,
  details: () => [...orderKeys.all, 'detail'] as const,
  detail: (id: string) => [...orderKeys.details(), id] as const,
};
```
