---
name: split-exercise-master
description: Generates 10 structured exercises written directly to an exercises folder, with solutions written to a separate markdown file in your notes.
---

# Split Exercise Master

This skill focuses on mastering programming concepts through practical implementation and testing. It generates exercises and saves them directly to a target exercises folder, while saving the solutions to a separate Markdown file in your SecondBrain/notes.

## Workflow

1.  **Identify Topic & Paths**: Ask the user to confirm:
    - The specific topic/concept.
    - The target programming language / file extension (e.g., `.ts`, `.py`).
    - Path 1: The folder path where the exercises should be written.
    - Path 2: The `.md` file path in their SecondBrain where the solutions should be written.
2.  **Generate Exercises**: Create exactly 10 exercises, structured by difficulty:
    - **4 Beginner**: Focused on basic usage and simple signatures.
    - **4 Intermediate**: Focused on intermediate language features.
    - **2 Advanced**: Focused on complex inference, patterns, and advanced types.
3.  **Write Exercises (Path 1)**: Write the generated exercises directly into the provided folder path using the `write_to_file` tool. 
    - Write all 10 exercises, including their starter code and test suites, into a single test file in the specified folder (e.g., `[topic].test.ts` or `[topic]_test.py`).
    - The starter code should be incomplete (e.g., using `any`, `TODO`, or `pass`) to be solved by the user.
    - Include necessary test framework imports at the top (e.g., `import { describe, it, expect, expectTypeOf } from 'vitest'`).
    - Use clear comment headers to separate exercises (e.g., `// --- Exercise 1: [Topic] ---`).
    - Ensure namespacing or unique naming if exercises share similar identifiers.
4.  **Write Solutions (Path 2)**: Write the full, completed solutions to the provided `.md` file path using the appropriate file editing tool (`write_to_file` or `replace_file_content` / `multi_replace_file_content` if appending to an existing note). 
    - The solutions should be contained within markdown codeblocks.
    - Include clear explanations of the solutions in the markdown.
    - Add a link/reference to the exercise file path from this solution file.
5.  **Feedback Loop**: Offer hints and explain the "why" behind the code's behavior, focusing on best practices.

## Guidelines

- **Modern Features & Coding Principles**: Utilize the latest language features, avoid deprecated patterns, and strictly follow current-day coding principles (clean code, immutability, architectural best practices).
- **Strict Linting**: Ensure all generated code strictly adheres to modern, up-to-date linting rules for the chosen language.
- **Strict Mode Compliance**: If using TypeScript, all exercises should assume and follow `strict: true` rules.
- **Testing Idioms**: Tests should be descriptive. 
- **Link Formatting**: Never use `file:///` URLs, absolute filesystem paths, or relative paths in `.md` files. When linking between exercise files and solution notes, use Obsidian Wikilinks (e.g., `[[exercise_note]]` or `[[exercise_note|Display Label]]`).
- **Direct File Modification**: You must write the exercises and solutions directly to the specified paths instead of asking the user to copy-paste.
