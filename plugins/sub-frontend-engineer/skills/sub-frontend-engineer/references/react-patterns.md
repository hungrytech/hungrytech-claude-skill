# React 컴포넌트 패턴 카탈로그

> React 18+ 기반 검증된 컴포넌트 설계 패턴.

---

## Compound Components

관련 컴포넌트를 하나의 네임스페이스로 묶어 암묵적 상태를 공유하는 패턴.

```tsx
// 사용
<Select value={value} onChange={onChange}>
  <Select.Trigger>선택하세요</Select.Trigger>
  <Select.Options>
    <Select.Option value="a">옵션 A</Select.Option>
    <Select.Option value="b">옵션 B</Select.Option>
  </Select.Options>
</Select>

// 구현
const SelectContext = createContext<SelectContextValue | null>(null);

function Select({ children, value, onChange }: SelectProps) {
  return (
    <SelectContext.Provider value={{ value, onChange }}>
      {children}
    </SelectContext.Provider>
  );
}

Select.Trigger = function Trigger({ children }: PropsWithChildren) { ... };
Select.Options = function Options({ children }: PropsWithChildren) { ... };
Select.Option = function Option({ value, children }: OptionProps) { ... };
```

**사용 시점**: 탭, 아코디언, 드롭다운 등 복합 UI 요소.

---

## Custom Hook Extraction

컴포넌트에서 로직을 훅으로 분리하여 재사용성과 테스트 용이성 확보.

```tsx
// Before: 로직 + UI 혼합
function OrderList() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => { fetchOrders().then(setOrders).finally(() => setLoading(false)); }, []);
  return loading ? <Spinner /> : <ul>{orders.map(o => <li key={o.id}>{o.name}</li>)}</ul>;
}

// After: 로직 분리
function useOrders() {
  return useQuery({ queryKey: ['orders'], queryFn: fetchOrders });
}

function OrderList() {
  const { data: orders, isLoading } = useOrders();
  if (isLoading) return <Spinner />;
  return <ul>{orders.map(o => <li key={o.id}>{o.name}</li>)}</ul>;
}
```

**사용 시점**: 2개 이상 컴포넌트에서 동일 로직 사용, 복잡한 상태 로직.

---

## Render Props / Children as Function

렌더링 로직을 호출자에게 위임하는 패턴.

```tsx
function DataFetcher<T>({ url, children }: { url: string; children: (data: T) => ReactNode }) {
  const { data, isLoading } = useFetch<T>(url);
  if (isLoading) return <Spinner />;
  return <>{children(data)}</>;
}

// 사용
<DataFetcher<User[]> url="/api/users">
  {(users) => <UserList users={users} />}
</DataFetcher>
```

**사용 시점**: 데이터 제공 컴포넌트, 렌더링 커스터마이징 필요 시.

---

## Higher-Order Component (HOC)

컴포넌트에 공통 기능을 주입하는 래핑 패턴. 훅이 커버하지 못하는 경우 사용.

```tsx
function withAuth<P extends object>(Component: ComponentType<P>) {
  return function AuthenticatedComponent(props: P) {
    const { user } = useAuthStore();
    if (!user) return <Navigate to="/login" />;
    return <Component {...props} />;
  };
}

const ProtectedDashboard = withAuth(Dashboard);
```

**사용 시점**: 인증 래퍼, 에러 바운더리 래퍼, 로깅 래퍼. 훅으로 대체 가능하면 훅 우선.

---

## Container / Presentational

데이터 페칭(Container)과 UI 렌더링(Presentational)을 분리하는 패턴.

```tsx
// Container: 데이터 로직
function OrderListContainer() {
  const { data, isLoading } = useOrders();
  return <OrderListView orders={data ?? []} isLoading={isLoading} />;
}

// Presentational: 순수 UI
function OrderListView({ orders, isLoading }: OrderListViewProps) {
  if (isLoading) return <Skeleton />;
  return <ul>{orders.map(o => <OrderItem key={o.id} order={o} />)}</ul>;
}
```

**사용 시점**: 스토리북 대응, 테스트 용이성 필요 시.

---

## Error Boundary

React Error Boundary로 하위 트리의 렌더링 에러를 격리.

```tsx
import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
  return (
    <div role="alert">
      <p>문제가 발생했습니다: {error.message}</p>
      <button onClick={resetErrorBoundary}>다시 시도</button>
    </div>
  );
}

// 사용
<ErrorBoundary FallbackComponent={ErrorFallback}>
  <OrderList />
</ErrorBoundary>
```

---

## 성능 최적화 패턴

| 패턴 | 방법 | 사용 시점 |
|------|------|----------|
| **React.memo** | `memo(Component)` | props 변경 없이 부모 리렌더링 시 |
| **useMemo** | `useMemo(() => expensiveCalc, [deps])` | 비용 높은 계산 결과 캐싱 |
| **useCallback** | `useCallback(fn, [deps])` | 자식에게 전달하는 콜백 안정화 |
| **Code Splitting** | `React.lazy(() => import('./Page'))` | 라우트/큰 컴포넌트 레이지 로딩 |
| **Virtualization** | `@tanstack/react-virtual` | 대량 리스트 (1000+ 항목) |
