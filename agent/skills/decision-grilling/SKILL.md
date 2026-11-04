---
name: decision-grilling
description: Stress-test a plan, design, or decision through a focused, evidence-led interview. Use when ambiguity, dependencies, risks, or irreversible choices need resolving before commitment; do not use for a clear, routine task with explicit acceptance criteria.
---

# Decision Grilling

Turn an underspecified plan into a set of explicit, testable decisions before implementation or approval.

## Operating Model

1. State the outcome being explored and the decisions already settled. Inspect the supplied context and relevant local materials before asking about facts they can answer.
2. Identify the decision frontier: unresolved decisions whose prerequisites are settled. Prioritize decisions that are irreversible, high-impact, security- or data-sensitive, or block multiple later choices.
3. Ask exactly one question at a time. Keep it concrete and answerable. Include a recommended answer and a brief reason, but preserve the user's authority to choose differently.
4. After each answer, record the result in a compact decision ledger: **decision**, **chosen direction**, **reason**, and any **open dependency**. Revisit a decision only when new evidence genuinely changes it.
5. Work depth-first through dependent decisions. Do not open speculative branches that neither affect the outcome nor change the next decision.

## Question Quality

Ask about assumptions, constraints, ownership, invariants, failure modes, rollout and rollback, observability, and acceptance criteria when they materially affect the design. Prefer decisions that can be falsified or validated over preferences phrased as abstractions.

If a question has a safe default, say so. If its answer depends on repository evidence, inspect the relevant files first and present what you found rather than asking the user to recall it. Do not use the user as a substitute for available evidence.

## Pace and Scope

Use one-question turns for consequential decisions. For independent, low-risk details, offer a concise proposed default set and ask for confirmation rather than turning each into a separate interview.

Do not begin implementation, write files, contact external systems, or expand the task merely because a design decision has been made. Obtain the authorization normally required for those actions.

## Completion

End the session when the outcome, constraints, key decisions, and validation path are clear; remaining uncertainty is reversible, low-impact, or cheaply testable; and no unresolved decision blocks the next authorized step.

Finish with:

- a decision ledger;
- the principal risks and their mitigations;
- explicit assumptions or deferred questions; and
- the smallest sensible next step.

If the user asks to stop, summarize the ledger immediately and clearly identify which decisions remain open.
