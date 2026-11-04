---
name: project-onboarding
description: Researches a codebase to explain its architecture, tech stack, and state, then generates a knowledge check quiz for the user. Use when the user asks to "explain this project", "how does this work", or "test my knowledge".
---

# Project Onboarding

This skill automates the process of understanding a new or existing codebase and verifying that understanding.

## Workflow

1.  **Research**:
    *   Examine `Cargo.toml`, `package.json`, `go.mod`, etc., to identify the tech stack.
    *   Read `README.md`, `AGY.md`, or `GEMINI.md` for architectural context.
    *   Use `ls -R` or `glob` to map the directory structure.
    *   Identify key entry points (e.g., `main.rs`, `index.js`).

2.  **Explain**:
    *   Provide a high-signal summary of the project's purpose.
    *   Detail the "Core Technologies" and "Current State".
    *   Explain how data flows through the system (e.g., threading models, API routes).

3.  **Validate (Knowledge Check)**:
    *   Generate a 3-question multiple-choice quiz.
    *   Focus on non-obvious architectural details identified during research.
    *   Ask the user for their answers to confirm they are ready to contribute.

## Guidelines

*   Be concise. Focus on *intent* and *rationale* over line-by-line code explanation.
*   If the project has an `AGY.md` or `GEMINI.md`, prioritize its instructions as the source of truth for architecture.
