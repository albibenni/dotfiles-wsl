---
name: adaptive-tdd
description: Build or fix concrete behavior through small, behavior-first test-driven slices. Use when reliable automated feedback should drive implementation; do not use when the work is exploratory, purely presentational, or lacks a testable behavior.
---

# Adaptive Test-Driven Development

Use red → green → refactor to create tests that protect user-visible behavior while keeping feedback fast and trustworthy.

## Before the First Test

Inspect the relevant code, existing tests, project test commands, and local conventions. Identify the observable behavior, the public seam through which it can be verified, and the smallest valuable first slice. Reuse established test patterns unless they would obscure the behavior or make feedback unreliable.

Choose the narrowest test level that gives confidence in the risk:

- **Unit** for deterministic domain logic and isolated transformations.
- **Integration** for persistence, framework, serialization, or module-boundary behavior.
- **Contract** for stable expectations between independently deployed components.
- **End-to-end** only for a critical journey that lower-level tests cannot prove.

State the selected seam and level when the choice is non-obvious, high-risk, or changes existing interfaces. Do not test private implementation details merely because they are convenient to reach.

## The Slice Loop

1. Write one failing test for one observable behavior at the chosen seam.
2. Run that test and confirm that it fails for the intended missing behavior, not due to broken setup.
3. Implement the smallest coherent change that makes it pass.
4. Re-run the focused test and relevant fast checks.
5. Refactor only while the suite is green, preserving behavior and improving duplication, clarity, or module boundaries where useful.
6. Select the next behavior based on the new evidence; do not pre-write a speculative batch of tests.

Name tests as capabilities or outcomes, not internal calls. A test should remain useful if the implementation is reorganized behind the same public behavior.

## Control Nondeterminism and Boundaries

Make time, randomness, network calls, queues, filesystem access, and third-party services explicit dependencies or controlled test fixtures. Avoid live external calls in ordinary test runs. Prefer deterministic clocks, seeded values, fakes, or contract fixtures appropriate to the seam.

Mock only a boundary the test does not own. Do not mock the module's core behavior until the test merely verifies the mock. For data-backed behavior, use isolated fixtures and assert the relevant durable result rather than incidental query or framework details.

## Proportionate Exceptions

For a spike, visual exploration, trivial configuration change, or a case where the behavior is not yet understood, first establish the smallest experiment or validation that reduces uncertainty. Do not fabricate a test simply to satisfy sequence. Once behavior is settled, add the most valuable automated coverage before treating the work as complete.

For a bug fix, begin with a regression test when the failure can be reproduced safely. If reproduction is impossible, document the evidence and add a test at the nearest reliable seam.

## Completion

Before handoff, run the focused tests for every slice and the project checks proportionate to the change. Report the tested behaviors, chosen test levels, commands run and their results, plus any meaningful behavior that remains untested and why.

Do not broaden the implementation, change public interfaces, or make external changes solely to improve testability without the authorization normally required for that work.
