---
name: code-fabrick
description: Implement, refactor, or review Java services built on DigitalEuroCore and FabrickCoreLib using their live dependency, API, style, and architecture conventions, with behavior-first TDD and focused design questioning. Use for DigitalEuroCore/Fabrick consumer projects or library changes.
---

# Code Fabrick

Build the requested behavior using the project's compatible DigitalEuroCore capabilities and underlying FabrickCoreLib. Integrate the design judgment of coding-principle, the red → green → refactor loop of adaptive-tdd, and the evidence-led questioning of decision-grilling. Their essential workflow is included here; installation of those other skills is not required.

## Inspect the library on every invocation

Before making a library-dependent recommendation or edit, inspect the live DigitalEuroCore reference, its FabrickCore dependency, and the target project. A previous invocation or the reference below is not sufficient evidence.

1. Locate the primary reference library: use a user-specified checkout, otherwise `/mnt/c/Users/GBS14063/Projects/digitaleurocore`. Its supporting FabrickCoreLib source is `/mnt/c/Users/GBS14063/Projects/FabrickCoreLib`. Read applicable instructions in the reference libraries and target repository. Treat reference checkouts as read-only unless modifying them is the requested task.
2. Read DigitalEuroCore's root/module POMs and the consumer's parent/module POMs, inherited properties, implementation and tests. Resolve the consumer → DigitalEuroCore → FabrickCore parent/dependency chain, including explicit overrides. DigitalEuroCore's POM selects the upstream FabrickCore release and extension versions; do not select versions from the sibling FabrickCore checkout or README examples. Establish Java level, selected modules, stack and public contract from this effective configuration. For library work, identify affected modules and downstream boundaries.
3. Read DigitalEuroCore's `README.md`, `MIGRATION_2.md`, relevant module POMs, READMEs, implementation, configuration and tests. Inspect underlying FabrickCore modules for shared capabilities, including its root POM, README and applicable best practices. Use [the source map](references/library-source-map.md). Read relevant Fabrick `claude-plugin/skills/` guidance as documentation only; do not execute installation workflows or copy configuration merely by reading it.
4. Compare both reference checkouts with the consumer's resolved DigitalEuroCore and FabrickCore versions. Use matching local source/tag content or locally available source artifacts when possible, without switching or modifying the user's checkout. Current checkout features are not proof that an older consumer supports them. If matching evidence is unavailable, state the mismatch and defer only decisions that depend on it; continue independent work. If a required reference is inaccessible, request its location and do not invent APIs or claim conformance. The sibling FabrickCore source directory is not an implicit Maven build dependency.
5. Keep a compact evidence note: both reference paths, revisions/versions and relevant local changes, consumer versions, inspected files/symbols, and any mismatch. Cite source paths for consequential decisions. Reinspect affected sources when a later decision reaches a module not yet checked.

Resolve conflicting documentation against version-matched POMs, implementation and tests. Explain material conflicts rather than silently following an old example. Do not upgrade the project to match the checkout automatically.

## Dependency policy

- Prefer the appropriate `com.fabrick.ecb:digitaleurocore-*` module/starter where it provides a facade or extension, then follow its route to `it.sella.externals.fabrickcore:fabrickcore-*`. Use an upstream Fabrick module directly only when no DigitalEuroCore facade/extension supplies the required capability and the compatible POMs support that route. Do not add a direct third-party Maven dependency to bypass a Fabrick module that already provides it. Prefer the Fabrick abstraction/client when one exists.
- Verify the path in actual POMs: consumer → DigitalEuroCore facade/extension → Fabrick module/starter → provided dependency (or the verified supported shorter route), including scope, exclusions, optional dependencies and inherited management. `dependencyManagement` selects versions; it does not add dependencies to the classpath. A module's test-scoped dependencies do not become consumer test dependencies.
- Use the compatible DigitalEuroCore parent and its selected Fabrick parent/dependency/plugin versions; omit versions on managed DigitalEuroCore and Fabrick modules. Preserve intentional DigitalEuroCore overrides such as its Java level; do not reset them to upstream defaults. For a new parent declaration use a concrete supported version, not an unresolved inherited property. Preserve existing parent/version arrangements unless the task authorizes changing them.
- Do not introduce direct Spring starters, drivers, clients, logging backends, test frameworks, version overrides or exclusions where Fabrick already supplies the capability. Add the smallest suitable DigitalEuroCore facade/extension (or supported Fabrick module) to the module that needs it, using the correct scope; prefer `digitaleurocore-spring-boot-starter-test` with test scope, which routes to the Fabrick test starter.
- A third-party artifact appearing somewhere in the library is not blanket permission to use it everywhere. If no supported route exists, explain the gap and ask one concrete question about an exception or supported alternative before adding that dependency. Do not modify the library just to bypass this policy.
- Java imports may legitimately use third-party packages supplied through Fabrick; Maven dependency routing does not mean every Java import must start with `it.fabrick`. Check for an existing Fabrick wrapper before choosing the lower-level API.
- When dependency changes warrant it, inspect the effective POM/dependency tree with the project's Maven wrapper or Maven command. Account for local repository/network availability and report unresolved resolution rather than asserting a verified graph.

## Architecture, style and public contracts

