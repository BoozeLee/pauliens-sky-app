/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.astro',
    './src/**/*.js',
    './src/**/*.ts',
  ],
  theme: {
    extend: {
      colors: {
        'cosmic-purple': '#8B5CF6',
        'cosmic-blue': '#3B82F6',
        'cosmic-pink': '#EC4899',
        'cosmic-indigo': '#6366F1',
      },
    },
  },
  plugins: [],
}