# Vite 설정 가이드

> Vite 빌드 설정, 플러그인, 최적화, 환경 변수 관리.

---

## 기본 설정

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

---

## 플러그인

| 플러그인 | 용도 |
|---------|------|
| `@vitejs/plugin-react` | React Fast Refresh, JSX 변환 |
| `vite-plugin-svgr` | SVG → React 컴포넌트 |
| `rollup-plugin-visualizer` | 번들 사이즈 시각화 |
| `vite-plugin-compression` | gzip/brotli 압축 |
| `vite-tsconfig-paths` | tsconfig paths 자동 연동 |

---

## 환경 변수

**규칙**: `VITE_` 접두사만 클라이언트에 노출.

```bash
# .env
VITE_API_URL=http://localhost:8080/api
VITE_APP_TITLE=My App

# .env.production
VITE_API_URL=https://api.example.com
```

**타입 안전 사용**:

```typescript
// src/env.d.ts
/// <reference types="vite/client" />
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_APP_TITLE: string;
}

// 사용
const apiUrl = import.meta.env.VITE_API_URL;
```

---

## 빌드 최적화

### 코드 스플리팅

```typescript
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
          query: ['@tanstack/react-query'],
        },
      },
    },
  },
});
```

### 청크 사이즈 경고

```typescript
export default defineConfig({
  build: {
    chunkSizeWarningLimit: 500, // KB
  },
});
```

### 소스맵

```typescript
export default defineConfig({
  build: {
    sourcemap: true, // 프로덕션 디버깅용 (sentry 등)
    // sourcemap: 'hidden', // 소스맵 생성하되 번들에 미포함
  },
});
```

---

## 개발 서버 프록시

```typescript
export default defineConfig({
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
});
```

---

## HMR (Hot Module Replacement)

Vite는 기본으로 HMR을 지원. `@vitejs/plugin-react`가 React Fast Refresh를 활성화한다.

**HMR 깨지는 경우**:
- 컴포넌트를 `export default`가 아닌 이름 없는 함수로 export
- 파일에서 React 컴포넌트와 비컴포넌트를 혼합 export
- `window` / `document` 직접 조작하는 사이드 이펙트

---

## Path Alias

```typescript
// vite.config.ts
resolve: {
  alias: {
    '@': path.resolve(__dirname, './src'),
    '@components': path.resolve(__dirname, './src/components'),
    '@hooks': path.resolve(__dirname, './src/hooks'),
    '@api': path.resolve(__dirname, './src/api'),
  },
}

// tsconfig.json (같이 설정 필요)
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@api/*": ["./src/api/*"]
    }
  }
}
```
