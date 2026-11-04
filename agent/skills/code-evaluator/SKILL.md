---
name: code-evaluator
description: Evaluates code for accuracy, style, security, and architectural patterns according to the latest industry standards.
---

# Code Evaluator

This skill provides a rigorous, multi-dimensional evaluation of code to ensure it meets modern engineering excellence standards. It focuses on four key pillars: Accuracy, Style, Security, and Patterns.

## Workflow

1.  **Identify Context**: Determine the programming language, framework, and the code's intended goal.
2.  **Accuracy Assessment**: 
    - Verify logical correctness and handling of edge cases.
    - Check for potential runtime errors or resource leaks.
    - Ensure the implementation aligns with the stated or inferred requirements.
3.  **Style & Idiomaticity Audit**:
    - Evaluate naming conventions, formatting, and documentation.
    - Check for idiomatic usage of language features (e.g., using `match` in Rust, list comprehensions in Python).
    - Align with the latest style guides (e.g., Google, Airbnb, or language-specific PEPs) as of June 2026.
4.  **Security Posture Review**:
    - Scan for common vulnerabilities (injection, insecure defaults, improper error handling).
    - Evaluate data privacy and sensitive information handling.
    - Recommend modern security practices (e.g., zero-trust, secure defaults).
5.  **Pattern & Architecture Analysis**:
    - Identify used design patterns and assess their appropriateness.
    - Evaluate modularity, coupling, and cohesion.
    - Suggest structural improvements for better maintainability and scalability.
6.  **Suggested Improvements & Actionable Synthesis**:
    - **Prioritized Findings**: Categorize issues by severity (Critical, High, Medium, Low) and impact.
    - **Targeted Refactors**: Provide concrete "Before" and "After" code blocks demonstrating how to implement the suggested improvements.
    - **Evolutionary Path**: Suggest how the code could be improved for future scale, performance, or changing requirements (e.g., transitioning from a monolith to microservices, or adopting a more performant library).
    - **Report Card**: Summarize the overall health of the code across the four pillars.

## Guidelines

- **Contemporary Standards**: Always use the standards and best practices current as of June 9, 2026. Mention specific modern tools or versions where applicable.
- **Deep Context**: If evaluating within a project, consider the existing codebase's conventions and architecture.
- **Objective & Justified**: Every critique must be backed by a technical rationale (e.g., "Improves cache locality," "Reduces attack surface").
- **Language-Specific Expertise**: Tailor the evaluation to the specific nuances of the language being reviewed.
