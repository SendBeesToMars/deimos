import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import reactDom from 'eslint-plugin-react-dom'
import reactX from 'eslint-plugin-react-x'
import tseslint from '@typescript-eslint/eslint-plugin'
import tsParser from '@typescript-eslint/parser'
import { defineConfig } from 'eslint/config'

export default defineConfig({
  ignores: ['dist/**'],
  linterOptions: {
    reportUnusedDisableDirectives: true,
  },
  plugins: {
    '@typescript-eslint': tseslint,
    'react-hooks': reactHooks,
    'react-refresh': reactRefresh,
    'react-dom': reactDom,
    'react-x': reactX,
  },
  languageOptions: {
    parser: tsParser,
    parserOptions: {
      ecmaVersion: 2020,
      sourceType: 'module',
      ecmaFeatures: { jsx: true },
    },
    globals: {
      ...globals.browser,
    },
  },
  rules: {
    // ESLint recommended rules
    ...js.configs.recommended.rules,
    // TypeScript rules
    ...tseslint.configs.recommended.rules,
    '@typescript-eslint/no-explicit-any': 'error',
    // React rules
    ...reactHooks.configs['recommended-latest'].rules,
    ...reactRefresh.configs.vite.rules,
  },
})
