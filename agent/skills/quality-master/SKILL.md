---
name: quality-master
description: Audits code against Clean Code and SOLID principles, providing specific refactoring suggestions and technical rationales to improve maintainability.
---

# Quality Master

This skill focuses on structural integrity and the long-term health of the codebase.

## Workflow

1.  **Source Analysis**: Read and analyze the provided code snippet or file to understand its current structure and intent.
2.  **Clean Code Audit**: Evaluate the code for:
    *   **Meaningful Naming**: Variables, functions, and classes.
    *   **Function Purity**: Small size, single task, and minimal side effects.
    *   **Comment Quality**: Avoiding redundant or noise comments.
3.  **SOLID Audit**: Evaluate the code for:
    *   **Single Responsibility (SRP)**: Does each class/module have only one reason to change?
    *   **Open/Closed (OCP)**: Is the code open for extension but closed for modification?
    *   **Liskov Substitution (LSP)**: Can subtypes be substituted for their base types?
    *   **Interface Segregation (ISP)**: Are clients forced to depend on methods they don't use?
    *   **Dependency Inversion (DIP)**: Does the code depend on abstractions rather than concretions?
4.  **Refactor Suggestions**: Provide targeted "Before" and "After" code blocks showing how to resolve identified issues.
5.  **Technical Rationale**: Explain the benefits of the changes (e.g., "Reduced cognitive load," "Decoupled logic").

## Guidelines

*   **Explicit Principles**: Always name the specific Clean Code or SOLID principle being discussed.
*   **Idiomatic Refactoring**: Ensure that suggested changes follow the idiomatic patterns of the language (e.g., using specific language features like Traits in Rust or Decorators in Python).
*   **Prioritize Impact**: Focus on the changes that will provide the most significant improvement to maintainability first.
