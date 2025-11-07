import js from '@eslint/js';
import globals from 'globals';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import reactDom from 'eslint-plugin-react-dom';
import reactX from 'eslint-plugin-react-x';
import prettierPlugin from 'eslint-plugin-prettier';
import prettierConfig from 'eslint-config-prettier';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';
import { defineConfig } from 'eslint/config';

const baseConfig = {
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
    prettier: prettierPlugin,
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
    // Prettier: disable conflicting ESLint rules and enable prettier rule
    ...((prettierConfig &&
      prettierConfig.configs &&
      prettierConfig.configs.recommended &&
      prettierConfig.configs.recommended.rules) ||
      {}),
    'prettier/prettier': ['error'],
    // enforce a sensible max line length
    'max-len': [
      'error',
      {
        code: 100,
        tabWidth: 2,
        ignoreComments: false,
        ignoreTrailingComments: true,
        ignoreUrls: true,
        ignoreStrings: true,
        ignoreTemplateLiterals: true,
        ignoreRegExpLiterals: true,
      },
    ],
    // React rules
    ...reactHooks.configs['recommended-latest'].rules,
    ...reactRefresh.configs.vite.rules,
  },
};

const testOverride = {
  files: ['**/*.test.{ts,tsx,js,jsx}', '**/__snapshots__/**', 'src/generated/**'],
  rules: {
    'max-len': ['warn', { code: 120, ignoreComments: true, ignoreUrls: true }],
  },
};

export default defineConfig([baseConfig, testOverride]);
