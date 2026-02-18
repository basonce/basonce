import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { copyFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

export default defineConfig({
  plugins: [
    react(),
    {
      name: 'copy-public-exclude',
      apply: 'build',
      writeBundle() {
        const publicDir = 'public';
        const outDir = 'dist';
        const files = readdirSync(publicDir);

        files.forEach(file => {
          if (file.includes(' copy ') || file.includes('copy copy')) {
            return;
          }

          try {
            const src = join(publicDir, file);
            const dest = join(outDir, file);
            if (statSync(src).isFile()) {
              copyFileSync(src, dest);
            }
          } catch (e) {
          }
        });
      }
    }
  ],
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
  publicDir: false,
});
