# 프론트엔드 테스트 가이드

> Vitest + React Testing Library + Playwright 기반 테스트 패턴.

---

## 테스트 피라미드

| 레벨 | 도구 | 범위 | 비율 |
|------|------|------|------|
| **단위 테스트** | Vitest + RTL | 컴포넌트, 훅, 유틸 | 70% |
| **통합 테스트** | Vitest + RTL | 페이지, 폼 플로우 | 20% |
| **E2E 테스트** | Playwright | 사용자 시나리오 | 10% |

---

## Vitest 설정

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    css: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'src/test/'],
    },
  },
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
});
```

### Setup 파일

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom/vitest';
```

---

## React Testing Library 패턴

### 컴포넌트 렌더링 테스트

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('Button', () => {
  it('텍스트를 표시한다', () => {
    render(<Button>클릭</Button>);
    expect(screen.getByRole('button', { name: '클릭' })).toBeInTheDocument();
  });

  it('클릭 이벤트를 처리한다', async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    render(<Button onClick={onClick}>클릭</Button>);
    await user.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalledOnce();
  });

  it('disabled 시 클릭 불가', async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    render(<Button onClick={onClick} disabled>클릭</Button>);
    await user.click(screen.getByRole('button'));
    expect(onClick).not.toHaveBeenCalled();
  });
});
```

### 쿼리 우선순위

| 우선순위 | 쿼리 | 용도 |
|---------|------|------|
| 1 | `getByRole` | 접근성 역할 기반 (권장) |
| 2 | `getByLabelText` | 폼 요소 |
| 3 | `getByPlaceholderText` | 입력 필드 |
| 4 | `getByText` | 비-상호작용 텍스트 |
| 5 | `getByTestId` | 최후의 수단 |

### 비동기 테스트

```typescript
it('데이터 로딩 후 표시', async () => {
  render(<OrderList />);
  expect(screen.getByText('로딩 중...')).toBeInTheDocument();
  expect(await screen.findByText('주문 #001')).toBeInTheDocument();
});
```

### 커스텀 훅 테스트

```typescript
import { renderHook, act, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: PropsWithChildren) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}

describe('useOrders', () => {
  it('주문 목록을 가져온다', async () => {
    const { result } = renderHook(() => useOrders({}), {
      wrapper: createWrapper(),
    });
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toHaveLength(3);
  });
});
```

---

## API 모킹

### MSW (Mock Service Worker)

```typescript
// src/test/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/orders', () => {
    return HttpResponse.json([
      { id: '001', name: '주문 1', status: 'active' },
      { id: '002', name: '주문 2', status: 'completed' },
    ]);
  }),
  http.post('/api/orders', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: '003', ...body }, { status: 201 });
  }),
];

// src/test/mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';
export const server = setupServer(...handlers);

// src/test/setup.ts
import { server } from './mocks/server';
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

---

## Playwright E2E 패턴

```typescript
import { test, expect } from '@playwright/test';

test.describe('로그인 플로우', () => {
  test('유효한 자격증명으로 로그인', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('이메일').fill('user@example.com');
    await page.getByLabel('비밀번호').fill('password123');
    await page.getByRole('button', { name: '로그인' }).click();
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('환영합니다')).toBeVisible();
  });

  test('잘못된 비밀번호로 에러 표시', async ({ page }) => {
    await page.goto('/login');
    await page.getByLabel('이메일').fill('user@example.com');
    await page.getByLabel('비밀번호').fill('wrong');
    await page.getByRole('button', { name: '로그인' }).click();
    await expect(page.getByText('이메일 또는 비밀번호가 올바르지 않습니다')).toBeVisible();
  });
});
```
