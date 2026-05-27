import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://pauliens-sky.vercel.app',
  trailingSlash: 'never',
  build: {
    format: 'directory',
  },
  integrations: [
    // Add integrations here if needed
  ],
});