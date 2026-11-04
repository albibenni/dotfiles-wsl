---
name: typescript-exercise-master
description: Generates 10 structured TypeScript exercises following modern best practices, designed for direct use in .test.ts files.
---

# TypeScript Exercise Master

This skill focuses on mastering TypeScript through practical, type-safe implementation and testing. It ensures exercises follow the latest language features and best practices.

## Workflow

1.  **Identify Topic**: Confirm the specific TypeScript concept (e.g., Generics, Utility Types, Discriminated Unions, Template Literal Types, Type-level Programming, etc.).
2.  **Generate Exercises**: Create exactly 10 exercises, structured by difficulty:
    - **4 Beginner**: Focused on basic types, interfaces, optionality, and simple function signatures.
    - **4 Intermediate**: Focused on Generics, Union/Intersection types, Type Guards, and Utility Types.
    - **2 Advanced**: Focused on Conditional Types, Mapped Types, Template Literal Types, and complex Inference.
3.  **Present Exercises**: List the exercises clearly. **All generated exercises must be written to a single `.md` file in the workspace (e.g., `typescript-exercises.md`) using the `write_file` tool.** Include a reference (e.g., a link) to the corresponding quiz file in this newly created file. Additionally, update the original file that was the subject of the exercise to include a reference (e.g., a link) pointing to this newly created exercise file.
    - **Exercises & Tests Codeblock**: All 10 exercises, including their starter code and test suites, MUST be contained within a **single** markdown codeblock. This allows the user to copy-paste the entire practice session into a single `.test.ts` file at once. The starter code should be incomplete (e.g., using `any` or `TODO` types) to be solved by the user.
        - Include necessary imports at the top (e.g., `import { describe, it, expect, expectTypeOf } from 'vitest'`).
        - Use clear comment headers to separate exercises (e.g., `// --- Exercise 1: [Topic] ---`).
        - Ensure namespacing or unique naming if exercises share similar identifiers.
    - **Test Suite Integration**: Use **Vitest** (preferred) or **Jest** syntax.
    - **Solutions Codeblock**: Include the full, completed solutions at the bottom of the **same .md file** in a **separate** markdown codeblock, clearly marked to avoid spoilers. This allows the user to refer to them only after attempting the exercises.
4.  **Feedback Loop**: Offer hints and explain the "why" behind TypeScript's behavior, focusing on type inference, structural typing, and safety.

## Guidelines

- **Modern TypeScript (5.x+)**: Utilize the latest features (e.g., `const` type parameters, `satisfies` operator, etc.) and avoid deprecated or non-idiomatic patterns (like `any`, `namespace`, or `enum` in favor of discriminated unions).
- **Strict Mode Compliance**: All exercises should assume and follow `strict: true` rules.
- **Best Practices**:
    - Prefer `unknown` over `any`.
    - Use `never` for exhaustive checks.
    - Favor composition and functional patterns.
    - Use descriptive type names.
- **Testing Idioms**: Tests should be descriptive. Use type-level assertions (like `expectTypeOf`) to verify that types are correctly inferred or constrained.
- **Link Formatting**: Never use `file:///` URLs, absolute filesystem paths, or relative paths in generated or updated `.md` files. Always use Obsidian Wikilinks (e.g., `[[typescript-exercises]]` or `[[typescript-exercises|Display Label]]`). Both the reference in the generated exercise note and the backlink added to the source note MUST use Obsidian Wikilinks.
- **Single Copy-Paste Action**: The primary goal is for the user to copy one single block of code from the `.md` file into a `.test.ts` file and have the entire 10-exercise practice suite ready to go.
