---
name: onboarding-architecture
description: Analyzes the codebase and explains it from an architectural perspective. Identifies API communication, design patterns, main technologies used, and data flow. Use when the user wants an architectural overview of a project.
---

# Architecture Onboarding

This skill analyzes a codebase to provide a comprehensive explanation of its architectural design. 

## Workflow

1.  **Codebase Analysis**:
    *   Examine package managers (`package.json`, `go.mod`, `Cargo.toml`, etc.) to identify the core technology stack and major dependencies.
    *   Explore the directory structure to identify modularity, domain boundaries, and typical design patterns (e.g., MVC, clean architecture, microservices).
    *   Analyze entry points and configuration files.

2.  **Architectural Explanation**:
    *   **Main Technologies**: List the primary frameworks, languages, and libraries driving the application.
    *   **Design Patterns**: Explain the high-level design patterns found in the codebase (e.g., Repository pattern, Singleton, Event-Driven, MVC).
    *   **API Communication**: Describe how the application communicates internally and externally (e.g., REST, GraphQL, gRPC, WebSockets, Message Queues).
    *   **Data Flow**: Outline how data moves through the system from input to storage.

3.  **Summary**:
    *   Provide a clear, high-signal summary of the application's overall architecture and how the components interact.

## Guidelines

*   Focus on structural intent and high-level decisions rather than line-by-line code logic.
*   Highlight any specific architectural diagrams or documentation already present in the codebase (like `ARCHITECTURE.md` or `README.md`).
*   Be concise and use clear formatting (bullet points, bold text) for readability.
