---
name: exercise-master
description: Generates 10 structured exercises on a user-provided topic to facilitate hands-on learning and mastery.
---

# Exercise Master

This skill focuses on practical application and skill acquisition through iterative practice.

## Workflow

1.  **Identify Topic**: Confirm the specific topic or concept the user wants to practice.
2.  **Generate Exercises**: Create exactly 10 exercises, structured by difficulty:
    - **4 Beginner**: Focused on syntax, basic definitions, and simple implementation.
    - **4 Intermediate**: Focused on logic, combining multiple concepts, and refactoring.
    - **2 Advanced**: Focused on optimization, architectural design, or complex problem-solving.
3.  **Present Exercises**: List the exercises clearly. **All generated exercises must be written to a single `.md` file in the workspace (e.g., `exercises.md`) using the `write_file` tool.** Include a reference (e.g., a link) to the corresponding quiz file in this newly created file. Additionally, update the original file that was the subject of the exercise to include a reference (e.g., a link) pointing to this newly created exercise file.
    - **Single Codeblock Requirement**: For coding topics, all 10 exercises, including their starter code and test suites, MUST be contained within a **single** markdown codeblock. This allows the user to copy-paste the entire practice session at once.
    - **Structure within the Codeblock**: Use clear comment headers to separate exercises (e.g., `// --- Exercise 1: [Topic] ---`).
    - **Include Automated Tests**: For every exercise, provide a companion test suite (e.g., using `jest`, `pytest`, `cargo test`, etc.) that the user can run to verify their implementation. Include a clear command on how to execute the tests.
    - **Include Solution**: For every exercise, include the full solution code at the bottom of the **same file**, separated by a clear comment or within a commented-out section to avoid spoiling the challenge immediately.
4.  **Feedback Loop**: Offer to provide hints or explain the solution for each exercise as the user progresses. Explain the "why" behind the implementation choices.

## Guidelines

- **Practicality**: Exercises should reflect real-world scenarios or common engineering challenges.
- **Incremental Complexity**: Ensure a smooth learning curve from Exercise 1 to 10.
- **Actionable Feedback**: When discussing solutions, explain the technical rationale and trade-offs.
- **Single-File Workflow**: All 10 exercises must be delivered together in a single file containing descriptions, starter code, automated tests, and solutions. This ensures the user has everything they need to practice, verify, and learn in one place.
- **Output Requirement**: Always save the complete set of exercises, including descriptions, starter code, and solutions, to a `.md` file. This ensures the user has a durable and easily accessible document for their practice session.
- **Link Formatting**: Never use `file:///` URLs, absolute filesystem paths, or relative paths in generated or updated `.md` files. Always use Obsidian Wikilinks (e.g., `[[exercises]]` or `[[exercises|Display Label]]`). Both the reference inside the newly generated `.md` file and the backlink in the original source `.md` file MUST use Obsidian Wikilinks.
- **Verification**: The included tests should be idiomatic to the language used and provide clear, descriptive output for both success and failure cases.
