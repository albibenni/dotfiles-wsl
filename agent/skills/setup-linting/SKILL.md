---
name: setup-linting
description: Dynamically sets up base ESLint, tsconfig, and Prettier configurations tailored to the current project's framework based on the albibenni/ts-is-fun standards. Prefer pnpm unless another package manager is detected.
---

# Setup Linting, Formatting, and TypeScript

When requested to set up the base linting, formatting, or tsconfig, you must act dynamically. Analyze the project's context (e.g., existing files, package manager, and framework) and construct the configurations accordingly, rather than relying on mechanical copy-pasting. Follow the core principles from the `albibenni/ts-is-fun` standard while adapting to the environment.

## 1. Context Analysis & Detection
Before writing any files, inspect the workspace to determine:
- **Package Manager**: Look for `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`, or `bun.lockb`. Default to `pnpm`.
- **Framework & Libraries**: Check `package.json` for frameworks like Next.js, standard React (Vite/CRA), Vue, Node.js, and libraries like Tailwind CSS or Vitest.

## 2. Dynamic Dependency Installation
Run the install command using the detected package manager.
**Core Dev Dependencies (Always Install):**
- `eslint`
- `@eslint/js`
- `eslint-config-prettier`
- `eslint-plugin-prettier`
- `globals`
- `prettier`
- `typescript`
- `typescript-eslint`

**Contextual Dev Dependencies:**
- **Next.js**: Install `@next/eslint-plugin-next`. (Do not blindly install generic React plugins if Next.js manages it).
- **Standard React**: Install `eslint-plugin-react` and `eslint-plugin-react-hooks`.
- **Tailwind CSS**: If Tailwind is present, install `prettier-plugin-tailwindcss`.

**Validation Dependencies:**
- **Zod**: Check if the framework/language already has a built-in schema validator or if the project uses a similar library (e.g., `yup`, `joi`, `class-validator`). If not, install `zod` as a regular dependency to ensure robust, type-safe runtime validation.

## 3. Configure Prettier
Write `.prettierrc` matching the standard base:
```json
{
  "trailingComma": "all",
  "tabWidth": 2,
  "semi": true,
  "singleQuote": false
}
```
Write `.prettierignore` ignoring build and cache directories intelligently based on the framework (e.g., `node_modules`, `dist`, `build`, `.next`).

## 4. Configure ESLint (Flat Config)
Construct `eslint.config.js` (or `.mjs`) dynamically based on the project framework:

**Core Configuration (Apply to all):**
- Import and spread `eslint.configs.recommended` and `tseslint.configs.recommendedTypeChecked`.
- Apply `eslintPluginPrettierRecommended`.
- Configure `languageOptions.parserOptions.projectService = true` and `tsconfigRootDir: import.meta.dirname`.
- Add common globals (`browser`, `es2022`, `node`) and framework-specific ones (e.g., `vitest` if used).
- Include the `albibenni/ts-is-fun` base disabled/warn rules (e.g., `"@typescript-eslint/no-explicit-any": "off"`, `"@typescript-eslint/consistent-type-imports": "warn"`, etc.).
- Add an `ignores` block for build directories.

**Framework Specifics:**
- **Next.js**: Import `@next/eslint-plugin-next`. Create a configuration object mapping `plugins: { "@next/next": nextPlugin }` and spread its rules (`...nextPlugin.configs.recommended.rules` and `...nextPlugin.configs["core-web-vitals"].rules`).
- **Standard React**: Import and use `eslint-plugin-react` and `eslint-plugin-react-hooks`. Ensure `jsx: true` is enabled in `languageOptions.parserOptions.ecmaFeatures` and React globals are applied.
- **Vanilla/Node**: Keep it strictly TypeScript-focused without React plugins.

## 5. Configure TypeScript
Create or update `tsconfig.json`. Use the `ts-is-fun` base but adapt parameters dynamically based on the project framework:
**Never overwrite core compiler settings (like `module`, `moduleResolution`, or `jsx`) if they are already managed by a framework like Next.js.**
- **Base Options to Inject**: `"target": "ESNext"`, `"strict": true`, `"noImplicitOverride": true`.
- **Vanilla/Node.js Options**: Only if not using a specialized framework/bundler that requires specific module resolution, apply `"module": "NodeNext"` and `"moduleResolution": "NodeNext"`.
- **Framework Adjustments**: Modify `include`, `exclude`, and `jsx` flags based on the framework. For example, use `"jsx": "preserve"` and include `.next/types/**/*.ts` for Next.js, or `"jsx": "react-jsx"` for standard React. For frameworks like Next.js, leave their native `module` and `moduleResolution` untouched.

## 6. Update Scripts
Inject the formatting script into `package.json`:
```json
"scripts": {
  "indent:write": "prettier . --write"
}
```
