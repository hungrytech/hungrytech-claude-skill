/// <reference types="vitest/config" />
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],

  test: {
    // jsdom 환경 (브라우저 API 모킹)
    environment: 'jsdom',

    // 글로벌 API (describe, it, expect 등 import 없이 사용)
    globals: true,

    // 테스트 셋업 파일
    setupFiles: './src/test/setup.ts',

    // CSS 처리
    css: true,

    // 커버리지 설정
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
      ],
    },

    // 파일 포함 패턴
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
  },

  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
