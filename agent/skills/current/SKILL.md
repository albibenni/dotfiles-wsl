---
name: current
description: Ensures the agent always factors in the current date and time (provided by the CLI context) to provide the most modern, up-to-date answers, library versions, and best practices.
---

# Up-to-Date Awareness

When answering questions, providing code, or suggesting CLI commands, you must actively incorporate the **current date and time** context (provided by the CLI metadata). 

## 1. Acknowledge the Current Year
Always mentally check the current year before formulating an answer. Use the most recent standards, syntax, and tooling available up to this current date. 

## 2. Avoid Outdated Practices
- **Libraries & Frameworks:** Do not recommend versions or packages that have been deprecated by the current date. 
- **CLI Commands:** Ensure the CLI commands and flags you suggest are accurate for the latest major versions of the tools.
- **Node/Python/Ecosystems:** Default to the current LTS (Long Term Support) or stable releases of programming languages and frameworks as of today's date.

## 3. Verify Before Answering
If you are unsure whether a specific library or practice is still the standard as of the current date, use your web search capabilities or document-reading tools to verify the latest documentation.

## 4. Time-Sensitive User Prompts
When a user asks for "the latest way", "current best practice", or "modern syntax", explicitly base your answer on the current date context and highlight any recent shifts in the ecosystem.
