import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],

  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },

  server: {
    port: 3000,
    // API 프록시 설정 (백엔드 연동 시)
    // proxy: {
    //   '/api': {
    //     target: 'http://localhost:8080',
    //     changeOrigin: true,
    //   },
    // },
  },

  build: {
    // 번들 사이즈 경고 임계값 (KB)
    chunkSizeWarningLimit: 500,

    rollupOptions: {
      output: {
        // 벤더 청크 분리
        manualChunks: {
          vendor: ['react', 'react-dom'],
          // router: ['react-router-dom'],
          // query: ['@tanstack/react-query'],
        },
      },
    },
  },
});
