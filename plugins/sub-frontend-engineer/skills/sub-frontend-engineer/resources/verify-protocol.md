# 검증 프로토콜

> Phase 4: 구현된 코드의 테스트, 번들 사이즈, 접근성을 검증한다.

---

## 실행 절차

### Step 1: Vitest 단위 테스트

**테스트 파일 컨벤션**:
- 컴포넌트: `ComponentName.test.tsx`
- 훅: `useHookName.test.ts`
- 유틸: `utilName.test.ts`
- 위치: 소스 파일 옆 (co-location) 또는 `__tests__/` 디렉토리

**컴포넌트 테스트 패턴**:

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { OrderList } from './OrderList';

describe('OrderList', () => {
  it('주문 목록을 렌더링한다', () => {
    render(<OrderList orders={mockOrders} />);
    expect(screen.getByText('주문 #001')).toBeInTheDocument();
  });

  it('주문 클릭 시 onSelect 호출', async () => {
    const onSelect = vi.fn();
    render(<OrderList orders={mockOrders} onSelect={onSelect} />);
    await fireEvent.click(screen.getByText('주문 #001'));
    expect(onSelect).toHaveBeenCalledWith('001');
  });
});
```

**훅 테스트 패턴**:

```typescript
import { renderHook, act } from '@testing-library/react';
import { useModal } from './useModal';

describe('useModal', () => {
  it('초기 상태는 닫힘', () => {
    const { result } = renderHook(() => useModal());
    expect(result.current.isOpen).toBe(false);
  });

  it('open() 호출 시 열림', () => {
    const { result } = renderHook(() => useModal());
    act(() => result.current.open());
    expect(result.current.isOpen).toBe(true);
  });
});
```

### Step 2: 번들 사이즈 확인

```bash
scripts/measure-bundle-size.sh [project-root]
```

**기준값**:

| 항목 | 권장 | 경고 | 위험 |
|------|------|------|------|
| 초기 JS 번들 | < 200KB (gzip) | 200-500KB | > 500KB |
| 최대 청크 | < 100KB (gzip) | 100-250KB | > 250KB |
| CSS 번들 | < 50KB (gzip) | 50-100KB | > 100KB |
| 총 에셋 | < 1MB | 1-3MB | > 3MB |

**번들 최적화 체크**:
- [ ] 코드 스플리팅: `React.lazy()` + `Suspense` 사용
- [ ] 트리 셰이킹: 사이드 이펙트 없는 모듈 확인
- [ ] 이미지 최적화: WebP/AVIF, 적절한 사이즈
- [ ] 의존성 크기: `rollup-plugin-visualizer`로 확인

### Step 3: 접근성 체크

**자동 검사 항목**:
- [ ] 모든 `<img>`에 `alt` 속성
- [ ] 폼 요소에 `<label>` 연결
- [ ] 버튼/링크에 접근 가능한 텍스트
- [ ] 색상 대비 충분 (WCAG AA 4.5:1)
- [ ] 키보드 내비게이션 (Tab/Shift+Tab/Enter/Escape)
- [ ] 시맨틱 HTML 사용 (`<nav>`, `<main>`, `<article>`)
- [ ] `aria-*` 속성 올바른 사용

### Step 4: TypeScript 타입 검사

```bash
npx tsc --noEmit
```

- strict 모드 위반 확인
- any 사용 최소화
- 미사용 import/변수 제거

## 출력

- **테스트 결과**: 통과/실패 수, 커버리지
- **번들 사이즈**: JS/CSS/총 에셋 크기
- **접근성 이슈**: 위반 항목 + 수정 제안
- **타입 에러**: TypeScript 컴파일 에러 목록
