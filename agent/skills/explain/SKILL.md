---
name: explain
description: Explains code, concepts, and architectures in clear, concise learning material. Use when the user wants to understand how something works, build a mental model, or compare implementation approaches.
---

# Explain

Help the user form a durable mental model before deciding what to build. Prioritize concepts, mechanisms, and reasoning. Treat code as an optional illustration unless the user asks for implementation help.

## Prefer the Smallest Clear Explanation

Make a simple concept feel simple. Start with its plain-language meaning, the problem it solves, and one small example or analogy only when it helps. State the main idea before qualifications.

- Default to a concise explanation. Add detail only when the user's question, stated level, or the concept's real complexity calls for it.
- Use short, direct sentences and familiar words. Replace abstract phrasing with a concrete action or consequence.
- Give one coherent example rather than several variations. Keep code to the smallest piece that makes the idea visible.
- Do not pad an explanation with exhaustive sections, repeated summaries, edge cases, or adjacent patterns that do not change understanding.
- Put caveats, trade-offs, and advanced distinctions after the core explanation, and include only those that affect a likely decision or prevent a meaningful misunderstanding.
- If a term can be understood without formal terminology, use plain language first; introduce the formal name second if useful.

For a quick concept explanation, aim for: **what it is → why it exists → how it works → one memorable takeaway**. Expand into a longer note only when the user requests depth, the concept needs it to be accurate, or the material is intended as a reference.

## Frame the Learning Goal

Before explaining, infer from the request and supplied context:

- what the learner should understand or be able to reason about afterward;
- their likely starting knowledge and the prerequisites that need bridging;
- whether they want a quick orientation, a deep learning note, implementation guidance, or a code walkthrough; and
- whether the deliverable is a conversational answer, one note, or a connected set of notes.

Inspect relevant supplied files and nearby project conventions before giving repository-specific guidance. Do not search for a destination or modify files unless the user asks for documentation or implementation.

### Resolve consequential ambiguity

Proceed with an explicit, reversible default when minor uncertainty will not materially change the explanation. If the topic, audience, intended outcome, decision criteria, depth, or deliverable has multiple plausible interpretations that would produce meaningfully different material, use a focused decision path before drafting. When the user asks which alternative to choose and the answer depends on unstated constraints, resolve those constraints through the same path rather than choosing generically.

Use this sequence:

1. State the learning outcome being explored and what is already clear from the request.
2. Identify the next unresolved decision that blocks the explanation. Inspect available context instead of asking the user for facts already present.
3. Ask exactly one concrete question at a time. Recommend an answer with a brief reason while preserving the user's choice.
4. Track answered decisions compactly and work depth-first through dependencies. Do not open branches that will not affect the material.
5. Start drafting once the learning outcome, audience, scope, and output shape are clear enough; leave reversible details to reasonable defaults.

For several independent, low-risk details, propose a concise set of defaults and ask for confirmation instead of conducting a long interview. Do not interrogate the user when the request is already clear.

## Choose the Note Architecture

When the user asks for persistent learning material, first map the core question, prerequisites, major subtopics, and dependencies. Then decide whether the subject is best served by one note or a small note set. Optimize for conceptual boundaries and future retrieval, not a fixed word count.

Keep one note when the material supports one learning objective, shares the same prerequisites and mental model, and can be understood in a coherent sequence.

Split into an overview and focused notes when one signal is decisive or several reinforce one another:

- distinct subtopics have their own learning objectives or mental models;
- later sections require substantially different prerequisites;
- layers or alternatives are useful independently and likely to be revisited separately;
- a section needs its own substantial worked example, trade-offs, or failure modes;
- combining the material would force the note to alternate repeatedly between abstraction levels; or
- the proposed note is becoming an index, tutorial, and reference at the same time.

Do not split merely because a note is long. Do not fragment a tightly coupled explanation into pages that require constant navigation.

If the choice would materially affect the user's vault structure and neither option is clearly better, resolve it through the focused decision path. Otherwise choose the clearer structure and state it briefly. For a note set:

- give the overview a map of the topic, suggested reading order, and links to every child note;
- give each child note one clear learning objective and enough context to stand on its own;
- keep cross-note duplication to the minimum needed for comprehension; and
- use verified final paths so the set contains no invented links or orphan notes.

## Build the Explanation

Adapt the structure to the topic rather than forcing every heading. Use only the parts that earn their place. For deeper material, preserve this learning progression where useful:

1. **Purpose and relevance**: establish the problem the concept solves and when it matters.
2. **Prerequisite bridge**: define necessary terms and connect new ideas to what the learner likely knows.
3. **Core mental model**: present the smallest accurate model that explains the whole topic.
4. **Mechanics**: develop the process, relationships, or data flow step by step, making causal links explicit.
5. **Concrete application**: use one coherent worked example, diagram, trace, or small code sample when it reduces abstraction.
6. **Boundaries**: cover trade-offs, alternatives, limitations, common misconceptions, and failure modes that change how the concept should be used.
7. **Consolidation**: summarize the few ideas worth retaining and, for substantial material, add a short self-check or next practice when it improves learning.

Sequence definitions before dependent ideas. Prefer one example carried through the explanation over several disconnected examples. Explain why each important step follows from the previous one; do not merely list facts. Use an analogy only when it improves the model, and state where the analogy stops matching reality.

## Evidence and Examples

- Honor an explicit language request and use the language established by supplied code or repository context. Otherwise write prose in English. When a code example is genuinely needed and no code language is established, default to concise, idiomatic Java. Use pseudocode instead only when language-neutral notation makes the concept materially clearer than concrete code.
- Keep examples minimal, correct, and idiomatic. Explain the idea demonstrated by the code rather than turning a conceptual answer into a style guide.
- Verify primary documentation for version-sensitive APIs, security guidance, framework advice, disputed claims, or current recommendations. Prefer specifications, official documentation, and papers.
- Ensure the prose stands on its own before the learner reads the example. A conceptual explanation does not require code solely because this skill is active.

## Vault Notes

- Write every created or materially updated vault note in English. Keep code identifiers, quotations, and established proper names unchanged where appropriate.
- Start each substantial note with a concise table of contents placed after any frontmatter, title, and brief introductory summary. Link its meaningful section headings with Obsidian-native links such as `[[#Core mental model|Core mental model]]`; mirror heading hierarchy with nested bullets, keep link targets exact and unique, and omit trivial or overly granular subsections. For ordinary Markdown outside an Obsidian vault, use standard heading links instead.
- Inspect only the nearest relevant notes: the target folder, its parent or index note when present, and a small number of direct topic matches. Stop once enough verified links are found; do not read the vault broadly.
- Add only useful, verified vault-relative links in the form `[[<note_path>]]` or `[[<note_path>|Display Text]]`. Use paths without `.md` unless the vault convention includes extensions. Do not invent targets or link unrelated notes.
- Use normal HTTPS Markdown links for external sources. Never put `file:///` URLs or absolute filesystem paths in a note.
- When another requested workflow creates quizzes or worksheets, add or coordinate links only after their final vault-relative paths are known.
- Write or update documentation only with explicit user authorization.
