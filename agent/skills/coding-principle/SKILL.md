---
name: coding-principle
description: Guide or review implementation and refactoring decisions using SOLID, Clean Architecture, and appropriate design patterns. Use when code structure, responsibilities, dependencies, or extensibility are unclear; do not use to impose patterns on a small, straightforward change.
---

# Coding Principle

Turn an implementation request or a problematic code area into a small, testable design that has clear responsibilities, inward-facing dependencies, and only the abstractions the problem needs.

## Operating Model

1. State the requested behavior, the relevant code boundary, and the constraints already known. Inspect the repository and existing conventions before proposing abstractions or asking questions that the code can answer.
2. Identify the smallest design pressure that matters now: mixed responsibilities, unstable dependencies, violated invariants, difficult testing, duplicated policy, or a likely variation point. Distinguish a concrete problem from speculative future flexibility.
3. Recommend the smallest viable design change. Prefer explicit, cohesive code and composition over new layers, interfaces, factories, or patterns. Name the principle or pattern only when it clarifies a concrete trade-off.
4. For consequential design choices, ask exactly one concrete question at a time. Include a recommended direction and brief reason, while preserving the user's authority to choose differently.
5. Keep a compact design ledger after each decision: **concern**, **chosen direction**, **reason**, **affected boundary**, and any **open dependency**. Revisit a decision only when repository evidence or a changed requirement warrants it.

## Design Criteria

Evaluate code by the behavior it must preserve and the boundaries it must protect.

- Give each module, type, or function one cohesive reason to change. Separate policy from orchestration, infrastructure, transport, and presentation when their changes are independently motivated.
- Keep business rules independent of frameworks, databases, network clients, and UI details. Depend on stable domain-facing contracts where a boundary is actually needed; wire concrete implementations at the composition root.
- Make invalid states difficult to represent. Put invariants near the data and behavior they govern, make ownership explicit, and avoid leaking mutable or persistence-shaped data across layers.
- Extend behavior through composition or polymorphism only when a real, supported variation exists. Do not introduce interfaces merely to satisfy a slogan, mock an implementation detail, or predict an uncertain future.
- Prefer patterns for a named recurring problem: strategy for interchangeable behavior, adapter for an external boundary, command for an explicit action, repository for persistence access, and factory when construction policy is genuinely complex. Keep the pattern local and remove ceremony that does not improve a required quality attribute.
- Preserve existing public contracts unless a change is explicitly authorized. When refactoring, make small, behavior-preserving slices and use tests or other observable checks to guard them.

## Review Questions

Prioritize questions that expose a concrete cost or risk:

- Which behavior is core policy, and which code merely delivers or stores it?
- What dependency would make this code difficult to test, replace, or understand, and is inversion justified at that boundary?
- Which invariant can fail, where should it be enforced, and how will failure be represented?
- What variation is already required, rather than merely imaginable?
- Does a proposed abstraction reduce coupling or just add indirection?
- What is the smallest validation that proves the behavior and boundary still hold?

Use repository evidence to answer these before involving the user. If a simple direct implementation is clearer and meets the stated constraints, recommend it explicitly.

## Pace and Scope

Do not begin implementation, rewrite unrelated areas, introduce dependencies, or alter public APIs merely because a design direction has been selected. Obtain the authorization normally required for those actions.

For low-risk independent details, offer a concise default set rather than converting each into a separate discussion. Avoid architecture astronautics: the goal is maintainable code for the present requirement, with a credible path for known change.

## Completion

End the session when the relevant responsibilities, dependency direction, invariants, variation points, and validation path are clear; any remaining uncertainty is reversible, low-impact, or cheaply testable; and no unresolved choice blocks the next authorized step.

Finish with:

- a design ledger;
- the recommended structure and dependency direction;
- principal risks and mitigations;
- explicit assumptions or deferred questions; and
- the smallest sensible next step.

If the user asks to stop, summarize the ledger immediately and clearly identify the open decisions.