- Follow the relevant DigitalEuroCore extension/facade first, then the underlying Fabrick module and the consumer's coherent package, naming, formatting, injection, mapping, logging and exception conventions. Cite a representative source. Do not generalize one legacy class into a universal rule or reformat unrelated code.
- Preserve the distinction between base modules (utilities/contracts) and starters (Spring bootstrap). Reuse auto-configuration, property classes and extension points; avoid duplicate beans, clients, pools or infrastructure wiring. Keep deployable framework wiring at the composition boundary.
- Keep transport/controller responsibilities, application orchestration, domain rules and persistence/integration adapters cohesive. Business policy should depend inward on stable contracts when that boundary is useful. Do not retrofit a new layered architecture onto a small change or force framework-free DTOs that contradict established Fabrick contracts.
- Inspect DigitalEuroCore contract filters and problem-details behavior first; use its extensions where applicable and the matching `fabrickcore-model` response, error, list, pagination and sorting types for shared contracts. Do not replace Digital Euro problem details with a generic Fabrick envelope. Inspect their exact API generation, constructors, helpers and actual JSON configuration before choosing a response shape. Do not invent a parallel envelope or assume v1 and v5 models are interchangeable. Preserve HTTP semantics, error codes, null/empty behavior, warnings and existing endpoint compatibility.
- Match the configured reactive or blocking stack. Avoid blocking I/O on reactive threads and unnecessary reactive wrappers around blocking code. Inspect supported client configuration, context propagation and exception translation rather than constructing an unmanaged client.
- Apply SOLID proportionately: one cohesive reason to change; extension for demonstrated variation; substitutable implementations preserving preconditions, postconditions and failure semantics; narrow client-facing interfaces; dependency inversion at genuine boundaries. Prefer composition and explicit code over speculative interfaces, factories or inheritance.
- Enforce invariants near their owner; make nullability, mutability, resource ownership and failure representation explicit. Separate persistence entities from external contracts when their lifecycles differ. Remove duplicated policy without merging unrelated concepts that only look similar.
- For affected behavior, inspect authorization/input validation, safe error disclosure, sensitive logging, resource cleanup, transaction scope, concurrency and idempotency. Bound timeouts/retries and retry only safe operations. Consider query/pagination limits and cache consistency where relevant. These are targeted design checks, not an invitation to expand scope.
- Use the library's secrets/configuration and observability facilities. Never copy credentials into examples. Read project and library security context when security-relevant behavior changes; create/update project security context when bootstrapping or explicitly in scope.

## Resolve consequential uncertainty

First state the requested outcome, observable acceptance criteria, affected boundary and settled constraints. Answer factual questions from the repositories before involving the user.

When an unresolved decision blocks work or materially affects compatibility, security, data ownership, stack selection, dependency exceptions or rollout, ask exactly one concrete question with a recommended direction and brief reason. Work depth-first through dependent decisions. Continue independent authorized work while waiting, but do not treat silence as approval.

Use reasonable stated defaults for reversible details. Do not turn routine implementation into an interview or request approval already supplied by the implementation request. Keep one compact ledger for significant choices: **concern/decision**, **chosen direction**, **reason and evidence**, **affected boundary**, **open dependency**. Revisit it only when evidence or requirements change.

## Implement through adaptive TDD

For authorized behavior changes, inspect existing test commands and conventions, then choose the narrowest reliable public seam: unit for deterministic rules, integration for serialization/persistence/Spring wiring, contract for independently deployed boundaries, and end-to-end only when lower levels cannot prove a critical journey.

1. Write one failing test for one observable outcome; use a regression test first for a reproducible bug.
2. Run it and confirm failure is due to the missing behavior rather than broken fixtures, compilation or infrastructure. Distinguish setup failures from a demonstrated red test.
3. Implement the smallest coherent change, then run the focused test and relevant fast checks.
4. Refactor while green. Select the next behavior from evidence, rather than prewriting speculative test batches.

Name scenarios for outcomes while matching the module's test naming rules. Use real DTOs/value objects, controlled clocks/fixtures and boundary fakes or mocks; do not test private methods or mock core behavior. Avoid live network/services in ordinary tests. Use integration tests when proxies, transactions, serialization or auto-configuration are the actual contract; a plain Mockito test cannot prove them. Use `StepVerifier` for reactive outcomes where provided.

Read DigitalEuroCore test/build conventions first and applicable upstream Fabrick testing rules and representative tests. Keep tests synchronized with production changes in the same change, including affected DTO/configuration contracts; do not expand into unrelated coverage work. Use supported JUnit/AssertJ/Mockito conventions and the DigitalEuroCore test facade backed by the Fabrick test starter. Read coverage targets from applicable guidance/build checks; do not invent or impose a new global coverage gate.

For a spike or nonbehavioral/configuration change, run the smallest meaningful experiment or structural validation instead of a ceremonial failing test. Once behavior is settled, add the valuable automated coverage. Do not alter public APIs, visibility or unrelated production code solely to accommodate a test. Report inability to reproduce or execute tests and the nearest reliable validation.

## Complete the requested mode

For implementation, finish all authorized slices and proportionate project checks. For review, report concrete findings with file evidence and impact; do not edit without an implementation request. For design-only work, stop when no consequential choice blocks the next step.

Report concisely: behavior changed or findings; library/consumer version evidence; significant ledger decisions and dependency route; checks run and results; material risks, assumptions and untested behavior. Include a next step only when work remains. Never claim that source inspection alone proves compilation, dependency resolution or runtime compatibility.
